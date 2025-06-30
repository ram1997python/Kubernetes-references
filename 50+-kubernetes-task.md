## Kubernetes Task List (Expanded)

-----

🧰 **Basic Cluster Info**

1.  **Check cluster info**

      * `kubectl cluster-info`
      * *Expected Output:*
        ```
        Kubernetes control plane is running at https://192.168.56.24:6443
        CoreDNS is running at https://192.168.56.24:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
        ```

2.  **List all nodes**

      * `kubectl get nodes`
      * *Expected Output:*
        ```
        NAME      STATUS   ROLES           AGE     VERSION
        master    Ready    control-plane   5d      v1.29.2
        worker1   Ready    <none>          5d      v1.29.2
        ```

3.  **Describe a node**

      * `kubectl describe node master`
      * *Expected Output:*
        ```
        Name:           master
        Roles:          control-plane
        Capacity:
          cpu:                2
        ...
        ```

4.  **Check Kubernetes version**

      * `kubectl version --short`
      * *Expected Output:*
        ```
        Client Version: v1.29.2
        Server Version: v1.29.2
        ```

5.  **Check API resources**

      * `kubectl api-resources`
      * *Expected Output:*
        ```
        NAME                 SHORTNAMES   APIVERSION                             NAMESPACED
        pods                 po           v1                                     true
        services             svc          v1                                     true
        ...
        ```

6.  **Get detailed cluster info (client and server versions)**

      * `kubectl version`
      * *Expected Output:*
        ```
        Client Version: v1.29.2
        Kustomize Version: v5.0.4-0.20230601164736-6ce0bf390ce3
        Server Version: v1.29.2
        ```

7.  **Get a specific API resource in YAML format**

      * `kubectl get deployment nginx -o yaml`
      * *Expected Output (YAML content of the deployment):*
        ```yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: nginx
        ...
        ```

-----

📦 **Pod & Deployment Management**

8.  **List all pods**

      * `kubectl get pods`
      * *Expected Output:*
        ```
        NAME        READY   STATUS    RESTARTS   AGE
        nginx       1/1     Running   0          2m
        ```

9.  **Create a pod (imperative)**

      * `kubectl run nginx --image=nginx`
      * *Expected Output:*
        ```
        pod/nginx created
        ```

10. **Describe a pod**

      * `kubectl describe pod nginx`
      * *Expected Output:* (Detailed information about the pod including events)
        ```
        Name:         nginx
        Namespace:    default
        ...
        Status:       Running
        ...
        Events:
          Type    Reason     Age        From               Message
          ----    ------     ----       ----               -------
          Normal  Scheduled  <some>     default-scheduler  Successfully assigned default/nginx to worker1
          Normal  Pulled     <some>     kubelet            Container image "nginx" already present on machine
          Normal  Created    <some>     kubelet            Created container nginx
          Normal  Started    <some>     kubelet            Started container nginx
        ```

11. **Check pod logs**

      * `kubectl logs nginx`
      * *Expected Output:* (Logs from the nginx container)
        ```
        /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
        /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
        ...
        ```

12. **Execute command in a pod**

      * `kubectl exec -it nginx -- sh`
      * *Expected Output:* (A shell prompt inside the container)
        ```
        #
        ```

13. **Get pods with wide output (shows node, IP)**

      * `kubectl get pods -o wide`
      * *Expected Output:*
        ```
        NAME    READY   STATUS    RESTARTS   AGE   IP           NODE      NOMINATED NODE   READINESS GATES
        nginx   1/1     Running   0          3m    10.42.0.10   worker1   <none>           <none>
        ```

14. **Delete a pod**

      * `kubectl delete pod nginx`
      * *Expected Output:*
        ```
        pod "nginx" deleted
        ```

15. **Create a deployment (imperative)**

      * `kubectl create deployment web --image=nginx`
      * *Expected Output:*
        ```
        deployment.apps/web created
        ```

16. **Scale a deployment**

      * `kubectl scale deployment web --replicas=3`
      * *Expected Output:*
        ```
        deployment.apps/web scaled
        ```

17. **Get deployments**

      * `kubectl get deployments`
      * *Expected Output:*
        ```
        NAME   READY   UP-TO-DATE   AVAILABLE   AGE
        web    3/3     3            3           5m
        ```

18. **Update deployment image**

      * `kubectl set image deployment/web nginx=nginx:1.21`
      * *Expected Output:*
        ```
        deployment.apps/web image updated
        ```

