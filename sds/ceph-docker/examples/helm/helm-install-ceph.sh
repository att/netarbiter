#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/8/2017

if [[ "$#" -ne 3 ]]; then
    echo "Usage: $0 <release_name> <public_network> <cluster_network>"
    echo "  release_name:    e.g. ceph"
    echo "  public_network:  e.g. 172.31.0.0/20"
    echo "  cluster_network: e.g. 172.31.0.0/20" 
    exit 1
fi

set -x

RELEASE_NAME=$1
PUBLIC_NETWORK=$2
CLUSTER_NETWORK=$3

helm install ./ceph --replace --namespace ceph -n $RELEASE_NAME $PUBLIC_NETWORK $CLUSTER_NETWORK
