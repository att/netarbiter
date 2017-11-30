# Loggging, Monitoring and Alerting  
Authors: Hee Won Lee <knowpd@research.att.com>  
Created on: 9/12/2017  

## InfluxDB  
### Getting Started  
src: <http://docs.influxdata.com/influxdb/v1.3/introduction/getting_started>  

```
$ influx -precision rfc3339
Connected to http://localhost:8086 version 1.4.2
InfluxDB shell version: 1.4.2
> create database mydb
> show databases
> use mydb
> insert cpu,host=serverA,region=us_west value=0.64
> select * from cpu
> SELECT "host", "region", "value" FROM "cpu"
> INSERT temperature,machine=unit42,type=assembly external=25,internal=37
> SELECT * FROM /.*/ LIMIT 1
> show measurements
```

### Schema Exploration  
src: <https://docs.influxdata.com/influxdb/v1.3/query_language/schema_exploration/>
```
> select * from cpu
name: cpu
time                host    region  value
----                ----    ------  -----
1511909482970376763 serverA us_west 0.64
>
>
> select * from temperature
name: temperature
time                external internal machine type
----                -------- -------- ------- ----
1511909562261175903 25       37       unit42  assembly
>
>
> show series
key
---
cpu,host=serverA,region=us_west
temperature,machine=unit42,type=assembly
>
>
> show measurements
name: measurements
name
----
cpu
temperature
>
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
