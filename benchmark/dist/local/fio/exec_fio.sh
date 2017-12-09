#!/bin/bash
# Author: Moo-Ryong Ra <mra@research.research.att.com>
# Modified on: 12/7/2017 by Hee Won Lee <knowpd@research.att.com>

#set -x
set -e

rw=$1
bs=$2
readratio=$3
iodepth=$4

# Note: `res_dir` is exported from `run.sh`.
jobfile="$res_dir/job/$rw-$bs-$readratio-$iodepth.fio"
logfile="$res_dir/log/fio-summary.log"
outfile="$res_dir/out/$rw-$bs-$readratio-$iodepth.json"

# Create a fio job file
echo "[global]" > $jobfile
echo "ioengine=libaio" >> $jobfile
echo "direct=1" >> $jobfile
echo "size=400G" >> $jobfile
echo "ramp_time=5" >> $jobfile
echo "runtime=5" >> $jobfile
echo "invalidate=1" >> $jobfile
echo "rw=$rw" >> $jobfile
echo "bs=$bs" >> $jobfile
echo "rwmixread=$readratio" >> $jobfile
echo "iodepth=$iodepth" >> $jobfile
echo "" >> $jobfile

# Note: `DEVLIST` is defined in `../start.sh`.
for i in $FIO_DEVLIST
do
	echo "[$i]" >> $jobfile
	echo "filename=/dev/$i" >> $jobfile
	echo "" >> $jobfile
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
