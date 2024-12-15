```

# Node Selectors
apiVersion: v1
kind: Pod
metadata:
  name: node-selector-pod
spec:
  nodeSelector:
    disktype: ssd
  containers:
  - name: nginx-container
    image: nginx:latest

---

```
