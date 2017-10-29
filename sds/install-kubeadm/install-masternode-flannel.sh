#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/20/2017

set -x

source common-functions.sh

# Install docker
sudo apt-get update
sudo apt-get install -y docker.io

# Install kubeadm, kubelet, and kubectl 
install_kubexxx                         # for latest version
# or you can find a specific version from: 
#   https://packages.cloud.google.com/apt/dists/kubernetes-xenial/main/binary-amd64/Packages
#install_kubexxx 1.7.6-00 

# kubeadm init and install flannel
kubeadm_init_flannel

# Schedule a pod on the master
kubectl taint nodes --all node-role.kubernetes.io/master-

