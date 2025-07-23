

---

# 📝 StatefulSet with One Replica (Manual PV + hostPath)

## 🛠 Prerequisites

* Kubernetes cluster (Vagrant, kubeadm, or Minikube)
* At least one **worker node**
* `kubectl` access from the control plane
* Ensure networking/firewall allows port `10250`

---

## 🔥 Step 0: Allow Kubelet Exec Port in Firewall

To allow `kubectl exec`, `logs`, etc., **port 10250 must be open** on all nodes.

### ✅ Open Port 10250 (firewalld)

```bash
sudo firewall-cmd --add-port=10250/tcp --permanent
sudo firewall-cmd --reload
```

### Or Temporarily Disable Firewall for Testing

```bash
sudo systemctl stop firewalld
```

---

## 📁 Step 1: Prepare HostPath Directory on Node

SSH into your worker node (where pod will run):

```bash
sudo mkdir -p /mnt/data/nginx-0
sudo chmod 777 /mnt/data/nginx-0
```

> This ensures the `hostPath` volume can be mounted by the container.

---

## 📦 Step 2: Create the PersistentVolume (PV)

Save as `nginx-pv-0.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nginx-pv-0
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/mnt/data/nginx-0"
```

Apply:

```bash
kubectl apply -f nginx-pv-0.yaml
```

---

## 🌐 Step 3: Create the Headless Service

Save as `nginx-headless-svc.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  clusterIP: None
  selector:
    app: nginx
  ports:
    - port: 80
      name: web
```

Apply:

```bash
kubectl apply -f nginx-headless-svc.yaml
```

---

## 🚀 Step 4: Create the StatefulSet (1 Replica)

Save as `nginx-statefulset.yaml`:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "web"
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
          volumeMounts:
            - name: www
              mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
    - metadata:
        name: www
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
        volumeName: nginx-pv-0
```

Apply:

```bash
kubectl apply -f nginx-statefulset.yaml
```

---

## 🔍 Step 5: Verify Everything

```bash
kubectl get pv
kubectl get pvc
kubectl get pods -l app=nginx
```

✅ You should see:

* PVC `www-web-0` in `Bound`
* PV `nginx-pv-0` in `Bound`
* Pod `web-0` in `Running`

---

## 🧪 Step 6: Test Data Persistence

### Write data into the volume:

```bash
kubectl exec -it web-0 -- /bin/bash
echo "Hello StatefulSet" > /usr/share/nginx/html/test.html
exit
```

### Check the file:

```bash
kubectl exec -it web-0 -- cat /usr/share/nginx/html/test.html
```

Output:

```
Hello StatefulSet
```

---

### Now Delete the Pod:

```bash
kubectl delete pod web-0
```

Wait for the pod to restart:

```bash
kubectl get pods -l app=nginx
```

Then recheck the file:

```bash
kubectl exec -it web-0 -- cat /usr/share/nginx/html/test.html
```

🎉 **File should still exist** — confirming that persistence is working.

---

## 🧼 Cleanup (Optional)

```bash
kubectl delete -f nginx-statefulset.yaml
kubectl delete -f nginx-headless-svc.yaml
kubectl delete -f nginx-pv-0.yaml
```

To delete host directory:

```bash
sudo rm -rf /mnt/data/nginx-0
```

---

Let me know if you'd like this as a downloadable README.md file or with comments inline in the YAMLs.
