FROM ubuntu:16.04
MAINTAINER Hee Won Lee "knowpd@research.att.com"

RUN apt-get update && apt-get install -y vim iputils-ping net-tools dnsutils curl python
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN mv /kubectl /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl
