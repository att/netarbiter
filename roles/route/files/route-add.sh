#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 09-29-2015

# Uncomment For debugging
set -x

if [ $# -lt 3 ]; then
 echo "USAGE: $0 <ROUTER_NAME> <REMOTE_CIDR> <REMOTE_GATEWAY>"
 exit 1
fi

IP=/sbin/ip
ROUTE=/sbin/route
NEUTRON=/usr/bin/neutron
LOCKFILE='/tmp/InterSite.lock'

ROUTER_NAME=$1
REMOTE_CIDR=$2
REMOTE_GATEWAY=$3
ROUTER_ID=`$NEUTRON router-list |grep $ROUTER_NAME |awk '{print $2}'`
if [ -z $ROUTER_ID ]; then
  echo Neutron router does not exist!
  exit 0
fi
ROUTER_NS=qrouter-$ROUTER_ID

(
  $IP netns exec $ROUTER_NS $ROUTE add -net $REMOTE_CIDR gw $REMOTE_GATEWAY
) 200>$LOCKFILE






