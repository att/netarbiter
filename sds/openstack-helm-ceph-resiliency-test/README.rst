========================================
Resiliency Tests for OpenStack-Helm/Ceph
========================================
Contributers:  `Hee Won Lee`_ and `Yu Xiang`_.

.. _Hee Won Lee: knowpd@research.att.com
.. _Yu Xiang: yxiang@research.att.com

Mission
=======

The goal of our resiliency tests for `OpenStack-Helm/Ceph <https://github.com/openstack/openstack-helm/tree/master/ceph>`_ is to provide the symptoms and solutions for the problems that occur due to software/hardward failure. 

* Caveats: 
   - This resiliency tests are of a limited scope to Ceph among various components of `OpenStack-Helm <https://github.com/openstack/openstack-helm>`_.
   - Our focus lies on resiliency for various failure scenarioes but not on performance or stress testing.
   - We assume that you are knowledgeable about `Ceph <http://docs.ceph.com/docs/master/>`_ and `Kubernetes <https://kubernetes.io/docs/concepts/>`_.

Software Failure
================
* `Provisioning failure <./provision-failure.rst>`_
* `OSD failure <./osd-failure.rst>`_
* `Monitor failure <./monitor-failure.rst>`_

Hardware Failure
================
* `Disk failure <./disk-failure.rst>`_
* `Journal SSD failure <./journal-sdd-failure.rst>`_ 
* `Host failure <./host-failure.rst>`_

Note
====
Communication
-------------
* Post your issues at https://github.com/att/netarbiter/issues.
* Email `Hee Won Lee`_ or `Yu Xiang`_.

.. _Hee Won Lee: knowpd@research.att.com
.. _Yu Xiang: yxiang@research.att.com

