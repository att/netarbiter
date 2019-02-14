#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/20/2017
# Modified on 1/30/2019

set -x

# Install kubeadm, kubelet, and kubectl
function install_kubexxx {
  if [ -n "$1" ]; then
    VERSION==$1
  else
    VERSION=
  fi

  sudo apt-get update && sudo apt-get install -y apt-transport-https
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  sudo sh -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF'
  sudo apt-get update
  sudo apt-get install -y --allow-unauthenticated kubeadm$VERSION kubelet$VERSION kubectl$VERSION
}

# Make kubectl work for your non-root user
function make_kubectl_work {
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  # Install kshell
  sudo cp ./kshell /usr/local/bin
}
