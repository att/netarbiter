# Kubeadm-managed Kubernetes
Author: Hee Won Lee <knowpd@research.att.com> and Yu Xiang <yxiang@research.att.com>  
Created on: 9/12/2017

## Master node
1. Install docker, kubectl, kubelet, and kubeadm
```
./install-docker
./install-kubectl  
./install-kubelet-kubeadm
```

2. Initialize the master node
```
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

3. Follow the instruction from the output of `kubeadm init` as follows:
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Put aside the last line for worker node.
# You will have a token and IP address different from:
#    kubeadm join --token 461371.ebfd9fbf7569cfa9 135.207.240.41:6443
```

3. Install Calico
```
kubectl apply -f http://docs.projectcalico.org/v2.4/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
```

4. If you want to schedule pods in the master node, run the following:
```
kubectl taint nodes --all node-role.kubernetes.io/master-
```


## Worker node
1. Install docker, kubelet, and kubeadm
```
install-docker
install-kubelet-kubeadm
```

2. Join the K8s cluster.
The command would be similar to the following:
```
sudo kubeadm join --token 461371.ebfd9fbf7569cfa9 135.207.240.41:644
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

