============
Host Failure
============

Test Environment
================

- Cluster size: 4 host machines
- Number of disks: 24 (= 6 disks per host * 4 hosts)
- Kubernetes 1.9.3
- Ceph 12.2.3
- OpenStack-Helm commit 28734352741bae228a4ea4f40bcacc33764221eb

Case: One work node where ceph-mgr is running is rebooted
=========================================================

Symptom:
--------

After reboot (node voyager3), the node status changes to ``NotReady``.

.. code-block:: console

  $ kubectl get nodes
  NAME       STATUS     ROLES     AGE       VERSION
  voyager1   Ready      master    22h       v1.10.5
  voyager2   Ready      <none>    21h       v1.10.5
  voyager3   NotReady   <none>    21h       v1.10.5
  voyager4   Ready      <none>    21h       v1.10.5

Ceph status shows that ceph-mgr (originally running on voyager3) now runs on voyager4. And one the ceph-mon running on voyager3 becomes out of quorum.

.. code-block:: console
  
  (mon-pod):/# ceph -s
    cluster:
      id:     205972fb-1d83-4f9a-b569-bdbf1218dd77
      health: HEALTH_WARN
              6 osds down
              1 host (6 osds) down
              mon voyager1 is low on available space
              1/3 mons down, quorum voyager1,voyager2
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2, out of quorum: voyager3
      mgr: voyager4(active)
      osd: 24 osds: 18 up, 24 in
   
    data:
      pools:   0 pools, 0 pgs
      objects: 0 objects, 0 bytes
      usage:   1941 MB used, 33506 GB / 33508 GB avail
      pgs: 

Recovery:
---------
The node status (of voyager3) changes to ``Ready`` after the node is up again. Also, Ceph pods will be restarted automatically. Ceph status shows that the monitor running on voyager3 is now in quorum. voyager3 also becomes a standby for ceph-mgr.

.. code-block::

  $ kubectl get nodes
  NAME       STATUS    ROLES     AGE       VERSION
  voyager1   Ready     master    22h       v1.10.5
  voyager2   Ready     <none>    21h       v1.10.5
  voyager3   Ready     <none>    21h       v1.10.5
  voyager4   Ready     <none>    21h       v1.10.5

.. code-block::

  (mon-pod):/# ceph -s
    cluster:
      id:     205972fb-1d83-4f9a-b569-bdbf1218dd77
      health: HEALTH_WARN
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager4(active), standbys: voyager3
      osd: 24 osds: 24 up, 24 in
   
    data:
      pools:   0 pools, 0 pgs
      objects: 0 objects, 0 bytes
      usage:   2449 MB used, 44675 GB / 44678 GB avail
      pgs:

  

Case: Two worker nodes where ceph-mgr and ceph-mon are running are rebooted
===========================================================================

Symptom:
--------

After reboot, the nodes appears in k8s cluster automatically, but the status is ``NotReady``.

.. code-block::

  $ kubectl get nodes 
  NAME       STATUS    ROLES     AGE       VERSION
  voyager1   Ready     master    65d       v1.9.3
  voyager2   Ready     <none>    8d        v1.9.3
  voyager3   NotReady  <none>    7d        v1.9.3
  voyager4   NotReady  <none>    15d       v1.9.3 

Ceph status in monitor shows two hosts are down. 

.. code-block::

  (mon-pod):/# ceph -s
  cluster:
    id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
    health: HEALTH_WARN
            12 osds down
            2 hosts (12 osds) down
            no active mgr
            Reduced data availability: 46 pgs inactive, 46 pgs incomplete
            mon voyager1 is low on available space
            1/3 mons down, quorum voyager1,voyager2

  services:
    mon: 3 daemons, quorum voyager1,voyager2, out of quorum: voyager3
    mgr: no daemons active
    osd: 24 osds: 12 up, 24 in

  data:
    pools:   18 pools, 918 pgs
    objects: 272 objects, 847 MB
    usage:   5473 MB used, 44672 GB / 44678 GB avail
    pgs:     5.011% pgs not active
             872 active+clean
             46  incomplete
  
Recovery:
---------
Disable swap, and then the kubelet process in the work node will restart. Now the node status will change to ``Ready``. Also, Ceph pods will be restarted automatically; ceph status recovers.

.. code-block::

  $sudo swapoff -a

.. code-block::

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              Reduced data availability: 46 pgs inactive, 46 pgs incomplete
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager4(active)
      osd: 24 osds: 24 up, 24 in
   
    data:
      pools:   18 pools, 918 pgs
      objects: 278 objects, 851 MB
      usage:   5505 MB used, 44672 GB / 44678 GB avail
      pgs:     5.011% pgs not active
               872 active+clean
               46  incomplete
