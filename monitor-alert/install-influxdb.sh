#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Updates:
#  - 11/01/2019: InfluxDB v1.7.8 
#  - 11/28/2017: Created
# Tested on Ubuntu 16.04

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <version>"
    echo "  version:    e.g. latest, 1.7.8, 1.4.2, etc."
    exit 1
fi

set -x

VERSION=$1

if [[ "$1" == "latest" ]]; then
  VERSION=1.7.8
fi

curl -LO https://dl.influxdata.com/influxdb/releases/influxdb_${VERSION}_amd64.deb
sudo dpkg -i influxdb_${VERSION}_amd64.deb


# Note: 
#   - You can restart telegraf by:
#       sudo systemctl restart influxd
#   - Configuration file location: /etc/influxdb/influxdb.conf

