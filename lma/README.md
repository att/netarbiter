# Loggging, Monitoring and Alerting  
Authors: Hee Won Lee <knowpd@research.att.com>  
Created on: 9/12/2017  

## InfluxDB  
### Getting Started  
src: <http://docs.influxdata.com/influxdb/v1.3/introduction/getting_started>  

```
$ influx -precision rfc3339
> create database mydb
> show databases
> use mydb
> insert cpu,host=serverA,region=us_west value=0.64
> select "host", "region", "value" FROM "cpu"
> INSERT temperature,machine=unit42,type=assembly external=25,internal=37
> SELECT * FROM /.*/ LIMIT 1
```

### Schema Exploration  
src: <https://docs.influxdata.com/influxdb/v1.3/query_language/schema_exploration/>
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
