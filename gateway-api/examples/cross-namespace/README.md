# Cross-namespace Routing with ReferenceGrant

This example shows how an `HTTPRoute` in one namespace can route to Services in other namespaces using `ReferenceGrant`.

Topology (namespaces):
- `platform` — hosts the `Gateway`
- `apps` — hosts the `HTTPRoute`
- `blog-ns` — hosts `jeevi-blog` Service/Deployment
- `services-ns` — hosts `jeevi-services` Service/Deployment

The `ReferenceGrant`s live in the target Service namespaces (`blog-ns` and `services-ns`) to allow the `apps` namespace to reference their Services.

---

## Steps

1) Create namespaces and base objects
```bash
kubectl apply -f namespaces.yaml
kubectl apply -f blog-deploy-svc.yaml
kubectl apply -f services-deploy-svc.yaml
```

2) Create Gateway (in `platform`)
```bash
kubectl apply -f gateway-crossns.yaml
```

3) Allow cross-namespace backend references
```bash
kubectl apply -f referencegrants.yaml
```

4) Create HTTPRoute (in `apps`)
```bash
kubectl apply -f httproute-crossns.yaml
```

---

## Test

Find NodePort of the Gateway Service (Envoy example):
```bash
kubectl get svc -n envoy-gateway-system | grep envoy-gateway
```
Assume Node IP `192.168.56.10`, NodePort `31080`.

```bash
# Blog
curl --resolve site.local:31080:192.168.56.10 http://site.local:31080/blog/

# Services
curl --resolve site.local:31080:192.168.56.10 http://site.local:31080/services/
```

---

## Cleanup
```bash
kubectl delete -f httproute-crossns.yaml
kubectl delete -f referencegrants.yaml
kubectl delete -f gateway-crossns.yaml
kubectl delete -f services-deploy-svc.yaml
kubectl delete -f blog-deploy-svc.yaml
kubectl delete -f namespaces.yaml
```
