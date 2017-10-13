# Install Kubernetes by `kubeadm`
Author: Hee Won Lee <knowpd@research.att.com>
Created on 9/12/2017

## In master node:
```
install-docker
install-kubectl  
install-kubelet-kubeadm
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
kubeadm-init-thereafter
```
## In worker node:
```
install-docker
install-kubelet-kubeadm
sudo kubeadm join --token 8ed09e.07990953c22fb689 135.207.240.41:6443
```

Cleanup
=======
(src: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#tear-down )

## In master node:

Reset all kubeadm installed state:
```
kubeadm reset
```

## In worker node:
Talking to the master with the appropriate credentials, run:
```
kubectl drain <node name> --delete-local-data --force --ignore-daemonsets
kubectl delete node <node name>
kubeadm reset
```

Trouble-shoot
=============
* Fails to join a node
   1. Symptom
   ```
   $ sudo kubeadm join --token 461371.ebfd9fbf7569cfa9 135.207.240.41:6443
   ...
   [discovery] Failed to connect to API Server "135.207.240.41:6443": there is no JWS signed token in the cluster-info ConfigMap. This token id "461371" is invalid for this cluster, can't connect
   ```
   2. Solution: From the master node, find a corrent token by:
   ```
   sudo kubeadm token list
   ```

