#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 6/19/2017

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <osd_id> <namespace>"
    echo "  osd_id:    e.g. 1"
    echo "  namespace: e.g. ceph"
    exit 1
fi

set -x

OSD_ID=$1
NAMESPACE=$2

MON="kubectl -n $NAMESPACE exec -it ceph-mon-0 -- "

# Remove the OSD from the CRUSH map so that it no longer receives data.
$MON ceph osd crush remove osd.$OSD_ID

# Remove the OSD authentication key.
$MON ceph auth del osd.$OSD_ID

# Remove the OSD.
$MON ceph osd rm $OSD_ID

