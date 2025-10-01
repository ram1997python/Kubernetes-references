# Host-based and Path-based Routing with Gateway API

This example shows:
- Host-based routing: `blog.local` → blog, `services.local` → services
- Path-based routing (single host): `site.local/blog` → blog, `site.local/services` → services

Designed for local Vagrant (1 master, 2 workers). Uses HTTP on NodePort for easy testing.

---

## Prerequisites
- Envoy Gateway installed and Gateway service patched to NodePort (see parent `gateway-api/Readme.md`).
- Images pushed and base Deployments/Services applied: `jeevi-blog`, `jeevi-services`.

---

## Apply manifests

Choose one style at a time to avoid route overlap.

### Option A: Host-based routing
```bash
kubectl apply -f gateway-hosts.yaml
kubectl apply -f httproute-hosts.yaml
```

### Option B: Path-based routing (single host)
```bash
kubectl apply -f gateway-paths.yaml
kubectl apply -f httproute-paths.yaml
```

---

## Find NodePort
```bash
kubectl get svc -n envoy-gateway-system | grep envoy-gateway
```
Assume Node IP is `192.168.56.10` and NodePort is `31080`.

---

## Test — Host-based
```bash
# Blog
curl --resolve blog.local:31080:192.168.56.10 http://blog.local:31080/

# Services
curl --resolve services.local:31080:192.168.56.10 http://services.local:31080/
```

## Test — Path-based (single host)
```bash
# Blog
curl --resolve site.local:31080:192.168.56.10 http://site.local:31080/blog/

# Services
curl --resolve site.local:31080:192.168.56.10 http://site.local:31080/services/
```

---

## Cleanup
```bash
kubectl delete -f httproute-hosts.yaml --ignore-not-found
kubectl delete -f gateway-hosts.yaml --ignore-not-found
kubectl delete -f httproute-paths.yaml --ignore-not-found
kubectl delete -f gateway-paths.yaml --ignore-not-found
```
