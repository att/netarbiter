#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 9/1/2016

if [[ "$#" -lt 4 ]]; then
    echo "Usage: $0 <dev> <part_size> <part_num> <num_of_parts> [typecode]"
    echo "  dev:               e.g., /dev/sdb"
    echo "  part_size (GiB):   e.g., 10"
    echo "  part_num:          e.g., 1 (Starting partition number)"
    echo "  num_of_parts:      e.g., 8"
    echo "  typecode:          use 'ceph-journal' for Ceph's journal typecode"
    exit 1
fi

set -x

DEV=$1
PART_SIZE=$2
PART_NUM=$3
NUM_OF_PARTS=$4
TYPECODE=$5

idx_end=$(($PART_NUM + $NUM_OF_PARTS - 1))

# Create partitions
#  - Ceph journal partition's typecode is 45b0969e-9b03-4f30-b4c6-b4b80ceff106.
for i in $(seq $PART_NUM $idx_end); do
  if [ "$TYPECODE" = "ceph-journal" ]; then
    sudo sgdisk --new=$i:0:+"$PART_SIZE"G --mbrtogpt --typecode=$i:45b0969e-9b03-4f30-b4c6-b4b80ceff106 -- $DEV

  else
    sudo sgdisk --new=$i:0:+"$PART_SIZE"G --mbrtogpt -- $DEV
  fi
done

# Change device ownership from root:disk to ceph:ceph
#sleep 1 		#  needs some time to complete creating partitions
sudo chown ceph:ceph $DEV*
