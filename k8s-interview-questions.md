
---

## 1. What is Kubernetes?

**Question:** What is Kubernetes, and why is it used in modern application deployment?

**Answer:**
Kubernetes (often abbreviated as *K8s*) is an **open-source container orchestration platform** developed by Google and now maintained by the Cloud Native Computing Foundation (CNCF). It helps automate **deployment, scaling, and management of containerized applications**.

Instead of manually starting/stopping containers, Kubernetes ensures applications are always running as expected—even if some nodes fail. It abstracts the underlying infrastructure (VMs, servers, cloud) and offers a **self-healing, scalable, and declarative environment** for applications.

**Example:**
Imagine you have an e-commerce app running in 10 Docker containers. If one container crashes at midnight, Kubernetes automatically restarts it—no human intervention needed.

---

## 2. Historical Context for Kubernetes

**Question:** Why was Kubernetes created, and what problem was it solving?

**Answer:**
Before Kubernetes, Google internally used a system called **Borg** to manage its massive container workloads (like Gmail, Search, and YouTube). Borg’s success inspired the creation of Kubernetes in 2014, making container orchestration available to the wider world.

The problem Kubernetes solved:

* Manual container deployment was error-prone.
* Scaling required human effort.
* Failures were not automatically handled.

Kubernetes provided a **standardized, automated way** to manage containers across clusters.

**Example:**
Without Kubernetes: A sysadmin manually starts 50 Docker containers and must restart them if they fail.
With Kubernetes: A YAML Deployment file defines “always keep 50 replicas running,” and Kubernetes enforces this automatically.

---

## 3. Kubernetes Alternatives

**Question:** Name some alternatives to Kubernetes and how they differ.

**Answer:**
While Kubernetes is the most popular, other orchestrators exist:

* **Docker Swarm** – simpler, tightly integrated with Docker, easier to learn but less feature-rich.
* **Apache Mesos + Marathon** – highly scalable, supports containers and non-containerized workloads, but more complex.
* **Nomad (by HashiCorp)** – lightweight and supports multi-cloud + non-container workloads.

**Example:**

* A startup with a few containers might prefer **Docker Swarm** for simplicity.
* Enterprises running massive data + compute jobs may consider **Mesos**.

---

## 4. Kubernetes Architecture

**Question:** Describe Kubernetes architecture at a high level.

**Answer:**
Kubernetes follows a **Master-Worker architecture**:

* **Master Node (Control Plane):** Manages the cluster (decides where workloads run, keeps state consistent).
* **Worker Nodes:** Run the actual containerized applications (pods).

Communication happens through the **kube-apiserver** as the “front door” of the cluster.

**Example Diagram (simplified):**

```
[ Master Node ]
   |-- API Server
   |-- Scheduler
   |-- Controller Manager
   |-- etcd (database)

[ Worker Nodes ]
   |-- kubelet
   |-- kube-proxy
   |-- Container Runtime (Docker/Containerd)
   |-- Pods (your apps)
```

## 5. Features of Kubernetes

**Question:** What are the key features of Kubernetes?

**Answer:**

* **Self-Healing:** Restarts failed containers automatically.
* **Horizontal Scaling:** Scale pods up/down easily.
* **Service Discovery & Load Balancing:** Assigns IPs/DNS to pods.
* **Automated Rollouts/Rollbacks:** Deploy new versions gradually, rollback if something breaks.
* **Storage Orchestration:** Mount volumes dynamically.
* **Secret & Config Management:** Store sensitive data securely.

**Example:**
During a shopping festival, traffic spikes. Kubernetes automatically scales pods from 5 → 50 to handle load.


---

## 🔹 Module 1: Core Concepts & Architecture

---

### 6. Master Node Components

**Question:** What are the main components of a Kubernetes Master Node, and what does each one do?

**Answer:**
The Master Node (Control Plane) makes decisions for the whole cluster. It includes:

1. **kube-apiserver** – The “front door” of Kubernetes. Handles REST requests (kubectl, UI, other services).
2. **etcd** – A distributed key-value database that stores the entire cluster state (like config, pod info, secrets).
3. **kube-scheduler** – Decides *where* new pods should run (which worker node).
4. **kube-controller-manager** – Runs controllers that ensure desired state (e.g., if a pod dies, bring it back).

**Example:**
If you deploy a YAML file saying “run 3 replicas,” the API server stores this in etcd, the scheduler picks nodes, and the controller ensures 3 pods are running at all times.

---

### 7. Worker Node Components

**Question:** What runs on a Worker Node in Kubernetes?

**Answer:**
Worker nodes are where application pods live. They include:

1. **kubelet** – Talks to the master, ensures pods are running on that node.
2. **kube-proxy** – Handles networking, ensures pods can talk to each other and to services.
3. **Container Runtime** – Runs the actual containers (e.g., Docker, containerd, CRI-O).

**Example:**
If a pod crashes, kubelet reports this to the master, and the master asks kubelet to restart it using the container runtime.

---

### 8. Key Components in Kubernetes

