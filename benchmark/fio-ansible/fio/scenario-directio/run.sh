#!/bin/bash
# Author: Moo-Ryong Ra <mra@research.research.att.com>
# Modified on: 12/7/2017 by Hee Won Lee <knowpd@research.att.com>

#set -x
set -e

# Setup
bslist_rand="4k 8k 32k"
bslist_seq="128k 1024k 4096k"
readratiolist="0 30 50 70 100"
iodepthlist="1 8 16 32 64"

# random test
for bs in $bslist_rand
do
	for readratio in $readratiolist
	do
		for iodepth in $iodepthlist
		do
			./exec_fio.sh randrw $bs $readratio $iodepth
		done
	done
done

# sequential test
for bs in $bslist_seq
do
	for readratio in $readratiolist
	do
		for iodepth in $iodepthlist
		do
			./exec_fio.sh rw $bs $readratio $iodepth
		done
	done
done





