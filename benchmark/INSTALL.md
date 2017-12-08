# InfluxDB/Telegraf/Grafana  
Authors: Hee Won Lee <knowpd@research.att.com>  
Created on: 12/1/2017   
Ref: <http://www.oznetnerd.com/installing-setting-up-influxdb-telegraf-grafana>  

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

## Grafana
### Install
```
./install-grafana.sh latest
```

### Configure
Browse to `http://<server_ip>:3000/login`  and log in with the username `admin` and password `admin`.

