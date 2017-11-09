# Ceph Helm
Authors: Hee Won Lee <knowpd@research.att.com> and Yu Xiang <yxiang@research.att.com>    
Created on 10/1/2017  
Adapted for Ubuntu 16.04 and Ceph Luminous  
Based on <https://github.com/ceph/ceph-container/tree/master/examples/helm>  
 
### Install Ceph Monitor

We assume that you have a [Kubeadm managed Kubernetes](../../../install-kubeadm) 1.7+ cluster. 
In addition, the Kubernetes cluster should have at least two nodes because ceph-mon and ceph-mon-check use a same port number (6789).

1. Preparation (from the master node of your K8s cluster)  
Unless you create a Kuberentes cluster, create one by:  
<https://github.com/att/netarbiter/tree/master/sds/install-kubeadm>

```
# Prepare helm and tiller
./install-helm.sh
helm init                    # or helm init --upgrade
helm serve &

# Prepare a ceph namespace in your K8s cluster
./prep-ceph-ns.sh
```

2. Run ceph-mon, ceph-mgr, ceph-mon-check, and rbd-provisioner (from the master node of your K8s cluster)
- Usage [[1](#notes)]:
```
# For helm-release-name, dash (-) is allowed, but underscore (_) is not.
# For public_network and cluster_network, refer to [1].
./helm-install-ceph.sh <helm-release-name> <public_network> <cluster_network>

# Example:
#   Use your VMs' internal network for AWS, GCE, etc.
./helm-install-ceph.sh ceph 172.31.0.0/20 172.31.0.0/20

# To reinstall, first delete the helm release.
helm delete <helm-release-name>
```

- Test
```
# To list your helm release
helm ls

# To check the pod status of ceph-mon, ceph-mgr, ceph-mon-check, and rbd-provisioner
# Note: the  status is not "RUNNING", then check if necessary ports are open [2].
kubectl get pods -n ceph

# To check if health status is HEALTH_OK/HEALTH_WARN 
kubectl -n ceph exec -it ceph-mon-0 -- ceph -s
```

### Install OSDs
You need this procedure for each OSD.

1. Preparation (from the master/worker nodes of your K8s cluster where OSDs will run)
   * For each osd device, you should zap/erase/destroy the device's partition table and contents.
   ```
   sudo apt install -y ceph
   sudo ceph-disk zap <osd_device>
   ```
   * If you use a separate SSD journal, you should prepare for the journal disk partitions.
   ```
   ./diskpart.sh <dev> <part_size> <part_num> <num_of_parts> [typecode]
   
   # Example: Create 8 journal partitions each with the size of 10GiB in /dev/sdb.
   ./diskpart.sh /dev/sdb 10 1 8 ceph-journal 
   ```

2. Add an OSD (from the master node of your K8s cluster)
- Usage:
```
./helm-install-ceph-osd.sh <hostname> <osd_device>
```

- Example:
   - bluestore:
   ```
   ./helm-install-ceph-osd.sh yourhostname /dev/sdc
   ```

   - filestore
   ```
   OSD_FILESTORE=1 ./helm-install-ceph-osd.sh yourhostname /dev/sdc
   ```

   - filestore with journal (recommended for production environment)
   ```
   OSD_FILESTORE=1 OSD_JOURNAL=/dev/sdb1 ./helm-install-ceph-osd.sh yourhostname /dev/sdc
   ```

- Test
```
# To check the pod status of ceph-osd
kubectl get pods -n ceph

# To check if your osds are up
kubectl -n ceph exec -it ceph-mon-0 -- ceph -s
kubectl -n ceph exec -it ceph-mon-0 -- ceph osd tree
```

3. Delete an OSD (from the master node of your K8s cluster)
```
# From your helm chart, find an OSD chart that you want to delete
helm ls

# Delete the OSD chart
helm delete <osd-chart-name>

# Find and remove the OSD from crushmap
kubectl -n ceph exec -it ceph-mon-0 -- ceph osd tree
./remove-osd.sh ceph <osd_id>
```
   
### Namespace Activation

To use Ceph Volumes in a namespace, a secret containing the Client Key needs to be present. For details, refer to [PERSISTENTVOLUME.md](./PERSISTENTVOLUME.md).

You can activate Ceph for a namespace by running:
```
./activate-namespace.sh default
```

where `default` is the name of the namespace you wish to use Ceph volumes in.


### Additional Configuration for Dynamic Provisioning

Kubernetes >=v1.6 makes RBAC the default admission controller. We does not currently have RBAC roles and permissions for each
component, so you need to relax the access control rules:
```
kubectl replace -f relax-rbac-k8s1.8.yaml
# Note: for Kubernetes 1.7, use relax-rbac-k8s1.7.yaml instead.
```
You need to have the K8s nodes setup to access the cluster network, and `/etc/resolv.conf` would be similar to the following [3]:
```
$ cat /etc/resolv.conf
nameserver 10.96.0.10           # K8s DNS IP
nameserver 135.207.240.13       # External DNS IP; You would have a different IP.
search ceph.svc.cluster.local svc.cluster.local cluster.local client.research.att.com research.att.com
```
   - You may replace K8s nodes' `/etc/resolv.conf` with `/etc/resolv.conf` of a ceph-mon pod (e.g., ceph-mon-0):
   ```
   kubectl -n ceph exec -it ceph-mon-0 -- cat /etc/resolv.conf
   ```
   - This step allows K8s nodes to use the DNS service (i.e., kubedns) of your Kubernetes cluster. That is, you can run `ping ceph-mon`. When creating an rbd device (e.g., /dev/rbd0), kubelet executes `rbd map ...` that connects to ceph-mon by domain name `ceph-mon`.

### Functional Testing
Once Ceph deployment has been performed you can functionally test the environment by running the jobs in the tests directory.
```
# Create a pool from a ceph-mon pod (e.g., ceph-mon-0):
kubectl -n ceph exec -it ceph-mon-0 -- ceph osd pool create rbd 100 100

# When mounting a pvc to a pod, you may encounter dmesg errors as follows: 
#    libceph: mon0 172.31.8.199:6789 feature set mismatch
#    libceph: mon0 172.31.8.199:6789 missing required protocol features
# Avoid them by running the following from a ceph-mon pod:
kubectl -n ceph exec -it ceph-mon-0 -- ceph osd crush tunables legacy

# Create a pvc and check if the pvc status is "Bound"
kubectl create -f tests/ceph/pvc.yaml
kubectl get pvc ceph-test

# Attach the pvc to a job
kubectl create -f tests/ceph/job.yaml

# Check if the job is successful (i.e., 1)
kubectl get jobs ceph-test-job
kubectl describe job ceph-test-job
```

### Use Cases
Refer to [USECASES.md](./USECASES.md)

### Troubleshoot
Refer to [TROUBLESHOOT.md](./TROUBLESHOOT.md)

### Notes
[1] For the public and cluster network setup, refer to http://docs.ceph.com/docs/hammer/rados/configuration/network-config-ref.   

[2] You need to open the following ports: kubeadm (TCP 6443), kubelet healthcheck (TCP 10250), Flannel (UDP 8285/8472), Calico (TCP 179), ETCD (TCP 2379-2380), ceph-mon (TCP 6789) and ceph-osd (TCP 6800~7100), etc.   
For AWS, all ports are blocked by default, so you need to set up a security group for your VMs in order to allow all traffic for your internal network.  
For GCE, by default, incoming traffic from outside your network is blocked, while all ports are open for internal IPs. Hence, you don’t have to worry about ports when you use internal network (e.g., 10.142.0.0/20) for Ceph’s cluster and public network.  

[3] Make sure that your `/etc/resolv.conf` includes the following:
```
nameserver 10.96.0.10
search ceph.svc.cluster.local svc.cluster.local cluster.local
```
