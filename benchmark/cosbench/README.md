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
1. Prepare your conf file.
```
cp conf/swift-config-sample.xml conf/swift-config-test.xml
```
2. Edit `conf/swift-config-test.xml`.  
For `auth_url`, use Keystone v2; COSBench does not support Keystone v3.
```
  <auth type="keystone" config="username=admin;password=admin123;tenant_name=admin;auth_url=http://voyager5:5000/v2.0;service=swift;region=RegionOne" />
```
   * Note: 
      - The `region` name (i.e., "RegionOne") is case-sensitive.
      - You can check Resion by running `$ openstack endpoint list`
3. Submit the file.
```
./cli.sh submit conf/swift-config-test.xml 
```
4. To find the result, browse `http://domain:19088/controller`.
