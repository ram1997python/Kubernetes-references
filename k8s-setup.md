# Kubernetes 3‑Node Lab on Vagrant & VirtualBox ( Windows 11 )

This project spins up a **single‑master, two‑worker Kubernetes cluster** on your local machine using **Vagrant** and **VirtualBox**, without any extra Vagrant plugins (no *landrush*, no *hostmanager*). Each VM is provisioned automatically with containerd, runc, CNI plugins, and Kubernetes (`kubelet`, `kubeadm`, `kubectl`).

| Role   | Hostname          | Private IP      | Forwarded Ports                                                   |
| ------ | ----------------- | --------------- | ----------------------------------------------------------------- |
| Master | `master.dev.com`  | `192.168.56.24` | 8081 → 8081 *(Argo CD, etc.)*,<br>30881 → 30881 *(NodePort demo)* |
| Worker | `worker1.dev.com` | `192.168.56.25` | —                                                                 |
| Worker | `worker2.dev.com` | `192.168.56.26` | —                                                                 |

## Prerequisites

| Tool             | Tested Version | Notes                                   |
| ---------------- | -------------- | --------------------------------------- |
| Vagrant          | ≥ 2.2          | [Download](https://www.vagrantup.com/)  |
| VirtualBox       | ≥ 6.1          | [Download](https://www.virtualbox.org/) |
| A 64‑bit host OS |                | Linux, macOS, or Windows                |

> **Tip (WSL 2 users)** – enable nested VT‑x and install the VirtualBox 7+ preview build that supports WSL.

## Quick Start

```bash
# 1. Clone this repo
$ git clone https://github.com/your‑org/k8s‑vagrant‑lab.git
$ cd k8s‑vagrant‑lab

# 2. Bring up the cluster (first run ≈ 10–15 min, depends on bandwidth)
$ vagrant up

# 3. SSH into the master and initialise Kubernetes
$ vagrant ssh master
[vagrant@master ~]$ sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Copy the join token printed at the end ↴
# kubeadm join 192.168.56.24:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>

[vagrant@master ~]$ mkdir -p $HOME/.kube
[vagrant@master ~]$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
[vagrant@master ~]$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 4. (Optional) Install a CNI – e.g. Flannel
[vagrant@master ~]$ kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# 5. Join the workers (run on worker1 & worker2)
$ vagrant ssh worker1   # in a separate terminal
[vagrant@worker1 ~]$ sudo <paste the kubeadm join command here>

$ vagrant ssh worker2
[vagrant@worker2 ~]$ sudo <paste the kubeadm join command here>

# 6. Verify
[vagrant@master ~]$ kubectl get nodes -o wide
```

## What the Provisioner Does

1. Installs system utilities and enables password SSH.
2. Downloads **containerd 2.0.0** and **runc 1.2.2** and sets them up as the CRI.
3. Installs **CNI plugins 1.6.0** into `/opt/cni/bin`.
4. Installs **cri‑tools 1.31.1** (`crictl`).
5. Loads required kernel modules (`overlay`, `br_netfilter`) and sets sysctl flags.
6. Disables SELinux (permissive) and swap (K8s requirement).
7. Adds the official Kubernetes repo and installs **kubelet, kubeadm, kubectl v1.30**.
8. Writes the hostname/IP map for all nodes into `/etc/hosts` so they resolve each other without DNS.

## Tearing Down

```bash
vagrant destroy -f     # removes all VMs
```

## Common Issues & Fixes

| Symptom                                     | Cause                                                  | Fix                                                                                           |
| ------------------------------------------- | ------------------------------------------------------ | --------------------------------------------------------------------------------------------- |
| `Unknown configuration section 'provision'` | Out‑dated Vagrant (< 1.8) or misplaced provision block | Upgrade Vagrant or use this Vagrantfile.                                                      |
| Provision stops at containerd download      | Slow/unstable internet                                 | Re‑run `vagrant provision <vm>` once network stabilises.                                      |
| `cgroup … not enabled` at `kubeadm init`    | Using systemd‑unified cgroup on host                   | Add `systemd.unified_cgroup_hierarchy=0` to grub on the guest, reboot, then re‑run `kubeadm`. |

## Extending the Lab

* **Load balancer**: add a `haproxy` VM or MetalLB.
* **Ingress**: install NGINX‑Ingress or Traefik.
* **CI/CD**: forward port 8081 (already done) and deploy Argo CD.
* **Storage**: attach VirtualBox disks and install an NFS or Longhorn CSI.

## License

MIT – feel free to fork and adapt.





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
    vb.memory = 1800
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

```
sudo kubeadm config images pull
```
```
sudo kubeadm init   --pod-network-cidr=10.244.0.0/16   --apiserver-advertise-address=192.168.56.24   --control-plane-endpoint=master.dev.com

```

## Run the following command.
```
# 1) Make sure firewalld is running (or skip if it’s already active)
sudo systemctl enable --now firewalld

# 2) Open the Kubernetes-API port (6443/TCP)
sudo firewall-cmd --zone=public --add-port=6443/tcp --permanent

# 3a) EITHER open one specific NodePort that Kubernetes chose, e.g. 31573/TCP
sudo firewall-cmd --zone=public --add-port=31573/tcp --permanent

# 3b) …OR open the whole NodePort range (30000-32767/TCP) in one shot
sudo firewall-cmd --zone=public --add-port=30000-32767/tcp --permanent

# 4) Reload the rules so they take effect
sudo firewall-cmd --reload

# 5) (Optional) Verify
firewall-cmd --zone=public --list-ports

```
```
wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml
```
## Stop running swap on all nodes

```
sudo swapoff -a
```

```
kubectl get node

```
