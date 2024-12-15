```

# Self-Healing Application (Deployment with Liveness Probe)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: self-healing-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: self-healing-app
  template:
    metadata:
      labels:
        app: self-healing-app
    spec:
      containers:
      - name: self-healing-container
        image: nginx:latest
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10

---

```
