#!/bin/bash
# Master Node Setup
sudo hostnamectl set-hostname lb.kube.com
echo "10.0.1.10 lb.kube.com lb" | sudo tee -a /etc/hosts > /dev/null
echo "10.0.1.11 master1.kube.com master1" | sudo tee -a /etc/hosts > /dev/null
echo "10.0.1.12 master2.kube.com master2" | sudo tee -a /etc/hosts > /dev/null
echo "10.0.1.13 worker1.kube.com worker1" | sudo tee -a /etc/hosts > /dev/null
echo "10.0.1.14 worker2.kube.com worker2" | sudo tee -a /etc/hosts > /dev/null
# Update system and install basic tools
sudo yum install -y wget git net-tools bind-utils iptables-services bridge-utils bash-completion sos psacct nfs-utils curl iproute tc

wget ftp://ftp.icm.edu.pl/vol/rzm7/linux-centos-vault/8.1.1911/cloud/x86_64/openstack-train/Packages/s/sshpass-1.06-8.el8.x86_64.rpm
sudo rpm -ivh sshpass-1.06-8.el8.x86_64.rpm

sudo yum install -y gpg

sudo -u azureuser bash -c 'ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N "" -q <<<y'
sudo -u azureuser ls -l /home/azureuser/.ssh/
echo "azureuser ALL=(ALL) NOPASSWD:ALL" |  sudo tee /etc/sudoers.d/90-cloud-init-users-azureuser
echo "jenkins ALL=(azureuser) NOPASSWD: /bin/cp"  |  sudo tee /etc/sudoers.d/90-cloud-init-users-azureuser

# Install HAproxy
sudo yum update -y
sudo yum install -y haproxy
sudo systemctl enable haproxy
sudo systemctl start haproxy

# Set SELinux boolean for HAProxy

setsebool -P haproxy_connect_any=1

# Configure HAProxy
cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg
global
    log /dev/log    local0
    log /dev/log    local1 notice
    daemon
    maxconn 2048

defaults
    log     global
    mode    tcp
    option  tcplog
    timeout connect 10s
    timeout client  1m
    timeout server  1m

frontend kubernetes-api
    bind 10.0.1.10:6443
    default_backend kubernetes-masters

backend kubernetes-masters
    balance roundrobin
    option tcp-check
    default-server inter 3s fall 3 rise 2

    server master1 10.0.1.11:6443 check
    server master2 10.0.1.12:6443 check
EOF

sudo systemctl restart haproxy
sudo systemctl status haproxy



# # Copy SSH key to worker nodes
for ip in "10.0.1.11"; do
  sudo -u azureuser sshpass -p "Welc0me@123" ssh-copy-id -o StrictHostKeyChecking=no -i /home/azureuser/.ssh/id_rsa.pub azureuser@$ip
done

## allow 6443 Kubernetes API server
sudo firewall-cmd --permanent --add-port=6443/tcp

# Allow communication to all control planes
sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv4' destination address='10.0.1.11' accept"
sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv4' destination address='10.0.1.12' accept"

sudo firewall-cmd --reload

