# Telegraf HOWTO 
Authors: Hee Won Lee <knowpd@research.att.com>
Created on: 12/1/2017

### Collect Disk IOPS and Network Interface Traffic
Ref: <https://www.crybit.com/sysstat-sar-on-ubuntu-debian>

To collect *disk.tps*, *network.rxkB_per_s*, *network.rxkB_per_s*, etc., take the following steps:

1. Install `sysstat`:
   1. Install the SAR utility:
   ```
   apt-get install sysstat
   ```
   
   2. In `/etc/default/sysstat`, change `ENABLED=”false”` to `ENABLED=”true”`.
   
   3. In `/etc/cron.d/sysstat`, change the collection interval from every 10 minutes to every 2 minutes.  
   Change
   ```
   5-55/10 * * * * root command -v debian-sa1 > /dev/null && debian-sa1 1 1
   ```
   To
   ```
   */2 * * * * root command -v debian-sa1 > /dev/null && debian-sa1 1 1
   ```
   4. Restart `sysstat`:
   ```
   systemctl restart sysstat
   ```

2. Configure `telegraf.conf`:
   1. In `/etc/telegraf/telegraf.conf`, uncomment the following lines:
   ```
   [[inputs.sysstat]]
     sadc_path = "/usr/lib/sysstat/sadc" # required
   
     [inputs.sysstat.options]
       -d = "disk"             # requires DISK activity
       "-n ALL" = "network"
   ```
   
   2. Restart `telegraf`:
   ```
   systemctl restart telegraf
   ```
