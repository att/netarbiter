# Monitoring and Alerting 
Maintainer: Hee Won Lee <knowpd@research.att.com>  
Ref: <http://www.oznetnerd.com/installing-setting-up-influxdb-telegraf-grafana>  

## Grafana
### Install   
```
./install-grafana.sh latest
```

### Start  
Browse to `http://<server_ip>:3000/login`  and log in with the username `admin` and password `admin`.

### Dashboard: Sample  
After login on your browser, go to `Dashboards/Import` and import [grafana-dashboard-fio-sample.json](grafana-dashboard-fio-sample.json).


## InfluxDB
### Install
```
./install-influxdb.sh latest
```

### Create user/password  
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

## Telegraf
### Install
```
./install-telegraf.sh latest
```

### Configure
Edit `/etc/telegraf/telegraf.conf`.
In `[[outputs.influxdb]]` section, uncomment the username and password lines and make sure their values match those which you set in InfluxDB:
```
  username = "influx"
  password = "influx_pw"
```
Restart the Telegraf service:
```
sudo systemctl restart telegraf
```

### Prometheus
### Install 
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

## Notes
[1] Find more information in [InfluxDB\_HOWTO.md](./InfluxDB_HOWTO.md)
[2] Find more information in [Telegraf\_HOWTO.md](./Telegraf_HOWTO.md)
