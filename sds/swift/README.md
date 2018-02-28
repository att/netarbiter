Swift
=====
Maintainer: Hee Won Lee <knowpd@research.att.com>

## Prerequisites
1. Install SQL database  
   - Refer to <https://docs.openstack.org/install-guide/environment-sql-database-ubuntu.html>

2. Install Keystone  
   - Refer to <https://docs.openstack.org/keystone/pike/install/keystone-install-ubuntu.html>

## Install Swift

### Install controller node
Refer to <https://docs.openstack.org/swift/latest/install/controller-install-ubuntu.html>

### Install storage nodes
Refere to <https://docs.openstack.org/swift/latest/install/storage-install-ubuntu-debian.html>

### Create initial rings
Ref: <https://docs.openstack.org/swift/latest/install/initial-rings.html>  

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

## Deployment Guide
Ref: <https://docs.openstack.org/swift/latest/deployment_guide.html>

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

