
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

Perfect 👍 Now let’s continue with **Module 4: Storage & Scheduling**.
This module covers *storage management, scheduling strategies, and special workload configurations*.

---

### 29. Storage Management

**Question:** How does Kubernetes handle storage management?

**Answer:**
Kubernetes abstracts storage the same way it abstracts compute. It allows pods to use **persistent storage** independent of the underlying hardware (local disk, NFS, cloud storage).

* **Persistent Volumes (PV):** Define storage resources in the cluster.
* **Persistent Volume Claims (PVC):** Pods request storage through claims.
* **Storage Classes:** Automate dynamic provisioning of volumes.

**Example:**
A developer requests a 10Gi volume in a PVC → Kubernetes binds it to an available PV or creates one dynamically.

---

### 30. Creating Persistent Volume (PV)

**Question:** What is a Persistent Volume, and how do you create one?

**Answer:**
A **Persistent Volume (PV)** is a piece of storage in the cluster provisioned by an admin. It exists independently of pods.

**Example (YAML):**

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-example
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data
```

This PV provides **5Gi storage** on the node’s `/mnt/data` directory.

---

### 31. Persistent Volume Claim (PVC)

**Question:** How does a Persistent Volume Claim work?

**Answer:**
A **PVC** is a user’s request for storage. Kubernetes finds a PV that matches the request and binds it.

**Example (YAML):**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-example
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

If a PV with ≥ 2Gi exists, Kubernetes binds it to this claim. The pod then mounts the PVC.

---

### 32. Manual Scheduling

**Question:** How can you manually schedule a pod to a specific node?

**Answer:**
You can use the **`nodeName`** field in the Pod spec.

**Example (YAML):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: manual-pod
spec:
  nodeName: worker-node1
  containers:
  - name: nginx
    image: nginx
```

This forces the pod to run on `worker-node1`.

---

### 33. Labels & Selectors

**Question:** What are Labels and Selectors in Kubernetes?

**Answer:**

* **Labels:** Key-value pairs attached to objects (e.g., `app=nginx`).
* **Selectors:** Used to filter resources by label.

**Example:**
A Deployment labels its pods with `app=nginx`. A Service uses a selector `app=nginx` to route traffic only to those pods.

```yaml
selector:
  matchLabels:
    app: nginx
```

---

### 34. Taints & Tolerations

**Question:** What are Taints and Tolerations in Kubernetes?

**Answer:**

* **Taint (Node property):** Marks a node to repel pods.
* **Toleration (Pod property):** Allows a pod to be scheduled on tainted nodes.

This ensures only specific pods run on certain nodes (e.g., GPU workloads).

**Example:**

```bash
kubectl taint nodes node1 gpu=true:NoSchedule
```

Only pods with a matching toleration can run on `node1`.

---

### 35. Node Selector

**Question:** How does NodeSelector work?

**Answer:**
NodeSelector is the simplest way to constrain pods to nodes with specific labels.

**Example (YAML):**

```yaml
spec:
  nodeSelector:
    disktype: ssd
```

This pod will only schedule on nodes labeled `disktype=ssd`.

---

### 36. Node Affinity

**Question:** What is Node Affinity, and how is it different from NodeSelector?

**Answer:**

* **NodeSelector:** Basic equality match (`key=value`).
* **Node Affinity:** More expressive; allows `In`, `NotIn`, `Exists` operators and **preferred** vs **required** rules.

**Example (YAML):**

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: disktype
          operator: In
          values:
          - ssd
```

---

### 37. Static Pods

**Question:** What is a Static Pod?

**Answer:**
A **Static Pod** is created directly by the **kubelet** on a node, not by the API server.

* Defined in `/etc/kubernetes/manifests/`
* Always tied to a specific node
* Often used for critical system pods (like kube-apiserver itself)

**Example:** If kube-apiserver dies, kubelet automatically recreates it because it’s defined as a static pod.

---

### 38. Multiple Schedulers

**Question:** Can Kubernetes run multiple schedulers?

**Answer:**
Yes. Kubernetes supports running multiple schedulers. You can define which scheduler a pod should use in the Pod spec.

**Example (YAML):**

```yaml
spec:
  schedulerName: custom-scheduler
