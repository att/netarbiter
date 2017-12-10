#!/usr/bin/python
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on: 12/6/2017

import sys, os, socket, subprocess, json
from pprint import pprint

filename = sys.argv[1]
rw = sys.argv[2]
bs = sys.argv[3]
readratio = sys.argv[4]
iodepth = sys.argv[5]

# Default variables
ip = os.getenv('INFLUXDB_IP', '10.1.2.3')
port = os.getenv('INFLUXDB_PORT', '8086')
dbname = os.getenv('INFLUXDB_DBNAME', 'telegraf')
user = os.getenv('INFLUXDB_USER', 'influx')
password = os.getenv('INFLUXDB_PASSWORD', 'influx_pw')

def run_bash(cmd):
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
    (stdout, stderr) = proc.communicate()
    return stdout + stderr

# Load a json file
with open(filename) as data_file:
    fio_output = json.load(data_file)

#pprint(fio_output)         # for debugging

# Calculate total iops/lat/bw
total_read_iops = 0
total_write_iops = 0
total_read_lat = 0
total_write_lat = 0
total_read_bw = 0
total_write_bw = 0
for job in fio_output['jobs']:
    total_read_iops = total_read_iops + job['read']['iops']
    total_write_iops = total_write_iops + job['write']['iops']
    total_read_bw = total_read_bw + job['read']['bw']
    total_write_bw = total_write_bw + job['write']['bw']
    total_read_lat = total_read_lat + job['read']['lat']['mean']
    total_write_lat = total_write_lat + job['write']['lat']['mean']
total_read_lat = total_read_lat / len(fio_output['jobs']) 
total_write_lat = total_write_lat / len(fio_output['jobs']) 

total_iops = total_read_iops + total_write_iops
total_bw = total_read_bw + total_write_bw
#total_lat = (total_read_lat + total_write_lat) / 2
# note: total_lat seems not meaningful; for read only (total_write_lat = 0), 
#      total_lat = total_read_lat / 2, which is incorrect!

# Add a query for total iops/bw/lat
query = ''
e = ('fio,host=' + socket.gethostname() + ',rw=' + rw +
     ',bs=' + str(bs) +  ',readratio=' + str(readratio) + ',iodepth=' + str(iodepth) +
     ' total_iops=' + str(total_iops) +
     ',total_bw=' + str(total_bw) +
     ',total_read_lat=' + str(total_read_lat) +
     ',total_write_lat=' + str(total_write_lat))
query = query + e + '\n'

# Add queries per fio job
for job in fio_output['jobs']:
    e = ('fio,host=' + socket.gethostname() + ',jobname=' + job['jobname'] + ',rw=' + rw +
         ',bs=' + str(bs) +  ',readratio=' + str(readratio) + ',iodepth=' + str(iodepth) +
         ' sys_cpu=' + str(job['sys_cpu']) +
         ',usr_cpu=' + str(job['usr_cpu']) +
         ',read_bw=' + str(job['read']['bw']) +
         ',read_iops=' + str(job['read']['iops']) +
         ',read_lat_mean=' + str(job['read']['lat']['mean']) +
         ',read_lat_stddev=' + str(job['read']['lat']['stddev']) +
         ',read_clat_percentile_95=' + str(job['read']['clat']['percentile']['95.000000']) +
         ',read_clat_percentile_99=' + str(job['read']['clat']['percentile']['99.000000']) +
         ',write_bw=' + str(job['write']['bw']) +
         ',write_iops=' + str(job['write']['iops']) +
         ',write_lat_mean=' + str(job['write']['lat']['mean']) +
         ',write_lat_stddev=' + str(job['write']['lat']['stddev']) +
         ',write_clat_percentile_95=' + str(job['write']['clat']['percentile']['95.000000']) +
         ',write_clat_percentile_99=' + str(job['write']['clat']['percentile']['99.000000']))
    query = query + e + '\n'

# Send data to InfluxDB
cmd = ("curl -i -XPOST 'http://" + ip + ":" + port + "/write?db=" + dbname +
       "&u=" + user + "&p=" + password + "'"
       " --data-binary " + "'" + query.rstrip() + "'")
print cmd   # required for logging
run_bash(cmd)
#print run_bash(cmd)    # for debugging

