```
# Pod with Init Container
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-init-container
spec:
  initContainers:
  - name: init-container
    image: busybox:latest
    command: ["sh", "-c", "echo Initializing... && sleep 5"]
  containers:
  - name: app-container
    image: nginx:latest
    ports:
    - containerPort: 80

---

```
