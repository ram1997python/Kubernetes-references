#!/bin/bash
# Master Node Setup
sudo hostnamectl set-hostname worker1
echo "10.0.1.10 lb.kube.com lb" | sudo tee -a /etc/hosts > /dev/null
echo "10.0.1.11 master1.kube.com master1" | sudo tee -a /etc/hosts > /dev/null
echo "10.0.1.12 master2.kube.com master2" | sudo tee -a /etc/hosts > /dev/null
echo "10.0.1.13 worker1.kube.com worker1" | sudo tee -a /etc/hosts > /dev/null
echo "10.0.1.14 worker2.kube.com worker2" | sudo tee -a /etc/hosts > /dev/null

# Update and install required packages
sudo yum clean all ; sudo yum repolist
sudo yum -y update
sudo yum -y install epel-release
sudo yum -y update
sudo yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct nfs-utils curl iproute-tc sshpass chpasswd
sudo yum -y install python3-pip
pip3 install --user ansible

#Install Containerd
wget https://github.com/containerd/containerd/releases/download/v2.0.0/containerd-2.0.0-linux-amd64.tar.gz
tar Cxzvf /usr/local/ containerd-2.0.0-linux-amd64.tar.gz
mkdir -p /usr/local/lib/systemd/system
wget -P /usr/local/lib/systemd/system/ https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

systemctl daemon-reload
systemctl enable --now containerd

#install runc

wget https://github.com/opencontainers/runc/releases/download/v1.2.2/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc
#cni plugin

wget https://github.com/containernetworking/plugins/releases/download/v1.6.0/cni-plugins-linux-amd64-v1.6.0.tgz

mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin/ cni-plugins-linux-amd64-v1.6.0.tgz

#install crictl command
VERSION="v1.31.1"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

cat <<CRICTL | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: false
CRICTL

cat <<K8S | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
K8S

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<K8SSYS | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
K8SSYS

# Apply sysctl params without reboot
sysctl --system

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

modprobe br_netfilter
sysctl -p /etc/sysctl.conf

lsmod | grep br_netfilter
lsmod | grep overlay

mkdir -p /etc/apt/keyrings/
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key |  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg


cat <<KUBER | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
KUBER

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

echo 1 > /proc/sys/net/ipv4/ip_forward
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


sudo usermod -aG wheel azureuser
sudo echo "root:redhat" | sudo chpasswd
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
PASSWORD="P@ssw0rd123"

# Generate SSH key for azureuser user
#sudo -u azureuser bash -c 'ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N "" -q <<<y'
sudo -u azureuser ls -l /home/azureuser/.ssh/
echo "azureuser ALL=(ALL) NOPASSWD:ALL" |  sudo tee /etc/sudoers.d/90-cloud-init-users-azureuser
echo "jenkins ALL=(azureuser) NOPASSWD: /bin/cp"  |  sudo tee /etc/sudoers.d/90-cloud-init-users-azureuser
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Kubelet API
sudo firewall-cmd --permanent --add-port=10250/tcp

# NodePort Services Range (if using NodePort services)
sudo firewall-cmd --permanent --add-port=30000-32767/tcp

# Allow connection from control plane (API server)
sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='10.0.1.11' accept"

sudo firewall-cmd --reload
