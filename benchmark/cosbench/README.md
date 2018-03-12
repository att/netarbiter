COSBench
========
Maintainer: Hee Won Lee <knowpd@research.att.com>  

## Prerequisites
```
sudo apt install openjdk-8-jre 
```
## Install
1. Download `v0.4.2 release candidate 4`
   - Note on 3/8/2018:  Other versions may not work. 
```
curl -LO https://github.com/intel-cloud/cosbench/releases/download/v0.4.2.c4/0.4.2.c4.zip
unzip 0.4.2.c4.zip
cd 0.4.2.c4
chmod +x *.sh
./start-all.sh
```
2. Browse `http://<server-ip>:19088/controller`.

## Run
1. Prepare a workload configuration file.
```
cp conf/swift-config-sample.xml conf/swift-config-test.xml
```
2. Define a workload.   
   * Autentication Method 1:  
   In `conf/swift-config-test.xml`, edit `<auth ...>` as follows:
   ```
   <auth type="keystone" config="username=admin;password=admin123;tenant_name=admin;auth_url=http://voyager5:5000/v2.0;service=swift;region=RegionOne" />
   ```
      - Note: 
         - For `auth_url`, use Keystone v2; COSBench does not support Keystone v3. The above example is a translation from:
         ```
         swift --os-auth-url http://voyager5:5000/v3 --auth-version 3 \
         --os-project-domain-name Default --os-user-domain-name Default --os-project-name admin \
         --os-username admin --os-password admin123 list 
         ```
         - The `region` name (i.e., "RegionOne") is case-sensitive; you can check it by running `$ openstack endpoint list`. When using "regionOne", I encountered the following error:
         ```
         2018-03-08 15:36:54,423 [INFO] [Log4jLogManager] - will append log to file /home/knowpd/pkg/0.4.2.c4/log/mission/ME754B5714.log
         2018-03-08 15:36:55,050 [INFO] [NoneStorage] - performing PUT at /mycontainers1
         2018-03-08 15:36:55,051 [ERROR] [AbstractOperator] - worker 1 fail to perform operation mycontainers1
         com.intel.cosbench.api.storage.StorageException: java.lang.IllegalStateException: Target host must not be null, or set in parameters.
         	at com.intel.cosbench.api.swift.SwiftStorage.createContainer(SwiftStorage.java:188)
         ```
         Ref: <https://github.com/intel-cloud/cosbench/issues/282>
   
   * Autentication Method 2:  
   ```
   $ openstack token issue
   +------------+---------------------------------------------------+
   | Field      | Value                                             |
   +------------+---------------------------------------------------+
   | expires    | 2018-03-09T22:28:57+0000                          |
   | id         | gAAAAABaovyZMxKGDN--jkOFyT1JLQtZLxEXm99...-Yb8Epc | <-- HERE
   | project_id | 2bccc882410f47f2b6e443ff6652d412                  |
   | user_id    | 1b59bfc213e8496b84e5581950eb03c4                  |
   +------------+---------------------------------------------------+

   $ openstack endpoint list
   +----------------------------------+-----------+--------------+--------------+---------+-----------+-----------------------------------------------+
   | ID                               | Region    | Service Name | Service Type | Enabled | Interface | URL                                           |
   +----------------------------------+-----------+--------------+--------------+---------+-----------+-----------------------------------------------+
   | 8f518f85248e4a26a9afbd1880f7bd41 | RegionOne | swift        | object-store | True    | public    | http://controller:8080/v1/AUTH_%(project_id)s | <-- HERE
   | a0a869b27f3b4f3fba0b8ffffc566805 | RegionOne | keystone     | identity     | True    | internal  | http://controller:5000/v3/                    |
   | be5a56e018224f0eab606dc6721ad7ff | RegionOne | keystone     | identity     | True    | admin     | http://controller:35357/v3/                   |
   | c597dd05de2e496ab660ca31f7fff18b | RegionOne | swift        | object-store | True    | admin     | http://controller:8080/v1                     |
   | ee45941d59a94981b736276d9bd263ff | RegionOne | swift        | object-store | True    | internal  | http://controller:8080/v1/AUTH_%(project_id)s |
   | fe5bfb83bc8b454990422cd20375a8e6 | RegionOne | keystone     | identity     | True    | public    | http://controller:5000/v3/                    |
   +----------------------------------+-----------+--------------+--------------+---------+-----------+-----------------------------------------------+

   $ openstack project list
   +----------------------------------+---------+
   | ID                               | Name    |
   +----------------------------------+---------+
   | 2bccc882410f47f2b6e443ff6652d412 | admin   | <--- HERE
   | 65ee2e82f27b4a6d9950036963e32f54 | service |
   +----------------------------------+---------+
   ```
   In `conf/swift-config-test.xml`, edit `<storage ...>` as follows:
   ```
   <storage type="swift" config="token=gAAAAABaovyZMxKGDN--jkOFyT1JLQtZLxEXm99...-Yb8Epc;storage_url=http://voyager5:8080/v1/AUTH_2bccc882410f47f2b6e443ff6652d412" />
   ```
      - Note:
         - Remove `<auth type="keystone" ...>` if you have the previous auth configuration.

3. Submit the workload.
```
./cli.sh submit conf/swift-config-test.xml 
```
4. To find the result, browse `http://<server_ip>:19088/controller`.


## Troubleshoot   

Refer to [TROUBLESHOOT.md](./TROUBLESHOOT.md)
