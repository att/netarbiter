#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/20/2017
# Modified on 1/16/2019

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <kubernetes-version>"
    echo "  kubernetes-version:    e.g. latest, 1.7.5-00, 1.7.6-00, 1.8.2-00, 1.9.3-00, 1.13.2-00"
    echo ""
    echo "Note:"
    echo "  You can find available versions at:"
    echo "  https://packages.cloud.google.com/apt/dists/kubernetes-xenial/main/binary-amd64/Packages"
    exit 1
fi

set -x

KUBERNETES_VERSION=$1

source common-functions.sh

# Install docker
sudo apt-get update
sudo apt-get install -y docker.io

# Disable all swaps from /proc/swaps
sudo swapoff -a

# Install kubeadm, kubelet, and kubectl 
if [[ "$1" == "latest" ]]; then
  install_kubexxx
else
  install_kubexxx $KUBERNETES_VERSION
fi

# kubeadm init and install calico
kubeadm_init_calico

# Schedule a pod on the master
kubectl taint nodes --all node-role.kubernetes.io/master-

