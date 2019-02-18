#!/bin/bash
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 10/20/2017
# Modified on 2/1/2019

# Ref: https://docs.helm.sh/using_helm/#installing-helm
#   - note: Tiller, the server portion of Helm, typically runs inside
#         of your Kubernetes cluster.

set -x

VERSION=2.12.3	# previous: 2.9.1

# Download a binary version
curl -O https://storage.googleapis.com/kubernetes-helm/helm-v${VERSION}-linux-amd64.tar.gz

# Install
tar xzvf helm-v${VERSION}-linux-amd64.tar.gz 
sudo cp linux-amd64/helm /usr/local/bin

# Cleanup
rm -rf linux-amd64
rm helm-v${VERSION}-linux-amd64.tar.gz
