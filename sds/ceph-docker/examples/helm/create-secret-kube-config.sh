#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/2/2017

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <namespace>"
    echo "  namespace:    e.g. ceph"
    exit 1
fi

set -x

NAMESPACE=$1

kubectl -n $NAMESPACE create secret generic kube-config --from-file=$HOME/.kube/config
