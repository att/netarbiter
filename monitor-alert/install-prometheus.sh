#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 1/5/2018
# Tested on Ubuntu 16.04

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <version>"
    echo "  version:    e.g. latest, 2.0.0, etc."
    exit 1
fi

set -x

VERSION=$1

if [[ "$1" == "latest" ]]; then
  VERSION=2.0.0			# 1/5/2018
fi

curl -LO https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz
tar xzvf prometheus-${VERSION}.linux-amd64.tar.gz
