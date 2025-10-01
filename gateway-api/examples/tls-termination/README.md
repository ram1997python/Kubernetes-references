# TLS Termination (HTTPS) with Gateway API

This example shows HTTPS (TLS) termination at the `Gateway`. It uses a self-signed certificate so students can test locally on a Vagrant cluster (1 master, 2 workers) without external DNS.

We will route:
- https://blog.local/ → `jeevi-blog` Service
- https://services.local/ → `jeevi-services` Service

Both services are the same from the base example in `gateway-api/`.

---

## Prerequisites

- Envoy Gateway installed and Gateway service patched to NodePort (see `gateway-api/Readme.md` Step 1)
- Images pushed: `yourdockerhub/jeevi-blog` and `yourdockerhub/jeevi-services`
- Base deployments applied (or you can apply just the two deployment YAMLs in the parent `gateway-api/` folder)

---

## Step 1: Create a TLS Secret

You can either use the provided `secret-tls.yaml` after generating base64 content, or create the secret directly with kubectl (recommended):

```bash
# Generate a self-signed cert valid for blog.local and services.local
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/CN=blog.local" \
  -addext "subjectAltName=DNS:blog.local,DNS:services.local"

# Create secret in default namespace
kubectl create secret tls site-tls --cert=tls.crt --key=tls.key
```

This creates a secret named `site-tls`.

---

## Step 2: Apply Gateway and HTTPRoute

```bash
kubectl apply -f gateway-tls.yaml
kubectl apply -f httproute-tls.yaml
```

- `gateway-tls.yaml` exposes an HTTPS listener (443) and allows routes from the same namespace.
- `httproute-tls.yaml` attaches to the Gateway and routes by hostname to `jeevi-blog` and `jeevi-services`.

---

## Step 3: Access from local machine

Find the NodePort of the Gateway Service (Envoy example):

```bash
kubectl get svc -n envoy-gateway-system | grep envoy-gateway
```

Assume HTTPS NodePort is `32443` and Node IP is the master (e.g., `192.168.56.10`). Since we have no DNS, use `curl --resolve` to map hostnames:

```bash
# Blog
curl -k --resolve blog.local:32443:192.168.56.10 https://blog.local:32443/

# Services
curl -k --resolve services.local:32443:192.168.56.10 https://services.local:32443/
```

- `-k` skips certificate verification (self-signed).
- Replace IP and NodePort with yours.

Optional: add entries to `/etc/hosts` in your host OS for `blog.local` and `services.local`, then browse at `https://blog.local:<nodeport>/`.

---

## Cleanup

```bash
kubectl delete -f httproute-tls.yaml
kubectl delete -f gateway-tls.yaml
kubectl delete secret site-tls
```
