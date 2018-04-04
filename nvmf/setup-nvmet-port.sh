#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 11/11/2017
# Ref: https://community.mellanox.com/docs/DOC-2504

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <traddr> <portid>"
    echo "  traddr (target address):  e.g. 10.154.0.61"
    echo "  portid:                   e.g. 1"
    exit 1
fi

set -xe

TRADDR=$1
PORTID=$2

PORT_PATH=/sys/kernel/config/nvmet/ports/$PORTID

# Prerequisites
#sudo modprobe mlx5_core
#sudo modprobe nvmet
#sudo modprobe nvmet-rdma
sudo modprobe nvme-rdma

# Set up port
sudo mkdir -p $PORT_PATH
sudo bash -c "echo $TRADDR > $PORT_PATH/addr_traddr"
sudo bash -c "echo rdma > $PORT_PATH/addr_trtype"		# transport type
sudo bash -c "echo 4420 > $PORT_PATH/addr_trsvcid"		# port number
sudo bash -c "echo ipv4 > $PORT_PATH/addr_adrfam"		# address family

# Check
dmesg | grep "enabling port"
