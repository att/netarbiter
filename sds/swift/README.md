Swift
=====
Maintainer: Hee Won Lee <knowpd@research.att.com>

## Prerequisites
1. Upgrade Openstack packages to OpenStack Pike  
   - Refer to <https://docs.openstack.org/install-guide/environment-packages-ubuntu.html>

2. Install SQL database  
   - Refer to <https://docs.openstack.org/install-guide/environment-sql-database-ubuntu.html>

3. Install Keystone  
   - Refer to <https://docs.openstack.org/keystone/pike/install/keystone-install-ubuntu.html>

## Install Swift

### Configure networking
Refer to <https://docs.openstack.org/swift/pike/install/environment-networking.html>

### Install controller node
Refer to <https://docs.openstack.org/swift/pike/install/controller-install-ubuntu.html>

* Note
   - After running `openstack user create --domain default --password-prompt swift`, you need the following:
   ```
   openstack project create --domain default --description "Service Project" service
   # Refer to <https://docs.openstack.org/mitaka/install-guide-obs/keystone-users.html>
   ```
   - The `memcached` daemon, by default, runs on 127.0.0.1. Change it to `0.0.0.0` in `/etc/memcached.conf` and restart the daemon by running `service memcached restart`.


### Install storage nodes
Refere to <https://docs.openstack.org/swift/pike/install/storage-install-ubuntu-debian.html>

### Create initial rings
Ref: <https://docs.openstack.org/swift/pike/install/initial-rings.html>  

First of all, change to the `/etc/swift` directory.  

* Create account ring
```
# Create the base account.builder file:
# Note:
#   - swift-ring-builder <builder_file> create <part_power> <replicas> <min_part_hours>
#   - We have 8 drivers, and 800 (8*100) < 2^10. Hence, part_power = 10.  
swift-ring-builder account.builder create 10 3 1

# Add each storage node to the ring:
swift-ring-builder account.builder add --region 1 --zone 1 --ip 10.10.0.11 --port 6202 --device sdb --weight 100
swift-ring-builder account.builder add --region 1 --zone 1 --ip 10.10.0.11 --port 6202 --device sdc --weight 100
swift-ring-builder account.builder add --region 1 --zone 2 --ip 10.10.0.12 --port 6202 --device sdb --weight 100
swift-ring-builder account.builder add --region 1 --zone 2 --ip 10.10.0.12 --port 6202 --device sdc --weight 100
swift-ring-builder account.builder add --region 1 --zone 3 --ip 10.10.0.13 --port 6202 --device sdb --weight 100
swift-ring-builder account.builder add --region 1 --zone 3 --ip 10.10.0.13 --port 6202 --device sdc --weight 100
swift-ring-builder account.builder add --region 1 --zone 4 --ip 10.10.0.14 --port 6202 --device sdb --weight 100
swift-ring-builder account.builder add --region 1 --zone 4 --ip 10.10.0.14 --port 6202 --device sdc --weight 100

# Verify the ring contents:
swift-ring-builder account.builder

# Rebalance the ring:
swift-ring-builder account.builder rebalance
```

* Create container ring
```
# Create the base container.builder file:
swift-ring-builder container.builder create 10 3 1

# Add each storage node to the ring:
swift-ring-builder container.builder add --region 1 --zone 1 --ip 10.10.0.11 --port 6201 --device sdb --weight 100
swift-ring-builder container.builder add --region 1 --zone 1 --ip 10.10.0.11 --port 6201 --device sdc --weight 100
swift-ring-builder container.builder add --region 1 --zone 2 --ip 10.10.0.12 --port 6201 --device sdb --weight 100
swift-ring-builder container.builder add --region 1 --zone 2 --ip 10.10.0.12 --port 6201 --device sdc --weight 100
swift-ring-builder container.builder add --region 1 --zone 3 --ip 10.10.0.13 --port 6201 --device sdb --weight 100
swift-ring-builder container.builder add --region 1 --zone 3 --ip 10.10.0.13 --port 6201 --device sdc --weight 100
swift-ring-builder container.builder add --region 1 --zone 4 --ip 10.10.0.14 --port 6201 --device sdb --weight 100
swift-ring-builder container.builder add --region 1 --zone 4 --ip 10.10.0.14 --port 6201 --device sdc --weight 100

# Verify the ring contents:
swift-ring-builder container.builder

# Rebalance the ring:
swift-ring-builder container.builder rebalance
```

