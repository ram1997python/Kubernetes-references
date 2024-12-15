```

# Labels and Selectors
apiVersion: v1
kind: Pod
metadata:
  name: labeled-pod
  labels:
    environment: production
spec:
  containers:
  - name: nginx-container
    image: nginx:latest
---
apiVersion: v1
kind: Service
metadata:
  name: service-selector
spec:
  selector:
    environment: production
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80

---

```
