#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/29/2017
# Modified on 1/30/2019

set -x

sudo service kubelet stop
sudo kubeadm reset
sudo rm -rf $HOME/.kube
sudo rm -f /usr/local/bin/kshell
sudo apt-get purge -y kubelet kubectl
sudo apt-get remove docker.io
