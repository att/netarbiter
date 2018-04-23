===============
Monitor Failure
===============

We have 3 Monitors, one on each Monitor hosts. 24 OSDs in this Ceph cluster, 6 OSDs on each of the 4 storage hosts (3 out of 4 hosts are labeled as both Monitor and Storage hosts).

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

We also monitored the status of the Monitor pod through ``kubectl get pods -n ceph``, and the status of the pod (where a Monitor process is killed) changed as follows: ``Running`` -> ``Error`` -> `` Running`` and this recovery process takes about 24 seconds.