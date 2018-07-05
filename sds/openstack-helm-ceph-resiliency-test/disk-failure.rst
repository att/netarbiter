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
We monitor the ceph status and notice one OSD (osd.2) on voyager4  which has ``/dev/sdh`` as a backend is down. 

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

After restoring/replacing the failed disk, excecute the following procedure to replace the failed OSD:

1. Disable osd pod on host::

.. code-block:: console

  $ kubectl label nodes --all ceph_maintenance_window=inactive
  $ kubectl label nodes voyager4 --overwrite ceph_maintenance_window=active

2. Obtain the yaml file of the OSD daemonset and identify the device (/dev/sdh) associated with the failed OSD:

.. code-block:: console

  $ kubectl get ds ceph-osd-default-64779b8c -n ceph -o yaml
  $ kubectl patch -n ceph ds ceph-osd-default-64779b8c -p='{"spec":{"template":{"spec":{"nodeSelector":{"ceph-osd":"enabled","ceph_maintenance_window":"inactive"}}}}}'

3. Remove the failed OSD:

.. code-block:: console

  (mon-pod):/# ceph osd lost 2
  (mon-pod):/# ceph osd crush remove osd.2
  (mon-pod):/# ceph auth del osd.2
  (mon-pod):/# ceph osd rm 2

4. Monitor the Ceph status:

.. code-block:: console

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

.. code-block:: console

  (voyager4)$ rm -rf /var/lib/openstack-helm/ceph/journal1/osd/journal-sdh/*
  (voyager4)$ parted /dev/sdh mklabel msdos

6. Re-enable the OSD pod on node:

.. code-block:: console

  $ kubectl label nodes rdm8r003o001 --overwrite ceph_maintenance_window=inactive

Validate Ceph status:

.. code-block:: console

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