19. **Roll back a deployment**

      * `kubectl rollout undo deployment web`
      * *Expected Output:*
        ```
        deployment.apps/web rolled back
        ```

20. **Check deployment rollout status**

      * `kubectl rollout status deployment/web`
      * *Expected Output:*
        ```
        Waiting for deployment "web" rollout to finish: 2 of 3 updated replicas are available...
        deployment "web" successfully rolled out
        ```

21. **View deployment history**

      * `kubectl rollout history deployment/web`
      * *Expected Output:*
        ```
        deployment.apps/web
        REVISION  CHANGE-CAUSE
        1         <none>
        2         <none>
        ```

22. **Pause a deployment rollout**

      * `kubectl rollout pause deployment/web`
      * *Expected Output:*
        ```
        deployment.apps/web paused
        ```

23. **Resume a paused deployment rollout**

      * `kubectl rollout resume deployment/web`
      * *Expected Output:*
        ```
        deployment.apps/web resumed
        ```

24. **Delete a deployment**

      * `kubectl delete deployment web`
      * *Expected Output:*
        ```
        deployment.apps "web" deleted
        ```

-----

☁️ **Services & Networking**

25. **Expose a deployment as a service (ClusterIP)**

      * `kubectl expose deployment web --port=80 --type=ClusterIP`
      * *Expected Output:*
        ```
        service/web exposed
        ```

26. **List services**

      * `kubectl get svc`
      * *Expected Output:*
        ```
        NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
        kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP        5d
        web          ClusterIP   10.100.0.10    <none>        80/TCP         1m
        ```

27. **Port forward to a pod**

      * `kubectl port-forward pod/nginx 8080:80` (Run in a separate terminal)
      * *Expected Output:*
        ```
        Forwarding from 127.0.0.1:8080 -> 80
        Forwarding from [::1]:8080 -> 80
        ```
      * *Verification:* Open `http://localhost:8080` in your browser.

28. **Create a NodePort service**

      * `kubectl expose deployment web --type=NodePort --port=80`
      * *Expected Output:*
        ```
        service/web exposed
        ```

29. **Describe a service**

      * `kubectl describe svc web`
      * *Expected Output:* (Detailed service information including endpoints)
        ```
        Name:                     web
        Namespace:                default
        ...
        Type:                     ClusterIP
        IP Family Policy:         SingleStack
        IP Families:              IPv4
        IP:                       10.100.0.10
        IPs:                      10.100.0.10
        Port:                     <unset>  80/TCP
        TargetPort:               80/TCP
        ...
        Endpoints:                10.42.0.11:80,10.42.0.12:80,10.42.0.13:80
        ```

30. **Access a service via ClusterIP (from inside cluster)**

      * `kubectl exec -it <some-pod-name> -- curl http://web`
      * *Expected Output:* (HTML content of the Nginx welcome page)
        ```html
        <!DOCTYPE html>
        <html>
        <head>
        <title>Welcome to nginx!</title>
        ...
        ```

31. **Check NodePort for a service**

      * `kubectl get svc web -o jsonpath='{.spec.ports[0].nodePort}'`
      * *Expected Output:* (A random port number, e.g., `30080`)
        ```
        30080
        ```

32. **Delete a service**

      * `kubectl delete svc web`
      * *Expected Output:*
        ```
        service "web" deleted
        ```

-----

🔐 **Config & Secrets**

33. **Create a config map from literal values**

      * `kubectl create configmap app-config --from-literal=ENV=dev --from-literal=LOG_LEVEL=info`
      * *Expected Output:*
        ```
        configmap/app-config created
        ```

34. **Get config maps**

      * `kubectl get configmap`
      * *Expected Output:*
        ```
        NAME               DATA   AGE
        app-config         2      30s
        kube-root-ca.crt   1      5d
        ```

35. **Describe a config map**

      * `kubectl describe configmap app-config`
      * *Expected Output:*
        ```
        Name:         app-config
        Namespace:    default
        Labels:       <none>
        Annotations:  <none>

        Data
        ====
        ENV:          dev
        LOG_LEVEL:    info
        Events:       <none>
        ```

36. **Create a secret from literal values**

      * `kubectl create secret generic db-secret --from-literal=username=admin --from-literal=password=supersecret`
      * *Expected Output:*
        ```
        secret/db-secret created
        ```

