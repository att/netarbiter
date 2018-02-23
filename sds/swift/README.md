Swift
=====
Maintainer: Hee Won Lee <knowpd@research.att.com>

## Deployment Guide
Ref: <https://docs.openstack.org/swift/latest/deployment_guide.html#>

### Deployment Options
* Proxy Services:  
   - CPU and network I/O intensive
   - scale overall API throughput by adding more Proxies.
   - A high-availability (HA) deployment of Swift requires that multiple proxy servers are deployed and requests are load-balanced between them. 
   - Each proxy server instance is stateless and able to respond to requests for the entire cluster.
* Storages Services (Object, Container, and Account Services): 
   - Disk and network I/O intensive
   - scale out horizontally as storage servers are added.

### Preparing the Ring
1. Determine the number of partitions that will be in the ring.
   - We recommend that there be a minimum of 100 partitions per drive to insure even distribution across the drives.
   - A good starting point might be to figure out the maximum number of drives the cluster will contain, and then multiply by 100, and then round up to the nearest power of two.
   - The more partitions there are, the more work that has to be done by the replicators and other backend jobs and the more memory the rings consume in process. 
   - The goal is to find a good balance between small rings and maximum cluster size.

2. Determine the number of replicas to store of the data. 
   - Recommendation: 3
3. Determine how many zones the cluster should have. 
   - Recommendation: 5 or above
