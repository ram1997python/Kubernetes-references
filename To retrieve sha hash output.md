### To get the sha value from Openssl command

```
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
```

Example Output:

```
root@k8s1:~# openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
c35b00989d4dc0f20b51eb38746ddd285b418934b87d608257ea4eb888a25991
root@k8s1:~# 

```
Now use the hash key to join the cluster in Kubeadm
```

kubeadm join --token 2f1a31.00f66dec74fd53f3 172.42.42.1:6443 --discovery-token-ca-cert-hash sha256:c35b00989d4dc0f20b51eb38746ddd285b418934b87d608257ea4eb888a25991

```
