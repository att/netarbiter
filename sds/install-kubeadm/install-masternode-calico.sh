#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/20/2017

set -x

source common-functions.sh

install_docker
install_kubexxx 1.7.6-00	# i.e., kubeadm, kubelet, and kubectl
kubeadm_init_calico

# Schedule a pod on the master
kubectl taint nodes --all node-role.kubernetes.io/master-

