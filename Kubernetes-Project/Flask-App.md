🟢 Simple REST API (e.g., Python Flask/Node.js Express)
Concept Focus: Pods, Deployments, Services, basic application containerization.

Idea: A basic "Hello World" REST API that returns a JSON response.

Learning:

Containerizing a simple application.

Ensuring the application listens on the correct port.

Exposing the API via a ClusterIP service.

Optional: Exposing via NodePort or LoadBalancer (if your K8s environment supports it).

Commands/Steps:

Write a minimal Flask/Express app.

Create Dockerfile, build and push image.

Create Deployment.yaml.

Create Service.yaml (e.g., ClusterIP).

kubectl apply -f ...

Test access using kubectl port-forward or by getting the service IP/NodePort.

----------------------------------------------


Here's a step-by-step guide to deploy a 🟢 **Simple REST API using Flask (Python)** on Kubernetes. It will cover containerization, Deployments, Services, and testing access.

---

## ✅ 1. Write a Minimal Flask App

### 📄 `app.py`

```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify(message="Hello from Flask API on Kubernetes!")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

---

## ✅ 2. Create a `requirements.txt`

```txt
flask
```

---

## ✅ 3. Dockerize the App

### 📄 `Dockerfile`

```Dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

---

## ✅ 4. Build and Push the Docker Image

> Replace `your-dockerhub-username` with your Docker Hub username.

```bash
docker build -t your-dockerhub-username/flask-api:v1 .
docker push your-dockerhub-username/flask-api:v1
```

---

## ✅ 5. Create Kubernetes Manifests

### 📄 `deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask-api
  template:
    metadata:
      labels:
        app: flask-api
    spec:
      containers:
      - name: flask-api
        image: your-dockerhub-username/flask-api:v1
        ports:
        - containerPort: 5000
```

---

### 📄 `service.yaml` (ClusterIP)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-api
spec:
  selector:
    app: flask-api
  ports:
  - port: 80
    targetPort: 5000
  type: ClusterIP
```

---

## ✅ 6. Apply the Manifests

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

---

## ✅ 7. Test Access

### 🔁 Using Port Forward

```bash
kubectl port-forward svc/flask-api 8080:80
```

In another terminal:

```bash
curl http://localhost:8080
```

Expected output:

```json
{"message":"Hello from Flask API on Kubernetes!"}
```

---

### 🌍 Optional: Expose via NodePort

### 📄 `service-nodeport.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-api-nodeport
spec:
  type: NodePort
  selector:
    app: flask-api
  ports:
  - port: 80
    targetPort: 5000
    nodePort: 30081
```

```bash
kubectl apply -f service-nodeport.yaml
```

Access from browser or curl:

```bash
curl http://<NodeIP>:30081
```

---

## ✅ Cleanup (Optional)

```bash
kubectl delete deployment flask-api
kubectl delete svc flask-api flask-api-nodeport
```

