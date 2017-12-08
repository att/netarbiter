#!/usr/bin/python
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on: 12/6/2017

import sys, os, socket, subprocess, json
from pprint import pprint

filename = sys.argv[1]
#filename ='direct/res/out/randrw-4k-30-32.txt'     # for debugging

influxdbip = os.getenv('INFLUXDBIP', 'yourmonitor.research.att.com') 
dbname = os.getenv('DBNAME', 'telegraf')
user = os.getenv('USER', 'influx')
password = os.getenv('PASSWORD', 'yourpassword')

def run_bash(cmd):
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
    (stdout, stderr) = proc.communicate()
    return stdout + stderr

# Load a json file
with open(filename) as data_file:
    fio_output = json.load(data_file)

#pprint(fio_output)         # for debugging

# Create a query
query = ''
for job in fio_output['jobs']:
    e = ('fio,hostname=' + socket.gethostname() +
         ',jobname=' + job['jobname'] +
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
         ',write_clat_percentile_95=' + str(job['write']['clat']['percentile']['95.000000']) +
         ',write_clat_percentile_99=' + str(job['write']['clat']['percentile']['99.000000']))
    query = query + e + '\n'

# Send data to InfluxDB
cmd = ("curl -i -XPOST 'http://" + influxdbip + ":8086/write?db=" + dbname +
       "&u=" + user + "&p=" + password + "'"
       " --data-binary " + "'" + query.rstrip() + "'")
run_bash(cmd)

#print cmd              # for debugging
#print run_bash(cmd)    # for debugging

