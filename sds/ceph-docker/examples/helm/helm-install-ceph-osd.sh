#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/2/2017

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <node_label> <osd_device>"
    echo "  node_label:    e.g. voyager1"
    echo "  osd_device:    e.g. /dev/sdb"
    echo ""
    echo "  Bluestore:"
    echo "    $0 voyager1 sdb"
    echo ""
    echo "  Filestore:"
    echo "    OSD_FILESTORE=1 $0 voyager1 /dev/sdb"
    echo ""
    echo "  Filestore with journal:"
    echo "    OSD_FILESTORE=1 OSD_JOURNAL=/dev/sdb1 $0 voyager1 /dev/sdb"
    echo ""
    exit 1
fi

set -x

NODE_LABEL=$1
OSD_DEVICE=$(basename $2)
NAMESPACE=${NAMESPACE:-ceph}
OSD_BLUESTORE=${OSD_BLUESTORE:-1}
OSD_FILESTORE=${OSD_FILESTORE:-0}
OSD_FORCE_ZAP=${OSD_FORCE_ZAP:-0} 	
# NOTE:  do not recommend to use OSD_FORCE_ZAP=1; whenever the kubernetes scheduler 
#      restarts an OSD pod, a new OSD ID is assigned.

if [[ "$OSD_FILESTORE" == "1" ]]; then
  OSD_BLUESTORE=0
fi

if [[ -n "${OSD_JOURNAL}" ]]; then
  helm install ./ceph-osd --name=ceph-osd-$NODE_LABEL-$OSD_DEVICE-$(basename $OSD_JOURNAL) --replace --namespace=$NAMESPACE --set ceph.osd.node_label=$NODE_LABEL --set ceph.osd.osd_device=$OSD_DEVICE --set ceph.osd.osd_force_zap=$OSD_FORCE_ZAP --set ceph.osd.osd_bluestore=$OSD_BLUESTORE --set ceph.osd.osd_filestore=$OSD_FILESTORE --set ceph.osd.osd_journal=$OSD_JOURNAL
else
  helm install ./ceph-osd --name=ceph-osd-$NODE_LABEL-$OSD_DEVICE --replace --namespace=$NAMESPACE --set ceph.osd.node_label=$NODE_LABEL --set ceph.osd.osd_device=$OSD_DEVICE --set ceph.osd.osd_force_zap=$OSD_FORCE_ZAP --set ceph.osd.osd_bluestore=$OSD_BLUESTORE --set ceph.osd.osd_filestore=$OSD_FILESTORE 
fi
