


# 🖥️ Multi-Cluster Kubernetes with HAProxy Load Balancer

This setup provides a **high availability, multi-node Kubernetes cluster** with centralized load balancing via **HAProxy**. The cluster includes control-plane nodes, worker nodes, and a dedicated HAProxy load balancer. This architecture supports scalability, resilience, and low-latency user access across multiple regions or failure zones.

---

## 🌐 Architecture Overview


```
                    +----------------------+
                    |    Clients / Users   |
                    +----------+-----------+
                               |
                     Load Balanced Traffic
                               |
                      +--------▼--------+
                      |  HAProxy (lb)   |
                      |  10.0.1.10       |
                      +--------+--------+
                               |
         +---------------------+---------------------+
         |                                           |
 +-------▼--------+                         +--------▼-------+
 | master1.kube.com|                       | master2.kube.com|
 | 10.0.1.11       |                       | 10.0.1.12       |
 | Control Plane   |                       | Control Plane   |
 +-----------------+                       +-----------------+
         |                                           |
 +-------+--------+                         +--------+-------+
 | worker1.kube.com|                       | worker2.kube.com|
 | 10.0.1.13       |                       | 10.0.1.14       |
 +-----------------+                       +-----------------+
```

````

---

## 🧩 Components

- **HAProxy (lb.kube.com - 10.0.1.10):**
  - Acts as a TCP load balancer for Kubernetes API server (port `6443`)
  - Ensures high availability by forwarding requests to active control planes

- **Control Planes:**
  - `master1.kube.com (10.0.1.11)`
  - `master2.kube.com (10.0.1.12)`
  - Manage cluster state and scheduling

- **Worker Nodes:**
  - `worker1.kube.com (10.0.1.13)`
  - `worker2.kube.com (10.0.1.14)`
  - Run application workloads and pods

---

## 🛠️ Host Configuration

Each server is configured with proper hostname and `/etc/hosts` entries for easy DNS resolution within the cluster.

```bash
sudo hostnamectl set-hostname <hostname>
````

Sample `/etc/hosts` additions on all nodes:

```bash
10.0.1.10 lb.kube.com lb
10.0.1.11 master1.kube.com master1
10.0.1.12 master2.kube.com master2
10.0.1.13 worker1.kube.com worker1
10.0.1.14 worker2.kube.com worker2
```

---

## 🔁 Why Use a Multi-Cluster Setup?

* **High Availability:** If one control plane or node goes down, others take over.
* **Disaster Recovery:** Separate clusters can act as fallbacks in failure scenarios.
* **Geographical Distribution:** Deploy workloads closer to users to reduce latency.
* **Scalability:** Easily add nodes and balance traffic efficiently.

---

## ⚙️ HAProxy Configuration

Example `haproxy.cfg`:

```haproxy
frontend kubernetes-frontend
    bind 10.0.1.10:6443
    mode tcp
    option tcplog
    default_backend kubernetes-backend

backend kubernetes-backend
    mode tcp
    balance roundrobin
    option tcp-check
    server master1 10.0.1.11:6443 check fall 3 rise 2
    server master2 10.0.1.12:6443 check fall 3 rise 2
```

---

## 🚀 Deployment Steps (High-Level)

1. **Set hostnames and /etc/hosts entries** on all nodes.
2. **Install and configure HAProxy** on `lb.kube.com`.
3. **Initialize the first control plane** using `kubeadm init`.
4. **Join additional control planes** using `kubeadm join --control-plane`.
5. **Install a CNI plugin** (e.g., Flannel or Calico).
6. **Join worker nodes** using the token from `kubeadm`.
7. **Verify the cluster status** using `kubectl get nodes`.

---

## ✅ Cluster Validation

```bash
kubectl get nodes
```

Expected output:

```
NAME      STATUS     ROLES           AGE     VERSION
master1   Ready      control-plane   XXm     v1.xx.x
master2   Ready      control-plane   XXm     v1.xx.x
worker1   Ready      <none>          XXm     v1.xx.x
worker2   Ready      <none>          XXm     v1.xx.x
```

---

## 📌 Notes

* Ensure HAProxy can bind to the VIP (`10.0.1.10`).
* Use `Keepalived` if you want to failover the HAProxy VIP between two LB nodes.
* Always verify firewall rules allow traffic between all nodes on necessary ports (e.g., 6443, 2379-2380 for etcd, 10250 for kubelet).

---

## 📚 Resources

* [Kubeadm HA Guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)
* [HAProxy Documentation](https://www.haproxy.org/)
* [Flannel CNI](https://github.com/flannel-io/flannel)

---


Let me know if you want this broken into multiple files (`haproxy.cfg`, `setup.sh`, etc.) or published as a GitHub repo template.
```
