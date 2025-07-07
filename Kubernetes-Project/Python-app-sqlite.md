Here’s a complete walkthrough to deploy a 🟡 **Basic SQLite Application** on Kubernetes that uses **PersistentVolumeClaim (PVC)** for data persistence — great for understanding **storage and pod lifecycles**.

---

# 📦 Application Overview

* **App**: Python script using SQLite to read/write tasks
* **Storage**: SQLite file stored in a volume `/app/data/mydb.sqlite`
* **PVC**: Bound to a PersistentVolume (dynamic or manual)
* **Goal**: Data remains even after pod deletion/recreation

---

## ✅ 1. Python App That Uses SQLite

### 📄 `sqlite_app.py`

```python
import sqlite3
import os

DB_FILE = "/app/data/mydb.sqlite"

os.makedirs("/app/data", exist_ok=True)

conn = sqlite3.connect(DB_FILE)
cursor = conn.cursor()

# Create table if it doesn't exist
cursor.execute("CREATE TABLE IF NOT EXISTS todos (task TEXT)")
conn.commit()

# Insert sample data
cursor.execute("INSERT INTO todos (task) VALUES ('Test Task')")
conn.commit()

# Read and print data
cursor.execute("SELECT * FROM todos")
tasks = cursor.fetchall()
print("📋 Todo List:")
for task in tasks:
    print("-", task[0])

conn.close()
```

---

## ✅ 2. Dockerize the App

### 📄 `Dockerfile`

```Dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY sqlite_app.py .
RUN pip install --no-cache-dir sqlite3 2>/dev/null || true
CMD ["python", "sqlite_app.py"]
```

Build & Push:

```bash
docker build -t youruser/sqlite-app:v1 .
docker push youruser/sqlite-app:v1
```

---

## ✅ 3. PVC Definition

### 📄 `pvc.yaml`

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sqlite-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

> Note: This assumes your cluster supports **dynamic volume provisioning** (e.g., using default `StorageClass`).

---

## ✅ 4. Deployment with VolumeMount

### 📄 `deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sqlite-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sqlite-app
  template:
    metadata:
      labels:
        app: sqlite-app
    spec:
      containers:
      - name: sqlite
        image: youruser/sqlite-app:v1
        volumeMounts:
        - name: sqlite-data
          mountPath: /app/data
      volumes:
      - name: sqlite-data
        persistentVolumeClaim:
          claimName: sqlite-pvc
```

---

## ✅ 5. Apply Everything

```bash
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
```

---

## ✅ 6. Verify Data Persistence

### Step 1: Check logs to see inserted task

```bash
kubectl logs deploy/sqlite-app
```

```
📋 Todo List:
- Test Task
```

---

### Step 2: Delete the pod

```bash
kubectl delete pod -l app=sqlite-app
```

---

### Step 3: Recheck logs after new pod starts

```bash
kubectl logs deploy/sqlite-app
```

If you see **multiple entries** of "Test Task", it confirms persistence!

---

## 📊 Optional: Inspect Volume Binding

```bash
kubectl get pvc
kubectl describe pvc sqlite-pvc
```

---

## 🧽 Cleanup

```bash
kubectl delete -f deployment.yaml
kubectl delete -f pvc.yaml
```

---

## ✅ Summary

| Component | Description                              |
| --------- | ---------------------------------------- |
| App       | Python with SQLite                       |
| Storage   | `/app/data/mydb.sqlite`                  |
| PVC       | Binds to volume used across pod restarts |
| Test      | Data remains after deleting pod          |

---


