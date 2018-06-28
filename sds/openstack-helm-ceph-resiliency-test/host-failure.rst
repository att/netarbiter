============
Host Failure
============

Test Environment
================

- Cluster size: 4 host machines
- Number of disks: 24 (= 6 disks per host * 4 hosts)
- Kubernetes version: 1.10.5 
- Ceph version: 12.2.3
- OpenStack-Helm commit 25e50a34c66d5db7604746f4d2e12acbdd6c1459

Case: One work node where ceph-mon & ceph-mgr is running is rebooted
====================================================================

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

Ceph status shows that ceph-mon running on ``voyager3`` becomes out of quorum and ceph-mgr (originally running on voyager3) now runs on ``voyager4``; 6 ceph-osds running on ``voyager3`` are down (i.e., 18 up out of 24 osds). 

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
The node status of ``voyager3`` changes to ``Ready`` after the node is up again. Also, Ceph pods are restarted automatically. Ceph status shows that the monitor running on ``voyager3`` is now in quorum. Also, ``voyager3`` becomes a standby for ceph-mgr.

.. code-block:: console

  $ kubectl get nodes
  NAME       STATUS    ROLES     AGE       VERSION
  voyager1   Ready     master    22h       v1.10.5
  voyager2   Ready     <none>    21h       v1.10.5
  voyager3   Ready     <none>    21h       v1.10.5
  voyager4   Ready     <none>    21h       v1.10.5

.. code-block:: console

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

