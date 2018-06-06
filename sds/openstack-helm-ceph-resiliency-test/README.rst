========================================
Resiliency Tests for OpenStack-Helm/Ceph
========================================

Mission
=======

The goal of our resiliency tests for `OpenStack-Helm/Ceph <https://github.com/openstack/openstack-helm/tree/master/ceph>`_ is to show symptoms of software/hardware failure and provide the solutions. 

* Caveats: 
   - This resiliency tests are of a limited scope to Ceph among various components of `OpenStack-Helm <https://github.com/openstack/openstack-helm>`_.
   - Our focus lies on resiliency for various failure scenarioes but not on performance or stress testing.
   - We assume that you are knowledgeable about `Ceph <http://docs.ceph.com/docs/master/>`_ and `Kubernetes <https://kubernetes.io/docs/concepts/>`_.

Test Environment
================
- Kubernetes 1.9.3
- Ceph 12.2.3
- Ceph Helm Chart 0.1.0

Software Failure
================
* `Monitor failure <./monitor-failure.rst>`_
* `OSD failure <./osd-failure.rst>`_
* `Miscellaneous failures <./miscellaneous-failure.rst>`_

Hardware Failure
================
* `Disk failure <./disk-failure.rst>`_
* `Journal SSD failure <./journal-sdd-failure.rst>`_ 
* `Host failure <./host-failure.rst>`_

Communication
=============
* Post your issues at https://github.com/att/netarbiter/issues.
* Email `Hee Won Lee`_ or `Yu Xiang`_.

.. _Hee Won Lee: knowpd@research.att.com
.. _Yu Xiang: yxiang@research.att.com

