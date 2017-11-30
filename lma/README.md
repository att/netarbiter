# Loggging, Monitoring and Alerting  
Authors: Hee Won Lee <knowpd@research.att.com>  
Created on: 9/12/2017  

## InfluxDB  
source: <http://docs.influxdata.com/influxdb/v1.3/introduction/getting_started>  

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
