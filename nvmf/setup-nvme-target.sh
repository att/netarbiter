#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 11/11/2017
# Ref: https://community.mellanox.com/docs/DOC-2504

if [[ "$#" -ne 4 ]]; then
    echo "Usage: $0 <target-address> <nvme-dev> <nvme-subsystem-name> <port-id>"
    echo "  target-address:      e.g. 10.154.0.61"
    echo "  nvme-dev:            e.g. /dev/nvme0n1"
    echo "  nvme-subsystem-name: e.g. nvme-eris101"
    echo "  port-id:             e.g. 1"
    exit 1
fi

set -x
set -e

TARGET_ADDRESS=$1
NVME_DEV=$2
NVME_SUBSYSTEM_NAME=$3
PORT_ID=$4

# Prerequisites
sudo modprobe mlx5_core
sudo modprobe nvmet
sudo modprobe nvmet-rdma
sudo modprobe nvme-rdma

# NVMe Target Configuration
SUBSYSTEM_PATH=/sys/kernel/config/nvmet/subsystems/$NVME_SUBSYSTEM_NAME
sudo mkdir -p $SUBSYSTEM_PATH
sudo bash -c "echo 1 > $SUBSYSTEM_PATH/attr_allow_any_host"
sudo mkdir -p $SUBSYSTEM_PATH/namespaces/10
sudo bash -c "echo -n $NVME_DEV > $SUBSYSTEM_PATH/namespaces/10/device_path"
sudo bash -c "echo 1 > $SUBSYSTEM_PATH/namespaces/10/enable"

PORT_PATH=/sys/kernel/config/nvmet/ports/$PORT_ID
sudo mkdir -p $PORT_PATH
sudo bash -c "echo $TARGET_ADDRESS > $PORT_PATH/addr_traddr"
sudo bash -c "echo rdma > $PORT_PATH/addr_trtype"
sudo bash -c "echo 4420 > $PORT_PATH/addr_trsvcid"
sudo bash -c "echo ipv4 > $PORT_PATH/addr_adrfam"

sudo ln -s $SUBSYSTEM_PATH $PORT_PATH/subsystems/$NVME_SUBSYSTEM_NAME

# Check
dmesg | grep "enabling port"
