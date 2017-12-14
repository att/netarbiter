# ATTBench 
Authors: Hee Won Lee <knowpd@research.att.com> and Moo-Ryong Ra <mra@research.att.com>   
Created on: 12/1/2017   

### Preparation
- Install *InfluxDB* (and *Grafana*) in a monitoring server, and *Telegraf* in host machines where you want to collect metrics.  
Refer to <https://github.com/att/netarbiter/tree/master/influxdb-telegraf-grafana>


## Local test

### Install prerequisites
Install fio, bc and python's yaml module in a host (or container) where you run ATTBench.
```
sudo apt-get install fio bc
sudo apt-get install python-pip
sudo pip install pyaml
```

### Configure and Run
1. Go to directory `local'

2. Create your own config file. 
```
cp config-sample.yaml yourconfig.yaml
```  

3. Edit yourconfig.yaml for your environment.  
For configuration details, refer to [config-sample.yaml](local/config-sample.yaml).

4. Run
```
./start.py -c yourconfig.yaml <benchmark_tool>

# Example:
./start.py fio
```
Note: Currently ATTBench supports Fio.


## Distributed test
You can concurrently run ATTBench on mutiple hosts.

### Configure
1. Set up Ansible inventory:
  - [option 1] Edit /etc/ansible/hosts
  - [option 2] Create your own inventory file as follows:
  ```
  [hostgroup]
  yourhostname1
  yourhostname2
  
  [hostgroup:vars]
  user=yourid  
  ```

2. Configure InfluxDB and Fio variables in `group_vars/hostgroup`.
```
---
env:
#  INFLUXDB_IP: 10.1.2.3     # (influxdb) IP or domain name
#  INFLUXDB_PORT: 8086       # (influxdb) Port
#  INFLUXDB_DBNAME: yourdb   # (influxdb) Database name (which should be created beforehand)
#  INFLUXDB_USER: yourid     # (influxdb) User ID
#  INFLUXDB_PASSWORD: yourpw # (influxdb) Password

#  FIO_RUNTIME: 300                    # FIO runtime (unit: sec)
#  FIO_DIRECT: 1                       # 1: Direct IO, 2: Buffered IO
#  FIO_SIZE: 400G                      # io size
  FIO_DEVLIST: "sdc"              # block list
#  FIO_RANDBSLIST: "4k 8k 32k"         # random block size list (optional)
#  FIO_SEQBSLIST: "128k 1024k 4096k"   # sequential block size list (optional)
#  FIO_READRATIOLIST: "0 30 50 70 100" # read/write ratio: e.g., 30 means read 30% and write 70%
#  FIO_IODEPTHLIST: "1 8 16 32 64"     # io depth list
#  FIO_NUMJOBSLIST: "1 8 16 32"        # number of jobs list
```
   
### Install prerequisites
To automatically install prerequisites (fio, bc, pyaml) in a group of hosts, run:
```
ansible-playbook -i hosts install-prerequisites.yaml
```

### Run
```
ansible-playbook -i hosts start-fio.yaml
```