37. **Get secrets**

      * `kubectl get secret`
      * *Expected Output:*
        ```
        NAME                  TYPE                                  DATA   AGE
        db-secret             Opaque                                2      1m
        default-token-xxxxx   kubernetes.io/service-account-token   3      5d
        ```

38. **Describe a secret**

      * `kubectl describe secret db-secret`
      * *Expected Output:*
        ```
        Name:         db-secret
        Namespace:    default
        Labels:       <none>
        Annotations:  <none>

        Type:  Opaque

        Data
        ====
        password:  8 bytes
        username:  5 bytes
        ```

39. **Mount config/secret in pod (via YAML)**

      * *YAML (example `pod-with-config.yaml`):*
        ```yaml
        apiVersion: v1
        kind: Pod
        metadata:
          name: my-app-pod
        spec:
          containers:
          - name: my-app
            image: alpine/git
            command: ["sh", "-c", "echo ENV: $ENV; echo LOG_LEVEL: $LOG_LEVEL; echo DB_USERNAME: $DB_USERNAME; echo DB_PASSWORD: $DB_PASSWORD && sleep 3600"]
            env:
            - name: ENV
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: ENV
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: LOG_LEVEL
            envFrom:
            - secretRef:
                name: db-secret
          restartPolicy: Never
        ```
      * `kubectl apply -f pod-with-config.yaml`
      * *Expected Output:*
        ```
        pod/my-app-pod created
        ```
      * *Verification (check logs):* `kubectl logs my-app-pod`
        ```
        ENV: dev
        LOG_LEVEL: info
        DB_USERNAME: admin
        DB_PASSWORD: supersecret
        ```

40. **Delete a config map**

      * `kubectl delete configmap app-config`
      * *Expected Output:*
        ```
        configmap "app-config" deleted
        ```

41. **Delete a secret**

      * `kubectl delete secret db-secret`
      * *Expected Output:*
        ```
        secret "db-secret" deleted
        ```

-----

📁 **Volumes & Storage**

42. **List PersistentVolumeClaims (PVCs)**

      * `kubectl get pvc`
      * *Expected Output:* (If no PVCs, `No resources found in default namespace.`)
        ```
        NAME      STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
        my-claim  Bound     pvc-49a37e1a-c0b9-4d6d-8e4a-b1e0f0c9f1e0   1Gi        RWO            standard       2m
        ```

43. **Describe a PVC**

      * `kubectl describe pvc myclaim`
      * *Expected Output:* (Detailed PVC information)
        ```
        Name:          myclaim
        Namespace:     default
        ...
        Status:        Bound
        Volume:        pvc-49a37e1a-c0b9-4d6d-8e4a-b1e0f0c9f1e0
        Capacity:      1Gi
        Access Modes:  RWO
        ...
        ```

44. **Create PVC from YAML**

      * *YAML (example `pvc.yaml`):*
        ```yaml
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: myclaim
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
          storageClassName: standard # Adjust if using a different storage class
        ```
      * `kubectl apply -f pvc.yaml`
      * *Expected Output:*
        ```
        persistentvolumeclaim/myclaim created
        ```

45. **Mount a PVC volume in a pod (via YAML)**

      * *YAML (example `pod-with-pvc.yaml`):*
        ```yaml
        apiVersion: v1
        kind: Pod
        metadata:
          name: my-app-pvc
        spec:
          containers:
          - name: my-container
            image: alpine
            command: ["sh", "-c", "echo 'Hello from PVC' > /mnt/data/test.txt && sleep 3600"]
            volumeMounts:
            - name: my-storage
              mountPath: /mnt/data
          volumes:
          - name: my-storage
            persistentVolumeClaim:
              claimName: myclaim
          restartPolicy: OnFailure
        ```
      * `kubectl apply -f pod-with-pvc.yaml`
      * *Expected Output:*
        ```
        pod/my-app-pvc created
        ```
      * *Verification:* `kubectl exec -it my-app-pvc -- cat /mnt/data/test.txt`
        ```
        Hello from PVC
        ```

