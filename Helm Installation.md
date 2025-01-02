## Install and setup Helm Package Manager

## Step 1: Download the Helm Installation Script

Helm provides a script to easily install the latest version:

```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

```
## Step 2: Verify the Installation

Check the installed Helm version to confirm it's working:

```
helm version
```
## Step 3: Add a Helm Repository

Add a Helm repository (e.g., for NGINX Ingress Controller):

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```
## Step 4: Update Helm Repositories

Update the list of charts in your repositories:
```
helm repo update
```
## Step 5: Install a Chart
Install a Helm chart (e.g., NGINX Ingress Controller):
```

helm install my-nginx ingress-nginx/ingress-nginx

```

https://opensource.com/article/20/5/helm-charts
