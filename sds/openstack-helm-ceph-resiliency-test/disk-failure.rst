============
Disk Failure
============

Test Environment
================

- Cluster size: 4 host machines
- Number of disks: 24 (= 6 disks per host * 4 hosts)
- Kubernetes 1.9.3
- Ceph 12.2.3
- OpenStack-Helm commit 28734352741bae228a4ea4f40bcacc33764221eb

Case: A Disk Fails
====================

Symptom: 
--------

This is to test a scenario when a disk failure happens.

To bring down a disk (e.g., ``/dev/sdh``) out of 24 disks, we run ``dd if=/dev/zero of=/dev/sdd`` from a storage host (not a pod). We monitor the ceph status in the mean time and notice one OSD which has ``/dev/sdh`` as a backend is down. 

.. code-block::

  (mon-pod):/# ceph -s
    cluster:
      id:     9d4d8c61-cf87-4129-9cef-8fbf301210ad
      health: HEALTH_WARN
              too few PGs per OSD (23 < min 30)
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager1(active), standbys: voyager3
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-65bb45dffc-cslr6=up:active}, 1 up:standby
      osd: 24 osds: 23 up, 23 in
      rgw: 2 daemons active
   
    data:
      pools:   18 pools, 182 pgs
      objects: 240 objects, 3359 bytes
      usage:   2548 MB used, 42814 GB / 42816 GB avail
      pgs:     182 active+clean
  

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_ERR
              1 scrub errors
              Possible data damage: 1 pg inconsistent
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager4(active)
      osd: 24 osds: 23 up, 23 in
   
    data:
      pools:   18 pools, 918 pgs
      objects: 320 objects, 982 MB
      usage:   5501 MB used, 42811 GB / 42816 GB avail
      pgs:     917 active+clean
               1   active+clean+inconsistent


.. code-block::

  (mon-pod):/# ceph osd tree
  ID CLASS WEIGHT   TYPE NAME         STATUS REWEIGHT PRI-AFF 
  -1       43.67981 root default                              
  -9       10.91995     host voyager1                         
   5   hdd  1.81999         osd.5         up  1.00000 1.00000 
   6   hdd  1.81999         osd.6         up  1.00000 1.00000 
  10   hdd  1.81999         osd.10        up  1.00000 1.00000 
  17   hdd  1.81999         osd.17        up  1.00000 1.00000 
  19   hdd  1.81999         osd.19        up  1.00000 1.00000 
  21   hdd  1.81999         osd.21        up  1.00000 1.00000 
  -3       10.91995     host voyager2                         
   1   hdd  1.81999         osd.1         up  1.00000 1.00000 
   4   hdd  1.81999         osd.4         up  1.00000 1.00000 
  11   hdd  1.81999         osd.11        up  1.00000 1.00000 
  13   hdd  1.81999         osd.13        up  1.00000 1.00000 
  16   hdd  1.81999         osd.16        up  1.00000 1.00000 
  18   hdd  1.81999         osd.18        up  1.00000 1.00000 
  -2       10.91995     host voyager3                         
   0   hdd  1.81999         osd.0         up  1.00000 1.00000 
   3   hdd  1.81999         osd.3         up  1.00000 1.00000 
  12   hdd  1.81999         osd.12        up  1.00000 1.00000 
  20   hdd  1.81999         osd.20        up  1.00000 1.00000 
  22   hdd  1.81999         osd.22        up  1.00000 1.00000 
  23   hdd  1.81999         osd.23        up  1.00000 1.00000 
  -4       10.91995     host voyager4                         
   2   hdd  1.81999         osd.2       down        0 1.00000 
   7   hdd  1.81999         osd.7         up  1.00000 1.00000 
   8   hdd  1.81999         osd.8         up  1.00000 1.00000 
   9   hdd  1.81999         osd.9         up  1.00000 1.00000 
  14   hdd  1.81999         osd.14        up  1.00000 1.00000 
  15   hdd  1.81999         osd.15        up  1.00000 1.00000


Solution:
---------

To recover the disk failure on ``/dev/sdh`` and bring back the failed OSD, excecute the following procedure:

1. Zap the disk:

.. code-block:: 

  $ sudo ceph-disk zap /dev/sdd

2. Idenfiy the name of the OSD pod associated with the disk failure: 

.. code-block:: 

  $ kubectl get pods -n ceph

3. Delete the OSD pod associated with the disk failure:

.. code-block:: 

  $ kubectl delete pod ceph-osd-default-83945928-z4wn7 -n ceph

4. Monitor the Ceph status:

.. code-block::

  (mon-pod):/# ceph -s
    cluster:
      id:     9d4d8c61-cf87-4129-9cef-8fbf301210ad
      health: HEALTH_WARN
              too few PGs per OSD (23 < min 30)
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager1(active), standbys: voyager3
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-65bb45dffc-cslr6=up:active}, 1 up:standby
      osd: 23 osds: 23 up, 23 in
      rgw: 2 daemons active
   
    data:
      pools:   18 pools, 182 pgs
      objects: 240 objects, 3359 bytes
      usage:   2551 MB used, 42814 GB / 42816 GB avail
      pgs:     182 active+clean

5. Clean up the failed OSD from the Ceph cluster.

   When ``kubectl get pods -n ceph`` shows all OSD pods in ``Running`` status, we noticed that a new OSD is created and the oringial OSD associated with the disk failure is still in crushmap. 


Remove the failed OSD (e.g., OSD id = 9):

.. code-block::

  (mon-pod):/# ceph osd crush remove osd.9
  (mon-pod):/# ceph auth del osd.9
  (mon-pod):/# ceph osd rm 9

Validate Ceph status:

.. code-block:: 

  (mon-pod):/# ceph -s
    cluster:
      id:     9d4d8c61-cf87-4129-9cef-8fbf301210ad
      health: HEALTH_WARN
              too few PGs per OSD (22 < min 30)
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager1(active), standbys: voyager3
      mds: cephfs-1/1/1 up  {0=mds-ceph-mds-65bb45dffc-cslr6=up:active}, 1 up:standby
      osd: 24 osds: 24 up, 24 in
      rgw: 2 daemons active
   
    data:
      pools:   18 pools, 182 pgs
      objects: 240 objects, 3359 bytes
      usage:   2665 MB used, 44675 GB / 44678 GB avail
      pgs:     182 active+clean
