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
