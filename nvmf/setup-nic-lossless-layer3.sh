#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 1/17/2017
# Ref: https://community.mellanox.com/docs/DOC-2881
if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <interface> <device>"
    echo "  interface: e.g. eth4"
    echo "  device:    e.g. mlx5_2"
    exit 1
fi

INTERFACE=$1
DEVICE=$2

mlnx_qos -i $INTERFACE --trust dscp
sudo sh -c " echo 106 > /sys/class/infiniband/${DEVICE}/tc/1/traffic_class"
cma_roce_tos -d $DEVICE -t 106
sudo sysctl -w net.ipv4.tcp_ecn=1
mlnx_qos -i $INTERFACE --pfc 0,0,0,1,0,0,0,0 
