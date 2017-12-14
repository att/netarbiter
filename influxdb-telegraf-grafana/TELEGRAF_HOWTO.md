# Telegraf HOWTO 
Authors: Hee Won Lee <knowpd@research.att.com>
Created on: 12/1/2017

### Collect Disk IOPS and Network Interface Traffic
Ref: <https://www.crybit.com/sysstat-sar-on-ubuntu-debian>

To collect `disk.tps` and `network.rxkB_per_s`, `network.rxkB_per_s`, etc., take the following steps:

1. Install sysstat
  1. Install the SAR utility:
  ```
  apt-get install sysstat
  ```
  
  2. From `/etc/default/sysstat`, change `ENABLED=”false”` to `ENABLED=”true”`.
  ```
  vi /etc/default/sysstat
  ----
  # Should sadc collect system activity informations? Valid values
  # are "true" and "false". Please do not put other values, they
  # will be overwritten by debconf!
  ENABLED="true"
  ----
  ```
  
  3. Change the collection interval from every 10 minutes to every 2 minutes
  ```
  ----
  vi /etc/cron.d/sysstat
  Change
  5-55/10 * * * * root command -v debian-sa1 > /dev/null && debian-sa1 1 1
  To
  */2 * * * * root command -v debian-sa1 > /dev/null && debian-sa1 1 1
  ----
  ```
  4. Restart service
  ```
  systemctl restart sysstat
  ```

2. Configure `telegraf.conf`
In `/etc/telegraf/telegraf.conf`, uncomment the following lines:
```
[[inputs.sysstat]]
  sadc_path = "/usr/lib/sysstat/sadc" # required

  [inputs.sysstat.options]
    -d = "disk"             # requires DISK activity
    "-n ALL" = "network"
```

