## Retrive the way to add a node

Get a kubeadm token on k8s-master:

$ TOKEN=`sudo kubeadm token list | grep authentication | awk '{print $1}'`
$ echo $TOKEN
c3cf19.89e62945a88d7a91
If you cannot get a token, need to recreate with:

$ sudo kubeadm token create
Get a discovery token on k8s-master:

$ DISCOVERY_TOKEN=`openssl x509 -pubkey \
-in /etc/kubernetes/pki/ca.crt | openssl rsa \
-pubin -outform der 2>/dev/null | openssl dgst \
-sha256 -hex | sed 's/^.* //'`
$ echo $DISCOVERY_TOKEN
b3bb83c24673649bf1909e9144929a64569b1a7988df97323a9a3449c3b4c1e6
Get an endpoint on k8s-master:

$ ENDPOINT=`cat admin.conf | grep server | sed s@"    server: https://"@@`
$ echo $ENDPOINT
192.168.1.105:6443
Use the token and the discovery token on k8s-node to add a new node on the node:

# TOKEN=c3cf19.89e62945a88d7a91
# DISCOVERY_TOKEN=b3bb83c24673649bf1909e9144929a64569b1a7988df97323a9a3449c3b4c1e6
# ENDPOINT=192.168.1.105:6443
#
# kubeadm join --token ${TOKEN} ${ENDPOINT} \
--discovery-token-ca-cert-hash sha256:${DISCOVERY_TOKEN}
