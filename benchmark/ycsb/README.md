YCSB
====

Install
-------
ref: <https://github.com/brianfrankcooper/YCSB>
```
curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.15.0/ycsb-0.15.0.tar.gz
tar xfvz ycsb-0.15.0.tar.gz
cd ycsb-0.15.0
```

Redis
-----
### Install/run Redis server   
ref: <https://redis.io/download>
```
wget http://download.redis.io/releases/redis-5.0.0.tar.gz
tar xzf redis-5.0.0.tar.gz
cd redis-5.0.0
make
src/redis-server 
```

### YCSB Test 
Refer to `ycsb-0.15.0/redis-binding/README.md`  
Workload file: [workloada-redis](workloada-redis)
```
# Load
bin/ycsb load redis -s -P workloads/workloada-redis -p threadcount=24

# Run
bin/ycsb run redis -s -P workloads/workloada-redis -p threadcount=24 > output-redis.txt
```

Aerospike
---------
Refer to `ycsb-0.15.0/aerospike-binding/README.md`  
Workload file: [workloada-aerospike](workloada-aerospike)

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

Cassandra
---------
Refer to `ycsb-0.15.0/cassandra-bindin`
Workload file: [workloada-cassandra](workloada-cassandra)

### Creating a table for use with YCSB  
```
$ cqlsh
cqlsh> create keyspace ycsb
    WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor': 1 };
cqlsh> use ycsb;
cqlsh:ycsb> create table usertable (
        y_id varchar primary key,
        field0 varchar,
        field1 varchar,
        field2 varchar,
        field3 varchar,
        field4 varchar,
        field5 varchar,
        field6 varchar,
        field7 varchar,
        field8 varchar,
        field9 varchar); 


```

### YCSB Test
```
# Load
bin/ycsb load cassandra-cql -s -P workloads/workloada-cassandra -p threadcount=24 > outputLoad-disk.txt

# Drop pagecache
sudo su -c 'echo 1 > /proc/sys/vm/drop_caches'

# Run
bin/ycsb run cassandra-cql -s -P workloads/workloada-cassandra -p threadcount=24 > output-cassandra.txt
```
