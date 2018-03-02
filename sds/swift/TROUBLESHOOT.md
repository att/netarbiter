Troubleshoot
============
Contributors:   
  - Hee Won Lee <knowpd@research.att.com>

## Problem 
- Symptom    
```
# su -s /bin/sh -c "keystone-manage db_sync" keystone
2018-02-28 15:42:00.890 5592 CRITICAL keystone [-] OperationalError: (pymysql.err.OperationalError) (1044, u"Access denied for user 'keystone'@'%' to da
tabase 'keystone\t# by hlee'")
2018-02-28 15:42:00.890 5592 ERROR keystone Traceback (most recent call last):
2018-02-28 15:42:00.890 5592 ERROR keystone   File "/usr/bin/keystone-manage", line 10, in <module>
2018-02-28 15:42:00.890 5592 ERROR keystone     sys.exit(main())
```
```
# keystone-manage bootstrap --bootstrap-password keystone123   --bootstrap-admin-url http://controller:35357/v3/   --bootstrap-internal-url http://controller:5000/v3/   --bootstrap-public-url http://controller:5000/v3/   --bootstrap-region-id RegionOne                         
2018-02-28 15:49:31.433 9869 WARNING keystone.assignment.core [-] Deprecated: Use of the identity driver config to automatically configure the same assignment driver has been deprecated, in the "O" release, the assignment driver will need to be expicitly configured if different than the default (SQL).
2018-02-28 15:49:31.517 9869 CRITICAL keystone [-] ValueError: Empty module name
2018-02-28 15:49:31.517 9869 ERROR keystone Traceback (most recent call last):
2018-02-28 15:49:31.517 9869 ERROR keystone   File "/usr/bin/keystone-manage", line 10, in <module>
2018-02-28 15:49:31.517 9869 ERROR keystone     sys.exit(main())
```

- Cause  
In `/etc/keystone/keystone.conf`, my comment (`by hlee`) caused the error.
```
[database]
connection = mysql+pymysql://keystone:keystone123@controller/keystone	# by hlee
provider = fernet	# by hlee
```

- Solution  
In `/etc/keystone/keystone.conf`, do not make any comment at the end of each line.


## Problem  
- Symptom:  
```
$ apt update
...
"GPG error: http://linux.dell.com/repo/community/ubuntu trusty Release: The following signatures couldn't be verified because the public key is not available"
```

- Solution:
Ref: <https://www.dell.com/community/General/Ubuntu-update-manager-failing-with-Dell-repository/m-p/3891784>  
```
gpg --keyserver pool.sks-keyservers.net --recv-key 1285491434D8786F
gpg -a --export 1285491434D8786F | apt-key add -
apt-get updat
```

## Problem
- Symptom:  
```
$ apt update
The repository 'http://ppa.launchpad.net/ubuntu-lxc/lxd-stable/ubuntu xenial Release' does not have a Release file.h
```

- Solution: 
Ref: <https://ubuntuforums.org/showthread.php?t=2324228> 
Disable/remove the lxc ppa, as it does not exist for 16.04.
```
sudo rm /etc/apt/sources.list.d/ubuntu-lxc-ubuntu-lxd-stable-xenial.list
sudo rm /etc/apt/sources.list.d/ubuntu-lxc-ubuntu-lxd-stable-xenial.list.save
```