**Question:** What are the “key components” of Kubernetes at a high level?

**Answer:**

* **Control Plane** (Master): API Server, etcd, Scheduler, Controllers
* **Worker Node:** Kubelet, Kube-proxy, Container runtime
* **Add-ons:** DNS, Dashboard, Ingress controller, Monitoring

**Example:**
Think of Kubernetes like a **city**:

* Master Node = City council (decision makers)
* Worker Nodes = Districts (where citizens live = pods)
* etcd = Registry office (keeps official records)
* Scheduler = Housing authority (assigns homes)

---

### 9. kube-apiserver, etcd, kube-scheduler, kube-controller

**Question:** Can you explain kube-apiserver, etcd, kube-scheduler, and kube-controller with an example?

**Answer:**

* **kube-apiserver**: Entry point; validates and processes commands.
* **etcd**: Database; stores the cluster’s desired & current state.
* **kube-scheduler**: Finds the best node for new pods.
* **kube-controller-manager**: Ensures cluster state matches the desired state.

**Example Walkthrough:**
You apply a Deployment YAML → API server stores it in etcd → Scheduler decides which worker gets the pod → Controller checks if the pod is running → if it dies, controller creates a new one.

---

### 10. What is Container Runtime?

**Question:** What is a container runtime, and why does Kubernetes need it?

**Answer:**
A **container runtime** is the software that actually runs containers. Kubernetes itself doesn’t run containers—it asks the runtime to do it.

Popular runtimes: **Docker, containerd, CRI-O**.

**Example:**
If Kubernetes tells a node, “Start a pod with Nginx,” the kubelet uses the container runtime (say containerd) to pull the Nginx image and run the container.

---

### 11. Container Runtime Interface (CRI)

**Question:** What is the CRI in Kubernetes?

**Answer:**
The **Container Runtime Interface (CRI)** is a standard API that allows Kubernetes to talk to different container runtimes. This means Kubernetes isn’t tied to Docker—it can work with multiple runtimes as long as they implement CRI.

**Example:**
If Docker is replaced with containerd, Kubernetes doesn’t care—it still talks via CRI. This is like how your TV remote can control different brands of TVs if they all support the same IR standard.

---

Perfect 👍 Let’s continue with **Module 2: Workloads in Kubernetes**.
This section covers the *objects students will use every day* (Pods, Deployments, ReplicaSets, etc.).

---


### 12. Pod

**Question:** What is a Pod in Kubernetes?

**Answer:**
A **Pod** is the smallest deployable unit in Kubernetes. It represents one or more tightly coupled containers that share:

* Network (same IP)
* Storage (volumes)
* Lifecycle

Pods are usually **one container each**, but can hold multiple if they must run together.

**Example (YAML):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

This Pod runs a single Nginx container.

---

### 13. ReplicaSets

**Question:** What is a ReplicaSet, and how is it different from a Pod?

**Answer:**
A **ReplicaSet (RS)** ensures a specified number of Pod replicas are always running. If a pod dies, RS replaces it.

* Pod = one running instance.
* ReplicaSet = controller that maintains multiple pods.

**Example (YAML):**

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
```

This ensures **3 Nginx pods** always run.

---

### 14. StatefulSets

**Question:** What is a StatefulSet, and when is it used?

**Answer:**
A **StatefulSet** is like a ReplicaSet but for **stateful applications** that need:

* Stable, unique pod IDs (like `db-0`, `db-1`, `db-2`)
* Persistent storage (each pod keeps its volume)
* Ordered startup/shutdown

**Example Use Case:** Databases like MySQL, Cassandra, MongoDB.

**Example (concept):** If one MySQL pod restarts, StatefulSet ensures it comes back as **mysql-0** with its old storage, not a new one.

---

### 15. Deployments

**Question:** What is a Deployment in Kubernetes?

**Answer:**
A **Deployment** is the most common way to run apps in Kubernetes. It manages ReplicaSets automatically and provides:

* Rolling updates
* Rollbacks
* Scaling

**Example (YAML):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
```

This runs 3 replicas of Nginx and can be updated seamlessly.

---

### 16. Services

**Question:** What is a Service in Kubernetes, and why do we need it?

**Answer:**
Pods have dynamic IPs, so if a pod restarts, its IP changes. A **Service** provides a stable network endpoint (DNS name or ClusterIP) to access pods.

Types of Services:

* **ClusterIP (default):** Internal access only.
* **NodePort:** Exposes service on node’s port.
* **LoadBalancer:** Uses cloud load balancer (AWS, GCP, Azure).

**Example:**
You can access Nginx pods via `http://nginx-service:80` even if individual pod IPs change.

---

### 17. Service Publishing

**Question:** How do we expose a service outside the cluster?

**Answer:**
Options:

* **NodePort** → opens a port on all nodes.
* **LoadBalancer** → integrates with cloud load balancer.
* **Ingress** → exposes HTTP/HTTPS routes using domain names.

**Example:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

Now `http://<node-ip>:30080` reaches Nginx.

