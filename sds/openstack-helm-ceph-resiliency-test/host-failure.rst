============
Host Failure
============

Case: A K8s worker node (where ceph mgr is running) is deleted
==============================================================
This is to test a scenario when a worker node is deleted from a k8s cluster. Here the k8s cluster have 4 nodes and we are removing one node where Ceph manager is running (voyager4).

.. code-block::

  $ kubectl drain voyager4 --delete-local-data --force --ignore-daemonsets
  $ kubectl delete node voyager4

Symptom: 
--------
The impact of the deleted node on the Ceph cluster is shown as below:

.. code-block::

  (ceph-mon):/# ceph osd tree 
  ID CLASS WEIGHT   TYPE NAME         STATUS REWEIGHT PRI-AFF
  -1       43.67981 root default
  -2       10.91995     host voyager1
   0   hdd  1.81999         osd.0         up  1.00000 1.00000
   1   hdd  1.81999         osd.1         up  1.00000 1.00000
   3   hdd  1.81999         osd.3         up  1.00000 1.00000
   4   hdd  1.81999         osd.4         up  1.00000 1.00000
   6   hdd  1.81999         osd.6         up  1.00000 1.00000
  24   hdd  1.81999         osd.24        up  1.00000 1.00000
  -9       10.91995     host voyager2
  14   hdd  1.81999         osd.14        up  1.00000 1.00000
  16   hdd  1.81999         osd.16        up  1.00000 1.00000
  17   hdd  1.81999         osd.17        up  1.00000 1.00000
  18   hdd  1.81999         osd.18        up  1.00000 1.00000
  19   hdd  1.81999         osd.19        up  1.00000 1.00000
  20   hdd  1.81999         osd.20        up  1.00000 1.00000
  -5       10.91995     host voyager3
   2   hdd  1.81999         osd.2         up  1.00000 1.00000
   5   hdd  1.81999         osd.5         up  1.00000 1.00000
   7   hdd  1.81999         osd.7         up  1.00000 1.00000
   8   hdd  1.81999         osd.8         up  1.00000 1.00000
  10   hdd  1.81999         osd.10        up  1.00000 1.00000
  11   hdd  1.81999         osd.11        up  1.00000 1.00000
  -7       10.91995     host voyager4
  12   hdd  1.81999         osd.12      down  1.00000 1.00000
  13   hdd  1.81999         osd.13      down  1.00000 1.00000
  15   hdd  1.81999         osd.15      down  1.00000 1.00000
  21   hdd  1.81999         osd.21      down  1.00000 1.00000
  22   hdd  1.81999         osd.22      down  1.00000 1.00000
  23   hdd  1.81999         osd.23      down  1.00000 1.00000

.. code-block::

  (ceph-mon):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              6 osds down
              1 host (6 osds) down
              no active mgr
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: no daemons active
      osd: 24 osds: 18 up, 24 in
   
    data:
      pools:   18 pools, 918 pgs
      objects: 315 objects, 980 MB
      usage:   5626 MB used, 44672 GB / 44678 GB avail
      pgs:     918 active+clean

Recovery
--------

Excute the following procedure to re-join the deleted node to k8s cluster:

1. Create a token in master node (if the original token was expired):

.. code-block::

  $ sudo kubeadm token create --description eternity --ttl 0
  $ sudo kubeadm token list

2. Use the token to re-join the k8s cluster on the worker node:

.. code-block::

  $ sudo kubeadm join --token 712081.15a0cad313a3f96c 135.207.240.41:6443 --discovery-token-unsafe-skip-ca-verification

In case you encounter the following error:

