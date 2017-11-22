Troubleshoot
============
Contributors:   
  - Hee Won Lee <knowpd@research.att.com>  
  - Yu Xiang <yxiang@research.att.com>   
  - Yih-Farn (Robin) Chen <chen@research.att.com>   
  - Bryan Sullivan <bryan.sullivan@research.att.com>  

## Problem: [install-kubeadm] 'kubeadm init' fails.
- Symptom
```
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
...
[kubelet-check] It seems like the kubelet isn't running or healthy.
[kubelet-check] The HTTP call equal to 'curl -sSL http://localhost:10255/healthz' failed with error: Get http://localhost:10255/healthz: dial tcp [::1]:10255: getsockopt: connection refused.
```

- Solution:   
(src: https://github.com/kubernetes/kubernetes/issues/53333 )

```
sudo iptables -F
sudo swapoff -a
sudo free -m
sudo kubeadm reset
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

### Problem: Fails to join a node
- Symptom
```
$ sudo kubeadm join --token 461371.ebfd9fbf7569cfa9 135.207.240.41:6443
...
[discovery] Failed to connect to API Server "135.207.240.41:6443": there is no JWS signed token in the cluster-info ConfigMap. This token id "461371" is invalid for this cluster, can't connect
```

- Solution: From the master node, find a correct token by:
```
sudo kubeadm token list
```

### Problem: Kubernetes kube-dns pod is pending, when running a single vcpu VM in GCE.
- Symptom
```
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                        READY     STATUS    RESTARTS   AGE
kube-system   calico-etcd-rt7l2                           1/1       Running   0          45m
kube-system   calico-node-wxqqb                           2/2       Running   0          45m
kube-system   calico-policy-controller-59fc4f7888-4bs2d   1/1       Running   0          45m
kube-system   etcd-hlee-instance-2                        1/1       Running   0          45m
kube-system   kube-apiserver-hlee-instance-2              1/1       Running   0          44m
kube-system   kube-controller-manager-hlee-instance-2     1/1       Running   0          44m
kube-system   kube-dns-545bc4bfd4-g7zsg                   0/3       Pending   0          45m
kube-system   kube-proxy-q425b                            1/1       Running   0          45m
kube-system   kube-scheduler-hlee-instance-2              1/1       Running   0          44m
kube-system   tiller-deploy-7dcdcd5f64-z2t78              1/1       Running   0          43m

$ kubectl -n kube-system describe pod kube-dns-545bc4bfd4-g7zsg
...
  Warning  FailedScheduling  3m (x150 over 47m)  default-scheduler  No nodes are available that match all of the predicates: Insufficient cpu (1).

```

- Solution: Kubernetes kube-dns pod is pending  
(src: https://stackoverflow.com/questions/42222513/kubernetes-kube-dns-pod-is-pending )

### Problem: couldn’t join the original K8S cluster as the old token expired.  
- Solution: create a new token on the master node:
```
~$
 sudo kubeadm token create --description eternity --ttl 0
77d8cd.c57e28e040760db2
```
Now you can find your new token from your master node:
```
$ sudo kubeadm token list
TOKEN                     TTL         EXPIRES   USAGES                   DESCRIPTION   EXTRA GROUPS
77d8cd.c57e28e040760db2   <forever>   <never>   authentication,signing   eternity      system:bootstrappers:kubeadm:default-node-token
```
From your work node, run the following:
```
$ sudo kubeadm join --token 77d8cd.c57e28e040760db2 10.142.0.2:6443
```
