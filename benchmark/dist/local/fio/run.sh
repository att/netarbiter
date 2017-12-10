#!/bin/bash
# Author: Moo-Ryong Ra <mra@research.research.att.com>
# Modified on: 12/7/2017 by Hee Won Lee <knowpd@research.att.com>

#set -x
set -e

# Default variables
FIO_RANDBSLIST=${FIO_RANDBSLIST:-""}		# e.g., "4k 8k 32k"
FIO_SEQBSLIST=${FIO_SEQBSLIST:-""}		# e.g., "128k 1024k 4096k"
FIO_READRATIOLIST=${FIO_READRATIOLIST:-"0"}	# e.g., "0 30 50 70 100"
FIO_IODEPTHLIST=${FIO_IODEPTHLIST:-"1"}		# e.g., "1 8 16 32 64"
FIO_NUMJOBSLIST=${FIO_NUMJOBSLIST:-"1"}		# e.g., "1 8 16 32"

# Prepare for result dirs
n=0
while ! mkdir ../res-$n
do
    n=$((n+1))
done
export res_dir=../res-$n
mkdir $res_dir/job
mkdir $res_dir/out


# random test
if [ -n "$FIO_RANDBSLIST" ]; then
    for bs in $FIO_RANDBSLIST; do
        for readratio in $FIO_READRATIOLIST; do
            for iodepth in $FIO_IODEPTHLIST; do
                for numjobs in $FIO_NUMJOBSLIST; do
                    ./exec_fio.sh randrw $bs $readratio $iodepth $numjobs
		done
            done
        done
    done
fi

# sequential test
if [ -n "$FIO_SEQBSLIST" ]; then
    for bs in $FIO_SEQBSLIST; do
        for readratio in $FIO_READRATIOLIST; do
            for iodepth in $FIO_IODEPTHLIST; do
                for numjobs in $FIO_NUMJOBSLIST; do
                    ./exec_fio.sh rw $bs $readratio $iodepth $numjobs
		done
            done
        done
    done
fi
