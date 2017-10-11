#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 09-29-2015

# Uncomment For debugging
set -x

if [ $# -lt 2 ]; then
  echo "USAGE: $0 <BRIDGE_NAME> <TUNNEL_NAME>"
  exit 1
fi

OVSVSCTL=/usr/bin/ovs-vsctl
LOCKFILE='/tmp/InterSite.lock'

BRIDGE_NAME=$1
TUNNEL_NAME=$2

(
  $OVSVSCTL del-port $BRIDGE_NAME $TUNNEL_NAME
) 200>$LOCKFILE
