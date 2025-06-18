# Define the Pod with Resource Requests
```
pod-requests.yaml
```
```
apiVersion: v1
kind: Pod
metadata:
  name: resource-request-pod
spec:
  containers:
    - name: request-container
      image: nginx
      resources:
        requests:
          memory: "64Mi"
          cpu: "250m"

```

```
kubectl apply -f pod-requests.yaml
```

```
kubectl describe pod resource-request-pod
```
```
pod-limits.yaml
```
```
apiVersion: v1
kind: Pod
metadata:
  name: resource-limit-pod
spec:
  containers:
    - name: limit-container
      image: nginx
      resources:
        limits:
          memory: "128Mi"
          cpu: "500m"

```
```
kubectl apply -f pod-limits.yaml
```
```
kubectl get pod resource-limit-pod
```
```
kubectl describe pod resource-limit-pod
```

## Define a pod with resouce quota

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-quota
spec:
  containers:
    - name: quota-container
      image: nginx
      resources:
        requests:
          memory: "64Mi"
          cpu: "250m"
        limits:
          memory: "128Mi"
          cpu: "500m"

```
```
kubectl apply -f pod-with-quota.yaml
```
```
kubectl get pod pod-with-quota

```
```
vi resource-quota.yaml
```
```
apiVersion: v1
kind: ResourceQuota
metadata:
  name: demo-quota
spec:
  hard:
    pods: "1" # Adjust as per your quota requirements
    requests.cpu: "1"
    requests.memory: "1Gi"
    limits.cpu: "2"
    limits.memory: "2Gi"

```
```
kubectl apply -f resource-quota.yaml

```
```
kubectl describe pod pod-with-quota

```
```
kubectl describe resourcequota demo-quota

```







