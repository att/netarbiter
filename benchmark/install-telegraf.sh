#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 11/28/2017
# Tested on Ubuntu 16.04

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <version>"
    echo "  version:    e.g. latest, 1.4.4-1, etc."
    exit 1
fi

set -x

VERSION=$1

if [[ "$1" == "latest" ]]; then
  VERSION=1.4.4-1			# 11/28/2017
fi

curl -LO https://dl.influxdata.com/telegraf/releases/telegraf_${VERSION}_amd64.deb
sudo dpkg -i telegraf_${VERSION}_amd64.deb

# Note: 
#   - Telegraf will start automatically using the default configuration when installed from a deb package.
#   - You can restart telegraf by:
#       sudo systemctl restart telegraf 
#   - Configuration file is located at /etc/telegraf/telegraf.conf
#   - Or you can create and edit a configuration file by:
#       telegraf -sample-config -input-filter cpu:mem -output-filter influxdb > telegraf.conf


