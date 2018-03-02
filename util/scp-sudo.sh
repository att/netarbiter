#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 3/2/2018

if [[ "$#" -ne 3 ]]; then
    echo "Usage: $0 <file_path> <remote_hostname> <remote_dir>"
    echo "  file_path:       e.g. /etc/rsyncd.conf  "
    echo "  remote_hostname: e.g. voyager1"
    echo "  remote_dir:      e.g. /etc"
    echo ""
    exit 1
fi

FILE_PATH=$1
REMOTE_HOSTNAME=$2
REMOTE_DIR=$3

scp $FILE_PATH $REMOTE_HOSTNAME:/tmp && ssh $REMOTE_HOSTNAME sudo mv /tmp/$(basename "$FILE_PATH") $REMOTE_DIR
