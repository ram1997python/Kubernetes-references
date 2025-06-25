## ETCD backup and Restore


# Create a namespace
```
kubectl create ns test

```
# Run a Pod in the Created Namespace
```
kubectl run mypod --image=nginx -n test

```
# Check the Pods in the Namespace
```
kubectl get pods -n test
```
# Take the ETCD Backup and restore

```
Centos
sudo yum install etcd -y

### https://snapcraft.io/install/etcd/rhel  -- use snap

Ubuntu
sudo apt-get install etcd-client
```

# Switch to root user
```
sudo su -

```
# Take backup

```
ETCDCTL_API=3 etcdctl \
--endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /tmp/etcd.db

```
# Delete nameserver

```
kubectl delete ns test

```
# check the backup process
```
ETCDCTL_API=3 etcdctl \
--endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot status /tmp/etcd.db
```
# stop kubelet

```
systemctl stop kubelet
```
```
ETCDCTL_API=3 etcdctl \
--endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot restore /tmp/etcd.db

```
# Remove the contents of directory andf move etcd data to kubernetes environment

```
rm -rf /var/lib/etcd/member

```
```
mv default.etcd/member /var/lib/etcd

```
# reboot the server

```
reboot
```
# verify the restore environem

```
kubectl get pods -n test

```
 