---

### 18. DaemonSets

**Question:** What is a DaemonSet, and when is it used?

**Answer:**
A **DaemonSet** ensures that **one pod runs on every node** (or selected nodes).

Common use cases:

* Logging agents (Fluentd, Logstash)
* Monitoring agents (Prometheus Node Exporter)
* Networking plugins (Calico, Flannel)

**Example:** If you have 5 worker nodes, DaemonSet deploys 1 pod per node automatically.

---

### 19. Volumes

**Question:** What is a Volume in Kubernetes, and how is it different from container storage?

**Answer:**

* By default, container data is **ephemeral** (deleted when pod dies).
* A **Volume** provides persistent storage to pods.

Types:

* **emptyDir** → lives as long as pod exists.
* **hostPath** → maps node’s filesystem.
* **PersistentVolume (PV)** → external storage (NFS, AWS EBS, etc.).

**Example:**
A WordPress pod can use a volume to persist uploaded images even if the pod restarts.

---

### 20. Secrets

**Question:** How does Kubernetes handle sensitive data?

**Answer:**
**Secrets** store sensitive information like passwords, API keys, TLS certs. Unlike ConfigMaps, data is base64 encoded.

**Example (YAML):**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=   # base64 for admin
  password: cGFzc3dvcmQ= # base64 for password
```

---

### 21. ConfigMap

**Question:** What is a ConfigMap in Kubernetes?

**Answer:**
A **ConfigMap** stores **non-sensitive configuration data** in key-value pairs, which pods can use as environment variables or config files.

**Example:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_MODE: "production"
  LOG_LEVEL: "debug"
```

Pods can reference these values instead of hardcoding them.

---

### 22. Namespace

**Question:** What is a Namespace in Kubernetes, and why use it?

**Answer:**
A **Namespace** is a virtual cluster inside Kubernetes. It helps organize and isolate resources.

Default namespaces:

* `default`
* `kube-system`
* `kube-public`

**Use Case:**

* Team A and Team B share the same cluster but have isolated resources in `namespace-a` and `namespace-b`.

---

### 23. Kubeconfig

**Question:** What is a Kubeconfig file?

**Answer:**
Kubeconfig is a YAML file that stores **cluster connection info**, including:

* API server address
* User credentials
* Contexts (cluster, user, namespace)

It allows `kubectl` to connect to the right cluster without retyping credentials.

**Example:** Default path = `~/.kube/config`.

---

### 24. Rolling Update

**Question:** What is a Rolling Update in Kubernetes, and why is it useful?

**Answer:**
A **Rolling Update** is the default update strategy in Deployments. Instead of stopping all old pods and starting new ones, Kubernetes **gradually replaces pods**—ensuring zero downtime.

* Old pods are terminated one by one.
* New pods are created one by one.
* At any moment, some old and some new pods coexist.

**Example:**
Updating a web app from `v1` → `v2`:

* 3 old pods (v1) running.
* Kubernetes creates 1 new pod (v2), deletes 1 old pod.
* Process repeats until all pods are `v2`.

---

### 25. Multi-Container Pod

**Question:** Can a Pod have multiple containers? If yes, why?

**Answer:**
Yes. A Pod can run multiple containers if they are **tightly coupled** and need to share network/storage.

Use cases:

* **Sidecar pattern** – one container does the main job, another provides logging, proxy, or monitoring.
* **Helper containers** – e.g., an Nginx container serving files + a sidecar container updating files.

**Example (YAML):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
  - name: log-agent
    image: busybox
    command: ["sh", "-c", "tail -f /var/log/app.log"]
```

---

### 26. Init Container

**Question:** What is an Init Container, and how does it work?

**Answer:**
An **Init Container** runs **before** the main container(s) in a pod. It’s useful for setup tasks like:

* Downloading configuration files
* Waiting for a service to be ready
* Checking database connection

**Example (YAML):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-example
spec:
  initContainers:
  - name: init-db
    image: busybox
    command: ["sh", "-c", "until nslookup mysql; do echo waiting for mysql; sleep 2; done;"]
  containers:
  - name: app
    image: myapp:1.0
```

Here, the app container won’t start until the MySQL service is reachable.

---

### 27. Liveness Probe

**Question:** What is a Liveness Probe, and why is it important?

**Answer:**
A **Liveness Probe** tells Kubernetes how to check if a container is still healthy. If the probe fails, Kubernetes **kills the container** and restarts it automatically.

Probe types:

* **HTTP check** (GET request)
* **Command execution**
* **TCP socket check**

**Example (YAML):**

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
```

This checks `/health` every 10s. If it fails → container restarts.

---

### 28. Events

**Question:** What are Events in Kubernetes, and how are they used?

**Answer:**
Events are records of **important cluster activities** (warnings, pod scheduling, failures, restarts, etc.).

They help in **troubleshooting** and monitoring.

**Command Example:**

```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```

You might see:

* Pod scheduled successfully
* Failed to pull image
* Liveness probe failed

These logs guide developers when something goes wrong.

---





