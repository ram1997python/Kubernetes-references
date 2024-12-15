```


# Manual Scheduling
apiVersion: v1
kind: Pod
metadata:
  name: manually-scheduled-pod
spec:
  nodeName: worker-node-1
  containers:
  - name: nginx-container
    image: nginx:latest

---

```