46. **Use emptyDir volume in a pod (via YAML)**

      * *YAML (example `pod-with-empty-dir.yaml`):*
        ```yaml
        apiVersion: v1
        kind: Pod
        metadata:
          name: my-app-empty-dir
        spec:
          containers:
          - name: my-container
            image: alpine
            command: ["sh", "-c", "echo 'Hello from emptyDir' > /cache/data.txt && sleep 3600"]
            volumeMounts:
            - name: cache-volume
              mountPath: /cache
          volumes:
          - name: cache-volume
            emptyDir: {}
          restartPolicy: OnFailure
        ```
      * `kubectl apply -f pod-with-empty-dir.yaml`
      * *Expected Output:*
        ```
        pod/my-app-empty-dir created
        ```
      * *Verification:* `kubectl exec -it my-app-empty-dir -- cat /cache/data.txt`
        ```
        Hello from emptyDir
        ```

47. **Delete a PVC**

      * `kubectl delete pvc myclaim`
      * *Expected Output:*
        ```
        persistentvolumeclaim "myclaim" deleted
        ```

-----

🚦 **Monitoring & Debugging**

48. **Check component statuses**

      * `kubectl get componentstatuses` (Note: `componentstatuses` is deprecated in newer K8s versions, but still useful for older clusters or for understanding concept)
      * *Expected Output:*
        ```
        NAME                 STATUS    MESSAGE                         ERROR
        controller-manager   Healthy   ok
        scheduler            Healthy   ok
        etcd-0               Healthy   {"health":"true","reason":""}
        ```

49. **Get events (cluster-wide)**

      * `kubectl get events --sort-by=.metadata.creationTimestamp`
      * *Expected Output:* (A list of recent cluster events)
        ```
        LAST SEEN   TYPE     REASON                    OBJECT                             MESSAGE
        5d          Normal   NodeReady                 node/master                        Node master is ready
        5d          Normal   SuccessfulAttachVolume    pod/web-xx-xx                      AttachVolume.Attach succeeded for volume "pvc-..."
        ...
        ```

50. **Watch pod logs (tailing)**

      * `kubectl logs -f nginx` (Assuming `nginx` pod exists)
      * *Expected Output:* (Continuous stream of logs from the `nginx` pod)
        ```
        ...
        2025/06/30 13:30:00 [notice] 1#1: start worker processes
        ...
        ```

