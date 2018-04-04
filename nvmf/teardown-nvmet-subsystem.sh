#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 1/31/2017
# Ref: https://community.mellanox.com/docs/DOC-2504

if [[ "$#" -ne 3 ]]; then
    echo "Usage: $0 <subnqn> <ns-num> <portid>"
    echo "  subnqn (nvmet subsystem): e.g. nvme-eris101"
    echo "  ns-num (namespace num):   e.g. 10"
    echo "  portid:                   e.g. 1"
    exit 1
fi

set -xe

SUBNQN=$1
NS_NUM=$2		# namespace number is similar to lun.
PORTID=$3

SUBSYSTEM_PATH=/sys/kernel/config/nvmet/subsystems/$SUBNQN
PORT_PATH=/sys/kernel/config/nvmet/ports/$PORTID

# Remove link
sudo rm -f $PORT_PATH/subsystems/$SUBNQN

# Remove subsystem
sudo rmdir $SUBSYSTEM_PATH/namespaces/$NS_NUM
sudo rmdir $SUBSYSTEM_PATH

# Remove port
#sudo rmdir $PORT_PATH

# Check
#dmesg | grep "enabling port"
