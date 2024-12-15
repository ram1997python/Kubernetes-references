```

# Static Pods
# Example assumes placing this manifest in /etc/kubernetes/manifests/
apiVersion: v1
kind: Pod
metadata:
  name: static-pod-example
spec:
  containers:
  - name: nginx-container
    image: nginx:latest

---

```
