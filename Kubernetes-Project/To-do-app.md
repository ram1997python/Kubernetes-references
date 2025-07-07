🟡 Todo List Application (Frontend + Backend)
Concept Focus: Multi-tier application, ConfigMaps, Services, possibly Ingress.

Idea: A simple web application with a frontend (e.g., React/Vue) and a backend API (e.g., Node.js/Python) that stores data in memory (for simplicity) or a local file.

Learning:

Deploying multiple interdependent services.

Service discovery (how frontend talks to backend using Kubernetes DNS).

Using ConfigMaps to pass configuration to the backend (e.g., API URL).

(Optional) Setting up an Ingress controller (e.g., Nginx Ingress) for external access.

Commands/Steps:

Develop a simple frontend and backend application.

Containerize both.

Create Deployment.yaml and Service.yaml for backend (e.g., ClusterIP).

Create Deployment.yaml and Service.yaml for frontend (e.g., NodePort or LoadBalancer).

Create a ConfigMap for frontend configuration (e.g., BACKEND_API_URL).

Configure frontend deployment to consume the ConfigMap.

(Optional) Deploy Nginx Ingress Controller and an Ingress.yaml for domain-based routing.


--------------------------------------------



Here’s a step-by-step guide to deploy a **Todo List Application** (Frontend + Backend) on Kubernetes — ideal to understand **multi-tier app deployment**, **Service Discovery**, **ConfigMaps**, and optionally **Ingress**.

---

# 🧩 Architecture Overview

* **Frontend**: React app served via Nginx
* **Backend**: Node.js REST API storing todos in memory
* **Communication**: Frontend calls backend via `http://todo-backend.default.svc.cluster.local`
* **ConfigMap**: Used to inject `BACKEND_API_URL` into the frontend
* **Ingress** (optional): Route `/api` to backend and `/` to frontend

---

## 📦 1. Backend (Node.js)

### 📁 `backend/app.js`

```js
const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

let todos = [];

app.use(cors());
app.use(express.json());

app.get('/api/todos', (req, res) => {
  res.json(todos);
});

app.post('/api/todos', (req, res) => {
  todos.push(req.body);
  res.status(201).json(req.body);
});

app.listen(port, () => {
  console.log(`Todo API listening at http://localhost:${port}`);
});
```

---

### 📄 `backend/Dockerfile`

```Dockerfile
FROM node:18
WORKDIR /app
COPY app.js .
RUN npm init -y && npm install express cors
EXPOSE 3000
CMD ["node", "app.js"]
```

Build and push:

```bash
docker build -t youruser/todo-backend:v1 .
docker push youruser/todo-backend:v1
```

---

### 📄 `backend-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: todo-backend
  template:
    metadata:
      labels:
        app: todo-backend
    spec:
      containers:
      - name: backend
        image: youruser/todo-backend:v1
        ports:
        - containerPort: 3000
```

---

### 📄 `backend-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: todo-backend
spec:
  selector:
    app: todo-backend
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP
```

---

## 🎨 2. Frontend (React or plain HTML+JS)

Create `frontend/index.html`:

```html
<!DOCTYPE html>
<html>
<head><title>Todo App</title></head>
<body>
<h1>Todo List</h1>
<ul id="list"></ul>
<input id="todo" placeholder="Add todo"><button onclick="addTodo()">Add</button>

<script>
const api = window.BACKEND_API_URL || 'http://todo-backend';

function fetchTodos() {
  fetch(api + '/api/todos')
    .then(res => res.json())
    .then(data => {
      document.getElementById('list').innerHTML = data.map(t => `<li>${t.text}</li>`).join('');
    });
}

function addTodo() {
  const text = document.getElementById('todo').value;
  fetch(api + '/api/todos', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({ text })
  }).then(fetchTodos);
}

fetchTodos();
</script>
</body>
</html>
```

---

### 📄 `frontend/Dockerfile`

```Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

Build and push:

```bash
docker build -t youruser/todo-frontend:v1 .
docker push youruser/todo-frontend:v1
```

---

### 📄 `frontend-configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
data:
  BACKEND_API_URL: http://todo-backend
```

---

### 📄 `frontend-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: todo-frontend
  template:
    metadata:
      labels:
        app: todo-frontend
    spec:
      containers:
      - name: frontend
        image: youruser/todo-frontend:v1
        ports:
        - containerPort: 80
        env:
        - name: BACKEND_API_URL
          valueFrom:
            configMapKeyRef:
              name: frontend-config
              key: BACKEND_API_URL
```

---

### 📄 `frontend-service.yaml` (NodePort)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: todo-frontend
spec:
  selector:
    app: todo-frontend
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30082
  type: NodePort
```

---

## 🚀 3. Apply Everything

```bash
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f frontend-configmap.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
```

---

## 🔍 4. Access the App

### 🌐 From browser or curl:

```bash
http://<NodeIP>:30082
```

You should see the frontend working with real backend integration.

---

## 🌐 (Optional) 5. Add Ingress

If using Ingress controller:

### 📄 `ingress.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: todo-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: todo.local
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: todo-backend
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: todo-frontend
            port:
              number: 80
```

Then edit your local DNS or `/etc/hosts`:

```
127.0.0.1 todo.local
```

---

## ✅ Summary

| Component | Type         | Exposed As      |
| --------- | ------------ | --------------- |
| Frontend  | React/HTML   | NodePort        |
| Backend   | Node.js API  | ClusterIP       |
| Config    | BACKEND\_API | ConfigMap       |
| Ingress   | Optional     | todo.local host |

---


