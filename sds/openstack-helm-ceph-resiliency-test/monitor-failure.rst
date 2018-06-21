===============
Monitor Failure
===============

Test Environment:
- Cluster size: 4 host machines
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
