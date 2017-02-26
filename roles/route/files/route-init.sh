#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 09-29-2015

# Uncomment For debugging
set -x

if [ $# -lt 3 ]; then
 echo "USAGE: $0 <BRIDGE_NAME> <ROUTER_NAME> <WANIP/PREFIXLEN>"
 exit 1
fi

IP=/sbin/ip
IFCONFIG=/sbin/ifconfig
NEUTRON=/usr/bin/neutron
LOCKFILE='/tmp/InterSite.lock'

BRIDGE_NAME=$1
ROUTER_NAME=$2
WANIP_PREFIXLEN=$3

ROUTER_ID=`$NEUTRON router-list |grep $ROUTER_NAME |awk '{print $2}'`
if [ -z $ROUTER_ID ]; then
  echo Neutron router does not exist!
  exit 0
fi
ROUTER_NS=qrouter-$ROUTER_ID

(
  $IP link set $BRIDGE_NAME netns $ROUTER_NS
  $IP netns exec $ROUTER_NS $IFCONFIG $BRIDGE_NAME $WANIP_PREFIXLEN
) 200>$LOCKFILE

