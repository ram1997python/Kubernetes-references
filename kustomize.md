### Step 1: Create and Navigate to the Project Directory


# 1. Create a directory for the demo application

```
mkdir demo-app

```
# Navigate into the demo-app directory:
```
cd demo-app/

```
# Step 2: Setup Kustomization Structure

Create a kustomize directory for configuration files:
```
mkdir kustomize
cd kustomize/
```
Create a base directory
```
mkdir base
cd base/

```
# Step 3: Define Base Deployment

Create a deployment.yaml file to define your Kubernetes deployment:

```
vi deployment.yaml

```
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.17
        ports:
        - containerPort: 80


```

Create a kustomization.yaml file to manage the resources:

```
vi kustomization.yaml

```
```
resources:
  - deployment.yaml

```
# Step 4: Setup Overlays

Return to the kustomize directory:
```
cd ..

```
Create an overlays directory:

```
mkdir overlays
cd overlays/

```
Create a staging directory for the staging environment:

```
mkdir staging
cd staging/

```
Create a kustomization.yaml file for the staging overlay:

```
vi kustomization.yaml

```
```
resources:
  - ../../base
patchesStrategicMerge:
  - replica-patch.yaml
```
Add a patch file (optional):
```
vi replica-patch.yaml

```
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3

```
Step 5: Apply the Configuration

Return to the kustomize directory:

```
cd ~/demo-app/kustomize

```
Apply the staging overlay
```
kubectl apply -k overlays/staging

```
# Step 6: Verify Deployment

Check the status of the deployment
```
kubectl get deployment nginx-deployment

```
Verify the pods created by the deployment
```
kubectl get pods -l app=nginx

```
