# Simple Monitoring Stack with Prometheus and Grafana using Helm

This guide will walk you through deploying a monitoring stack in Kubernetes using Helm, with Prometheus for metrics collection and Grafana for visualization.

## Prerequisites
- A running Kubernetes cluster
- `kubectl` configured to access your cluster
- Helm installed (we'll cover this in Step 1)

## Step 1: Install Helm

First, let's install Helm on your local machine:

```bash
# Download and install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Verify installation
helm version
```

## Step 2: Add Prometheus and Grafana Helm Repositories

```bash
# Add the stable Helm repository (contains Prometheus and Grafana charts)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# Update your local Helm chart repository cache
helm repo update
```

## Step 3: Install Prometheus

We'll install Prometheus first with some customizations to make it easier to access:

```bash
# Create a dedicated namespace for monitoring
kubectl create namespace monitoring

# Install Prometheus with NodePort service for access
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.service.type=NodePort \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set alertmanager.enabled=false
```

This command:
- Creates a new namespace called "monitoring"
- Installs the kube-prometheus-stack (which includes Prometheus and related components)
- Configures Prometheus service as NodePort for external access
- Disables Alertmanager to keep things simple

## Step 4: Verify Prometheus Installation

```bash
# Check the pods
kubectl get pods -n monitoring

# Check the services
kubectl get svc -n monitoring
```

Look for the `prometheus-operated` service with type NodePort.

## Step 5: Install Grafana

Now let's install Grafana with some default configurations:

```bash
# Install Grafana with NodePort service and default credentials
helm install grafana grafana/grafana \
  --namespace monitoring \
  --set service.type=NodePort \
  --set adminPassword=admin \
  --set persistence.enabled=false
```

This command:
- Installs Grafana in the same monitoring namespace
- Sets the service type to NodePort for external access
- Sets the admin password to "admin" (change this in production!)
- Disables persistence for simplicity (data will be lost if pod restarts)

## Step 6: Access Grafana

First, let's find out how to access Grafana:

```bash
# Get the NodePort for Grafana
kubectl get svc -n monitoring grafana -o jsonpath='{.spec.ports[0].nodePort}'
echo ""
```

This will output a port number (e.g., 32321). You can access Grafana at:
`http://<your-node-ip>:<node-port>`

Alternatively, you can use port-forwarding:

```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
```

Then access Grafana at http://localhost:3000

Login with:
- Username: admin
- Password: admin

## Step 7: Configure Prometheus as a Data Source in Grafana

1. After logging in to Grafana, click on the gear icon (Configuration) in the left sidebar
2. Select "Data Sources"
3. Click "Add data source"
4. Choose "Prometheus"
5. For the URL, enter: `http://prometheus-operated:9090` (this is the internal service name)
6. Click "Save & Test" - you should see a green "Data source is working" message

## Step 8: Import a Pre-built Kubernetes Dashboard

1. In Grafana, click the "+" icon in the left sidebar
2. Select "Import"
3. Enter the dashboard ID `3119` (this is a popular Kubernetes dashboard)
4. Click "Load"
5. Select the Prometheus data source you created earlier
6. Click "Import"

You should now see a comprehensive Kubernetes dashboard with cluster metrics!

## Step 9: (Optional) Access Prometheus UI Directly

If you want to access the Prometheus UI directly:

```bash
# Get the NodePort for Prometheus
kubectl get svc -n monitoring prometheus-operated -o jsonpath='{.spec.ports[0].nodePort}'
echo ""
```

Access it at `http://<your-node-ip>:<node-port>`

## Step 10: Understanding RBAC Components

The Helm charts automatically set up the necessary RBAC (Role-Based Access Control) components. You can inspect them:

```bash
# View service accounts
kubectl get serviceaccounts -n monitoring

# View roles
kubectl get roles -n monitoring

# View role bindings
kubectl get rolebindings -n monitoring

# View cluster roles (some are cluster-scoped)
kubectl get clusterroles | grep monitoring
```

## Cleanup (When Needed)

If you want to remove the monitoring stack:

```bash
helm uninstall grafana -n monitoring
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
```

## Conclusion

You now have a complete monitoring stack running in your Kubernetes cluster:
- Prometheus is collecting metrics from your cluster
- Grafana is visualizing these metrics with a pre-built dashboard
- All components are properly secured with RBAC

You can explore more dashboards in the Grafana dashboard repository (https://grafana.com/grafana/dashboards/) by importing them with their IDs.