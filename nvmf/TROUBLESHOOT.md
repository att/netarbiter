Troubleshoot
============
Contributors:   
  - Hee Won Lee <knowpd@research.att.com> 

## Problem: ping not working after configuring Mellanox Spectrum Switch
- Cause:  
```
# Log into your switch
(config) # show run
...
interface ethernet 1/13 switchport mode trunk
interface ethernet 1/14 switchport mode trunk
...
```
- Solution:  
```
(config) # no interface ethernet 1/13 switchport mode
(config) # no interface ethernet 1/14 switchport mode
```

## Problem:  
- Symptom: after running fio with 100% write
```
fio: io_u error on file /dev/nvme2n1: Input/output error: write offset=565273092096, buflen=4096
```
To check, run `dmesg`:
```
[95777.186816] nvmet_rdma: received IB QP event: last WQE reached (16)
```
