#!/bin/bash
# Author: Moo-Ryong Ra <mra@research.research.att.com>
# Modified on: 12/7/2017 by Hee Won Lee <knowpd@research.att.com>

#set -x
set -e

DEVLIST=${DEVLIST:-"sdc"}
rw=$1
bs=$2
readratio=$3
iodepth=$4

jobfile="res/job/$rw-$bs-$readratio-$iodepth.fio"
logfile="res/log/fio-summary.log"
outfile="res/out/$rw-$bs-$readratio-$iodepth.json"

# Create directories for results
mkdir -p res/job
mkdir -p res/log 
mkdir -p res/out

# Create a fio job file
echo "[global]" > $jobfile
echo "ioengine=libaio" >> $jobfile
echo "direct=1" >> $jobfile
echo "size=400G" >> $jobfile
echo "ramp_time=5" >> $jobfile
echo "runtime=10" >> $jobfile
echo "invalidate=1" >> $jobfile
echo "rw=$rw" >> $jobfile
echo "bs=$bs" >> $jobfile
echo "rwmixread=$readratio" >> $jobfile
echo "iodepth=$iodepth" >> $jobfile
echo "" >> $jobfile

for i in $DEVLIST
do
	echo "[$i]" >> $jobfile
	echo "filename=/dev/$i" >> $jobfile
	echo "" >> $jobfile
done

# Run fio
sudo fio --output-format=json --output=$outfile $jobfile

# Log setup
echo "rw=$rw bs=$bs readratio=$readratio iodepth=$iodepth" >> $logfile

# Parse fio output and send it to InfluxDB server
../parse_and_report_influxdb.py $outfile >> $logfile
