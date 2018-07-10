===============
Monitor Failure
===============

Test Environment
================

- Cluster size: 4 host machines
- Number of disks: 24 (= 6 disks per host * 4 hosts)
- Kubernetes 1.9.3
- Ceph 12.2.3
- OpenStack-Helm commit 28734352741bae228a4ea4f40bcacc33764221eb

We have 3 Monitors in this Ceph cluster, one on each of the 3 Monitor hosts.

Case: 1 out of 3 Monitor Processes is Down
==========================================

This is to test a scenario when 1 out of 3 Monitor processes is down.

To bring down 1 Monitor process (out of 3), we identify a Monitor process and kill it from the monitor host (not a pod).

.. code-block::

  $ ps -ef | grep ceph-mon
  ceph     16112 16095  1 14:58 ?        00:00:03 /usr/bin/ceph-mon --cluster ceph --setuser ceph --setgroup ceph -d -i voyager2 --mon-data /var/lib/ceph/mon/ceph-voyager2 --public-addr 135.207.240.42:6789
  $ sudo kill -9 16112

In the mean time, we monitored the status of Ceph and noted that it takes about 24 seconds for the killed Monitor process to recover from ``down`` to ``up``. The reason is that Kubernetes automatically restarts pods whenever they are killed.

.. code-block::

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              mon voyager1 is low on available space
              1/3 mons down, quorum voyager1,voyager3
   
    services:
      mon: 3 daemons, quorum voyager1,voyager3, out of quorum: voyager2
      mgr: voyager4(active)
      osd: 24 osds: 24 up, 24 in

.. code-block::

  (mon-pod):/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              mon voyager1 is low on available space
              1/3 mons down, quorum voyager1,voyager2
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager3
      mgr: voyager4(active)
      osd: 24 osds: 24 up, 24 in

We also monitored the status of the Monitor pod through ``kubectl get pods -n ceph``, and the status of the pod (where a Monitor process is killed) changed as follows: ``Running`` -> ``Error`` -> ``Running`` and this recovery process takes about 24 seconds.

Case: 2 out of 3 Monitor Processes are Down
===========================================

This is to test a scenario when 2 out of 3 Monitor processes are down.
To bring down 2 Monitor processes (out of 3), we identify two Monitor processes and kill them from the 2 monitor hosts (not a pod).

We monitored the status of Ceph when the Monitor processes are killed and noted that the symptoms are similar to when 1 Monior process is killed: 

- It takes longer (about 1 minute) for the killed Monitor processes to recover from ``down`` to ``up``.
  
- The status of the pods (where the two Monitor processes are killed) changed as follows: ``Running`` -> ``Error`` -> ``CrashLoopBackOff`` -> ``Running`` and this recovery process takes about 1 minute.


Case: 3 out of 3 Monitor Processes are Down
===========================================

This is to test a scenario when 3 out of 3 Monitor processes are down.
To bring down 3 Monitor processes (out of 3), we identify all 3 Monitor processes and kill them from the 3 monitor hosts (not pods).

We monitored the status of Ceph Monitor pods and noted that the symptoms are similar to when 1 or 2 Monior processes are killed:

.. code-block::

  $ kubectl get pods -n ceph -o wide | grep ceph-mon 
  NAME                                       READY     STATUS    RESTARTS   AGE
  ceph-mon-8tml7                             0/1       Error     4          10d
  ceph-mon-kstf8                             0/1       Error     4          10d
  ceph-mon-z4sl9                             0/1       Error     7          10d

.. code-block::

  $ kubectl get pods -n ceph -o wide | grep ceph-mon
  NAME                                       READY     STATUS               RESTARTS   AGE
  ceph-mon-8tml7                             0/1       CrashLoopBackOff     4          10d
  ceph-mon-kstf8                             0/1       Error                4          10d
  ceph-mon-z4sl9                             0/1       CrashLoopBackOff     7          10d


