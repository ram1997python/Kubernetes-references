
# What *Is* `containerd`?

**`containerd`** is an **industry-standard container runtime** used by Kubernetes and Docker to manage containers efficiently.

---

### ✅ Key Features of `containerd`:

| Feature             | Description                                                |
| ------------------- | ---------------------------------------------------------- |
| 🧠 Core Runtime     | Manages container lifecycle: create, start, stop, delete   |
| 📦 Image Management | Pull, unpack, manage container images                      |
| 🛠 OCI Compliant    | Uses Open Container Initiative (OCI) image & runtime specs |
| 🔌 CRI Compatible   | Works with Kubernetes via the Container Runtime Interface  |
| 📡 Remote API       | Exposes gRPC API for container operations                  |
| ⚙️ Used By          | Docker, Kubernetes, CRI-O alternatives, AWS Fargate, etc.  |

---

### 🏗 Architecture Overview

```
Kubernetes
   ↓
CRI (Container Runtime Interface)
   ↓
containerd
   ↓
runc
   ↓
Linux namespaces & cgroups
```

---

### 🖥 Tools Used With `containerd`

| Tool       | Purpose                                                        |
| ---------- | -------------------------------------------------------------- |
| `ctr`      | Low-level CLI for containerd                                   |
| `crictl`   | CRI CLI used by Kubernetes admins                              |
| `runc`     | Low-level container runtime used by containerd                 |
| `buildkit` | Used for building images (containerd doesn’t do this directly) |

---




## 🧱 What They Are

| Feature | **Docker**                         | **containerd**                         |
| ------- | ---------------------------------- | -------------------------------------- |
| Type    | Full container platform            | Lightweight container runtime daemon   |
| Scope   | High-level CLI + runtime + builder | Low-level container runtime only       |
| Origin  | Developed by Docker, Inc.          | Extracted from Docker, donated to CNCF |

---

## 🧪 What Each One Does

| Task                        | Docker | containerd                |
| --------------------------- | ------ | ------------------------- |
| Pull images                 | ✅      | ✅                         |
| Build images (`Dockerfile`) | ✅      | ❌ (use `buildkit`)        |
| Run containers              | ✅      | ✅                         |
| CLI (`docker`, `ctr`)       | ✅      | ✅ (via `ctr` or `crictl`) |
| Manages volumes/networks    | ✅      | ❌                         |
| Uses containerd internally  | ✅      | N/A                       |

> 🔧 Docker internally **uses containerd** as its runtime layer.

---

## 🧩 Component Relationship

```bash
Docker CLI
   ↓
Docker Engine (dockerd)
   ↓
containerd
   ↓
runc
```

`containerd` is **embedded inside Docker**, but can run **independently** without Docker.

---

## 🐳 Docker Is a Complete Platform

Includes:

* CLI (`docker`)
* Image builder
* Registry support
* Networking
* Volumes
* Compose support

Use Docker when:

* You're building, testing, and running containers **locally**
* You need features like **Docker Compose**, build tools, or registry integration

---

## 🔧 containerd Is for Production & Kubernetes

Includes:

* Runtime
* Image puller
* Storage management
* No build system
* Faster, minimal footprint

Use containerd when:

* You're deploying containers in **Kubernetes**
* You want a **lightweight, efficient runtime**
* You **don’t need build** or advanced CLI features

---

## 🧠 In Kubernetes Context

* Kubernetes **does not use Docker directly** anymore (since v1.24+)
* It uses **containerd** via the **CRI interface**
* Tools like `crictl` or `ctr` are used to interact with containerd in K8s

---

## 📝 Summary Table

| Feature                 | Docker                  | containerd       |
| ----------------------- | ----------------------- | ---------------- |
| Full container platform | ✅                       | ❌                |
| Supports Kubernetes CRI | ❌ (deprecated)          | ✅                |
| Used in Kubernetes      | ❌ (removed after v1.24) | ✅                |
| Build container images  | ✅                       | ❌ (use BuildKit) |
| Lightweight and fast    | ❌                       | ✅                |
| CLI Tool                | `docker`                | `ctr`, `crictl`  |
| Good for Dev/Local use  | ✅                       | 🚫               |
| Good for Production/K8s | 🚫                      | ✅                |

---

## 🧪 Verify Installation

containerd --version
sudo systemctl enable --now containerd
sudo systemctl status containerd


---

`crictl` is a **CLI tool for CRI-compatible container runtimes** like `containerd`, `CRI-O`, and `Docker (via dockershim)` — it's like `docker` or `ctr`, but specifically designed for Kubernetes environments using the **Container Runtime Interface (CRI)**.

---

## ✅ Install `crictl`

### 🔹 1. Download the binary (latest release)

```bash
VERSION="v1.30.0"  # Match your Kubernetes version
curl -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/${VERSION}/crictl-${VERSION}-linux-amd64.tar.gz
```

### 🔹 2. Extract and move to `/usr/local/bin`

```bash
sudo tar -C /usr/local/bin -xzf crictl-${VERSION}-linux-amd64.tar.gz
```

### 🔹 3. Verify

```bash
crictl --version
```

---

## ⚙️ Configure `crictl` (Optional but Recommended)

Create or edit `/etc/crictl.yaml`:

### For containerd:

```yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
```

### For CRI-O:

```yaml
runtime-endpoint: unix:///var/run/crio/crio.sock
```

Then test:

```bash
crictl info
```

---

## 🧪 Common `crictl` Commands

| Task              | Command                         |
| ----------------- | ------------------------------- |
| List pods         | `crictl pods`                   |
| List containers   | `crictl ps -a`                  |
| Pull image        | `crictl pull nginx`             |
| Run container     | `crictl runp <pod-config>.json` |
| Inspect container | `crictl inspect <container-id>` |
| Stop container    | `crictl stop <container-id>`    |
| Delete container  | `crictl rm <container-id>`      |
| Logs              | `crictl logs <container-id>`    |

---

## 📂 Example: Pull and Run NGINX (low-level)

1. Create `nginx-pod.json` and `nginx-container.json` config files (can provide them if needed)
2. Run pod:

   ```bash
   crictl runp nginx-pod.json
   ```
3. Start container:

   ```bash
   crictl create <pod-id> nginx-container.json nginx-pod.json
   crictl start <container-id>
   ```

---

