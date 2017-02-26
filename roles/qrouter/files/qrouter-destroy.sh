#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 09-29-2015

# Uncomment For debugging
set -x

if [ $# -lt 3 ]; then
  echo "USAGE: $0 <BRIDGE_NAME> <NET_NAME> <SUBNET_NAME> <ROUTER_NAME>"
  exit 1
fi

OVSVSCTL=/usr/bin/ovs-vsctl
NEUTRON=/usr/bin/neutron
LOCKFILE='/tmp/InterSite.lock'

BRIDGE_NAME=$1
NET_NAME=$2
SUBNET_NAME=$3
ROUTER_NAME=$4

(
  $NEUTRON router-interface-delete $ROUTER_NAME $SUBNET_NAME
  $NEUTRON router-delete $ROUTER_NAME
  $NEUTRON subnet-delete $SUBNET_NAME
  $NEUTRON net-delete $NET_NAME
  $OVSVSCTL del-br $BRIDGE_NAME
) 200>$LOCKFILE
