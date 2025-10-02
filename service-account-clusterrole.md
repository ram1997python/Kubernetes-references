## Create a Service Account

```
vi lab-user.yaml 
```
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

```
vi pod.yaml
```
```
apiVersion: v1
kind: Pod
metadata:
  name: lab-sa-pod
spec:
  containers:
  - name: abc
    image: nginx
  serviceAccountName: lab-user
```
```
kubectl create -f pod.yaml

```
```
kubectl exec -it lab-sa-pod -- bash
```
```
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
```
```
curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/namespaces/default/pods/ --insecure
```
```
curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/namespaces/kube-system/pods/ --insecure
```
If not service account, create user

```

#!/bin/bash

set -e

cwd=$(pwd)

#---------------------------------------
# Step 1: Create Namespace
#---------------------------------------
read -p "Please type the Kubernetes namespace to create: " namespace

if kubectl get namespace "$namespace" >/dev/null 2>&1; then
  echo "[i] Namespace '$namespace' already exists."
else
  kubectl create namespace "$namespace"
  echo "[✓] Namespace '$namespace' created."
fi

#---------------------------------------
# Step 2: Create Linux User
#---------------------------------------
read -p "Please type the Linux username to create: " username

if id "$username" >/dev/null 2>&1; then
  echo "[i] User '$username' already exists."
else
  useradd -m "$username"
  echo "[✓] User '$username' created."
fi

read -s -p "Please type a password for user '$username': " password
echo
echo "$username:$password" | sudo chpasswd
echo "[✓] Password set for '$username'."

#---------------------------------------
# Step 3: Generate Client Certificates
#---------------------------------------
echo "[*] Generating SSL certificates..."

openssl genrsa -out "$username.key" 2048
openssl req -new -key "$username.key" -out "$username.csr" -subj "/CN=$username/O=$namespace"

cp -f /etc/kubernetes/pki/ca.{crt,key} "$cwd/"

openssl x509 -req -in "$username.csr" \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out "$username.crt" -days 365

echo "[✓] Certificates created for user '$username'."

#---------------------------------------
# Step 4: Create kubeconfig File
#---------------------------------------
echo "[*] Creating kubeconfig file..."

clustername=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
myipaddress=$(ip addr show | grep -A2 'state UP' | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n1)

kubectl --kubeconfig kube.kubeconfig config set-cluster "$clustername" \
  --server="https://$myipaddress:6443" \
  --certificate-authority=ca.crt \
  --embed-certs=true

kubectl --kubeconfig kube.kubeconfig config set-credentials "$username" \
  --client-certificate="$cwd/$username.crt" \
  --client-key="$cwd/$username.key" \
  --embed-certs=true

kubectl --kubeconfig kube.kubeconfig config set-context "$username-kubernetes" \
  --cluster="$clustername" \
  --namespace="$namespace" \
  --user="$username"

kubectl --kubeconfig kube.kubeconfig config use-context "$username-kubernetes"

mv kube.kubeconfig config
echo "[✓] kubeconfig file created as 'config'."

#---------------------------------------
# Step 5: Copy Config Files to User's Home
#---------------------------------------
echo "[*] Copying kubeconfig and certs to /home/$username/.kube"

mkdir -p /home/$username/.kube
cp -rvf "$cwd"/* /home/$username/.kube/
chown -R "$username:$username" /home/$username/.kube

echo "[✔] Kubernetes client configuration setup completed for user '$username'."


```







