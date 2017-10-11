#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/8/2017

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <release_name>"
    echo "  release_name:   e.g. ceph"
    exit 1
fi

set -x

RELEASE_NAME=$1

helm install ./ceph -n $RELEASE_NAME --replace --namespace ceph
