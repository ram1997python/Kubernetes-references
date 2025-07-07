🟢 Simple Static Website with Nginx

Concept Focus: Pods, Deployments, Services (ClusterIP & NodePort).

Idea: Deploy an Nginx server hosting a basic HTML page.

Learning:

Containerizing a static website.

Creating a Deployment to manage Nginx pods.

Exposing the deployment using a ClusterIP Service for internal access.

Exposing it again using a NodePort Service to access it from outside the cluster.

Commands/Steps:

Create a simple index.html.

Create a Dockerfile to build an Nginx image with your index.html.

Build and push your Docker image to a registry.

Write a Deployment.yaml for your Nginx app.

Write a Service.yaml for ClusterIP.

Write another Service.yaml for NodePort.

kubectl apply -f <yaml-files>

Verify access using curl to ClusterIP (from inside a pod) and NodePort (from outside).


---

## ✅ 1. Prepare Your Static Website

Create a folder for your project:

```bash
mkdir nginx-static-site && cd nginx-static-site
```

### `index.html`

```html
<!-- index.html -->
<!DOCTYPE html>
<html>
<head><title>Welcome</title></head>
<body><h1>Hello from Kubernetes Nginx!</h1></body>
</html>
```

---

## ✅ 2. Create a Dockerfile

```Dockerfile
# Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

---

## ✅ 3. Build and Push the Docker Image

> Replace `your-dockerhub-username` with your Docker Hub username.

```bash
docker build -t your-dockerhub-username/nginx-static:v1 .
docker push your-dockerhub-username/nginx-static:v1
```

---

## ✅ 4. Create Kubernetes YAML Files

### ✏️ `deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-static
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-static
  template:
    metadata:
      labels:
        app: nginx-static
    spec:
      containers:
      - name: nginx
        image: your-dockerhub-username/nginx-static:v1
        ports:
        - containerPort: 80
```

---

### ✏️ `service-clusterip.yaml` (Internal access)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-clusterip
spec:
  type: ClusterIP
  selector:
    app: nginx-static
  ports:
    - port: 80
      targetPort: 80
```

---

### ✏️ `service-nodeport.yaml` (External access)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  type: NodePort
  selector:
    app: nginx-static
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080  # Choose from 30000-32767
```

---

## ✅ 5. Apply the YAMLs

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service-clusterip.yaml
kubectl apply -f service-nodeport.yaml
```

---

## ✅ 6. Verify Everything Is Running

```bash
kubectl get pods
kubectl get svc
```

Expected output:

```
NAME               TYPE        CLUSTER-IP     PORT(S)        AGE
nginx-clusterip    ClusterIP   10.96.1.5      80/TCP         2m
nginx-nodeport     NodePort    10.96.2.5      80:30080/TCP   2m
```

---

## ✅ 7. Access the Website

### 🔍 From inside the cluster (ClusterIP)

```bash
kubectl run test --rm -it --image=busybox -- sh
wget -qO- http://nginx-clusterip
```

Expected:

```html
<h1>Hello from Kubernetes Nginx!</h1>
```

---

### 🌍 From outside the cluster (NodePort)

If using Minikube:

```bash
minikube service nginx-nodeport
```

If using kubeadm:

```bash
curl http://<NodeIP>:30080
```

You should see your HTML output.

---

## ✅ Cleanup (Optional)

```bash
kubectl delete deployment nginx-static
kubectl delete svc nginx-clusterip nginx-nodeport
```

---

Would you like a downloadable zip with all files (`index.html`, Dockerfile, YAMLs) ready to go?
