#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 11/11/2017
# Ref: https://community.mellanox.com/docs/DOC-2504

if [[ "$#" -lt 4 ]]; then
    echo "Usage: $0 <dev> <subnqn> <ns-num> <portid> [offload-enable]"
    echo "  dev (nvme device):             e.g. /dev/nvme0n1"
    echo "  subnqn (nvmet subsystem name): e.g. nvme0n1"
    echo "  ns-num (namespace num):        e.g. 10"
    echo "  portid:                        e.g. 1"
    echo "  offload-enable:                yes (default) or no "
    echo ""
    echo "  * Note: "
    echo "     - When there are multiple nvme drives in a host, while ns-num and portid"
    echo "      can be shared, subnqn should be unique (i.e., subnqn per drive)."
    echo "     - Currently, an offloaded subsystem can be associated with only one namespace."
    exit 1
fi

set -xe

DEV=$1
SUBNQN=$2
NS_NUM=$3		# namespace number is similar to lun.
PORTID=$4
OFFLOAD_ENABLE=${5:-yes}

# Set up subsystem
SUBSYSTEM_PATH=/sys/kernel/config/nvmet/subsystems/$SUBNQN
sudo mkdir -p $SUBSYSTEM_PATH
sudo bash -c "echo 1 > $SUBSYSTEM_PATH/attr_allow_any_host"

if [ $OFFLOAD_ENABLE == "yes" ]; then
  sudo bash -c "echo 1 > $SUBSYSTEM_PATH/attr_offload"
elif [ $OFFLOAD_ENABLE == "no" ]; then
  sudo bash -c "echo 0 > $SUBSYSTEM_PATH/attr_offload"
fi

sudo mkdir -p $SUBSYSTEM_PATH/namespaces/$NS_NUM
sudo bash -c "echo -n $DEV > $SUBSYSTEM_PATH/namespaces/$NS_NUM/device_path"
sudo bash -c "echo 1 > $SUBSYSTEM_PATH/namespaces/$NS_NUM/enable"

# Link subsystem to port
sudo ln -s $SUBSYSTEM_PATH /sys/kernel/config/nvmet/ports/$PORTID/subsystems/$SUBNQN
