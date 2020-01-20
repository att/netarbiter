#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/20/2017
# Modified on 
#   - 01/20/2020
#   - 02/01/2019

# Ref: https://helm.sh/docs/intro/install/
#   - note: Tiller, the server portion of Helm, typically runs inside
#         of your Kubernetes cluster.

set -x

VERSION=2.14.3	# previous: 2.9.1, 2.12.3
# You can find a new version at https://github.com/helm/helm/releases

# Download a binary version
curl -O https://get.helm.sh/helm-v${VERSION}-linux-amd64.tar.gz
#curl -O https://storage.googleapis.com/kubernetes-helm/helm-v${VERSION}-linux-amd64.tar.gz

# Install
tar xzvf helm-v${VERSION}-linux-amd64.tar.gz 
sudo cp linux-amd64/helm /usr/local/bin

# Cleanup
rm -rf linux-amd64
rm helm-v${VERSION}-linux-amd64.tar.gz
