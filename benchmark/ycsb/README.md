YCSB
====

Install
-------
Ref: https://github.com/brianfrankcooper/YCSB
```
curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.15.0/ycsb-0.15.0.tar.gz
tar xfvz ycsb-0.15.0.tar.gz
cd ycsb-0.15.0
```

Redis test
----------
## Install/run Redis server   
ref: <https://redis.io/download>
```
wget http://download.redis.io/releases/redis-5.0.0.tar.gz
tar xzf redis-5.0.0.tar.gz
cd redis-5.0.0
make
src/redis-server 
```

## YCSB Test 
Refer to `ycsb-0.15.0/redis-binding/README.md`  
Workload file: workloada-redis(./workloada-redis)
```
# Load
bin/ycsb load redis -s -P workloads/workloada-redis -p threadcount=24

# Run
bin/ycsb run redis -s -P workloads/workloada-redis -p threadcount=24 > output-redis.txt
```

Aerospike test
--------------
Refer to `ycsb-0.15.0/aerospike-binding/README.md`  
Workload file: workloada-aerospike(./workloada-aerospike)

### YCSB Test: namespace - ram
```
# Load
bin/ycsb load aerospike -s -P workloads/workloada-aerospike -p as.namespace=ram -p threadcount=24

# Drop pagecache
sudo su -c 'echo 1 > /proc/sys/vm/drop_caches'

# Run
bin/ycsb run aerospike -s -P workloads/workloada-aerospike -p as.namespace=ram -p threadcount=24 > output-aerospike-ram.txt
```

### YCSB Test: namespace: disk
```
# Load
bin/ycsb load aerospike -s -P workloads/workloada-aerospike -p as.namespace=disk -p threadcount=24

# Drop pagecache
sudo su -c 'echo 1 > /proc/sys/vm/drop_caches'

# Run
bin/ycsb run aerospike -s -P workloads/workloada-aerospike -p as.namespace=disk -p threadcount=24 > output-aerospike-disk.txt
```
