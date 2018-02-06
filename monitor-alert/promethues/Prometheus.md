# Prometheus
Authors: Hee Won Lee <knowpd@research.att.com>  
Created on: 1/11/2018

### Install Prometheus 
Ref: <https://prometheus.io/docs/prometheus/latest/getting_started>  

```
# Install
./install-prometheus.sh <version>
# You can also run:
#   ./install-prometheus.sh latest

# Start
cd ~/prometheus/prometheus-<version>.linux-amd64/
./prometheus --config.file=prometheus.yml
```
- By default, Prometheus stores its database in ./data (flag --storage.tsdb.path).
- Browse to a status page about itself at `localhost:9090`.   
- Browse to its metrics endpoint at `localhost:9090/metrics`.

### Install Node Exporter
Ref: <https://prometheus.io/docs/introduction/first_steps>
```
# Install
./install-node-exporter.sh <version>
# You can also run:
#   ./install-node-exporter.sh latest

# Start
cd ~/prometheus/node_exporter-<version>.linux-amd64/
./node_exporter
```
Add a new job definition to the scrape_configs section in your `prometheus.yml`:
```
- job_name: node
    static_configs:
      - targets: ['localhost:9100']
```
Now restart `prometheus`:
```
./prometheus --config.file=prometheus.yml
```
