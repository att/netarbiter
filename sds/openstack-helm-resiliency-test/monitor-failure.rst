===============
Monitor Failure
===============

Case:
=====

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
