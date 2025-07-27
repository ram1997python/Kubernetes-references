
# What is HPA in Kubernetes?
HPA (Horizontal Pod Autoscaler) is a Kubernetes feature that automatically adjusts the number of pod replicas in a deployment (or replica set) based on observed resource usage, such as:

  CPU usage (most common)
  
  Memory usage (with custom setup)
  
  Custom application metrics (via external tools)

#  How Does HPA Work?
Metrics Server collects usage metrics (like CPU, memory) from pods and nodes.

HPA checks the current metric values against the target thresholds defined in your configuration.

If the usage is too high, it increases the number of pods (scales out).

If the usage drops, it decreases the number of pods (scales in).

Example:
If you configure HPA to maintain CPU usage at 50%, and your app is running at 90%, HPA will add more pods to distribute the load.

📦 When to Use HPA
✅ Use HPA when:

Your application experiences variable load

You want cost savings by scaling down during idle times

You need high availability under traffic spikes

## 📘 Kubernetes HPA Setup Guide with ApacheBench Load Testing

### ✅ Prerequisites

You’ll need:

* A running **Kubernetes cluster** (Minikube, AKS, EKS, etc.)
* `kubectl` configured
* Cluster nodes have internet access (for pulling images)

---

## 🚀 Step 1: Install Metrics Server (with TLS workaround)

### 1.1 Deploy Metrics Server

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 1.2 Edit the Deployment to fix TLS errors

```bash
kubectl edit deployment metrics-server -n kube-system
```

In the `containers:` section, add the following `args:`:

```yaml
args:
  - --kubelet-insecure-tls
  - --kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP
```

These arguments:

* Skip certificate validation (`--kubelet-insecure-tls`)
* Connect using node IP addresses (`--kubelet-preferred-address-types`)

### 1.3 Verify Metrics Server is working

```bash
kubectl top nodes
kubectl top pods
```

You should see CPU/memory metrics. If not, wait a minute or check pod logs.

---

## 📦 Step 2: Create NGINX Deployment

### 2.1 Create the deployment file

```yaml
# nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
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
        image: nginx
        resources:
          requests:
            cpu: "100m"
          limits:
            cpu: "200m"
        ports:
        - containerPort: 80
```

### 2.2 Apply the deployment

```bash
kubectl apply -f nginx-deployment.yaml
```

---

## 🌐 Step 3: Create a Service for NGINX

```yaml
# nginx-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
```

```bash
kubectl apply -f nginx-service.yaml
```

---

## 📈 Step 4: Configure Horizontal Pod Autoscaler (HPA)

```bash
kubectl autoscale deployment nginx-deployment \
  --cpu-percent=50 \
  --min=2 \
  --max=5
```

Check HPA:

```bash
kubectl get hpa
```

---

## 🔥 Step 5: Generate Load Using ApacheBench (ab)

Use the `jordi/ab` image to send requests:

```bash
kubectl run ab --image=jordi/ab --restart=Never -- \
  -n 100000 -c 50 http://nginx-service.default.svc.cluster.local/
```

> This sends **100,000 requests** with **50 concurrent connections** to your NGINX service.

---

## 📊 Step 6: Monitor HPA Activity

Watch autoscaler metrics:

```bash
kubectl get hpa -w
```

Look for increased CPU usage and pod scaling (replica count going up).

---

## 🧹 Step 7: Clean Up (Optional)

```bash
kubectl delete deployment nginx-deployment
kubectl delete service nginx-service
kubectl delete hpa nginx-deployment
kubectl delete pod ab
```

---

## ✅ Summary

| Component      | Description                                  |
| -------------- | -------------------------------------------- |
| Metrics Server | Collects resource usage metrics              |
| NGINX App      | Sample app to be scaled                      |
| Service        | Exposes NGINX for internal access            |
| HPA            | Automatically scales pods based on CPU       |
| ApacheBench    | Generates HTTP traffic to increase CPU usage |

---


