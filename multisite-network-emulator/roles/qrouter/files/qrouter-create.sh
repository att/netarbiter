#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 09-29-2015

# Uncomment For debugging
set -x

if [ $# -lt 5 ]; then
 echo "USAGE: $0 <BRIDGE_NAME> <NET_NAME> <SUBNET_NAME> <ROUTER_NAME> <SITE_CIDR> <SITE_GATEWAY>"
 exit 1
fi

OVSVSCTL=/usr/bin/ovs-vsctl
NEUTRON=/usr/bin/neutron
LOCKFILE='/tmp/InterSite.lock'

BRIDGE_NAME=$1
NET_NAME=$2
SUBNET_NAME=$3
ROUTER_NAME=$4
SITE_CIDR=$5
SITE_GATEWAY=$6

# Sanitate; if the same entry exists, exit.
if neutron net-list |grep $NET_NAME; then
  echo $NET_NAME exists!
  exit 0    
fi

if neutron subnet-list |grep $SUB_NAME; then
  echo $SUBNET_NAME exists!
  exit 0    
fi

if neutron router-list |grep $ROUTER_NAME; then
  echo $ROUTER_NAME exists!
  exit 0    
fi

(
  $OVSVSCTL add-br $BRIDGE_NAME
  $NEUTRON net-create $NET_NAME --shared
  $NEUTRON subnet-create $NET_NAME $SITE_CIDR --name $SUBNET_NAME --gateway $SITE_GATEWAY
  $NEUTRON router-create $ROUTER_NAME
  $NEUTRON router-interface-add $ROUTER_NAME $SUBNET_NAME
) 200>$LOCKFILE

