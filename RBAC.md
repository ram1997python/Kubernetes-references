Sure! Here's a **simplified step-by-step guide** to **secure a Kubernetes cluster using RBAC**:

---

## 🔐 Secure Kubernetes with RBAC (Simple Steps)

---

### ✅ Step 1: Understand What RBAC Does

RBAC controls **who can do what** in your cluster:

* **Role** = Permissions (in a namespace)
* **RoleBinding** = Assign Role to user
* **ClusterRole** = Permissions (cluster-wide)
* **ClusterRoleBinding** = Assign ClusterRole to user

---

### ✅ Step 2: Create a Role (read-only pods in `dev` namespace)

```yaml
# role.yaml
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

Run:

```bash
kubectl apply -f role.yaml
```

---

### ✅ Step 3: Bind Role to a User

```yaml
# rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bind-pod-reader
  namespace: dev
subjects:
- kind: User
  name: dev-user         # replace with actual username
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Run:

```bash
kubectl apply -f rolebinding.yaml
```

---

### ✅ Step 4: Test Access

Run:

```bash
kubectl auth can-i list pods --as=dev-user --namespace=dev
```

---

That’s it! You’ve now:

✔️ Created a permission rule
✔️ Linked it to a user
✔️ Verified access

---

Want help customizing this for your users or service accounts?
