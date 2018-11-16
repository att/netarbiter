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

kubectl -n $NAMESPACE delete secrets ceph-bootstrap-mds-keyring
kubectl -n $NAMESPACE delete secrets ceph-bootstrap-osd-keyring
kubectl -n $NAMESPACE delete secrets ceph-bootstrap-rgw-keyring
kubectl -n $NAMESPACE delete secrets ceph-bootstrap-rbd-keyring
kubectl -n $NAMESPACE delete secrets ceph-client-admin-keyring
kubectl -n $NAMESPACE delete secrets ceph-mon-keyring
kubectl -n $NAMESPACE delete secrets pvc-ceph-conf-combined-storageclass