* Create object ring
```
# Create the base object.builder file:
swift-ring-builder object.builder create 10 3 1

# Add each storage node to the ring:
swift-ring-builder object.builder add --region 1 --zone 1 --ip 10.10.0.11 --port 6200 --device sdb --weight 100
swift-ring-builder object.builder add --region 1 --zone 1 --ip 10.10.0.11 --port 6200 --device sdc --weight 100
swift-ring-builder object.builder add --region 1 --zone 2 --ip 10.10.0.12 --port 6200 --device sdb --weight 100
swift-ring-builder object.builder add --region 1 --zone 2 --ip 10.10.0.12 --port 6200 --device sdc --weight 100
swift-ring-builder object.builder add --region 1 --zone 3 --ip 10.10.0.13 --port 6200 --device sdb --weight 100
swift-ring-builder object.builder add --region 1 --zone 3 --ip 10.10.0.13 --port 6200 --device sdc --weight 100
swift-ring-builder object.builder add --region 1 --zone 4 --ip 10.10.0.14 --port 6200 --device sdb --weight 100
swift-ring-builder object.builder add --region 1 --zone 4 --ip 10.10.0.14 --port 6200 --device sdc --weight 100

# Verify the ring contents:
swift-ring-builder object.builder

# Rebalance the ring:
swift-ring-builder object.builder rebalance
```

* Distribute ring configuration files  
Copy the `account.ring.gz`, `container.ring.gz`, and `object.ring.gz` files to the `/etc/swift` directory on each storage node and any additional nodes running the proxy service.

## Finalize installation  
Refer to <https://docs.openstack.org/swift/pike/install/finalize-installation-ubuntu-debian.html>

On the controller node and any other nodes running the proxy service, restart the Object Storage proxy service including its dependencies:  
```
sudo service memcached restart
sudo service swift-proxy restart
```

On the storage nodes, start the Object Storage services:  
```
sudo swift-init all start
```

## Verify operation
Refer to <https://docs.openstack.org/swift/pike/install/verify.html>
```
. demo-openrc		# OR . admin-openrc
swift stat
openstack container create container1
openstack object create container1 myfile.txt
openstack object list container1
openstack object save container1 myfile.txt
```
After saving `myfile.txt`, the service status is as follows:  
```
$ swift stat
                        Account: AUTH_2bccc882410f47f2b6e443ff6652d412
                     Containers: 1
                        Objects: 1
                          Bytes: 32
Containers in policy "policy-0": 1
   Objects in policy "policy-0": 1
     Bytes in policy "policy-0": 32
    X-Account-Project-Domain-Id: default
         X-Openstack-Request-Id: txdc5c3855393c425ea47d4-005a9ab810
                    X-Timestamp: 1520025972.57070
                     X-Trans-Id: txdc5c3855393c425ea47d4-005a9ab810
                   Content-Type: text/plain; charset=utf-8
                  Accept-Ranges: bytes
```

## Deployment Guide
Ref: <https://docs.openstack.org/swift/pike/deployment_guide.html>

### Deployment Options
* Proxy Services:  
   - CPU and network I/O intensive
   - scale overall API throughput by adding more Proxies.
   - A high-availability (HA) deployment of Swift requires that multiple proxy servers are deployed and requests are load-balanced between them. 
   - Each proxy server instance is stateless and able to respond to requests for the entire cluster.
* Storages Services (Object, Container, and Account Services): 
   - Disk and network I/O intensive
   - scale out horizontally as storage servers are added.

### Preparing Ring
1. Determine the number of partitions that will be in the ring.
   - We recommend that there be a minimum of 100 partitions per drive to insure even distribution across the drives.
   - A good starting point might be to figure out the maximum number of drives the cluster will contain, and then multiply by 100, and then round up to the nearest power of two.
   - The more partitions there are, the more work that has to be done by the replicators and other backend jobs and the more memory the rings consume in process. 
   - The goal is to find a good balance between small rings and maximum cluster size.

2. Determine the number of replicas to store of the data. 
   - Recommendation: 3
3. Determine how many zones the cluster should have. 
   - Recommendation: 5 or above

## Troubleshoot   

Refer to [TROUBLESHOOT.md](./TROUBLESHOOT.md)

For debugging, take a look at syslog:
```
tail -f /var/log/syslog
```

## References  
1. Restart an OpenStack service:  
<https://docs.openstack.org/fuel-docs/latest/userdocs/fuel-user-guide/troubleshooting/restart-service.html>

2. admin-openrc
```
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=admin123
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```
