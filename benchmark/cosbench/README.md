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
2. Browse `http://domain:19088/controller`.

## Run
1. Prepare a workload configuration file.
```
cp conf/swift-config-sample.xml conf/swift-config-test.xml
```
2. Define a workload.   
In `conf/swift-config-test.xml`, edit authentication info. An example is as follows:
```
<auth type="keystone" config="username=admin;password=admin123;tenant_name=admin;auth_url=http://voyager5:5000/v2.0;service=swift;region=RegionOne" />
```
   * Note: 
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
3. Submit the workload.
```
./cli.sh submit conf/swift-config-test.xml 
```
4. To find the result, browse `http://domain:19088/controller`.
