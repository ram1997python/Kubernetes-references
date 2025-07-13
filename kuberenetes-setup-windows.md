# 3 Node Cluster

```
# -*- mode: ruby -*-
# vi: set ft=ruby :
 
# Purpose: Three‑node Kubernetes lab (1 master + 2 workers) on VirtualBox
# without external plugins. Each guest gets the host map in /etc/hosts so
# they can talk by hostname. Tested on Vagrant ≥ 2.2.0.
 
require 'socket'
 
hostname   = Socket.gethostname
local_ip   = IPSocket.getaddress(hostname)
puts "This machine has the IP '#{local_ip}' and host name '#{hostname}'"
 
VAGRANTFILE_API_VERSION = '2'
BOX_NAME                = 'generic/centos8'
 
# ── Network layout ───────────────────────────────────────────────────────
NETWORK_BASE  = '192.168.56'
START_OCTET   = 24          # => .24, .25, .26
HOSTS = {
  'master.dev.com'  => "#{NETWORK_BASE}.#{START_OCTET}",
  'worker1.dev.com' => "#{NETWORK_BASE}.#{START_OCTET + 1}",
  'worker2.dev.com' => "#{NETWORK_BASE}.#{START_OCTET + 2}"
}
 
# Helper: write host map into /etc/hosts inside each VM
HOSTS_APPENDER = <<-BASH
  set -e
  (grep -qxF "# ---- added by Vagrant ----" /etc/hosts) || echo "# ---- added by Vagrant ----" >> /etc/hosts
  #{HOSTS.map { |h, ip| "grep -qxF '#{ip} #{h}' /etc/hosts || echo '#{ip} #{h}' >> /etc/hosts" }.join("\n  ")}
BASH
 
# ── Full bootstrap script ───────────────────────────────────────────────
$bootstrap = <<'SCRIPT'
# Install base utilities
yum -y install wget git net-tools bind-utils iptables-services bridge-utils \
               bash-completion kexec-tools sos psacct nfs-utils curl iproute-tc
 
yum clean all && yum repolist -v
yum -y update
 
# Enable root SSH for convenience (lab only)
echo "redhat" | passwd root --stdin
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
 
# ── Install containerd ───────────────────────────────────────────────────
wget -q https://github.com/containerd/containerd/releases/download/v2.0.0/containerd-2.0.0-linux-amd64.tar.gz
mkdir -p /usr/local && tar Cxzvf /usr/local containerd-2.0.0-linux-amd64.tar.gz
mkdir -p /usr/local/lib/systemd/system
wget -q -P /usr/local/lib/systemd/system/ https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
systemctl daemon-reload && systemctl enable --now containerd
 
# ── Install runc ─────────────────────────────────────────────────────────
wget -q https://github.com/opencontainers/runc/releases/download/v1.2.2/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc
 
# ── Install CNI plugins ─────────────────────────────────────────────────
wget -q https://github.com/containernetworking/plugins/releases/download/v1.6.0/cni-plugins-linux-amd64-v1.6.0.tgz
mkdir -p /opt/cni/bin && tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.6.0.tgz
 
# ── Install cri‑tools (crictl) ───────────────────────────────────────────
VERSION="v1.31.1"
wget -q https://github.com/kubernetes-sigs/cri-tools/releases/download/${VERSION}/crictl-${VERSION}-linux-amd64.tar.gz
sudo tar zxvf crictl-${VERSION}-linux-amd64.tar.gz -C /usr/local/bin && rm -f crictl-${VERSION}-linux-amd64.tar.gz
 
cat <<EOF | tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint:   unix:///run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: false
EOF
 
# ── Kernel modules & sysctl ─────────────────────────────────────────────
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
 
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system
 
# ── Disable SELinux & swap (lab only) ───────────────────────────────────
setenforce 0 || true
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/' /etc/fstab
 
# ── Kubernetes repo and packages ─────────────────────────────────────────
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
 
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet
SCRIPT
 
# ── Vagrant configuration ───────────────────────────────────────────────
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Speed‑up box handling if vagrant‑cachier is present
  config.cache.scope = :box if Vagrant.has_plugin?('vagrant-cachier')
 
  config.vm.box = BOX_NAME
  config.vm.provider :virtualbox do |vb|
    vb.memory = 1500
    vb.cpus   = 2
  end
 
  # ── MASTER ────────────────────────────────────────────────────────────
  config.vm.define 'master' do |m|
    m.vm.hostname = 'master.dev.com'
    m.vm.network  :private_network, ip: HOSTS['master.dev.com']
    m.vm.network  'forwarded_port', guest: 8081,  host: 8081
    m.vm.network  'forwarded_port', guest: 30881, host: 30881
 
    # Bootstrap + hostname map
    m.vm.provision 'shell', inline: $bootstrap, privileged: true
    m.vm.provision 'shell', inline: HOSTS_APPENDER, privileged: true
  end
 
  # ── WORKER 1 ───────────────────────────────────────────────────────────
  config.vm.define 'worker1' do |w1|
    w1.vm.hostname = 'worker1.dev.com'
    w1.vm.network  :private_network, ip: HOSTS['worker1.dev.com']
 
    w1.vm.provision 'shell', inline: $bootstrap, privileged: true
    w1.vm.provision 'shell', inline: HOSTS_APPENDER, privileged: true
  end
 
  # ── WORKER 2 ───────────────────────────────────────────────────────────
  config.vm.define 'worker2' do |w2|
    w2.vm.hostname = 'worker2.dev.com'
    w2.vm.network  :private_network, ip: HOSTS['worker2.dev.com']
 
    w2.vm.provision 'shell', inline: $bootstrap, privileged: true
    w2.vm.provision 'shell', inline: HOSTS_APPENDER, privileged: true
  end
end

```
