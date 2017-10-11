#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 09-29-2015

# Uncomment For debugging
set -x

if [ $# -lt 3 ]; then
 echo "USAGE: $0 <BRIDGE_NAME> <TUNNEL_NAME> <REMOTE_IP>"
 exit 1
fi

OVSVSCTL=/usr/bin/ovs-vsctl
LOCKFILE='/tmp/InterSite.lock'

TUNTYPE=gre
BRIDGE_NAME=$1
TUNNEL_NAME=$2
REMOTE_IP=$3

(
  $OVSVSCTL add-port $BRIDGE_NAME $TUNNEL_NAME -- set interface $TUNNEL_NAME type=$TUNTYPE options:remote_ip=$REMOTE_IP
) 200>$LOCKFILE
