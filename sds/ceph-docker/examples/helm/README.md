# Ceph Helm
Authors: Hee Won Lee <knowpd@research.att.com> and Yu Xiang <yxiang@research.att.com>    
Created on 10/1/2017  
Adapted for Ubuntu 16.04 and Ceph Luminous  
Based on https://github.com/ceph/ceph-docker/tree/master/examples/helm  

### Qucikstart

Assuming you have a [Kubeadm managed Kubernetes](../../../install-kubeadm) 1.7+ cluster, you can get going straight away! 

0. Preflight checklist
```
sudo apt install ceph-common		# for every K8s nodes
sudo apt install jq			# used in activate-namespace.sh
```

1. Install helm and tiller
```
curl -O https://storage.googleapis.com/kubernetes-helm/helm-v2.6.1-linux-amd64.tar.gz
tar xzvf helm-v2.6.1-linux-amd64.tar.gz 
sudo cp linux-amd64/helm /usr/local/bin

helm init       # or helm init --upgrade
helm serve &
```

2. Run ceph-mon, ceph-mgr, ceph-mon-check, and rbd-provisioner 
- Preparation:   
Create a `.kube/config` secret so that a K8s job could run `kubectl` inside the container.
```
kubectl create namespace ceph
./create-secret-kube-config.sh ceph
```

- Usage [[1](#Notes)]:   
```
./helm-install-ceph.sh <release_name> <public_network> <cluster_network>

# Example
./helm-install-ceph.sh my_ceph_chart 172.31.0.0/20 172.31.0.0/20
```

3. Run ceph-osd
- Preparation:  
   * For each osd device, you should zap/erase/destroy the device's partition table and contents.
   ```
   ceph-disk zap <osd_device>
   ```
   * If you use a separate SSD journal, you should prepare for the journal disk partitions.
   ```
   ./diskpart.sh <dev> <part_size> <part_num> <num_of_parts> [typecode]
   
   # Example: Create 8 journal partitions each with the size of 10GiB in /dev/sdb.
   ./diskpart.sh /dev/sdb 10 1 8 ceph-journal 
   ```

- Usage:
```
./helm-install-ceph-osd.sh <hostname> <osd_device>
```

- Example:
   - bluestore:
   ```
   ./helm-install-ceph-osd.sh myhostname /dev/sdc
   ```

   - filestore
   ```
   OSD_FILESTORE=1 ./helm-install-ceph-osd.sh myhostname /dev/sdc
   ```

   - filestore with journal (recommended for production environment)
   ```
   OSD_FILESTORE=1 OSD_JOURNAL=/dev/sdb1 ./helm-ceph-osd.sh myhostname /dev/sdc
   ```
   
### Namespace Activation

To use Ceph Volumes in a namespace a secret containing the Client Key needs to be present.

Once defined you can then activate Ceph for a namespace by running:
```
./activate-namespace.sh default
```

Where `default` is the name of the namespace you wish to use Ceph volumes in.


### Additional Configuration for Dynamic Provisioning

Kubernetes >=v1.6 makes RBAC the default admission controller. We does not currently have RBAC roles and permissions for each
component, so you need to relax the access control rules:
```
# For Kubernetes 1.6 and 1.7
kubectl replace -f relax-rbac-k8s1.7.yaml

# For Kubernetes 1.8+
kubectl replace -f relax-rbac-k8s1.8.yaml
```
You need to have the K8s nodes setup to access the cluster network, and `/etc/resolv.conf` would be similar to the following:
```
$ cat /etc/resolv.conf
nameserver 10.96.0.10           # K8s DNS IP
nameserver 135.207.240.13       # External DNS IP; You would have a different IP.
search ceph.svc.cluster.local svc.cluster.local cluster.local client.research.att.com research.att.com
```
   - You may replace K8s nodes' `/etc/resolv.conf` with `/etc/resolv.conf` in a ceph-mon pod (e.g., ceph-mon-0) by Ctrl-C & Ctrl-V.
   - This step allows K8s nodes to use the DNS service (i.e., kubedns) of your Kubernetes cluster. That is, you can run `ping ceph-mon.ceph`. When creating an rbd device (e.g., /dev/rbd0), kubelet executes `rbd map ...` that connects to ceph-mon by domain name `ceph-mon.ceph`.

### Functional Testing
Once Ceph deployment has been performed you can functionally test the environment by running the jobs in the tests directory.
```
# Create a pool from a ceph-mon pod (e.g., ceph-mon-0):
ceph osd pool create rbd 100 100

# When mounting a pvc to a pod, you may encounter dmesg errors as follows: 
#    libceph: mon0 172.31.8.199:6789 feature set mismatch
#    libceph: mon0 172.31.8.199:6789 missing required protocol features
# Avoid them by running the following from a ceph-mon pod:
ceph osd crush tunables legacy

# Create a pvc and attach it to a job:
kubectl create -R -f tests/ceph
```

### Troubleshoot
Refer to [TROUBLESHOOT.md](./TROUBLESHOOT.md)

### [Notes]
[1] For the public and cluster network setup, refer to http://docs.ceph.com/docs/hammer/rados/configuration/network-config-ref.
