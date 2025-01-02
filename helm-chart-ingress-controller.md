## Helm Guide: NGINX Ingress Controller Setup
# Prerequisites
Kubernetes cluster
Helm installed (v3+)
kubectl configured

## Step 1: Install Helm

Download and install Helm:

```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```
Verify the Helm installation:
```
helm version
```
## Step 2: Add and Update the Helm Repository
Add the NGINX Ingress Helm repository
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

```
Update the Helm repositories
```
helm repo update
```
Search for NGINX-related charts
```
helm search repo nginx

```
## Step 3: Install the NGINX Ingress Controller
Install the ingress-nginx chart:
```
helm install my-nginx ingress-nginx/ingress-nginx

```
List the installed Helm releases
```
helm list

```
Verify the deployed resources:
```
kubectl get all
```

## Step 4: Fetch and Customize the Chart
Fetch the chart and extract its contents:
```
helm fetch ingress-nginx/ingress-nginx --untar
```
Navigate to the extracted chart directory
```
cd ingress-nginx
```
Open and modify the values.yaml file to customize the chart:
```
vi values.yaml

```
## Step 5: Upgrade the Helm Release

Upgrade the deployment using the modified values.yaml file:
```
helm upgrade my-nginx ingress-nginx/ingress-nginx -f values.yaml

```
Verify the updated pods
```
kubectl get pods
```
Check the Helm releases again
```
helm list
```

## Step 6: Review and Roll Back Changes
Check the deployment history
```
helm history my-nginx

```
Roll back to a specific revision (e.g., revision 1)
```
helm rollback my-nginx 1
```
Verify the resources after rollback
```
kubectl get all
```
## Step 7: Uninstall the Release
```
Uninstall the Helm release:
```
helm uninstall my-nginx
```
Verify that the resources are deleted
```
kubectl get all
```
