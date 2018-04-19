========================================
Resiliency Tests for OpenStack-Helm/Ceph
========================================

Mission
-------

The goal of resiliency tests for OpenStack-Helm/Ceph is to provide the symptoms and solutions for the problems that happen due to software and/or hardward failures. Our resiliency test is of a limited scope to Ceph among mutiple OpenStack-Helm compoments.

Communication
-------------
* Post your issues on <https://github.com/att/netarbiter/issues>
* Email Hee Won Lee <knowpd@research.att.com> or Yu Xiang <yxiang@research.att.com>

Deployment/Operations Failures
------------------------------

`Deployment Failures <./ceph-deploy.rst>`__

Software Failures
-----------------
* OSD down, K8s node down, Journal down, Monitor down

Hardware Failures
-----------------
* Disk down, Host down, Journal SSD down
