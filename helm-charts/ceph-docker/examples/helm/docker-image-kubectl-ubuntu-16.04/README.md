# Docker image for kubectl on Ubuntu 16.04
Author: Hee Won Lee <knowpd@research.att.com>  
Created on: 10/12/2017  

### Purpose
This image is used in `ceph/templates/jobs/job.yaml`, which generates ceph keys in K8s secrets.

### Build 
1. Create your account in `https://hub.docker.com`.

2. Log in and create a repository (e.g., ceph).

3. Build your image.
```
docker build -t your_account/your_repository:kubectl-ubuntu-16.04 .
```

4. Push your image to Docker Hub.
```
$ docker login -u your_account
$ docker push your_account/your_repository:kubectl-ubuntu-16.04
```

