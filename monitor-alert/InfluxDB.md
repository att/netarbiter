# InfluxDB 
Maintainer: Hee Won Lee <knowpd@research.att.com>  
Ref: <http://www.oznetnerd.com/installing-setting-up-influxdb-telegraf-grafana> 

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

## Notes
[1] Find more information in [InfluxDB\_HOWTO.md](./InfluxDB_HOWTO.md)

