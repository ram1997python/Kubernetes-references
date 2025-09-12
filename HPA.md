
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
cat <<'EOF' > components.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
  name: system:aggregated-metrics-reader
rules:
- apiGroups:
  - metrics.k8s.io
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - nodes/metrics
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  ports:
  - appProtocol: https
    name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    k8s-app: metrics-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      hostNetwork: true
      containers:
      - args:
        - --cert-dir=/tmp
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls
        - --kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP
        - --secure-port=4443
        image: registry.k8s.io/metrics-server/metrics-server:v0.8.0
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /livez
            port: https
            scheme: HTTPS
          periodSeconds: 10
        name: metrics-server
        ports:
        - containerPort: 4443
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: https
            scheme: HTTPS
          initialDelaySeconds: 20
          periodSeconds: 10
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
          seccompProfile:
            type: RuntimeDefault
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-cluster-critical
      serviceAccountName: metrics-server
      volumes:
      - emptyDir: {}
        name: tmp-dir
---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  labels:
    k8s-app: metrics-server
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100
EOF


```

--
Here’s what each thing does and when to use it:

### `hostNetwork: true`

* **What it does:** Runs the metrics-server pod in the node’s network namespace. The pod listens on the **node’s IP** (not the Pod IP) at port 4443.
* **Why/when to use:** Workaround when the API server can’t reach Pod CIDRs or Service VIPs (CNI broken, kube-proxy missing on control-plane, strict firewalls). It often makes the APIService flip to `Available=True`.
* **Caveats:**

  * Add `dnsPolicy: ClusterFirstWithHostNet`.
  * Port 4443 must be free on the host.
  * It’s a **workaround**; the real fix is healthy CNI and kube-proxy (or eBPF replacement).

### `--kubelet-insecure-tls`

* **What it does:** Tells metrics-server to **skip TLS verification** when scraping kubelets on `:10250`.
* **Why/when to use:** Labs or clusters where kubelet serving certs **lack IP SANs** (your original error) or you don’t have the CA handy.
* **Caveats / security:** Disables cert verification → vulnerable to MITM inside the cluster. **Don’t use in production.**

  * **Proper fix:** enable kubelet `serverTLSBootstrap`, approve CSRs so the kubelet cert includes the node’s IP; or point metrics-server at the CA via `--kubelet-certificate-authority`.

### `--kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP`

* **What it does:** Sets the **priority order** of addresses metrics-server uses to contact each kubelet.
* **Why/when to use:** Ensures it tries the **InternalIP** first (usually routable & matches kubelet cert SANs).

  * Putting `Hostname` second is fine **only if** cluster DNS resolves hostnames correctly; otherwise prefer `ExternalIP` second.
* **Tips:** Common, safe default: `InternalIP,ExternalIP,Hostname`. In cloud VPCs, InternalIP is almost always right.

---



### 1.3 Verify Metrics Server is working

```bash
kubectl top nodes
kubectl top pods
```

<img width="787" height="189" alt="image" src="https://github.com/user-attachments/assets/7430c848-9bde-4645-bcec-9c3d83939a49" />


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


