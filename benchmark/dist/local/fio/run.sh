#!/bin/bash
# Author: Moo-Ryong Ra <mra@research.research.att.com>
# Modified on: 12/7/2017 by Hee Won Lee <knowpd@research.att.com>

#set -x
set -e

# For debugging
FIO_RANDBSLIST=${FIO_RANDBSLIST:-"4k 8k 32k"}
FIO_SEQBSLIST=${FIO_SEQBSLIST:-"128k 1024k 4096k"}
FIO_READRATIOLIST=${FIO_READRATIOLIST:-"0 30 50 70 100"}
FIO_IODEPTHLIST=${FIO_IODEPTHLIST:-"1 8 16 32 64"}

# Create directories for results
n=0
while ! mkdir ../res-$n
do
    n=$((n+1))
done

mkdir ../res-$n/job
mkdir ../res-$n/log
mkdir ../res-$n/out

export res_dir=../res-$n

# random test
for bs in $FIO_RANDBSLIST
do
	for readratio in $FIO_READRATIOLIST
	do
		for iodepth in $FIO_IODEPTHLIST
		do
			./exec_fio.sh randrw $bs $readratio $iodepth
		done
	done
done

# sequential test
for bs in $FIO_SEQBSLIST
do
	for readratio in $FIO_READRATIOLIST
	do
		for iodepth in $FIO_IODEPTHLIST
		do
			./exec_fio.sh rw $bs $readratio $iodepth
		done
	done
done
