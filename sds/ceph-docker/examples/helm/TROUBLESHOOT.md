Troubleshoot
============
Author: Hee Won Lee <knowpd@research.att.com>  
Created on : 10/1/2017  


### Problem: tiller issue
- Symptom
```
$ helm install ./ceph
Error: no available release name found
```

- Solution: https://stackoverflow.com/questions/43499971/helm-error-no-available-release-name-found
```
$ kubectl create serviceaccount --namespace kube-system tiller
serviceaccount "tiller" created
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
clusterrolebinding "tiller-cluster-rule" created
$ kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
deployment "tiller-deploy" patched
```

### Problem: failure of job.yaml
- Symptom
```
# bash ./ceph-keys.sh 
...
+ kubectl get --namespace default secrets ceph-client-admin-keyring
Error from server (Forbidden): User "system:serviceaccount:default:default" cannot get secrets 
in the namespace "default". (get secrets ceph-client-admin-keyring)
```

- Solution: Container should be able to run kubectl
   1. In job.yaml, add the followings:
   ```
       volumeMounts:
         - name: kubeconfig                          # HLEE: added
           mountPath: /root/.kube/config             # HLEE: added
           subPath: admin.conf                       # HLEE: added
           readOnly: true                            # HLEE: added
   volumes:
     - name: kubeconfig                              # HLEE: added
       secret:                                       # HLEE: added
         secretName: kubeconfig                      # HLEE: added
   ```
   2. Create a secret for kubeconfig as follows:
   ```
   sudo kubectl create secret generic kubeconfig --from-file=/etc/kubernetes/admin.conf
   ```

### Problem: ceph-mon does not work.
- Symptom
```
+start_mon.sh:136: start_mon(): ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-rbd/ceph.keyring
can't open /var/lib/ceph/bootstrap-rbd/ceph.keyring: can't open /var/lib/ceph/bootstrap-rbd/ceph.keyring: (2) No such file or directory
```

- Solution: Create a secret of ceph-bootstrap-rbd-keyring and use it in mon/statefulset.yaml.  
The files that should be modified are as follows: 
   - jobs/configmap.yaml
   - jobs/job.yaml
   - mon/statefulset.yaml.

### Problem: PVC Pending with "executable file not found in $PATH"
- Symptom
```
$ kubectl get pvc
NAME        STATUS    VOLUME    CAPACITY   ACCESSMODES   STORAGECLASS   AGE
ceph-test   Pending                                      general        9m

$ kubectl describe pvc ceph-test
Name:           ceph-test
Namespace:      default
StorageClass:   general
Status:         Pending
Volume:
Labels:         <none>
Annotations:    volume.beta.kubernetes.io/storage-class=general
                volume.beta.kubernetes.io/storage-provisioner=kubernetes.io/rbd
Capacity:
Access Modes:
Events:
  FirstSeen     LastSeen        Count   From                            SubObjectPath   Type            Reason                  Message
  ---------     --------        -----   ----                            -------------   --------        ------                  -------
  7m            2s              32      persistentvolume-controller                     Warning         ProvisioningFailed      Failed to provision volume with StorageClass "general": failed to create rbd image: executable file not found in $PATH, command output: 
```

- Solution   
Modify ceph/templates/storageclass.yaml as follows:   
From:
```
provisioner: kubernetes.io/rbd
```
To:
```
provisioner: ceph.com/rbd
```

### Problem: PVC Pending with "waiting for a volume to be created"
- Symptom
```
$ kubectl get pvc
NAME        STATUS    VOLUME    CAPACITY   ACCESSMODES   STORAGECLASS   AGE
ceph-test   Pending    

$ kubectl describe pvc ceph-test
Name:           ceph-test
Namespace:      default
StorageClass:   general
Status:         Pending
Volume:
Labels:         <none>
Annotations:    volume.beta.kubernetes.io/storage-class=general
                volume.beta.kubernetes.io/storage-provisioner=ceph.com/rbd
Capacity:
Access Modes:
Events:
  FirstSeen     LastSeen        Count   From                            SubObjectPath   Type            Reason                  Message
  ---------     --------        -----   ----                            -------------   --------        ------                  -------
  47s           1s              5       persistentvolume-controller                     Normal          ExternalProvisioning    waiting for a volume to be created, either by external provisioner "ceph.com/rbd" or manually created by system administrator
```

