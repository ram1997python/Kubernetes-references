# Traffic Splitting (Canary) with Gateway API

This example splits traffic between a stable and canary version of the blog using `HTTPRoute` weighted backends.

- Stable: `jeevi-blog`
- Canary: `jeevi-blog-canary`
- Split: 90% stable, 10% canary

Designed for local Vagrant (1 master, 2 workers), HTTP on NodePort.

---

## Prerequisites
- Envoy Gateway installed and NodePort exposed (see parent `gateway-api/Readme.md`).
- Base stable deployments applied (or apply the provided canary + reuse stable from parent folder).

---

## Apply manifests
```bash
kubectl apply -f jeevi-blog-canary-deployment.yaml
kubectl apply -f gateway-split.yaml
kubectl apply -f httproute-split.yaml
```

---

## Find NodePort
```bash
kubectl get svc -n envoy-gateway-system | grep envoy-gateway
```
Assume Node IP `192.168.56.10` and NodePort `31080`.

---

## Test
Run multiple requests; you should occasionally see the canary content.

```bash
for i in {1..20}; do curl -s --resolve site.local:31080:192.168.56.10 http://site.local:31080/blog/ | grep -E "Jeevi|Canary"; done
```

- The canary image should serve content that mentions "Canary" to distinguish from stable.

---

## Cleanup
```bash
kubectl delete -f httproute-split.yaml
kubectl delete -f gateway-split.yaml
kubectl delete -f jeevi-blog-canary-deployment.yaml
```
