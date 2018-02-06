# Monitoring and Alerting 
Authors: Hee Won Lee <knowpd@research.att.com>  
Created on: 12/1/2017   

### InfluxDB and Telegraf
Refer to [InfluxDB-Telegraf.md](./InfluxDB-Telegraf.md)

### Grafana
* Install   
```
./install-grafana.sh latest
```

* Start  
Browse to `http://<server_ip>:3000/login`  and log in with the username `admin` and password `admin`.

* Dashboard: Sample  
After login on your browser, go to `Dashboards/Import` and import [grafana-dashboard-fio-sample.json](grafana-dashboard-fio-sample.json).

### Prometheus
Refer to [prometheus/README.md](./prometheus/README.md)
