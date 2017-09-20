
# Overview 
NetArbiter enables you to stitch multiple OpenStack clusters and emulate the network delay and bandwidth.

For details, see <https://github.com/att/netarbiter/blob/master/netarbiter.pdf>.

# Prerequisites
For Ubuntu:
```
$ sudo apt-get install ansible
```
For Mac OS X:
```
$ brew install ansible
```

# How to run 
1. Setup
  1. Add your public key (i.e., id_rsa.pub) to each server's authorized_keys.
  2. Store all hosts' domain names (or IP addresses) to an inventory file "all"
  3. Create an inventory file for each link between two sites. This file is for route-create.yml and route-destroy.yml

2. Create/destroy a qrouter (and an ovs bridge) in a host
   ```
   $ ansible-playbook -K -i hosts/all qrouter-create.yml -e HOST=<hostname> 
   $ ansible-playbook -K -i hosts/all qrouter-destroy.yml -e HOST=<hostname> 
   ```

3. Create/destroy routes (and tunnels) to connect two sites 
   ```
   $ ansible-playbook -K -i hosts/<inventory> route-create.yml
   $ ansible-playbook -K -i hosts/<inventory> route-destroy.yml
   ```

4. Create delay, rate, and ceil with tc/netem
   ```
   $ ansible-playbook -K -i hosts/<inventory> netemu-create.yml [-e DELAY=<delay> -e RATE=<rate> CEIL=<ceil>]
   $ ansible-playbook -K -i hosts/<inventory> netemu-destroy.yml [-e DELAY=<delay> -e RATE=<rate> CEIL=<ceil>]
   ```

   NOTE:
    - Default delay and bandwidth are configured in each link's inventroy file. 
    - Refer to tc manual(i.e., $ man tc) for the units of delay, rate, and ceil. 
