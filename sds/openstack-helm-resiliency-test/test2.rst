=========
Multinode
=========

Overview
========

In order to drive towards a production-ready Openstack solution, our
goal is to provide containerized

Kubernetes Preparation
======================

You can use any Kubernetes deployment tool to bring up a working Kubernetes
cluster for use with OpenStack-Helm. For simplicity however we will describe
deployment using the OpenStack-Helm gate scripts to bring up a reference cluster
using KubeADM and Ansible.

OpenStack-Helm Infra KubeADM deployment
---------------------------------------

On the master node install the latest versions of Git, CA Certs & Make if necessary