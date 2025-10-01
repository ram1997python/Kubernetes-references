# Deploy IaC-Quiz to Kubernetes with NGINX Ingress (NodePort)

This guide builds the Flask quiz app Docker image, deploys it to Kubernetes, and exposes it via NGINX Ingress using NodePort for a local Vagrant cluster (1 master, 2 workers).

---

## 1) Build and push the Docker image
From the `IaC-quiz/` folder:

```bash
# Build
DOCKER_USER=<your-dockerhub-username>
docker build -t $DOCKER_USER/iac-quiz:latest .

# Push
docker push $DOCKER_USER/iac-quiz:latest
```

Update the Deployment image in `k8s/deployment.yaml`:
```yaml
image: <your-dockerhub-username>/iac-quiz:latest
```

---

## 2) Install NGINX Ingress Controller
If you don’t have an Ingress controller yet, install it (cloud/static manifest variant), then patch to NodePort for local cluster access:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml

# Wait for pods
kubectl get pods -n ingress-nginx -w

# Patch service to NodePort
kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec": {"type": "NodePort"}}'
```

---

## 3) Deploy the quiz app
Apply the app manifests in any namespace (default used here):

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

Check resources:
```bash
kubectl get deploy,svc,ingress
```

---

## 4) Find NodePort and test
Get NodePort of the Ingress controller service:

```bash
kubectl get svc -n ingress-nginx | grep ingress-nginx-controller
```

Example output:
```
ingress-nginx-controller   NodePort   10.101.0.123   <none>   80:31286/TCP,443:31443/TCP   10m
```

If port 80 maps to NodePort `31286` and your master/worker IP is `192.168.56.10`, access the app:

```bash
curl http://192.168.56.10:31286/
# or open in a browser: http://192.168.56.10:31286/
```

The root path (`/`) should show the quiz name capture page.

---

## 5) Troubleshooting
- Ensure Ingress pods are running: `kubectl get pods -n ingress-nginx`
- Describe the Ingress to see events/errors: `kubectl describe ingress iac-quiz`
- Check app Pod logs: `kubectl logs deploy/iac-quiz`
- Confirm Service endpoints: `kubectl get endpoints iac-quiz -o wide`

---

## 6) Cleanup
```bash
kubectl delete -f k8s/ingress.yaml
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml
```
