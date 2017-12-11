#!/bin/bash
# Author: Moo-Ryong Ra <mra@research.research.att.com>
# Modified on: 12/7/2017 by Hee Won Lee <knowpd@research.att.com>

#set -x
set -e

rw=$1
bs=$2
readratio=$3
iodepth=$4
numjobs=$5

# Default variables
FIO_DEVLIST=${FIO_DEVLIST:-"sdf sdg"}
FIO_DIRECT=${FIO_DIRECT:-"1"}
FIO_SIZE=${FIO_SIZE:-"400G"}
FIO_RUNTIME=${FIO_RUNTIME:-"60"}

# Prepare for result files
jobfile="$res_dir/job/$rw-$bs-$readratio-$iodepth-$numjobs.fio"
outfile="$res_dir/out/$rw-$bs-$readratio-$iodepth-$numjobs.json"
logfile="$res_dir/fio-summary.log"

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

for i in $FIO_DEVLIST; do
    for j in $(seq 1 $numjobs); do
        echo "[$i]" >> $jobfile
        echo "filename=/dev/$i" >> $jobfile
        echo "" >> $jobfile
    done
done

# Run fio
sudo fio --output-format=json --output=$outfile $jobfile

# Log current setup
printf "\nFio completed: "
echo "rw=$rw bs=$bs readratio=$readratio iodepth=$iodepth numjobs=$numjobs" #| tee -a $logfile

# Drop caches
if [ $FIO_DIRECT == '1' ]; then
    echo "Drop caches!"
    sudo su -c 'echo 3 > /proc/sys/vm/drop_caches'
fi 

# Translate bs into a number
#   e.g., 4k or 4K -> 4, 256b or 256B -> 0.256
str=$2
i=$((${#str}-1))
unit="${str:$i:1}"
bs=$(echo $2 | sed -e "s/[KkBb]$//")
if [ "$unit" = "B" ] || [ "$unit" = "b" ]; then
    parsed=$(echo "scale=3; $bs/1000" | bc)
    bs=`echo "0"$parsed`
fi

echo "Parse fio output and send it to InfluxDB server:"
./parse_and_report_influxdb.py $outfile $rw $bs $readratio $iodepth $numjobs | tee -a $logfile
echo '' >> $logfile
