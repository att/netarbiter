# ATTBench 
Authors: Hee Won Lee <knowpd@research.att.com> and Moo-Ryong Ra <mra@research.att.com>   
Created on: 12/1/2017   

### Prerequisites
- Install *InfluxDB* (and *Grafana*) in a monitoring server, and *Telegraf* in host machines where you want to collect metrics.  
Refer to <https://github.com/att/netarbiter/tree/master/influxdb-telegraf-grafana>

- Install Python's yaml module in a host (or container) where you run ATTBench (i.e., `start.py`).
```
sudo apt-get install python-pip
sudo pip install pyaml
```

### Local test
You can run ATTBench from a local host. 
```
# Go to directory `local'
cd local

# Prepare your config file
cp config-sample.yaml config.yaml


# Edit `config.yaml' and Run
./start.py <benchmark_tool>
```

As of now, ATTBench supports: 
  - Fio
  - COSBench (to be supported)

### Distributed test
You can concurrently run ATTBench on mutiple hosts.   

TBA
