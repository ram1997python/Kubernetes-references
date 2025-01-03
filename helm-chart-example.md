## Helm Command to Create Chart Structure

```
helm create <chart-name>
```
# Example
```
helm create my-nginx-chart
```
This command will generate a default Helm chart structure like this:
```
my-nginx-chart/
├── Chart.yaml          # Metadata about the Helm chart
├── values.yaml         # Default values for the chart
├── charts/             # Directory for chart dependencies
├── templates/          # Directory for Kubernetes YAML templates
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── _helpers.tpl    # Helper template functions
│   └── NOTES.txt       # Post-installation instructions
└── .helmignore         # Files to ignore when packaging the chart
```
## Customizing the Generated Chart
After running helm create, you can:

Edit the values.yaml file to customize default configurations.

Modify or add templates in the templates/ directory for additional Kubernetes resources.

Add dependencies in the charts/ directory if needed.

# 1. Chart.yaml
Defines the metadata of your Helm chart.
```
apiVersion: v2
name: my-nginx-chart
description: A simple Helm chart for NGINX
version: 0.1.0
appVersion: "1.21.1"

```
# 2. values.yaml
Contains default values that can be overridden during deployment.
```
replicaCount: 2

image:
  repository: nginx
  tag: "1.21.1"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  annotations: {}
  hosts:
    - host: nginx.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []

resources: {}
```
# 3. templates/deployment.yaml
Defines the Kubernetes Deployment resource.
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-nginx
  labels:
    app: {{ .Chart.Name }}
    release: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
      release: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Chart.Name }}
        release: {{ .Release.Name }}
    spec:
      containers:
      - name: nginx
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: 80

```
# 4. templates/service.yaml
Defines the Kubernetes Service resource
```
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-nginx
  labels:
    app: {{ .Chart.Name }}
    release: {{ .Release.Name }}
spec:
  type: {{ .Values.service.type }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: 80
  selector:
    app: {{ .Chart.Name }}
    release: {{ .Release.Name }}

```
# 5. templates/ingress.yaml
Defines the Kubernetes Ingress resource (optional).
```
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-nginx
  annotations:
    {{- range $key, $value := .Values.ingress.annotations }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
spec:
  rules:
  {{- range .Values.ingress.hosts }}
  - host: {{ .host }}
    http:
      paths:
      {{- range .paths }}
      - path: {{ .path }}
        pathType: {{ .pathType }}
        backend:
          service:
            name: {{ $.Release.Name }}-nginx
            port:
              number: {{ $.Values.service.port }}
      {{- end }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
  {{- range .Values.ingress.tls }}
  - hosts:
      {{- range .hosts }}
      - {{ . }}
      {{- end }}
    secretName: {{ .secretName }}
  {{- end }}
  {{- end }}
{{- end }}

```
## Deploying the Helm Chart
# Step 1: Package the Chart

Navigate to the directory containing the chart and run:

```
helm package my-nginx-chart

```
# Step 2: Install the Chart

Install the chart into your Kubernetes cluster:

```
helm install my-nginx ./my-nginx-chart
```
# Step 3: Verify Deployment
Check the resources created:

```
kubectl get all

```
# Step 4: Test the Application
Forward the service port (if no ingress is enabled):

```
kubectl port-forward svc/my-nginx-nginx 8080:80

```
