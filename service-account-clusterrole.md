## Create a Service Account
vi lab-user.yaml 

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: lab-user			

```
```
kubectl apply -f lab-user.yaml
```
```
kubectl get serviceaccount lab-user
```
## Assign roles and permissions

```
vi lab-cluster-role.yaml
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: lab-cluster-role
rules:
- apiGroups: [""]
  resources: ["pods", "deployments"]
  verbs: ["get", "list"]
```

```
kubectl apply -f lab-cluster-role.yaml
```

## Role binding

```
vim lab-role-binding.yaml

```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: lab-cluster-role-binding
subjects:
- kind: ServiceAccount
  name: lab-user
  namespace: default
roleRef:
  kind: ClusterRole
  name: lab-cluster-role
  apiGroup: rbac.authorization.k8s.io
```
```
kubectl apply -f lab-role-binding.yaml

```

## Service account permissions

Let's restart the CoreDNS deployment and create and run a nginx image as a pod without a service account in the kubernetes cluster with the help of the following command.

```
kubectl -n kube-system rollout restart deployment coredns

```
```
kubectl run defaultsa-pod --image=quay.io/gauravkumar9130/nginx

```

```
kubectl exec -it defaultsa-pod -- sh

```
```
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
```
```
curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/namespaces/default/pods/ --insecure
```
you will see forbidden error