- Solution: Run a rbd-provisioner pod in the namespace of "ceph"  
(src: https://github.com/kubernetes/kubernetes/issues/38923 )  
(src: https://github.com/kubernetes-incubator/external-storage/tree/master/ceph/rbd )  

### Problem: Failure of attaching a volume using PVC 
- Symptom
```
$ kubectl get pods
NAME                                     READY     STATUS              RESTARTS   AGE
mypod-deploy-4058341149-gj97h   0/1       ContainerCreating   0          7m

$ kubectl describe pod mypod-deploy-4058341149-gj97h
...
Events:
  FirstSeen     LastSeen        Count   From                    SubObjectPath   Type            Reason                  Message
  ---------     --------        -----   ----                    -------------   --------        ------                  -------
  27s           27s             1       default-scheduler                       Normal          Scheduled               Successfully assigned kubectl-ubnt16-deploy-4058341149-gj97h to voyager1
  26s           26s             1       kubelet, voyager1                       Normal          SuccessfulMountVolume   MountVolume.SetUp succeeded for volume "default-token-z6gvr"
  26s           9s              6       kubelet, voyager1                       Warning         FailedMount             MountVolume.SetUp failed for volume "pvc-63e7fc39-add8-11e7-855a-d4ae52a3acc1" : rbd: image kubernetes-dynamic-pvc-6cb96404-add8-11e7-a387-eaccdc8b6118 is locked by other nodes
```

- Solution
You may encounter dmesg errors as follows:
```
libceph: mon0 172.31.8.199:6789 feature set mismatch
libceph: mon0 172.31.8.199:6789 missing required protocol features
```
Avoid them by running the following from a ceph-mon pod:
```
ceph osd crush tunables legacy
```

### Problem: Failure of attaching a PVC to a pod
- Symptom  
When mouting a rbd volume, kubelet would try to run "rbd map ..." of a Kubernetes node.
However, the host machine cannot solve the IP of ceph-mon.ceph.
```
$ journalctl -l -ru kubelet
Oct 11 10:23:12 voyager1 kubelet[7211]: I1011 10:23:12.555829    7211 rbd_util.go:141] lock list output "2017-10-11 10:23:12.484558 7f13b80ef100 -1 did not load config file, using default settings.\nserver name not found: ceph-mon.ceph (Name or ser
```

For the debugging purpose, you can see the same output by running 'rbd ls' as follows:
```
$ rbd ls -m ceph-mon.ceph
2017-10-11 14:29:39.242028 7fd2ab8b7100 -1 did not load config file, using default settings.
server name not found: ceph-mon.ceph (Name or service not known)
unable to parse addrs in 'ceph-mon.ceph'
rbd: couldn't connect to the cluster!
```

- Solution 1: Temporary  
```
$ kubectl -n ceph exec -it ceph-mon-0 -- cat /etc/resolv.conf 
nameserver 10.96.0.10
search ceph.svc.cluster.local svc.cluster.local cluster.local client.research.att.com research.att.com
```
Set up each Kubernetes node's /etc/resov.conf as above.
 
- Solution 2: Permanent   
Set up each Kubernetes node's /etc/network/interfaces as follows:
```
auto enp66s0f0
iface enp66s0f0 inet static
  address 10.10.0.12
  netmask 255.255.255.0
  network 10.10.0.0
  dns-nameserver 10.96.0.10						### ADD THIS LINE
  dns-search ceph.svc.cluster.local svc.cluster.local cluster.local	### ADD THIS LINE
```
And then, restart networking as follows:
```
$ /etc/init.d/networking restart
```

### Problem: Failure of attaching a PVC to a pod
- Symptom:   
If ceph-test-job fails and you see the error “rbd: map failed exit status 110 rbd: sysfs write failed” in the output of “kubectl describe pods --namespace default”.

- Solution:  
```
kubectl -n ceph exec -it ceph-mon-0 -- ceph osd crush tunables legacy
```
If this is not working for you, try to replace “legacy” with “hammer” or “optimal”.


### Problem: after attaching pvc, a new rbd device is not shown as /dev/rbd0
- Solution: reload udevadm rules  
(src: https://unix.stackexchange.com/questions/39370/how-to-reload-udev-rules-without-reboot )  
```
sudo udevadm control --reload-rules && udevadm trigger 
```

### Problem:
- Symptom
```
$ kubectl describe pod ceph-mon-0 -n ceph
  Warning  FailedScheduling  3m (x26 over 10m)  default-scheduler  No nodes are available that match all of the predicates: PodFitsHostPorts (1).
```

- Solution  
This problem occurs when running a K8s cluster with a single VM in GCE.  
You should use at least two nodes in a K8s cluster because ceph-mon and ceph-mon-check use a same port number (6789).

### Problem:
- Symptom
If you encounter the message below:
```
Forbidden 403: User "system:serviceaccount:kube-system:default" cannot list pods in the namespace in
"default". (get pods)
```

- Solution: Run the following:
```
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
```

### Problem [AWS]:
- Symptom  
Forbidden 403: User "system:serviceaccount:kube-system:default" cannot list pods in the namespace "default". (get pods)

- Solution  
(src: https://github.com/kubernetes/dashboard/issues/1800 )  
```
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
```

### Bug Fix
(src: https://stackoverflow.com/questions/15540635/what-is-the-use-of-pipe-symbol-in-yaml )

In Kubernetes 1.8.0, jobs.yaml fails to create a secret-generator-deployment pod.
This is due to a bug in configmap.yaml. Please fix two lines as follows:

In https://raw.githubusercontent.com/ceph/ceph-docker/master/examples/helm/ceph/templates/jobs/configmap.yaml,
```
          cat <<EOF
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: ${KUBE_SECRET_NAME}
    type: Opaque
    data:
      ${CEPH_KEYRING_NAME}: |                                               ### BUG: "|" should be removed
        $( kube_ceph_keyring_gen ${CEPH_KEYRING} ${CEPH_KEYRING_TEMPLATE} )
    EOF

          cat <<EOF
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: ${KUBE_SECRET_NAME}
    type: kubernetes.io/rbd
    data:
      key: |                                                                ### BUG: "|" should be removed
        $( echo ${CEPH_KEYRING} | base64 | tr -d '\n' )
    EOF
        } | kubectl create --namespace {{ .Release.Namespace }} -f -
      fi
    }
```

### Debugging: Creating an rbd device manually

```
# To check if there exists a pool named “rbd”
kubectl -n ceph exec -it ceph-mon-0 -- ceph osd lspools

# To list rbd images
kubectl -n ceph exec -it ceph-mon-0 -- rbd ls

# Now, try to manually create an rbd device as follows:
kubectl -n ceph exec -it ceph-mon-0 -- rbd create --size 4096 --pool rbd vol01
kubectl -n ceph exec -it <your_osd_pod> -- rbd map vol01 --pool rbd

# To check if an rbd device is created
kubectl -n ceph exec -it <your_osd_pod> -- ls -al /dev/rbd0
```

###  Problem: About straw\_calc\_version 
- Symptom: For 2 nodes with 4 OSDs, Ceph health is HEALTH\_WARN.

- Solution:
```
kubectl -n ceph exec -it ceph-mon-0 -- ceph osd pool set rbd size 2
kubectl -n ceph exec -it ceph-mon-0 -- ceph osd pool application enable rbd rbd
kubectl -n ceph exec -it ceph-mon-0 -- rbd pool init rbd
kubectl -n ceph exec -it ceph-mon-0 -- ceph osd crush set-tunable straw_calc_version 1
```
Syntax: `ceph osd pool application enable <pool-name> <application-name>`




