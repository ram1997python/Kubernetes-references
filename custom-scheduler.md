```

 Multiple Schedulers
apiVersion: v1
kind: Pod
metadata:
  name: custom-scheduler-pod
  annotations:
    scheduler.alpha.kubernetes.io/name: custom-scheduler
spec:
  containers:
  - name: nginx-container
    image: nginx:latest

---

# Configuring Kubernetes Scheduler
# ConfigMap for custom scheduler
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-scheduler-config
  namespace: kube-system
  labels:
    component: kube-scheduler
    tier: control-plane
    k8s-app: custom-scheduler
  data:
    config.yaml: |
      apiVersion: kubescheduler.config.k8s.io/v1
      kind: KubeSchedulerConfiguration
      leaderElection:
        leaderElect: true
      clientConnection:
        kubeconfig: "/etc/kubernetes/scheduler.conf"

# Deployment of custom scheduler
apiVersion: apps/v1
kind: Deployment
metadata:
  name: custom-scheduler
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      component: custom-scheduler
  template:
    metadata:
      labels:
        component: custom-scheduler
    spec:
      containers:
      - name: kube-scheduler
        image: k8s.gcr.io/kube-scheduler:v1.27.0
        command:
        - kube-scheduler
        - --config=/etc/kubernetes/scheduler-config.yaml
        volumeMounts:
        - name: config-volume
          mountPath: /etc/kubernetes
      volumes:
      - name: config-volume
        configMap:
          name: custom-scheduler-config

```
