Troubleshoot
============
Author: Hee Won Lee <knowpd@research.att.com> and Yu Xiang <yxiang@research.att.com> 
Created on : 10/1/2017 

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
kubeadm reset
add "Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"" to /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet
kubeadm init --pod-network-cidr=192.168.0.0/16 --skip-preflight-checks


### Problem: Fails to join a node
- Symptom
```
$ sudo kubeadm join --token 461371.ebfd9fbf7569cfa9 135.207.240.41:6443
...
[discovery] Failed to connect to API Server "135.207.240.41:6443": there is no JWS signed token in the cluster-info ConfigMap. This token id "461371" is invalid for this cluster, can't connect
```
- Solution: From the master node, find a corrent token by:
```
sudo kubeadm token list
```
