#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/20/2017
# Modified on
#   - 1/16/2019 
#   - 1/20/2020

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <kubernetes-version>"
    echo "  kubernetes-version:    e.g. 1.7.6-00, 1.8.2-00, 1.13.2-00, 1.16.5-00, latest"
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

# kubeadm init for flannel
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Make kubectl work for your non-root user
make_kubectl_work

# Install flannel
sudo sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.0/Documentation/kube-flannel.yml

# Allow scheduling pods on master
kubectl taint nodes --all node-role.kubernetes.io/master-

