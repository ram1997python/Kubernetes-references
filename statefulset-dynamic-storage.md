
# 📘 Step-by-Step: Dynamic Storage with OpenEBS + StatefulSet

This guide includes:

* Installing OpenEBS
* Creating a custom StorageClass
* Deploying a StatefulSet with dynamic PVCs
* Verifying persistent volume behavior
* Clean YAML examples

---

## 🛠️ STEP 1: Prerequisites

* A working Kubernetes cluster (e.g., via `kubeadm` on Vagrant VMs)
* `kubectl` configured on the control plane
* Internet access from nodes (to pull OpenEBS images)
* Enough disk space and RAM on each node (2 GB RAM per node minimum)

---

## 🔥 STEP 2: Install OpenEBS Operator

Install OpenEBS with one command:

```bash
kubectl apply -f https://openebs.github.io/charts/openebs-operator.yaml
```

✅ Verify that the pods are running:

```bash
kubectl get pods -n openebs
```

You should see:

```
openebs-localpv-provisioner-xxx   Running
openebs-ndm-xxx                   Running
...
```

---

## 📂 STEP 3: Create a Custom StorageClass (Optional but Recommended)

By default, OpenEBS stores volumes under `/var/openebs/local`. You can change this with a **custom StorageClass**.

### 📄 `openebs-hostpath-custom.yaml`

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: openebs-hostpath-custom
provisioner: openebs.io/local
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
parameters:
  storageType: hostPath
  basePath: /mnt/openebs-data
```

🛠️ Apply it:

```bash
kubectl apply -f openebs-hostpath-custom.yaml
```

📁 Then create the path on each node:

```bash
sudo mkdir -p /mnt/openebs-data
sudo chmod 777 /mnt/openebs-data
```

---

## 🌐 STEP 4: Deploy the Headless Service and StatefulSet

### 📄 `nginx-openebs.yaml`

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
---
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
        storageClassName: openebs-hostpath-custom
        resources:
          requests:
            storage: 1Gi
```

📦 Apply it:

```bash
kubectl apply -f nginx-openebs.yaml
```

---

## ✅ STEP 5: Verify

### Check Pod, PVC, and PV status:

```bash
kubectl get pods -l app=nginx
kubectl get pvc
kubectl get pv
```

You should see:

* `web-0` → **Running**
* `www-web-0` PVC → **Bound**
* `pvc-xxxx` PV → **Bound**

📁 On your node, the data will be stored under:

```bash
ls /mnt/openebs-data/
```

---

## 🧪 STEP 6: Test Persistent Volume

### Step 1: Write test data to volume

```bash
kubectl exec -it web-0 -- /bin/bash
echo "Hello from OpenEBS" > /usr/share/nginx/html/test.html
exit
```

### Step 2: Restart pod

```bash
kubectl delete pod web-0
```

Wait until it restarts:

```bash
kubectl get pods -l app=nginx
```

### Step 3: Read the data again

```bash
kubectl exec -it web-0 -- cat /usr/share/nginx/html/test.html
```

✅ Output:

```
Hello from OpenEBS
```

---

## 🧼 STEP 7: Clean Up (if needed)

```bash
kubectl delete -f nginx-openebs.yaml
kubectl delete -f openebs-hostpath-custom.yaml
```

---

## 🔍 Additional Notes

| Feature              | Description                               |
| -------------------- | ----------------------------------------- |
| StorageClass         | `openebs-hostpath-custom`                 |
| Volume path          | `/mnt/openebs-data/pvc-xxxx...`           |
| Dynamic provisioning | Handled by `openebs.io/local` provisioner |
| Retention policy     | Set to `Delete`, will remove PVs with PVC |

---


