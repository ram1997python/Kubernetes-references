
---

````markdown
# 📦 Jeevi Academy – Static Website Deployment on Kubernetes with NGINX Ingress

This project demonstrates how to deploy a static website for **Jeevi Academy** using Kubernetes, with NGINX Ingress and path-based routing.

We will deploy:
- `/blog`      → Jeevi Academy Blog
- `/services` → Jeevi Academy Services

---

## 🚀 Prerequisites

- Kubernetes cluster (Minikube, Vagrant, or cloud)
- Ingress NGINX controller installed
- Docker & Docker Hub account
- kubectl configured and running

---

## 🔧 Step 1: Install Ingress NGINX Controller

Install Ingress controller:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml
````

For **local setups (like Vagrant)**, change the service to `NodePort`:

```bash
kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec": {"type": "NodePort"}}'
```

Check controller pods:

```bash
kubectl get pods -n ingress-nginx
```

---

## 📄 Step 2: Create and Push Docker Images

Each website section (blog & services) is a static HTML page served by NGINX.

**Dockerfile (common):**

```Dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
```

### Example `index.html` for Blog:

```html
<h1>Welcome to Jeevi Academy Blog</h1>
<p>Articles, tutorials, and news updates!</p>
```

### Example `index.html` for Services:

```html
<h1>Jeevi Academy Services</h1>
<p>Explore our training and mentorship programs.</p>
```

Then:

```bash
docker build -t yourdockerhub/jeevi-blog ./jeevi-blog
docker build -t yourdockerhub/jeevi-services ./jeevi-services

docker push yourdockerhub/jeevi-blog
docker push yourdockerhub/jeevi-services
```

Replace `yourdockerhub` with your Docker Hub username.

---

## ⚙️ Step 3: Apply Kubernetes Configurations

### 🧱 `jeevi-blog-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jeevi-blog
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jeevi-blog
  template:
    metadata:
      labels:
        app: jeevi-blog
    spec:
      containers:
      - name: blog
        image: yourdockerhub/jeevi-blog
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: jeevi-blog
spec:
  selector:
    app: jeevi-blog
  ports:
    - port: 80
      targetPort: 80
```

---

### 🧱 `jeevi-services-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jeevi-services
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jeevi-services
  template:
    metadata:
      labels:
        app: jeevi-services
    spec:
      containers:
      - name: services
        image: yourdockerhub/jeevi-services
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: jeevi-services
spec:
  selector:
    app: jeevi-services
  ports:
    - port: 80
      targetPort: 80
```

---

### 🧭 `jeevi-ingress.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jeevi-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /blog
        pathType: Prefix
        backend:
          service:
            name: jeevi-blog
            port:
              number: 80
      - path: /services
        pathType: Prefix
        backend:
          service:
            name: jeevi-services
            port:
              number: 80
```

---

## 📥 Step 4: Apply All YAMLs

```bash
kubectl apply -f jeevi-blog-deployment.yaml
kubectl apply -f jeevi-services-deployment.yaml
kubectl apply -f jeevi-ingress.yaml
```

---

## 🌐 Step 5: Access the Website

Find your Ingress controller NodePort:

```bash
kubectl get svc -n ingress-nginx
```

Example URL if NodePort is `31286`:

```
http://<master-or-worker-node-ip>:31286/blog
http://<master-or-worker-node-ip>:31286/services
```

Use `curl` or open in browser.

---

## 🧹 Cleanup

```bash
kubectl delete -f jeevi-ingress.yaml
kubectl delete -f jeevi-blog-deployment.yaml
kubectl delete -f jeevi-services-deployment.yaml
```

---

## 📚 Summary

This setup shows how to:

* Serve multiple static websites using Docker and NGINX
* Deploy them on Kubernetes
* Route requests using a single Ingress with paths

Ideal for students learning Ingress, services, and containerized website deployment.

Happy Learning! 🚀

```

---

Would you like me to generate a ZIP file containing this `README.md`, plus sample `index.html`, and YAMLs?
```
