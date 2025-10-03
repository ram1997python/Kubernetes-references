# 🚪 Jeevi Academy – Static Website on Kubernetes with Gateway API

This folder mirrors `kuberenetes-ingress/` and shows the same app using the Kubernetes Gateway API with path-based routing.

We will deploy:
- `/blog` → Jeevi Academy Blog
- `/services` → Jeevi Academy Services

---

## 🚀 Prerequisites

- Kubernetes cluster (Minikube, Vagrant, or cloud)
- Gateway API CRDs and a Gateway implementation installed
- Docker & Docker Hub account
- kubectl configured and running

---

## 🔧 Step 1: Install a Gateway API Implementation

Gateway API defines CRDs but needs a controller to implement them. Choose one:

- Envoy Gateway (default assumed in these manifests):

  ```bash
  kubectl apply -f https://github.com/envoyproxy/gateway/releases/latest/download/install.yaml
  ```
  ```
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -out /tmp/tls.crt -keyout /tmp/tls.key \
  -subj "/CN=envoy-gateway/O=envoy-gateway"
  ```
  ```
  kubectl create secret tls envoy-gateway \
  --cert=/tmp/tls.crt \
  --key=/tmp/tls.key \
  -n envoy-gateway-system
  ````

Verify CRDs and controller pods:

```bash
kubectl get crds | grep gateway.networking.k8s.io
kubectl get pods -A | grep -i gateway
```

For local setups without a LoadBalancer (e.g., Vagrant), the Gateway Service might be `LoadBalancer`. Patch it to `NodePort`:

- Envoy Gateway example (adjust namespace/name if different):

  ```bash
  kubectl get svc -A | grep envoy-gateway # find the service
  kubectl patch svc envoy-gateway -n envoy-gateway-system -p '{"spec": {"type": "NodePort"}}'
  ```

---

## 📄 Step 2: Build and Push Docker Images

Reuse the static sites from `kuberenetes-ingress/`:

```bash
docker build -t yourdockerhub/jeevi-blog ../kuberenetes-ingress/jeevi-blog

docker build -t yourdockerhub/jeevi-services ../kuberenetes-ingress/jeevi-services

# Push

docker push yourdockerhub/jeevi-blog

docker push yourdockerhub/jeevi-services
```

Replace `yourdockerhub` with your Docker Hub username.

---

## ⚙️ Step 3: Apply Kubernetes Manifests

This demo reuses the same Deployments/Services and adds Gateway API resources.

```bash
kubectl apply -f jeevi-blog-deployment.yaml
kubectl apply -f jeevi-services-deployment.yaml
kubectl apply -f gatewayclass.yaml
kubectl apply -f gateway.yaml
kubectl apply -f httproute.yaml
```

Files in this folder:
- `jeevi-blog-deployment.yaml` – blog Deployment/Service
- `jeevi-services-deployment.yaml` – services Deployment/Service
- `gatewayclass.yaml` – selects controller implementation
- `gateway.yaml` – exposes HTTP listener (:80)
- `httproute.yaml` – routes `/blog` and `/services` to Services

---

## 🌐 Step 4: Access the Website

Get the Gateway’s Service and NodePort:

```bash
kubectl get svc -A | egrep "envoy-gateway"
```

Example URLs if NodePort is `31080`:

```
http://<node-ip>:31080/blog
http://<node-ip>:31080/services
```

---

## 🧹 Cleanup

```bash
kubectl delete -f httproute.yaml
kubectl delete -f gateway.yaml
kubectl delete -f gatewayclass.yaml
kubectl delete -f jeevi-services-deployment.yaml
kubectl delete -f jeevi-blog-deployment.yaml
```

(Optional) Uninstall the chosen Gateway controller.

---

## 🆚 Ingress vs. Gateway API (Quick Comparison)

- Resource model:
  - Ingress: single `Ingress` object.
  - Gateway API: `GatewayClass` (implementation), `Gateway` (data-plane entry), `HTTPRoute` (app routing), etc.
- Roles:
  - Ingress: often shared between platform/app teams.
  - Gateway API: platform owns `GatewayClass/Gateway`; app teams attach `HTTPRoute`s.
- Capabilities:
  - Ingress: basic HTTP routing, extensions via annotations.
  - Gateway API: richer routing/filters, cross-namespace refs, better conformance.
- Extensibility:
  - Ingress: annotations.
  - Gateway API: structured fields and `ExtensionRef`.

Happy Learning! 🚀
