You're inside a pod (`test-16868`) and trying to access another service (`web.svc.cluster.local`), but you’re getting:

```
wget: bad address 'web.svc.cluster.local'
```

This means **DNS is not working** inside your pod — it **can't resolve service names** like `web.svc.cluster.local`.

---

## 🔍 Breakdown of `/etc/resolv.conf` in Pod

```
nameserver 10.96.0.10
```

This means the pod is configured to use the **CoreDNS service** running at `10.96.0.10` to resolve internal DNS names (like `*.svc.cluster.local`).

---

## ✅ Checklist to Fix Kubernetes DNS

### 1. **Check if CoreDNS is Running**

Run on the master:

```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

You should see something like:

```
coredns-xxxxxx   Running
```

If it’s **CrashLoopBackOff** or not running, check logs:

```bash
kubectl logs -n kube-system -l k8s-app=kube-dns
```

---

### 2. **Check kube-dns Service**

```bash
kubectl get svc -n kube-system
```

You should see:

```
kube-dns   ClusterIP   10.96.0.10   53/UDP,53/TCP,9153/TCP
```

If this service is missing, DNS won’t work.

---

### 3. **Check `kubelet` Has `--cluster-dns` Set Correctly**

Run on each node (especially the one running the pod):

```bash
ps aux | grep kubelet | grep cluster-dns
```

Expected flag:

```
--cluster-dns=10.96.0.10
```

If not set, check `/var/lib/kubelet/config.yaml` and make sure you have:

```yaml
clusterDNS:
  - 10.96.0.10
```

If you add/change it, restart kubelet:

```bash
sudo systemctl restart kubelet
```

---

### 4. **Check NetworkPolicy (if using)**

If you have **NetworkPolicies** applied, make sure they’re not blocking DNS to `10.96.0.10`.

---

### 5. **Check DNS from Another Pod**

Create a test pod and use `nslookup` or `dig`:

```bash
kubectl run -it --rm dns-test --image=busybox:1.28 --restart=Never -- sh
```

Then inside:

```sh
nslookup web
nslookup kube-dns.kube-system.svc.cluster.local
```

---

## ✅ Summary Fix Plan

| Check                                     | Command                                               |
| ----------------------------------------- | ----------------------------------------------------- |
| Is CoreDNS running?                       | `kubectl get pods -n kube-system -l k8s-app=kube-dns` |
| Is kube-dns service present?              | `kubectl get svc -n kube-system`                      |
| Is kubelet using correct DNS IP?          | Check for `--cluster-dns=10.96.0.10`                  |
| Does pod have correct `/etc/resolv.conf`? | ✅ It does                                             |
| Can other pods resolve DNS?               | Use `kubectl run` and test `nslookup`                 |

---

Let me know:

* Output of `kubectl get pods -n kube-system`
* Output of `kubectl get svc -n kube-system`
* Logs from `coredns` pods if they exist

I can help troubleshoot from there.

------

Thanks — this confirms the **CoreDNS pod is failing DNS resolution itself**, with repeated errors like:

```
HINFO: read udp 10.244.0.X:XXXXX -> 10.0.2.3:53: read: no route to host
```

---

## 🔍 What This Means

* CoreDNS is **trying to resolve external names (like `google.com`)** via your host’s upstream DNS (in this case `10.0.2.3`)
* But there’s **no route to `10.0.2.3`** from inside the pod network (`10.244.0.0/16`), likely because of a **bad NAT setup or missing default route**.

---

## 🛠️ Fix Options

You’re using **Vagrant + VirtualBox**, so this is likely caused by a mismatch between your **VM networking** and the **Flannel overlay**.

---

## ✅ Fix Option 1: Use Public DNS Upstream in CoreDNS

Edit the CoreDNS ConfigMap to **replace `10.0.2.3` with Google DNS (8.8.8.8)** or Cloudflare (1.1.1.1):

### 1. Edit ConfigMap:

```bash
kubectl edit configmap coredns -n kube-system
```

Look for a block like:

```txt
forward . /etc/resolv.conf
```

🔁 Replace it with:

```txt
forward . 8.8.8.8 1.1.1.1
```

Final block might look like:

```txt
.:53 {
    errors
    health
    ready
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
    }
    prometheus :9153
    forward . 8.8.8.8 1.1.1.1
    cache 30
    loop
    reload
    loadbalance
}
```

Save and exit.

---

### 2. Restart CoreDNS

```bash
kubectl rollout restart deployment coredns -n kube-system
```

---

### 3. Test Again

Inside any pod:

```bash
nslookup web
wget -qO- http://web
```

---