```

---

### 39. Configure Kubernetes Custom Scheduler

**Question:** How do you configure a custom scheduler in Kubernetes?

**Answer:**
Steps:

1. Write your custom scheduler logic (e.g., in Go).
2. Run it as a Pod in the cluster.
3. Assign pods to it using `schedulerName`.

**Use Case:** Workloads with special requirements (e.g., GPU-intensive jobs).

---

### 40. CronJobs

**Question:** What is a CronJob in Kubernetes, and when is it used?

**Answer:**
A **CronJob** schedules jobs to run periodically (like Linux `cron`).

**Example (YAML):**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello-cron
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            command: ["echo", "Hello from CronJob!"]
          restartPolicy: OnFailure
```

### 41. Resource Allocation

**Question:** What is Resource Allocation in Kubernetes?

**Answer:**
Resource allocation means **defining CPU and memory requests** for pods so that the scheduler can place them properly.

* **Request:** Minimum resource needed. Used by scheduler.
* **Limit:** Maximum resource pod can use.

**Example (YAML):**

```yaml
resources:
  requests:
    cpu: "200m"
    memory: "256Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

This pod *requests* 200 millicores & 256Mi memory, but can use up to 500m CPU & 512Mi.

---

### 42. Resource Limitation

**Question:** Why are Resource Limits important?

**Answer:**
Without limits, a single pod could **consume all node resources**, starving others.
Limits enforce fairness and cluster stability.

**Example:**

* Pod A hogs CPU = Pod B slows down.
* With limits → Pod A is throttled to its quota.

---

### 43. HPA (Horizontal Pod Autoscaler)

**Question:** What is an HPA in Kubernetes?

**Answer:**
The **Horizontal Pod Autoscaler** automatically scales the number of pod replicas based on resource usage (CPU, memory, or custom metrics).

**Example (Command):**

```bash
kubectl autoscale deployment nginx --cpu-percent=50 --min=2 --max=10
```

If CPU usage > 50%, HPA increases replicas.

---

### 44. ClusterRole

**Question:** What is a ClusterRole in Kubernetes?

**Answer:**
A **ClusterRole** defines permissions at the **cluster level**, not just a namespace.

Examples:

* View pods across all namespaces
* Manage nodes

**Example (YAML):**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

---

### 45. ClusterRoleBinding

**Question:** What is a ClusterRoleBinding?

**Answer:**
A **ClusterRoleBinding** grants a ClusterRole to a user, group, or service account.

**Example (YAML):**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-pods-global
subjects:
- kind: User
  name: jane
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Here, user `jane` can read pods in **all namespaces**.

---

### 46. RBAC (Role-Based Access Control)

**Question:** What is RBAC, and why is it used in Kubernetes?

**Answer:**
**RBAC** controls who can do what in the cluster. It defines:

* **Role/ClusterRole:** What actions are allowed.
* **RoleBinding/ClusterRoleBinding:** Who gets those permissions.

It enhances **security** by ensuring users and apps only have the permissions they need.

---

### 47. Role & RoleBinding

**Question:** How do Role and RoleBinding differ from ClusterRole and ClusterRoleBinding?

**Answer:**

* **Role:** Permissions limited to one namespace.
* **RoleBinding:** Grants that Role to users/groups in that namespace.
* **ClusterRole:** Cluster-wide permissions.
* **ClusterRoleBinding:** Cluster-wide assignment.

**Example (Role YAML):**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

---

### 48. Security Context

**Question:** What is a Security Context in Kubernetes?

**Answer:**
A **Security Context** defines security settings for a pod or container, such as:

* Run as specific user/group ID
* Linux capabilities
* Privilege settings

**Example (YAML):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-pod
spec:
  containers:
  - name: app
    image: nginx
    securityContext:
      runAsUser: 1000
      readOnlyRootFilesystem: true
```

Here, the container runs as **user 1000** and has a **read-only filesystem**.

---

Perfect 👍 Now we’re entering **Module 6: Networking & Ingress**.
This module is about how pods talk to each other, how Kubernetes secures networking, and how apps are exposed externally.

---

### 49. Network Namespaces

**Question:** What is a Network Namespace in Kubernetes?

**Answer:**
A **Network Namespace** is a Linux kernel feature that provides an isolated network environment for containers. Each pod gets its **own network namespace**, but containers inside the same pod share it.

