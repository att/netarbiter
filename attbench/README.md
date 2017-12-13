# ATTBench 
Authors: Hee Won Lee <knowpd@research.att.com> and Moo-Ryong Ra <mra@research.att.com>   
Created on: 12/1/2017   

### Prerequisites
- Install *InfluxDB* (and *Grafana*) in a monitoring server, and *Telegraf* in host machines where you want to collect metrics.  
Refer to <https://github.com/att/netarbiter/tree/master/influxdb-telegraf-grafana>

- Install Python's yaml module in a host (or container) where you run ATTBench.
```
sudo apt-get install python-pip
sudo pip install pyaml
```

### Local test
To run ATTBench from a local host, 
1. Go to directory `local'
2. Create your own config file.  For details, refer to [config-sample.yaml](local/config-sample.yaml).
```
cp config-sample.yaml config.yaml
```  
3. Run
```
./start.py <benchmark_tool>

# Fio Example:
./start.py fio
```

As of now, ATTBench supports Fio.

### Distributed test
You can concurrently run ATTBench on mutiple hosts.   

TBA
