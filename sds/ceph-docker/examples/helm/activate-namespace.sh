#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/8/2017

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <namespace>"
    echo "  namespace:   e.g. default"
    echo ""
    echo "  To use Ceph Volumes in a namespace, a secret containing the Client Key needs to be present."
    exit 1
fi

set -x

kube_namespace=$1

if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  apt-get install -y jq
fi

{
cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: "pvc-ceph-client-key"
type: kubernetes.io/rbd
data:
  key:
    $(kubectl get secret pvc-ceph-conf-combined-storageclass --namespace=ceph -o json | jq -r '.data | .[]')
EOF
} | kubectl create --namespace ${kube_namespace} -f -
