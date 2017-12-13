# ATTBench 
Authors: Hee Won Lee <knowpd@research.att.com> and Moo-Ryong Ra <mra@research.att.com>   
Created on: 12/1/2017   

### Prerequisites
1. Install *InfluxDB* and *Grafana* (optional) in a monitoring server.
2. Install *Telegraf* in host machines where you want to collect metrics.
3. Install Python's yaml module in a host/container where you run attbench (i.e., `start.py`).
```
sudo apt-get install python-pip
sudo pip install pyaml
```

### Local test
You can run ATTBench from a local host. 
```
# Go to directory `local'.
cd local

# Prepare your config file
cp config-sample.yaml config.yaml


# Edit `config.yaml' and Run
./start.py <benchmark_tool>
```

* As of now, ATTBench supports: 
  - Fio
  - COSBench (to be supported)

### Distributed test
You can concurrently run ATTBench on mutiple hosts. 
