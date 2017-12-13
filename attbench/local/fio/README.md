# FIO Tester
Authors: Moo-Ryong Ra <mra@research.att.com> and Hee Won Lee <knowpd@research.att.com>  

* [run.sh](run.sh): 
  - Main script to run a test for various blocksizes, r/w ratio, iodepth, numjobs 
 
* [exec-fio.sh](exec_fio.sh): 
  - Used by run.sh. 
  - Generate fio configuration, run, and trigger the report script (below).

* [parse-and-report-influxdb.py](parse-and-report-influxdb.py): 
  - Used by `exec_fio.sh`. 
  - Parse fio output logs and report to influxdb.

