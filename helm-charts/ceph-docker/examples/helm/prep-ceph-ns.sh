#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/21/2017

set -x

# Create a namespace for ceph
kubectl create namespace ceph

# Create a secret for `.kube/config` so that a K8s job could run `kubectl` inside the container.
kubectl -n ceph create secret generic kube-config --from-file=$HOME/.kube/config

# Allow user "system:serviceaccount:kube-system:default" to list pods in the namespace "default"
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
