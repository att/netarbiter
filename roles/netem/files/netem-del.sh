#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10-01-2015

# Uncomment For debugging
set -x

if [ $# -lt 3 ]; then
 echo "USAGE: $0 <BRIDGE_NAME> <ROUTER_NAME> <REMOTE_CIDR>"
 exit 1
fi

IP=/sbin/ip
TC=/sbin/tc
LOCKFILE='/tmp/InterSite.lock'

BRIDGE_NAME=$1
ROUTER_NAME=$2
REMOTE_CIDR=$3

ROUTER_ID=`neutron router-list |grep $ROUTER_NAME |awk '{print $2}'`
if [ -z $ROUTER_ID ]; then
  echo Neutron router does not exist!
  exit 0
fi
ROUTER_NS=qrouter-$ROUTER_ID

# TC_CLASSID (tc class-id) generation algorithm (for example):
# Example: REMOTE_CIDR=10.254.40.0/24 is IP=0AFE2800 and NETMASK = 24
# + CIDR_DEC='10 254 40 0 24'
# + IP_DEC='10 254 40 0'
# + NETMASK_DEC=24
# + IP_HEX=0AFE2800
# + SHIFTED=720424
# + MASKED=65064
# + TCID=FE28
CIDR_DEC=`echo $REMOTE_CIDR | sed 's/[^0-9]/ /g'`
IP_DEC=`echo $CIDR_DEC |awk '{print $1, $2, $3, $4}'`
NETMASK_DEC=`echo $CIDR_DEC |awk '{print $5}'`
IP_HEX=`printf '%02X' $IP_DEC; echo`
SHIFTED=$(( 0x$IP_HEX >> 32 - NETMASK_DEC ))
MASKED=$(( $SHIFTED & 0xFFFF  ))
TC_CLASSID=`printf '%02X' $MASKED; echo`


(
  $IP netns exec $ROUTER_NS $TC filter del dev $BRIDGE_NAME parent 1: protocol ip prio 1 u32 match ip dst $REMOTE_CIDR flowid 1:$TC_CLASSID
  $IP netns exec $ROUTER_NS $TC qdisc del dev $BRIDGE_NAME parent 1:$TC_CLASSID handle $TC_CLASSID: 
  $IP netns exec $ROUTER_NS $TC class del dev $BRIDGE_NAME parent 1: classid 1:$TC_CLASSID
  #$IP netns exec $ROUTER_NS $TC qdisc del dev $BRIDGE_NAME handle 1: root
) 200>$LOCKFILE

