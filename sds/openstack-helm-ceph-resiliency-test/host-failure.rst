============
Host Failure
============

Case: A K8s worker node (where ceph mgr is running) is deleted
==============================================================


.. code-block::

  $ kubectl drain voyager4 --delete-local-data --force --ignore-daemonsets
  $ kubectl delete node voyager4

Symptom: 
--------

This is to test a scenario when a disk failure happens.

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

