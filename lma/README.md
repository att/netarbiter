# Loggging, Monitoring and Alerting  
Authors: Hee Won Lee <knowpd@research.att.com>  
Created on: 9/12/2017  

## InfluxDB

### Key Concepts
src: <https://docs.influxdata.com/influxdb/v1.3/concepts/key_concepts>  
- Fields are a required piece of InfluxDB’s data structure.
- Fields are not indexed, so they should not contain commonly-queried metadata.
- Tags are optional and indexed.
- A measurement is conceptually similar to a table.
- A single measurement can belong to different retention policies. 
- A retention policy describes how long InfluxDB keeps data (DURATION) and how many copies of those data are stored in the cluster (REPLICATION). 
```
> show retention policies
name    duration shardGroupDuration replicaN default
----    -------- ------------------ -------- -------
autogen 0s       168h0m0s           1        true
```
- InfluxDB is a schemaless database which means it’s easy to add new measurements, tags, and fields at any time.

  
### Getting Started  
src: <http://docs.influxdata.com/influxdb/v1.3/introduction/getting_started>  

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
src: <https://docs.influxdata.com/influxdb/v1.3/query_language/schema_exploration>
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
