Sure! Here’s a step-by-step guide to *set up a Kubernetes cluster using kind (Kubernetes IN Docker)*: ( Windows ) - Use git bash to download kind package

---

## ✅ Step 1: Prerequisites

You need the following installed:

* [Docker](https://docs.docker.com/get-docker/)
* [Go](https://golang.org/) (optional if building from source)
* [kind](https://kind.sigs.k8s.io/)

Install kind:

```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

---

## ✅ Step 2: Create a Cluster

Create a cluster using default configuration:

```
kind create cluster --name my-cluster

```

You can also use a custom config file (e.g., with multiple nodes):

*kind-config.yaml*:

yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker


Create the cluster:

bash
kind create cluster --name my-cluster --config kind-config.yaml


---

## ✅ Step 3: Verify the Cluster

```
kubectl cluster-info --context kind-my-cluster
kubectl get nodes
```

Expected output:


NAME                  STATUS   ROLES           AGE   VERSION
my-cluster-control-plane   Ready    control-plane   1m    v1.28.x
my-cluster-worker          Ready    <none>          1m    v1.28.x


---

## ✅ Step 4: Deploy an App (Optional)

```
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get svc

```

