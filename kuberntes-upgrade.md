## Upgrade k8s cluster

# check version

```
kubectl version

```
# check status

```
systemctl status kubelet

```
# get node details

```
kubectl get nodes

```
# disable scheduling pod on the node

```

kubectl cordon <nodename>

```
# check the status of node

```
kubectl get nodes

```
# Drain the node to gracefully evict existing pods, ensuring that they are rescheduled on other nodes

```
kubectl drain <nodename> --force --ignore-daemonsets --delete-emptydir-data

```

# check for the latest upgrade plan

```
sudo kubeadm upgrade plan
```
#Apply the latest upgrade to the node using kubeadm

```
sudo kubeadm upgrade apply v1.xx.xx

```
