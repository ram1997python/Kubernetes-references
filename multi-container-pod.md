```
---

# Multi-container Pod
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: app-container-1
    image: nginx:latest
    ports:
    - containerPort: 80
  - name: app-container-2
    image: redis:latest

---

```
