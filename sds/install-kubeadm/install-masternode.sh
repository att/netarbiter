#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/20/2017

set -x

source common_functions.sh

install_docker
install_kubexxx
kubeadm_init_calico
#kubeadm_init_flannel

# Schedule a pod on the master
kubectl taint nodes --all node-role.kubernetes.io/master-

