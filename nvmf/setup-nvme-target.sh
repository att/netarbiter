#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 11/11/2017

set -x
set -e

NVME_SUBSYSTEM_NAME=nvme-eris101
NUMBER_OF_PORTS=1

# Prerequisites
sudo modprobe mlx5_core
sudo modprobe nvmet
sudo modprobe nvmet-rdma
sudo modprobe nvme-rdma

# NVMe Target Configuration
sudo mkdir -p /sys/kernel/config/nvmet/subsystems/$NVME_SUBSYSTEM_NAME
sudo bash -c "echo 1 > /sys/kernel/config/nvmet/subsystems/$NVME_SUBSYSTEM_NAME/attr_allow_any_host"
sudo mkdir -p /sys/kernel/config/nvmet/subsystems/$NVME_SUBSYSTEM_NAME/namespaces/10
sudo bash -c "echo -n /dev/nvme0n1> /sys/kernel/config/nvmet/subsystems/$NVME_SUBSYSTEM_NAME/namespaces/10/device_path"
sudo bash -c "echo 1 > /sys/kernel/config/nvmet/subsystems/$NVME_SUBSYSTEM_NAME/namespaces/10/enable"
sudo mkdir -p /sys/kernel/config/nvmet/ports/$NUMBER_OF_PORTS
sudo bash -c "echo 10.154.0.61 > /sys/kernel/config/nvmet/ports/$NUMBER_OF_PORTS/addr_traddr"
sudo bash -c "echo rdma > /sys/kernel/config/nvmet/ports/$NUMBER_OF_PORTS/addr_trtype"
sudo bash -c "echo 4420 > /sys/kernel/config/nvmet/ports/$NUMBER_OF_PORTS/addr_trsvcid"
sudo bash -c "echo ipv4 > /sys/kernel/config/nvmet/ports/$NUMBER_OF_PORTS/addr_adrfam"
sudo ln -s /sys/kernel/config/nvmet/subsystems/$NVME_SUBSYSTEM_NAME /sys/kernel/config/nvmet/ports/$NUMBER_OF_PORTS/subsystems/$NVME_SUBSYSTEM_NAME

# Check
dmesg | grep "enabling port"