.. code-block::

  $ kubectl get pods -n ceph -o wide | grep ceph-mon 
  NAME                                       READY     STATUS    RESTARTS   AGE
  ceph-mon-8tml7                             1/1       Running   5          10d
  ceph-mon-kstf8                             1/1       Running   5          10d
  ceph-mon-z4sl9                             1/1       Running   8          10d

The status of the pods (where the three Monitor processes are killed) changed as follows: ``Running`` -> ``Error`` -> ``CrashLoopBackOff`` -> ``Running`` and this recovery process takes about 1 minute.



Case: Create additional Monitor Process
=======================================

We delete a K82 worker node where a Monitor pod is running.

.. code-block::

  $ kubectl get pods -n ceph |grep ceph-mon
  ceph-mon-kstf8                             0/1       Running   6          18d
  ceph-mon-rh2s2                             0/1       Running   1          14m
  ceph-mon-z4sl9                             0/1       Running   8          18d

.. code-block::

  $ kubectl get pods -n ceph |grep ceph-mon
  ceph-mon-kstf8                             1/1       Running   6          18d
  ceph-mon-rh2s2                             1/1       Running   1          14m
  ceph-mon-z4sl9                             1/1       Running   8          18d
  
  
.. code-block::

  root@voyager2:/# ceph -s
    cluster:
      id:     fd366aef-b356-4fe7-9ca5-1c313fe2e324
      health: HEALTH_WARN
              6 osds down
              1 host (6 osds) down
              Degraded data redundancy: 251/945 objects degraded (26.561%), 208 pgs degraded, 702 pgs undersized
              mon voyager1 is low on available space
   
    services:
      mon: 3 daemons, quorum voyager1,voyager2,voyager4
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

It took about 9 minutes.

Case: Monitor database is destroyed
===================================                                                                                                                                                      Tue Jul 10 18:27:54 2018

  cluster:
    id:     9d4d8c61-cf87-4129-9cef-8fbf301210ad
    health: HEALTH_WARN
            too few PGs per OSD (22 < min 30)
            mon voyager1 is low on available space
            1/3 mons down, quorum voyager1,voyager2

  services:
    mon: 3 daemons, quorum voyager1,voyager2, out of quorum: voyager3
    mgr: voyager1(active), standbys: voyager3
    mds: cephfs-1/1/1 up  {0=mds-ceph-mds-65bb45dffc-cslr6=up:active}, 1 up:standby
    osd: 24 osds: 24 up, 24 in
    rgw: 2 daemons active

  data:
    pools:   18 pools, 182 pgs
    objects: 240 objects, 3359 bytes
    usage:   2675 MB used, 44675 GB / 44678 GB avail
    pgs:     182 active+clean

ubuntu@voyager1:~$ kubectl get pods -n ceph -o wide|grep mon
ceph-mon-4gzzw                             1/1       Running            0          6d        135.207.240.42    voyager2
ceph-mon-6bbs6                             0/1       CrashLoopBackOff   5          6d        135.207.240.43    voyager3
ceph-mon-check-d85994946-pm4jx             1/1       Running            0          6d        192.168.255.51    voyager2
ceph-mon-keyring-generator-ncp4c           0/1       Completed          0          6d        192.168.197.233   voyager3
ceph-mon-qgc7p 

$ kubectl logs ceph-mon-6bbs6 -n ceph
+ ceph-mon --setuser ceph --setgroup ceph --cluster ceph -i voyager3 --inject-monmap /etc/ceph/monmap-ceph --keyring /etc/ceph/ceph.mon.keyring --mon-data /var/lib/ceph/mon/ceph-voyager3
2018-07-10 18:30:04.546200 7f4ca9ed4f00 -1 rocksdb: Invalid argument: /var/lib/ceph/mon/ceph-voyager3/store.db: does not exist (create_if_missing is false)
2018-07-10 18:30:04.546214 7f4ca9ed4f00 -1 error opening mon data directory at '/var/lib/ceph/mon/ceph-voyager3': (22) Invalid argument

root@voyager2:/# ceph -s
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
    usage:   2675 MB used, 44675 GB / 44678 GB avail
    pgs:     182 active+clean