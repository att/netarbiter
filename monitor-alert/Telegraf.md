# Telegraf 
Authors: Hee Won Lee <knowpd@research.att.com>  
Ref: <http://www.oznetnerd.com/installing-setting-up-influxdb-telegraf-grafana> 

## Install
```
./install-telegraf.sh latest
```

## Configure
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

## Notes
[1] Find more information in [Telegraf\_HOWTO.md](./Telegraf_HOWTO.md)

