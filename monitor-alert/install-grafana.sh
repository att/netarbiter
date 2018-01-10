#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 12/4/2017
# Tested on Ubuntu 16.04

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <version>"
    echo "  version:    e.g. latest, 4.6.2, etc."
    exit 1
fi

set -x
set -e

VERSION=$1

if [[ "$1" == "latest" ]]; then
  VERSION=4.6.2				# 12/4/2017
fi

curl -LO https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${VERSION}_amd64.deb
sudo apt-get install -y libfontconfig
sudo dpkg -i grafana_4.6.2_amd64.deb 

