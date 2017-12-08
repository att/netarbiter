#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on: 12/6/2017

export INFLUXDBIP=10.0.0.1 
export DBNAME=telegraf
export USER=influx
export PASSWORD=influx_pw
export DEVLIST="sdb sdc"

# Scenario 1: Direct IO
cd scenario-directio; ./run.sh

# Scenario 2: Buffered IO 
#cd scenario-bufferedio; ./run.sh
