# InfluxDB HOWTO 
Authors: Hee Won Lee <knowpd@research.att.com>  
Created on: 9/12/2017  

### Key Concepts
ref.: <https://docs.influxdata.com/influxdb/v1.3/concepts/key_concepts>  
- Fields are a *required* piece of InfluxDB’s data structure.
- Fields are not indexed, so they should not contain commonly-queried metadata.
- Tags are *optional* and indexed.
- A measurement is conceptually similar to a table.
- A single measurement can belong to different retention policies. 
- A retention policy describes how long InfluxDB keeps data (DURATION) and how many copies of those data are stored in the cluster (REPLICATION). 
- InfluxDB automatically creates a retention policy (duration = infinite and replication factor = 1).
```
> show retention policies
name    duration shardGroupDuration replicaN default
----    -------- ------------------ -------- -------
autogen 0s       168h0m0s           1        true
```
- InfluxDB is a schemaless database which means it’s easy to add new measurements, tags, and fields at any time.
- A series is the collection of data that share a retention policy, measurement, and tag set.

  
### Getting Started  
ref.: <http://docs.influxdata.com/influxdb/v1.3/introduction/getting_started>  

```
$ influx -precision rfc3339
> create database mydb
> show databases
> use mydb
> insert cpu,host=serverA,region=us_west value=0.64
> select "host", "region", "value" from "cpu"
> INSERT temperature,machine=unit42,type=assembly external=25,internal=37
> SELECT * FROM /.*/ LIMIT 1
```

### Schema Exploration  
ref.: <https://docs.influxdata.com/influxdb/v1.3/query_language/schema_exploration>
```
$ influx -precision rfc3339
> show databases
> use mydb
>
> select * from cpu
name: cpu
time                           host    region  value
----                           ----    ------  -----
2017-11-28T22:51:22.970376763Z serverA us_west 0.64
>
> select * from temperature
name: temperature
time                           external internal machine type
----                           -------- -------- ------- ----
2017-11-28T22:52:42.261175903Z 25       37       unit42  assembly
>
> show series
key
---
cpu,host=serverA,region=us_west
temperature,machine=unit42,type=assembly
>
> show measurements
name: measurements
name
----
cpu
temperature
>
> show tag keys
name: cpu
tagKey
------
host
region

name: temperature
tagKey
------
machine
type
>
> show tag keys from cpu
name: cpu
tagKey
------
host
region
>
> show tag keys from temperature
name: temperature
tagKey
------
machine
type
>
> show field keys
name: cpu
fieldKey fieldType
-------- ---------
value    float

name: temperature
fieldKey fieldType
-------- ---------
external float
internal float 
```

### Authentication and Authorization  
ref.: <https://docs.influxdata.com/influxdb/v1.3/query_language/authentication_and_authorization>

Authorization is only enforced once you’ve enabled authentication. By default, authentication is disabled, all credentials are silently ignored, and all users have all privileges.  

InfuxDB configuration files is  `/etc/influxdb/influxdb.conf`.  
What we need to do is find the HTTP authentication line, uncomment it and change it to true, like so:
```
  # Determines whether user authentication is enabled over HTTP/HTTPS.
  auth-enabled = true
```
Restart the InfluxDB service:
```
sudo systemctl restart influxdb
```
First of all, you *must* create user admin with a password.
```
$ infux
> create user admin with password 'admin_pw' with all privileges
```
Now, you can access InfluxDB with credentials.
```
$ influx -username admin -password admin_pw
# or 
# $ influx
#  > auth
#  username: admin
#  password: admin_pw
>
```
To set up a username and password in InfluxDB
```
> CREATE USER "influx" WITH PASSWORD 'influx_pass' WITH ALL PRIVILEGES

# To reset a user’s password:
> SET PASSWORD FOR influx = 'influx_pw'

# To check
> show users
```


### Queries
```
> select * from cpu where time > now() - 1h;
> select last(*) from cpu;
```
