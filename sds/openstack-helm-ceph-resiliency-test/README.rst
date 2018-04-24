========================================
Resiliency Tests for OpenStack-Helm/Ceph
========================================

Mission
-------

The goal of resiliency tests for OpenStack-Helm/Ceph is to provide the symptoms and solutions for the problems that happen due to software and/or hardward failures. Our resiliency test is of a limited scope to Ceph among mutiple OpenStack-Helm compoments.

Communication
-------------
* Post your issues at https://github.com/att/netarbiter/issues
* Email `Hee Won Lee <knowpd@research.att.com>`_ or `Yu Xiang <yxiang@research.att.com>`_.

Software Failure
----------------
* `Provisioning failure <./provision-failure.rst>`_
* `OSD failure <./osd-failure.rst>`_
* `Monitor failure <./monitor-failure.rst>`_

Hardware Failure
----------------
* `Disk failure <./disk-failure.rst>`_
* `Journal SSD failure <./journal-sdd-failure.rst>`_ 
* `Host failure <./host-failure.rst>`_
