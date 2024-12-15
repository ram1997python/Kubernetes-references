```
# Persistent Volume Definition
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-persistent-volume
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain # Can be Recycle or Delete
  storageClassName: manual
  hostPath:
    path: /mnt/data

---

# Persistent Volume Claim
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-persistent-volume-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: manual

---

# Deployment with Attached PVC
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app-container
        image: nginx:latest
        volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: app-storage
      volumes:
      - name: app-storage
        persistentVolumeClaim:
          claimName: my-persistent-volume-claim

---

```
