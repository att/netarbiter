#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 1/12/2018
# Tested on Ubuntu 16.04

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <version>"
    echo "  version:    e.g. latest, 0.15.2, etc."
    exit 1
fi

set -x

VERSION=$1

if [[ "$1" == "latest" ]]; then
  VERSION=0.15.2 		# 1/12/2018
fi

FILE=node_exporter-${VERSION}.linux-amd64.tar.gz

mkdir -p ~/prometheus; cd ~/prometheus
curl -LO https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/${FILE}
tar xzvf ${FILE}
rm ${FILE}
