#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/29/2017

set -x

sudo service kubelet stop
sudo kubeadm reset
sudo apt-get purge -y kubelet kubectl