.. code-block::

  $ sudo kubeadm join --token 712081.15a0cad313a3f96c 135.207.240.41:6443 --discovery-token-unsafe-skip-ca-verification
  [preflight] Running pre-flight checks.
          [WARNING FileExisting-crictl]: crictl not found in system path
  [preflight] Some fatal errors occurred:
          [ERROR Port-10250]: Port 10250 is in use
          [ERROR FileAvailable--etc-kubernetes-pki-ca.crt]: /etc/kubernetes/pki/ca.crt already exists
          [ERROR FileAvailable--etc-kubernetes-kubelet.conf]: /etc/kubernetes/kubelet.conf already exists
  [preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`

then run:

.. code-block::

  $ sudo kubeadm reset

In case you additionally encouter the following error:

.. code-block::

  $ sudo kubeadm join --token 712081.15a0cad313a3f96c 135.207.240.41:6443 --discovery-token-unsafe-skip-ca-verification
  [preflight] Running pre-flight checks.
          [WARNING FileExisting-crictl]: crictl not found in system path
  [preflight] Some fatal errors occurred:
          [ERROR Swap]: running with swap on is not supported. Please disable swap
  [preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`

.. code-block::

  $ sudo swapoff -a    

3. Add Ceph storage and Ceph manager labels to the re-joined node:

.. code-block::

  $ kubectl label node voyager3 ceph-mon=enabled                # to add ceph-mon
  $ kubectl label node voyager4 ceph-osd=enabled                # to add ceph-osds
  $ kubectl label node voyager4 ceph-mgr=enabled                # to add ceph-mgr

4. Check if the deleted node (voyager4) is shown as ``Ready`` in k8s cluster.

.. code-block::

  $ kubectl get nodes
  NAME       STATUS    ROLES     AGE       VERSION
  voyager1   Ready     master    17d       v1.9.3
  voyager2   Ready     <none>    17d       v1.9.3
  voyager3   Ready     <none>    17d       v1.9.3
  voyager4   Ready     <none>    11m       v1.9.3

5. Check Ceph status in one of the Ceph monitors. All impacted Ceph components(mgr, osd) on the deleted node are automatically recovered.

.. code-block::

  (mon-pod):/# ceph -s
  cluster:
    id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
    health: HEALTH_WARN
            mon voyager1 is low on available space

  services:
    mon: 3 daemons, quorum voyager1,voyager2,voyager3
    mgr: voyager4(active)
    osd: 24 osds: 24 up, 24 in

  data:
    pools:   18 pools, 918 pgs
    objects: 320 objects, 971 MB
    usage:   5651 MB used, 44672 GB / 44678 GB avail
    pgs:     918 active+clean


Case: Two K8s worker nodes (where ceph-mon & ceph-mgr are running) are deleted
==============================================================================

Symptom: 
--------
.. code-block::

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              5 osds down
              1 host (6 osds) down
              no active mgr
              12/272 objects unfound (4.412%)
              Reduced data availability: 525 pgs inactive, 32 pgs down, 427 pgs peering, 46 pgs incomplete, 599 p
  gs stale
              Degraded data redundancy: 71/816 objects degraded (8.701%), 19 pgs degraded, 38 pgs undersized
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2, out of quorum: voyager3
      mgr: no daemons active
      osd: 24 osds: 12 up, 17 in; 27 remapped pgs
   
    data:
      pools:   18 pools, 918 pgs
      objects: 272 objects, 840 MB
      usage:   2951 MB used, 33505 GB / 33508 GB avail
      pgs:     57.190% pgs not active
               71/816 objects degraded (8.701%)
               12/272 objects unfound (4.412%)
               418 stale+peering
               262 active+clean
               82  stale+active+clean
               46  incomplete
               32  stale+down
               30  stale+active+undersized
               17  stale+activating
               11  active+recovery_wait+degraded
               9   stale+creating+peering
               8   stale+active+undersized+degraded
               3   stale+creating+activating

  (mon-pod):/# ceph osd tree
  ID CLASS WEIGHT   TYPE NAME         STATUS REWEIGHT PRI-AFF 
  -1       43.67981 root default                              
  -2       10.91995     host voyager1                         
   3   hdd  1.81999         osd.3         up  1.00000 1.00000 
   4   hdd  1.81999         osd.4         up  1.00000 1.00000 
   9   hdd  1.81999         osd.9         up  1.00000 1.00000 
  25   hdd  1.81999         osd.25        up  1.00000 1.00000 
  26   hdd  1.81999         osd.26        up  1.00000 1.00000 
  27   hdd  1.81999         osd.27        up  1.00000 1.00000 
  -9       10.91995     host voyager2                         
   0   hdd  1.81999         osd.0         up  1.00000 1.00000 
   1   hdd  1.81999         osd.1         up  1.00000 1.00000 
   6   hdd  1.81999         osd.6         up  1.00000 1.00000 
  24   hdd  1.81999         osd.24        up  1.00000 1.00000 
  28   hdd  1.81999         osd.28        up  1.00000 1.00000 
  29   hdd  1.81999         osd.29        up  1.00000 1.00000 
  -5       10.91995     host voyager3                         
   2   hdd  1.81999         osd.2       down        0 1.00000 
   5   hdd  1.81999         osd.5       down        0 1.00000 
   7   hdd  1.81999         osd.7       down        0 1.00000 
   8   hdd  1.81999         osd.8       down        0 1.00000 
  10   hdd  1.81999         osd.10      down        0 1.00000 
  11   hdd  1.81999         osd.11      down        0 1.00000 
  -7       10.91995     host voyager4                         
  30   hdd  1.81999         osd.30      down        0 1.00000 
  31   hdd  1.81999         osd.31      down  1.00000 1.00000 
  32   hdd  1.81999         osd.32      down  1.00000 1.00000 
  33   hdd  1.81999         osd.33      down  1.00000 1.00000 
  34   hdd  1.81999         osd.34      down  1.00000 1.00000 
  35   hdd  1.81999         osd.35      down  1.00000 1.00000 

Recovery:
---------

1. Use the token to re-join the k8s cluster on the worker node (e.g. voyager3):

.. code-block::

  $ sudo kubeadm join --token 712081.15a0cad313a3f96c 135.207.240.41:6443 --discovery-token-unsafe-skip-ca-verification

2. Add ceph-mon label to the re-joined K8s node (e.g. voyager3):

.. code-block::

  $ kubectl label node voyager3 ceph-mon=enabled 

3. Check if 3 mon daemons are in quorum:

.. code-block::

  (mon-pod):/# ceph -s  
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              5 osds down
              1 host (6 osds) down
              no active mgr
              12/272 objects unfound (4.412%)
              Reduced data availability: 525 pgs inactive, 32 pgs down, 427 pgs peering, 46 pgs incomplete, 599 pgs stale
              Degraded data redundancy: 71/816 objects degraded (8.701%), 19 pgs degraded, 38 pgs undersized
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: no daemons active
      osd: 24 osds: 12 up, 17 in; 27 remapped pgs
   
    data:
      pools:   18 pools, 918 pgs
      objects: 272 objects, 840 MB
      usage:   2951 MB used, 33505 GB / 33508 GB avail
      pgs:     57.190% pgs not active
               71/816 objects degraded (8.701%)
               12/272 objects unfound (4.412%)
               418 stale+peering
               262 active+clean
               82  stale+active+clean
               46  incomplete
               32  stale+down
               30  stale+active+undersized
               17  stale+activating
               11  active+recovery_wait+degraded
               9   stale+creating+peering
               8   stale+active+undersized+degraded
               3   stale+creating+activating

3. Add ceph-osd label to the re-joined K8s node (e.g., voyager3):

.. code-block::

  $ kubectl label node voyager4 ceph-osd=enabled

4. Check if 6 osds are back up (i.e., from 12 up to 18 up):

.. code-block::

  (mon-pod):/# ceph -s

    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              3 osds down
              1 host (6 osds) down
              no active mgr
              12/272 objects unfound (4.412%)
              Reduced data availability: 525 pgs inactive, 32 pgs down, 427 pgs peering, 46 pgs incomplete, 599 pgs stale
              Degraded data redundancy: 71/816 objects degraded (8.701%), 19 pgs degraded, 38 pgs undersized
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: no daemons active
      osd: 24 osds: 18 up, 21 in; 335 remapped pgs
   
    data:
      pools:   18 pools, 918 pgs
      objects: 272 objects, 840 MB
      usage:   2951 MB used, 33505 GB / 33508 GB avail
      pgs:     57.190% pgs not active
               71/816 objects degraded (8.701%)
               12/272 objects unfound (4.412%)
               418 stale+peering
               262 active+clean
               82  stale+active+clean
               46  incomplete
               32  stale+down
               30  stale+active+undersized
               17  stale+activating
               11  active+recovery_wait+degraded
               9   stale+creating+peering
               8   stale+active+undersized+degraded
               3   stale+creating+activating
 
5. Use the token to re-join the k8s cluster on the worker node (e.g. voyager4):

.. code-block::

  $ sudo kubeadm join --token 712081.15a0cad313a3f96c 135.207.240.41:6443 --discovery-token-unsafe-skip-ca-verification

6. Add ceph-mgr label to the re-joined K8s node (e.g. voyager4):

.. code-block::

  $ kubectl label node voyager4 ceph-mgr=enabled 

7. Check if ceph-mgr is Running  
(before)  

.. code-block::

  $ kubectl get pods -n ceph |grep ceph-mgr
  ceph-mgr-7c66bd658-mhww8                   0/1       Pending   0          23h

(after)  

.. code-block::
  $ kubectl get pods -n ceph |grep ceph-mgr
  ceph-mgr-7c66bd658-mhww8                   1/1       Running   0          23h


8. Add ceph-osd label to the re-joined K8s node (e.g. voyager4):

.. code-block::

  $ kubectl label node voyager4 ceph-osd=enabled 

9. Check if all 24 osds are up:

.. code-block::

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              Reduced data availability: 193 pgs inactive, 46 pgs incomplete
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager4(active)
      osd: 24 osds: 24 up, 24 in
   
    data:
      pools:   18 pools, 918 pgs
      objects: 277 objects, 822 MB
      usage:   5381 MB used, 44672 GB / 44678 GB avail
      pgs:     16.013% pgs unknown
               5.011% pgs not active
               725 active+clean
               147 unknown
               46  incomplete


Case: Two K8s worker nodes (each has one ceph-mon running) are deleted
======================================================================

This is to test a scenario when two worker nodes (voayger2 and voyager3, each of which has a ceph-mon running) are deleted from a k8s cluster. 

Symptom:
--------
.. code-block::

  $ kubectl drain voyager2 --delete-local-data --force --ignore-daemonsets
  $ kubectl delete node voyager2
  $ kubectl drain voyager3 --delete-local-data --force --ignore-daemonsets
  $ kubectl delete node voyager3  

.. code-block::

  (mon-pod):/# ceph -s
  2018-06-05 21:11:55.785848 7fd263070700  0 monclient(hunting): authenticate timed out after 300
  2018-06-05 21:11:55.785911 7fd263070700  0 librados: client.admin authentication error (110) Connection timed out
  [errno 110] error connecting to the cluster


Recovery:
---------
1. In worker node,  use the token to re-join the k8s cluster on the worker node (e.g. voyager3):

.. code-block::

  $ sudo kubeadm join --token 712081.15a0cad313a3f96c 135.207.240.41:6443 --discovery-token-unsafe-skip-ca-verification
  $ sudo kubeadm reset

2. In master node, add the ceph-mon label to the re-joined k8s node (e.g. voyager2)

.. code-block::

  $ kubectl label node voyager2 ceph-mon=enabled

3. Check the ceph cluster status in one of the running monitor pods:
.. code-block::

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              12 osds down
              2 hosts (12 osds) down
              Reduced data availability: 489 pgs inactive, 42 pgs down, 4 pgs incomplete
              Degraded data redundancy: 267/801 objects degraded (33.333%), 218 pgs degraded, 872 pgs undersized
              10 slow requests are blocked > 32 sec
              mon voyager1 is low on available space
   
    services:
      mon: 2 daemons, quorum voyager1,voyager2
      mgr: voyager4(active)
      osd: 24 osds: 12 up, 24 in
   
    data:
      pools:   18 pools, 918 pgs
      objects: 267 objects, 818 MB
      usage:   5393 MB used, 44672 GB / 44678 GB avail
      pgs:     53.268% pgs not active
               267/801 objects degraded (33.333%)
               340 active+undersized
               314 undersized+peered
               129 undersized+degraded+peered
               89  active+undersized+degraded
               42  down
               2   creating+incomplete
               2   incomplete
