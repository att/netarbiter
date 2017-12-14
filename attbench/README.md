# ATTBench 
Authors: Hee Won Lee <knowpd@research.att.com> and Moo-Ryong Ra <mra@research.att.com>   
Created on: 12/1/2017   

### Prerequisites
Install *InfluxDB* (and *Grafana*) in a monitoring server, and *Telegraf* in host machines where you want to collect metrics.  
For details, refer to <https://github.com/att/netarbiter/tree/master/influxdb-telegraf-grafana>

## Local test

### Dependencies
Install fio, bc and python's yaml module in a host (or container) where you run ATTBench.
```
sudo apt-get install fio bc
sudo apt-get install python-pip
sudo pip install pyaml
```

### Configure
1. Go to directory `local`.

2. Create your own config file:
```
cp config-sample.yaml yourconfig.yaml
```  

3. Edit yourconfig.yaml for your environment.  
For details, refer to [config-sample.yaml](local/config-sample.yaml).

### Run
```
./start.py -c yourconfig.yaml <benchmark_tool>

# Example:
./start.py fio
```
* Note: ATTBench currently supports Fio and plans to support COSBench.


## Distributed test
You can concurrently run ATTBench on mutiple hosts.

### Dependencies
You require *Ansible*.
```
sudo apt install ansible
```

### Configure
1. Set up an Ansible inventory:
  - [option 1] Edit /etc/ansible/hosts.
  - [option 2] Create your own inventory file (e.g., `yourhosts.ini`) as follows.  
For details, refer to [hosts-sample.ini](hosts-sample.ini).

2. Configure InfluxDB and Fio variables in `group_vars/hostgroup`.
```
cd group_vars; cp hostgroup-sample hostgroup
```
For details, refer to [group_vars/hostgroup-sample](group_vars/hostgroup-sample).
   
### Install
To install dependencies (fio, bc, pyaml) in your group of hosts, run:
```
# For /etc/ansible/hosts:
ansible-playbook install-prerequisites.yaml

# For your own inventory file (e.g., yourhosts.ini)
ansible-playbook -i yourhosts.ini install-prerequisites.yaml
```

### Run
```
# For /etc/ansible/hosts:
ansible-playbook start-fio.yaml

# For your own inventory file (e.g., yourhosts.ini)
ansible-playbook -i yourhosts.ini start-fio.yaml
```
