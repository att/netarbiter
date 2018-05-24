CNI HOWTO
=========

### Understanding CNI (Container Networking Interface)  
source: <http://www.dasblinkenlichten.com/understanding-cni-container-networking-interface>

```
$ mkdir cni; cd cni:
$ curl -O -L https://github.com/containernetworking/cni/releases/download/v0.4.0/cni-amd64-v0.4.0.tgz
$ tar xzvf cni-amd64-v0.4.0.tgz 

$ sudo ip netns add 1234567890
$ ip netns list
1234567890 (id: 2)

$ cat > mybridge.conf <<"EOF"
{
    "cniVersion": "0.2.0",
    "name": "mybridge",
    "type": "bridge",
    "bridge": "cni_bridge0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "subnet": "10.15.20.0/24",
        "routes": [
            { "dst": "0.0.0.0/0" },
            { "dst": "1.1.1.1/32", "gw":"10.15.20.1"}
        ]
    }
}
EOF

$ sudo CNI_COMMAND=ADD CNI_CONTAINERID=1234567890 CNI_NETNS=/var/run/netns/1234567890 \
CNI_IFNAME=eth12 CNI_PATH=`pwd` ./bridge <mybridge.conf
```
To test
```
$ ip link list
181: cni_bridge0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 0a:58:0a:0f:14:01 brd ff:ff:ff:ff:ff:ff
182: vethdf3524a4@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cni_bridge0 state UP mode DEFAULT group default 
    link/ether ae:60:1f:50:b4:14 brd ff:ff:ff:ff:ff:ff link-netnsid 2

$ sudo ip netns exec 1234567890 ip link list
4: eth12@if182: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 0a:58:0a:0f:14:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0

$ sudo ip netns exec 1234567890 ifconfig
eth12     Link encap:Ethernet  HWaddr 0a:58:0a:0f:14:02  
          inet addr:10.15.20.2  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::448d:8aff:fe3a:5058/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:15 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1206 (1.2 KB)  TX bytes:648 (648.0 B)
          
$ sudo ip netns exec 1234567890 ip route
default via 10.15.20.1 dev eth12 
1.1.1.1 via 10.15.20.1 dev eth12 
10.15.20.0/24 dev eth12  proto kernel  scope link  src 10.15.20.2 

$ sudo iptables-save |grep mybridge
-A POSTROUTING -s 10.15.20.0/24 -m comment --comment "name: \"mybridge\" id: \"1234567890\"" -j CNI-26633426ea992aa1f0477097
-A CNI-26633426ea992aa1f0477097 -d 10.15.20.0/24 -m comment --comment "name: \"mybridge\" id: \"1234567890\"" -j ACCEPT
-A CNI-26633426ea992aa1f0477097 ! -d 224.0.0.0/4 -m comment --comment "name: \"mybridge\" id: \"1234567890\"" -j MASQUERADE
```


### Using CNI with Docker  
source: <http://www.dasblinkenlichten.com/using-cni-docker>

```
# Create a container
#   When using a network of ‘none’, it will create the network namespace for the container, 
#   but it will not attempt to connect the containers network namespace to anything else.
docker run --name cnitest --net=none -d jonlangemak/web_server_1

# To check
docker ps
docker exec cnitest ifconfig

cat > mybridge2.conf <<"EOF"
{
    "cniVersion": "0.2.0",
    "name": "mybridge",
    "type": "bridge",
    "bridge": "cni_bridge1",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "subnet": "10.15.30.0/24",
        "routes": [
            { "dst": "0.0.0.0/0" },
            { "dst": "1.1.1.1/32", "gw":"10.15.30.1"}
        ],
        "rangeStart": "10.15.30.100",
        "rangeEnd": "10.15.30.200",
        "gateway": "10.15.30.99"
    }
}
EOF
            
# Find 'SandboxKey' for CNI_NETNS and 'Id' for CNI_CONTAINERID
docker inspect cnitest |grep -E "SandboxKey|Id"

# Note:
#   In the world of Docker, the network namespace file location is referred to as the 
#   ‘SandboxKey’ and the ‘Id’ is the container ID assigned by Docker.
sudo CNI_COMMAND=ADD CNI_CONTAINERID=58351bcd7b2c6f2bdaf147f02c93b42456b3880d1edbbe3caef745d9701ae00e \
CNI_NETNS=/var/run/docker/netns/9ebc9ec9cc9a CNI_IFNAME=eth0 CNI_PATH=`pwd` ./bridge <mybridge2.conf
```