51. **Dry run a deployment (client-side)**

      * `kubectl create deployment test --image=nginx --dry-run=client -o yaml`
      * *Expected Output:* (YAML output of the deployment that *would* be created, but isn't)
        ```yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          creationTimestamp: null
          labels:
            app: test
          name: test
        spec:
          replicas: 1
          selector:
            matchLabels:
              app: test
          strategy: {}
          template:
            metadata:
              creationTimestamp: null
              labels:
                app: test
            spec:
              containers:
              - image: nginx
                name: nginx
                resources: {}
        status: {}
        ```

52. **Top node (requires metrics-server)**

      * `kubectl top nodes`
      * *Expected Output:*
        ```
        NAME      CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
        master    100m         5%     1000Mi          20%
        worker1   50m          2%     500Mi           10%
        ```

53. **Top pod (requires metrics-server)**

      * `kubectl top pod nginx`
      * *Expected Output:*
        ```
        NAME    CPU(cores)   MEMORY(bytes)
        nginx   1m           5Mi
        ```

54. **Debug a pod (ephemeral containers - Kubernetes 1.25+)**

      * `kubectl debug -it <pod-name> --image=ubuntu --target=<container-name>` (Replace `<container-name>` if your pod has multiple containers)
      * *Expected Output:* (A shell prompt inside an ephemeral debug container attached to the pod's namespaces)
        ```
        #
        ```

-----

🔒 **RBAC & Access**

55. **List service accounts**

      * `kubectl get serviceaccounts`
      * *Expected Output:*
        ```
        NAME      SECRETS   AGE
        default   1         5d
        ```

56. **Create a role**

      * `kubectl create role pod-reader --verb=get,list,watch --resource=pods`
      * *Expected Output:*
        ```
        role.rbac.authorization.k8s.io/pod-reader created
        ```

57. **Create a role binding (user)**

      * `kubectl create rolebinding read-pods-for-admin --role=pod-reader --user=admin`
      * *Expected Output:*
        ```
        rolebinding.rbac.authorization.k8s.io/read-pods-for-admin created
        ```

58. **Create a role binding (service account)**

      * `kubectl create rolebinding read-pods-for-sa --role=pod-reader --serviceaccount=default:default`
      * *Expected Output:*
        ```
        rolebinding.rbac.authorization.k8s.io/read-pods-for-sa created
        ```

59. **View roles and role bindings**

      * `kubectl get roles,rolebindings`
      * *Expected Output:*
        ```
        NAME                                   AGE
        role.rbac.authorization.k8s.io/pod-reader   1m

        NAME                                                  AGE
        rolebinding.rbac.authorization.k8s.io/read-pods-for-admin   30s
        rolebinding.rbac.authorization.k8s.io/read-pods-for-sa      20s
        ```

60. **Check current context**

      * `kubectl config current-context`
      * *Expected Output:*
        ```
        minikube
        ```

61. **List all contexts**

      * `kubectl config get-contexts`
      * *Expected Output:*
        ```
        CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
        * minikube   minikube   minikube   default
                  my-cluster my-cluster my-user
        ```

62. **Switch context**

      * `kubectl config use-context minikube`
      * *Expected Output:*
        ```
        Switched to context "minikube".
        ```

-----

⚙️ **Cluster Management**

63. **Drain a node (evict pods)**

      * `kubectl drain worker1 --ignore-daemonsets --delete-emptydir-data`
      * *Expected Output:*
        ```
        node/worker1 cordoned
        evicting pod default/nginx
        ...
        node/worker1 drained
        ```

64. **Cordon a node (mark unschedulable)**

      * `kubectl cordon worker1`
      * *Expected Output:*
        ```
        node/worker1 cordoned
        ```

65. **Uncordon a node (mark schedulable)**

      * `kubectl uncordon worker1`
      * *Expected Output:*
        ```
        node/worker1 uncordoned
        ```

66. **Delete a namespace**

      * `kubectl delete namespace my-namespace`
      * *Expected Output:*
        ```
        namespace "my-namespace" deleted
        ```

67. **Create a namespace**

      * `kubectl create namespace dev`
      * *Expected Output:*
        ```
        namespace/dev created
        ```

68. **Switch active namespace**

      * `kubectl config set-context --current --namespace=dev`
      * *Expected Output:*
        ```
        Context "minikube" modified.
        ```

69. **View objects in a specific namespace**

      * `kubectl get pods -n kube-system`
      * *Expected Output:* (Pods in `kube-system` namespace)
        ```
        NAME                               READY   STATUS    RESTARTS   AGE
        coredns-xxxxxxxx-xxxxx             1/1     Running   0          5d
        etcd-master                        1/1     Running   0          5d
        ...
        ```

-----

🧪 **Advanced/Testing**

70. **Create a Job**

      * `kubectl create job pi --image=perl -- perl -Mbignum=bpi -wle 'print bpi(2000)'`
      * *Expected Output:*
        ```
        job.batch/pi created
        ```
      * *Verification:* `kubectl get job pi` and `kubectl logs job/pi` (once complete)

71. **Create a CronJob**

      * `kubectl create cronjob hello --image=busybox --schedule="*/1 * * * *" -- echo "hello from cronjob"`
      * *Expected Output:*
        ```
        cronjob.batch/hello created
        ```
      * *Verification:* `kubectl get cronjob hello` and then `kubectl get jobs` after a minute to see the job created by the cronjob.

72. **Apply a manifest (create/update declarative)**

      * `kubectl apply -f deployment.yaml` (Assuming `deployment.yaml` exists)
      * *Expected Output:*
        ```
        deployment.apps/web created
        ```
        or
        ```
        deployment.apps/web configured
        ```

73. **Edit a live resource**

      * `kubectl edit deployment web`
      * *Expected Output:* (Opens the resource in your default editor; upon saving and exiting)
        ```
        deployment.apps/web edited
        ```

74. **View all resources (across namespaces)**

      * `kubectl get all --all-namespaces`
      * *Expected Output:* (All deployments, services, pods, etc., across all namespaces)
        ```
        NAMESPACE     NAME                                           READY   STATUS    RESTARTS   AGE
        default       pod/nginx-67999889-abcde                       1/1     Running   0          5d
        kube-system   pod/coredns-xxxxxxxx-xxxxx                     1/1     Running   0          5d
        ...
        ```

75. **Force delete a pod (not recommended for production)**

      * `kubectl delete pod <pod-name> --force --grace-period=0`
      * *Expected Output:*
        ```
        warning: Immediate deletion does not wait for confirmation that the running object has been terminated. The resource may continue to run on the cluster indefinitely.
        pod "nginx" force deleted
        ```

-----
