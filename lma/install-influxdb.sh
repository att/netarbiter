#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 11/28/2017
# Tested on Ubuntu 16.04

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <version>"
    echo "  version:    e.g. latest, 1.4.2, etc."
    exit 1
fi

set -x

VERSION=$1

if [[ "$1" == "latest" ]]; then
  VERSION=1.4.2			# 11/28/2017
fi

curl -LO https://dl.influxdata.com/influxdb/releases/influxdb_${VERSION}_amd64.deb
sudo dpkg -i influxdb_${VERSION}_amd64.deb


# Note: 
#   - You can restart telegraf by:
#       sudo systemctl restart influxd
#   - Configuration file location: /etc/influxdb/influxdb.conf

# Example: http://docs.influxdata.com/influxdb/v1.3/introduction/getting_started
#   $ influx -precision rfc3339
#   Connected to http://localhost:8086 version 1.4.2
#   InfluxDB shell version: 1.4.2
#   > create database mydb
#   > show databases
#   > use mydb
#   > insert cpu,host=serverA,region=us_west value=0.64
#   > select * from cpu
#   > SELECT "host", "region", "value" FROM "cpu"
#   > INSERT temperature,machine=unit42,type=assembly external=25,internal=37
#   > SELECT * FROM /.*/ LIMIT 1