To test
```
$ ifconfig
cni_bridge1 Link encap:Ethernet  HWaddr 0a:58:0a:0f:1e:63  
          inet addr:10.15.30.99  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::18c4:aff:fe59:e60/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:536 (536.0 B)  TX bytes:648 (648.0 B)

veth415eaf10 Link encap:Ethernet  HWaddr de:f0:16:4c:eb:24  
          inet6 addr: fe80::dcf0:16ff:fe4c:eb24/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:648 (648.0 B)  TX bytes:648 (648.0 B)

$ docker exec cnitest ifconfig
eth0      Link encap:Ethernet  HWaddr 0a:58:0a:0f:1e:64  
          inet addr:10.15.30.100  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::e8ca:36ff:fe18:daba/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:648 (648.0 B)  TX bytes:648 (648.0 B)

$ ip link list
183: cni_bridge1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 0a:58:0a:0f:1e:63 brd ff:ff:ff:ff:ff:ff
184: veth415eaf10@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cni_bridge1 state UP mode DEFAULT group default 
    link/ether de:f0:16:4c:eb:24 brd ff:ff:ff:ff:ff:ff link-netnsid 3

$ docker exec -it cnitest ip link list
4: eth0@if184: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 0a:58:0a:0f:1e:64 brd ff:ff:ff:ff:ff:ff

$ docker exec cnitest ip route
default via 10.15.30.99 dev eth0 
1.1.1.1 via 10.15.30.1 dev eth0 
10.15.30.0/24 dev eth0  proto kernel  scope link  src 10.15.30.100 

$ ping 10.15.30.100
$ curl http://10.15.30.100

$ sudo iptables-save |grep mybridge
-A POSTROUTING -s 10.15.30.0/24 -m comment --comment "name: \"mybridge\" id: \"58351bcd7b2c6f2bdaf147f02c93b42456b3880d1edbbe3caef745d9701ae00e\"" -j CNI-3491076d6559f2628d67a9c8
-A CNI-3491076d6559f2628d67a9c8 -d 10.15.30.0/24 -m comment --comment "name: \"mybridge\" id: \"58351bcd7b2c6f2bdaf147f02c93b42456b3880d1edbbe3caef745d9701ae00e\"" -j ACCEPT
-A CNI-3491076d6559f2628d67a9c8 ! -d 224.0.0.0/4 -m comment --comment "name: \"mybridge\" id: \"58351bcd7b2c6f2bdaf147f02c93b42456b3880d1edbbe3caef745d9701ae00e\"" -j MASQUERADE
```


### IPAM and DNS with CNI  
source: <http://www.dasblinkenlichten.com/ipam-dns-cni>

Install rkt
```
wget https://github.com/coreos/rkt/releases/download/v1.25.0/rkt_1.25.0-1_amd64.deb
wget https://github.com/coreos/rkt/releases/download/v1.25.0/rkt_1.25.0-1_amd64.deb.asc
gpg --keyserver keys.gnupg.net --recv-key 18AD5014C99EF7E3BA5F6CE950BDD3E0FC8A365E
gpg --verify rkt_1.25.0-1_amd64.deb.asc
sudo dpkg -i rkt_1.25.0-1_amd64.deb

# To check
rkt version
```

The default directory rkt searches for network configuration files is ‘/etc/rkt/net.d/’
```
~# mkdir /etc/rkt/net.d; cd /etc/rkt/net.d
/etc/rkt/net.d# cat > custom_rkt_bridge.conf <<"EOF"
{
    "cniVersion": "0.2.0",
    "name": "customrktbridge",
    "type": "bridge",
    "bridge": "cni0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "subnet": "10.11.0.0/16",
        "routes": [
            { "dst": "0.0.0.0/0" }
        ]
    }
}
EOF

$ sudo rkt run --interactive --net=customrktbridge quay.io/coreos/alpine-sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr A2:EB:4B:30:7D:88  
          inet addr:10.11.0.2  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::a0eb:4bff:fe30:7d88/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:14 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1128 (1.1 KiB)  TX bytes:648 (648.0 B)

eth1      Link encap:Ethernet  HWaddr AE:11:E3:3A:E8:3F  
          inet addr:172.17.0.2  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::ac11:e3ff:fe3a:e83f/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:648 (648.0 B)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

# To test 
rkt list --full

~# more /var/lib/cni/networks/customrktbridge/10.11.0.2
d75c9e7e-3853-4b2b-a466-83af094d8442
```

Let’s take a look at a custom CNI network definition that uses DHCP for IPAM.  
From a shell window
```
$ cd ~/cni
$ sudo ./dhcp daemon
```

From another shell window
```
~# cd /etc/rkt/net.d
/etc/rkt/net.d# cat > custom_rkt_bridge_dhcp.conf <<"EOF"
{
    "cniVersion": "0.2.0",
    "name": "customrktbridgedhcp",
    "type": "macvlan",
    "master": "enp66s0f0",
    "ipam": {
        "type": "dhcp"
    }
}
EOF

$ sudo rkt run --interactive --net=customrktbridgedhcp quay.io/coreos/alpine-sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr BA:08:B3:AB:2E:E2  
          inet addr:10.20.0.8  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::b808:b3ff:feab:2ee2/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5 errors:0 dropped:0 overruns:0 frame:0
          TX packets:10 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:864 (864.0 B)  TX bytes:1276 (1.2 KiB)

eth1      Link encap:Ethernet  HWaddr 0E:31:64:71:1E:37  
          inet addr:172.17.0.3  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::c31:64ff:fe71:1e37/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:508 (508.0 B)  TX bytes:508 (508.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # ip route
10.20.0.0/24 dev eth0  src 10.20.0.8 
172.17.0.0/16 via 172.17.0.1 dev eth1  src 172.17.0.3 
172.17.0.1 dev eth1  src 172.17.0.3 
```



