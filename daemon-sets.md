```

# Daemon Sets
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: daemonset-example
spec:
  selector:
    matchLabels:
      app: daemonset-app
  template:
    metadata:
      labels:
        app: daemonset-app
    spec:
      containers:
      - name: nginx-container
        image: nginx:latest

---

```
