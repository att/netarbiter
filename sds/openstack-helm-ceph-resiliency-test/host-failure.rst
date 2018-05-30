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

  $ sudo kubeadm join --token 712081.15a0cad313a3f96c 135.207.240.41:6443 --discovery-token-unsafe-skip-
  ca-verification
  [preflight] Running pre-flight checks.
          [WARNING FileExisting-crictl]: crictl not found in system path
  [preflight] Some fatal errors occurred:
          [ERROR Swap]: running with swap on is not supported. Please disable swap
  [preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`

.. code-block::

  $ sudo swapoff -a    

3. Add Ceph storage and Ceph manager labels to the re-joined node:

.. code-block::

  $ kubectl label node voyager4 ceph-osd=enabled
  $ kubectl label node voyager4 ceph-mgr=enabled

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
  root@voyager1:/# ceph osd tree
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
   2   hdd  1.81999         osd.2       down  1.00000 1.00000 
   5   hdd  1.81999         osd.5       down  1.00000 1.00000 
   7   hdd  1.81999         osd.7       down  1.00000 1.00000 
   8   hdd  1.81999         osd.8       down  1.00000 1.00000 
  10   hdd  1.81999         osd.10      down  1.00000 1.00000 
  11   hdd  1.81999         osd.11      down  1.00000 1.00000 
  -7       10.91995     host voyager4                         
  12   hdd  1.81999         osd.12        up  1.00000 1.00000 
  13   hdd  1.81999         osd.13        up  1.00000 1.00000 
  15   hdd  1.81999         osd.15        up  1.00000 1.00000 
  21   hdd  1.81999         osd.21        up  1.00000 1.00000 
  22   hdd  1.81999         osd.22        up  1.00000 1.00000 
  23   hdd  1.81999         osd.23        up  1.00000 1.00000 

.. code-block::

  root@voyager1:/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              6 osds down
              1 host (6 osds) down
              Degraded data redundancy: 251/945 objects degraded (26.561%), 208 pgs degraded, 702 pgs undersized
              mon voyager1 is low on available space
              1/3 mons down, quorum voyager1,voyager2
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2, out of quorum: voyager3
      mgr: voyager4(active)
      osd: 24 osds: 18 up, 24 in
   
    data:
      pools:   18 pools, 918 pgs
      objects: 315 objects, 966 MB
      usage:   5654 MB used, 44672 GB / 44678 GB avail
      pgs:     251/945 objects degraded (26.561%)
               494 active+undersized
               216 active+clean
               208 active+undersized+degraded