This means:

* Pods have unique IPs.
* Containers inside a pod can talk via `localhost`.

**Example:**
Two containers in the same pod (app + sidecar) can talk on `localhost:8080`.

---

### 50. Key Features of Kubernetes Networking

**Question:** What are the key features of Kubernetes networking?

**Answer:**

1. Every pod has its **own IP address**.
2. All pods in a cluster can talk to each other without NAT.
3. Containers inside the same pod share networking.
4. Services provide stable endpoints for pods.

**Example:**
Pod A (10.0.0.5) can directly connect to Pod B (10.0.0.8) without special routing.

---

### 51. Namespace Isolation in Networking

**Question:** How does Kubernetes isolate workloads using namespaces?

**Answer:**
Namespaces logically separate resources (pods, services, configs). By default, networking is open between namespaces, but **NetworkPolicies** can enforce isolation.

**Example:**

* `dev` namespace pods cannot reach `prod` namespace pods if a NetworkPolicy is applied.

---

### 52. Understanding Pod Networking

**Question:** How do pods communicate inside a cluster?

**Answer:**

* Each pod gets an IP from the cluster’s **CNI plugin** (Flannel, Calico, Weave).
* Pods can talk to each other directly.
* Services + kube-proxy route traffic when pod IPs change.

**Example:**
`curl http://10.0.0.12:80` → connects directly to another pod.

---

### 53. Network Policy

**Question:** What is a Network Policy, and why is it important?

**Answer:**
A **Network Policy** controls which pods can communicate with each other (like a firewall for pods).

By default: **all pods can talk to all pods**.
With policies: you can restrict traffic.

**Example (YAML):** Allow traffic only from pods with label `role=frontend` to `role=db`.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
spec:
  podSelector:
    matchLabels:
      role: db
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
```

---

### 54. Docker Network Model

**Question:** How does Docker networking relate to Kubernetes?

**Answer:**

* **Docker:** Provides `bridge`, `host`, `overlay` networks.
* **Kubernetes:** Uses CNI plugins instead of Docker’s default networking.

Kubernetes networking is more advanced since it ensures pod-to-pod communication across nodes.

**Example:**

* Docker container gets `172.17.0.2`.
* Kubernetes pod gets `10.244.0.2`.
  But both rely on **network namespaces** underneath.

---

### 55. Kubernetes Ingress

**Question:** What is an Ingress in Kubernetes?

**Answer:**
Ingress manages **HTTP/HTTPS access** to services inside the cluster.
It works with an **Ingress Controller** (like NGINX, Traefik).

Benefits:

* Host-based routing (`app1.example.com`, `app2.example.com`).
* Path-based routing (`/api → backend`, `/ui → frontend`).
* TLS termination.

**Example (YAML):**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  rules:
  - host: myapp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

---

### 56. Kubernetes Gateway API

**Question:** What is the Kubernetes Gateway API?

**Answer:**
The **Gateway API** is the next-generation alternative to Ingress.
It provides:

* More flexibility (supports TCP, UDP, HTTP).
* Better separation of roles (infra team manages gateways, app team manages routes).
* Standard API across vendors.

**Example Use Case:** Cloud providers (AWS, GCP, Azure) are adopting Gateway API for traffic management.

---

### 57. Ingress vs Gateway API

**Question:** How does Ingress differ from the Gateway API?

**Answer:**

* **Ingress:** Focused on HTTP/HTTPS only. Limited flexibility.
* **Gateway API:** Supports multiple protocols (TCP, UDP, TLS, HTTP). More extensible.

**Analogy:**
Ingress = Simple “main gate.”
Gateway API = Full-featured “security checkpoint” with lanes for cars, trucks, pedestrians.

---

### 58. Demanding Scenario (Networking Challenge)

**Question:** Imagine you have a frontend in `namespace=dev` and a backend in `namespace=prod`. How would you secure communication so only the frontend can reach the backend?

**Answer:**

1. Create a **NetworkPolicy** in `prod` that only allows traffic from pods in `dev`.
2. Optionally, use **Ingress + TLS** to secure external communication.
3. Ensure backend service is not exposed publicly.

**Example (Policy YAML):**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-allow-dev
  namespace: prod
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: dev
```








