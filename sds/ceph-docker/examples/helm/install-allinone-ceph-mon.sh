#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/20/2017

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <public_network> <cluster_network>"
    echo "  public_network:  e.g. 172.31.0.0/20"
    echo "  cluster_network: e.g. 172.31.0.0/20" 
    exit 1
fi

set -x

PUBLIC_NETWORK=$1
CLUSTER_NETWORK=$2

sudo apt install ceph ceph-common	# for every K8s nodes
sudo apt install jq			# used in activate-namespace.sh

# Note: we do not require a specific helm version.
curl -O https://storage.googleapis.com/kubernetes-helm/helm-v2.6.1-linux-amd64.tar.gz
tar xzvf helm-v2.6.1-linux-amd64.tar.gz 
sudo cp linux-amd64/helm /usr/local/bin

helm init       # or helm init --upgrade
helm serve &

kubectl create namespace ceph
./create-secret-kube-config.sh ceph

./helm-install-ceph.sh ceph $PUBLIC_NETWORK $CLUSTER_NETWORK
