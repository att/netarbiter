#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <subcommand>"
    echo "  subcommand:    prep, redis-start, redis-shutdown, ycsb-start, clean"
    exit 1
fi

set -x
set -e

PORT_BEGIN=7000
PORT_END=7039
YCSB_DIR=$HOME/pkg/ycsb-0.15.0
INIT_DIR=$(pwd)

# Prepare redis.conf & ycsb-workload
if [[ "$1" == "prep" ]]; then
  for port in $(seq $PORT_BEGIN $PORT_END); do
    mkdir ${port}
    cd ${port}
  
    cat >redis.conf << EOF
port ${port}
daemonize yes
#cluster-enabled yes
#cluster-config-file nodes.conf
#cluster-node-timeout 5000
#appendonly yes

dir ./
loglevel notice
logfile ${port}.log

save 900 1
save 300 10
save 60 10000
EOF

    cat >ycsb-workload << EOF
# by hlee 
redis.host=127.0.0.1
# default port 6379
redis.port=${port}
#redis.cluster=true
#threadcount=50
#measurementtype=histogram
#measurementtype=timeseries
#measurementtype=raw
#measurement.raw.output_file = /tmp/redis_output_histogram

# Yahoo! Cloud System Benchmark
# Workload A: Update heavy workload
#   Application example: Session store recording recent actions
#                        
#   Read/update ratio: 50/50
#   Default data size: 1 KB records (10 fields, 100 bytes each, plus key)
#   Request distribution: zipfian

recordcount=2000000
operationcount=2000000
workload=com.yahoo.ycsb.workloads.CoreWorkload

readallfields=true

readproportion=0.5
updateproportion=0.5
scanproportion=0
insertproportion=0

# The distribution of requests across the keyspace
#requestdistribution=zipfian
requestdistribution=uniform
#requestdistribution=latest
EOF

    cd ..
  done
  exit
fi

# Start redis-server processes
if [[ "$1" == "redis-start" ]]; then
  for port in $(seq $PORT_BEGIN $PORT_END); do
    cd ${port}
    redis-server redis.conf
    cd ..
  done
  exit
fi

# Shut down redis-server processes
if [[ "$1" == "redis-shutdown" ]]; then
  for port in $(seq $PORT_BEGIN $PORT_END); do
    redis-cli -p ${port} shutdown &
  done
  exit
fi

# Start YCSB test

if [[ "$1" == "ycsb-start" ]]; then
  # Make dir for result
  n=0
  while ! mkdir res-$n
  do
      n=$((n+1))
  done
  RES_DIR=$INIT_DIR/res-$n

  for port in $(seq $PORT_BEGIN $PORT_END); do
    pushd $YCSB_DIR
    bin/ycsb load redis -s -P $INIT_DIR/${port}/ycsb-workload -p threadcount=30 > $RES_DIR/output-redis-${port}.txt &
    popd
  done
  exit
fi

# Clean
if [[ "$1" == "clean" ]]; then
  for port in $(seq $PORT_BEGIN $PORT_END); do rm -rf ${port}; done
fi
