### ✅ Goal

Upgrade all your Kubernetes nodes to version `v1.32.9`.

---

## ✅ Step-by-Step: Upgrade Kubernetes Cluster to v1.32.9

---

### 🔹 **Step 1: Pre-check (on all nodes)**

Run this on **each node (`node2`, `node3`)**:

```bash
cat /etc/redhat-release
kubectl get nodes -o wide
```

Make sure nodes are accessible and using CentOS.

---

### 🔹 **Step 2: Configure the Kubernetes repository (v1.32)**

Run on **each node**:

```bash
sudo rm -f /etc/yum.repos.d/kubernetes.repo

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl
EOF
```

---

### 🔹 **Step 3: Clean and update package cache**

```bash
sudo yum clean all
sudo yum makecache
```

```bash

yum list kubeadm --showduplicates --disableexcludes=kubernetes

```

---

### 🔹 **Step 4: Install Kubernetes components (on node2 & node3)**

```bash
sudo yum install -y kubeadm-1.32.9-0 --disableexcludes=kubernetes
sudo yum install -y kubelet-1.32.9-0 kubectl-1.32.9-0 --disableexcludes=kubernetes
```

---

### 🔹 **Step 5: Restart the kubelet**

```bash
sudo systemctl daemon-reexec
sudo systemctl restart kubelet
```

---

### 🔹 **Step 6: Upgrade node using kubeadm**

This upgrades the node itself (worker nodes don’t control the cluster state, so this is safe):

```bash
sudo kubeadm upgrade node
```

---

### 🔹 **Step 7: Verify**

```bash
kubectl get nodes
```

You should now see all nodes at `v1.32.9` and in `Ready` state.

---

## 🧼 Optional: Clean Up and Check Versions

On each node:

```bash
kubeadm version
kubelet --version
kubectl version --client
```

---

## ✅ Summary

| Node    | Role          | Version Before       | Version After |
| ------- | ------------- | -------------------- | ------------- |
| `node1` | control-plane | v1.31.13 → ✅ v1.32.9 | ✅             |
| `node2` | worker        | v1.30.14             | ✅ v1.32.9     |
| `node3` | worker        | v1.30.14             | ✅ v1.32.9     |

---

Would you like a script to automate this on all nodes?
