# Kubeadm-managed Kubernetes
Contributors:
   - Hee Won Lee <knowpd@research.att.com>  
   - Yu Xiang <yxiang@research.att.com> 

## Updates
- 01/10/2018: Upgraded Calico version from v2.6 to v3.0
   * Modified files:  common-functions.sh
   * Kubernetes version 1.9+ requires this update. Without this update, you may encounter status `ContainerCreating` for your kube-dns container.

## Install
### In master node:
1. Assuming you are in a clean state (i.e., no docker, kubectl, kubelet, or kubeadm), install a master node by:  
```
./install-masternode-calico.sh latest
# Note:
#   - Instead of `latest`, you can install a specific Kubernetes version (e.g., 1.7.5-00, 1.8.2-00, etc).
#     Find available versions at:
#     https://packages.cloud.google.com/apt/dists/kubernetes-xenial/main/binary-amd64/Packages
#
#   - If you install K8s on AWS, GCE or Azure, you may encounter a nameserver issue with Calico [1].
#     Different from Calico (based on L3), Flannel (based on L2)  works without any additional 
#     configuration. Instead of Calico, you can use flannel by:
#     ./install-masternode-flannel.sh latest

# To check if your master node is "Ready"
#   (it may take a minute to get to the "Ready" status)
kubectl get nodes

# To check if all pods are "Running" [2]
kubectl get pods --all-namespaces
```

2. From the output of `./install-masternode-calico.sh latest`, put aside a line similar to the following:
```
# For Kubernetes v1.7 or less
kubeadm join --token 19b3d3.2a94bdb1d53c9515 10.150.0.6:6443

# For Kubernetes v1.8+
kubeadm join --token 19b3d3.2a94bdb1d53c9515 10.150.0.6:6443 --discovery-token-ca-cert-hash sha256:e61a4ab6c6506d75061c813f4f6826e6d7bdec5aee1bc801ecf15c8ca0ac5ab1

# Note: this will be used later when a new worker node joins the K8s cluster.
```

### In worker node:
1. Install docker, kubelet, and kubeadm
```
./install-workernode.sh latest
# In your master node, if you have used a specific Kubernetes version instead of `latest`, you should use it here.
```

2. Join the K8s cluster.
```
sudo kubeadm join --token <token_string> <master_node_ip>:6443
# You can readily get this from the output of `./install-masternode-calico.sh latest`.

# To check if a new worker node is "Ready"
kubectl get nodes
```
- You can also find your token string by running `sudo kubeadm token list` from the master node.

## Delete a worker node from your K8s cluster 
(src: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#tear-down )  
In the master node
```
kubectl drain <node_name> --delete-local-data --force --ignore-daemonsets
kubectl delete node <node_name>
```

## Uninstall (for re-install)
In master/work nodes, run:
```
./uninstall.sh
```

## (Optional) Install helm  
In the master node, install the helm client
```
# install the helm client
./install-helm.sh

# Install tiller (the helm serverside component) in the currently-running Kubernetes
helm init                    # or helm init --upgrade

# Start a local chart repository server that serves charts from a local directory
#   By default, it will scan all of the charts in '$HELM_HOME/repository/local' 
#   and serve those over the local IPv4 TCP port (default '127.0.0.1:8879').
helm serve &
```

To delete and reinstall tiller
```
kubectl delete deployment tiller-deploy --namespace kube-system
helm init
```


## Troubleshoot   

Refer to [TROUBLESHOOT.md](./TROUBLESHOOT.md)

### Note
[1] To check if pods can connect to Kubedns (nameserver 10.96.0.10), you can take the following steps:
```
# Create two pods
kubectl create -f ktest.yaml

# Get two pods, each of which will run in different K8s nodes
kubectl get pods -o wide

# Check if two pods can connect to the nameserver 
kshell <pod1>
root@pod1:/# nslookup google.com
kshell <pod2>
root@pod2:/# nslookup google.com
```
When deploying Calico and Kubernetes on AWS and GCE, refer to   
<https://docs.projectcalico.org/v2.0/getting-started/kubernetes/installation/aws> and   
<https://docs.projectcalico.org/v2.0/getting-started/kubernetes/installation/gce> respectively.  
For Azure, it is unknown whether Calico works there.

[2] If you are installing on a single vcpu VM, the kube-dns pod is likely to be a "Pending" status due to insufficient cpu. To make it "Running", you need to install a mster node on a 2+ vcpu VM; or you may add 1+ work nodes later.

