#!/bin/bash
# Author: Moo-Ryong Ra <mra@research.research.att.com>
# Modified on: 12/7/2017 by Hee Won Lee <knowpd@research.att.com>

#set -x
set -e

rw=$1
bs=$2
readratio=$3
iodepth=$4

# Default variables
FIO_DEVLIST=${FIO_DEVLIST:-"sdf sdg"}
FIO_NUMOFJOBS=${FIO_NUMOFJOBS:-"1"}
FIO_DIRECT=${FIO_DIRECT:-"1"}
FIO_SIZE=${FIO_SIZE:-"400G"}
FIO_RUNTIME=${FIO_RUNTIME:-"60"}

# Prepare for result dirs/files
n=0
while ! mkdir ../res-$n
do
    n=$((n+1))
done
res_dir=../res-$n

mkdir $res_dir/job
mkdir $res_dir/log
mkdir $res_dir/out

jobfile="$res_dir/job/$rw-$bs-$readratio-$iodepth.fio"
logfile="$res_dir/log/fio-summary.log"
outfile="$res_dir/out/$rw-$bs-$readratio-$iodepth.json"

# Create a fio job file
echo "[global]" > $jobfile
echo "ioengine=libaio" >> $jobfile
echo "direct=$FIO_DIRECT" >> $jobfile
echo "size=$FIO_SIZE" >> $jobfile
echo "ramp_time=5" >> $jobfile
echo "runtime=$FIO_RUNTIME" >> $jobfile
echo "invalidate=1" >> $jobfile
echo "rw=$rw" >> $jobfile
echo "bs=$bs" >> $jobfile
echo "rwmixread=$readratio" >> $jobfile
echo "iodepth=$iodepth" >> $jobfile
echo "" >> $jobfile

# Note: `DEVLIST` is defined in `../start.sh`.
for i in $FIO_DEVLIST; do
  for j in $(seq 1 $FIO_NUMOFJOBS); do
    echo "[$i]" >> $jobfile
    echo "filename=/dev/$i" >> $jobfile
    echo "" >> $jobfile
  done
done

# Run fio
sudo su -c 'echo 3 > /proc/sys/vm/drop_caches'
sudo fio --output-format=json --output=$outfile $jobfile

# Log current setup
printf "\nCompleted: "
echo "rw=$rw bs=$bs readratio=$readratio iodepth=$iodepth" #| tee -a $logfile

# Translate bs into a number
#   e.g., 4k or 4K -> 4, 256b or 256B -> 0.256
str=$2
i=$((${#str}-1))
unit="${str:$i:1}"
bs=$(echo $2 | sed -e "s/[KkBb]$//")
if [ "$unit" = "B" ] || [ "$unit" = "b" ]
then
        parsed=$(echo "scale=3; $bs/1000" | bc)
        bs=`echo "0"$parsed`
fi

# Parse fio output and send it to InfluxDB server
./parse_and_report_influxdb.py $outfile $rw $bs $readratio $iodepth | tee -a $logfile
echo '' >> $logfile
