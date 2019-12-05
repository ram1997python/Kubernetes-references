```
Kubectl run httpd-app --image=httpd --replicas=2

--

1 kubectl sends a deployment request to the API Server.

2 The API Server notifies Controller Manager to create a deployment resource .

3 Scheduler performs scheduled tasks to distribute two replica Pods to k8s-node1 and k8s-node2.

The kubelets on 4 k8s-node1 and k8s-node2 create and run Pods on their respective nodes .

Add two points:

The configuration and current state information of the application is stored in etcd, and the kubectl get pod API Server reads the data from etcd at execution  time.

The flannel assigns an IP to each Pod. Because the service was not created, the kube-proxy is not yet involved.

--

kubectl run nginx-deployment --image=nginx:1.7.9 --replicas=2

kubectl apply -f nginx.yml

kubectl get deployment

kubectl describe deployment nginx-deployment

kubectl get replicaset

kubectl describe replicaset nginx-deployment-d5655dd9d

add label to node

Kubectl label node node1 disktype=ssd

remove label to node

Kubectl label node node1 disktype-


kubectl rolloutstatus deployment/lykops-dpm
kubectl describe deployment/lykops-dpm


kubectl api-versions


command	Explanation
Kubectl cluster-info	View cluster information
Kubectl version	        Display the kubectl command line and the version of the kube server
Kubectl api-version	Display supported API version collection
Kubectl config view	Display current kubectl configuration
Kubectl get no	        View nodes in the cluster

kubectl create secret generic mysecret --from-literal=username=admin --from-literal=password=123456

kubectl create configmap myconfigmap --from-literal=config1=xxx --from-literal=config2=yyy



$ kubectl --namespace=<insert-namespace-name-here> run nginx --image=nginx
$ kubectl --namespace=<insert-namespace-name-here> get pods
$ kubectl config set-context $(kubectl config current-context) --namespace=<insert-namespace-name-here>
# Validate it
$ kubectl config view | grep namespace:


# In a namespace
$ kubectl api-resources --namespaced=true

# Not in a namespace
$ kubectl api-resources --namespaced=false



[node1 etc]$ cat datadir-cockroachdb-0.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
  name: cockroach-pv0
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 1G
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: datadir-cockroachdb-0
    namespace: default
  hostPath:
    path: /etc
  persistentVolumeReclaimPolicy: Recycle
[node1 etc]$
    Last State:     Terminated


[node1 etc]$ cat datadir-cockroachdb-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: datadir-cockroachdb-0
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1G
  volumeName: cockroach-pv0
[node1 etc]$

Disable pod scheduling to this node

kubectl cordon <node>



kubectl taint nodes node1 key1=value1:NoSchedule
kubectl taint nodes node1 key1=value1:NoExecute
kubectl taint nodes node1 key2=value2:NoSchedule

kubectl taint nodes node1 key1:NoSchedule-
kubectl taint nodes node1 key1:NoExecute-
kubectl taint nodes node1 key2:NoSchedule-

kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80
kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1

kubectl rollout undo deployment/nginx-deployment

kubectl get deployments
kubectl get rs
kubectl get pods --show-labels


One or more containers running within a pod for enhancing the main container functionality (logger container, git synchronizer container); These are sidecar container
One or more containers running within a pod for accessing external applications/servers (Redis cluster, memcache cluster); These are called ambassador container
One or more containers running within a pod to allow access to application running within the container (Monitoring container); These are called as adapter containers

change label name

oc label pod testjdk-1-nfw58 run=modified --overwrite

create namespace

kubectl create namespace custom-namespace

delete pod on particular label
kubectl delete po -l rel=canary



$ openssl genrsa -out tls.key 2048
$ openssl req -new -x509 -key tls.key -out tls.cert -days 360 -subj
? /CN=kubia.example.com

kubectl create secret tls tls-secret --cert=tls.cert --key=tls.key



Signaling when a pod is ready to accept connections
There’s one more thing we need to cover regarding both Services and Ingresses.
You’ve already learned that pods are included as endpoints of a service if their labels
match the service’s pod selector. As soon as a new pod with proper labels is created, it
becomes part of the service and requests start to be redirected to the pod. But what if
the pod isn’t ready to start serving requests immediately?
The pod may need time to load either configuration or data, or it may need to perform
a warm-up procedure to prevent the first user request from taking too long and
affecting the user experience. In such cases you don’t want the pod to start receiving
requests immediately, especially when the already-running instances can process
requests properly and quickly. It makes sense to not forward requests to a pod that’s in
the process of starting up until it’s fully ready.

create role

kubectl create role service-reader --verb=get --verb=list --resource=services -n bar


oc project vs kubectl command

kubectl  config  view  #??kubeconfig ????
kubectl  config set-cluster  #??kubeconfig ?cluster?
kubectl  config set-credentials #??kubeconfig?user?
kubectl  config set-context  # ??kubeconfig?context??,???????????
kubectl config use-context 



---
kubernetes in action page  179

Configuring Ingress to handle TLS traffic
You’ve seen how an Ingress forwards HTTP traffic. But what about HTTPS? Let’s take
a quick look at how to configure Ingress to support TLS.
CREATING A TLS CERTIFICATE FOR THE INGRESS
When a client opens a TLS connection to an Ingress controller, the controller terminates
the TLS connection. The communication between the client and the controller
is encrypted, whereas the communication between the controller and the backend
pod isn’t. The application running in the pod doesn’t need to support TLS. For example,
if the pod runs a web server, it can accept only HTTP traffic and let the Ingress
controller take care of everything related to TLS. To enable the controller to do that,
you need to attach a certificate and a private key to the Ingress. The two need to be
stored in a Kubernetes resource called a Secret, which is then referenced in the
Ingress manifest. We’ll explain Secrets in detail in chapter 7. For now, you’ll create the
Secret without paying too much attention to it.
First, you need to create the private key and certificate:
$ openssl genrsa -out tls.key 2048
$ openssl req -new -x509 -key tls.key -out tls.cert -days 360 -subj
? /CN=kubia.example.com
Listing 5.15 Ingress exposing multiple services on different hosts
Requests for
foo.example.com will be
routed to service foo.
Requests for
bar.example.com will be
routed to service bar.
148 CHAPTER 5 Services: enabling clients to discover and talk to pods
Then you create the Secret from the two files like this:
$ kubectl create secret tls tls-secret --cert=tls.cert --key=tls.key
secret "tls-secret" created
The private key and the certificate are now stored in the Secret called tls-secret.
Now, you can update your Ingress object so it will also accept HTTPS requests for
kubia.example.com. The Ingress manifest should now look like the following listing.
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
name: kubia
spec:
tls:
- hosts:
- kubia.example.com
secretName: tls-secret
rules:
- host: kubia.example.com
http:
paths:
- path: /
backend:
serviceName: kubia-nodeport
servicePort: 80
TIP Instead of deleting the Ingress and re-creating it from the new file, you
can invoke kubectl apply -f kubia-ingress-tls.

--


kubectl set image deployment kubia nodejs=luksa/kubia:v2


---

kubectl set image deployment kubia nodejs=luksa/kubia:v4

kubectl rollout pause deployment kubia

```
