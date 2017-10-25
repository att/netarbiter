#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/20/2017

set -x

# Install docker
function install_docker {
  sudo apt-get update
  sudo apt-get install -y docker.io
}

# Install kubeadm, kubelet, and kubectl
function install_kubexxx {
  sudo apt-get update && sudo apt-get install -y apt-transport-https
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  sudo sh -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
  deb http://apt.kubernetes.io/ kubernetes-xenial main
  EOF'
  sudo apt-get update
  sudo apt-get install -y --allow-unauthenticated kubeadm kubelet kubectl

  # Install kshell
  sudo cp ./kshell /usr/local/bin
}

# Initialize your master with calico
function kubeadm_init_calico {
  sudo kubeadm init --pod-network-cidr=192.168.0.0/16
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  
  # Install calico
  kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
}

# Initialize your master with flannel
function kubeadm_init_flannel {
  sudo kubeadm init --pod-network-cidr=10.244.0.0/16
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  
  # Install flannel
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.0/Documentation/kube-flannel.yml
}

