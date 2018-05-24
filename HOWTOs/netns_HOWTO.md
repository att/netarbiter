netns, Linux Network Namespace HOWTO
====================================
source: <http://blog.scottlowe.org/2013/09/04/introducing-linux-network-namespaces>

### Key commands
```
ip netns add <network namespace>
ip netns exec <network namespace> <command to run against that namespace>
ip link list
ip addr list
ip route list
```

### Create a network namespace
```
ip netns add blue

# To test
ip netns list

ip link add veth0 type veth peer name veth1
ip link list
ip link set veth1 netns blue
```

### Create a pair of virtual Ethernet interface (veth)
```
~# ip link add veth0 type veth peer name veth1
~# ip link list
6: veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether ee:d4:03:81:7e:b2 brd ff:ff:ff:ff:ff:ff
7: veth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:9e:f7:d2:40:48 brd ff:ff:ff:ff:ff:ff


~# ip link set veth1 netns blue
~# ip link list
7: veth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:9e:f7:d2:40:48 brd ff:ff:ff:ff:ff:ff

~# ip netns exec blue ip link list
6: veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether ee:d4:03:81:7e:b2 brd ff:ff:ff:ff:ff:ff
```

### Set ip address
```
~# ip netns exec blue ifconfig veth1 10.1.1.1/24 up
~# ip addr list
7: veth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 52:9e:f7:d2:40:48 brd ff:ff:ff:ff:ff:ff

~# ip netns exec blue ip addr list
6: veth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
    link/ether ee:d4:03:81:7e:b2 brd ff:ff:ff:ff:ff:ff
    inet 10.1.1.1/24 brd 10.1.1.255 scope global veth1
       valid_lft forever preferred_lft forever
```

LWN.net - Namespaces in operation, part 7: Network namespaces
=============================================================
source: <https://lwn.net/Articles/580893>

```
ip netns add netns1
```
it will create a bind mount for it under /var/run/netns.

```
ip netns delete netns1
```
This command removes the bind mount referring to the given network namespace.

- New network namespaces will have a loopback device but no other network devices.
- Physical devices (those connected to real hardware) cannot be assigned to namespaces other than the root. 
- Instead, virtual network devices (e.g. virtual ethernet or veth) can be created and assigned to a namespace.
These virtual devices allow processes inside the namespace to communicate over the network

```
ip netns exec netns1 ip link set dev lo up

ip link add veth0 type veth peer name veth1
ip link set veth1 netns netns1
ip netns exec netns1 ifconfig veth1 10.1.1.1/24 up
ifconfig veth0 10.1.1.2/24 up

# Packets sent to veth0 will be received by veth1 and vice versa.
ping 10.1.1.1
ip netns exec netns1 ping 10.1.1.2
ip netns exec netns1 route
ip netns exec netns1 iptables -L
```
- Non-root processes that are assigned to a namespace (via clone(), unshare(), or setns()) only have access to the networking devices and configuration that have been set up in that namespace.
- Using the ip netns sub-command, there are two ways to address a network namespace: by its name, like netns1, 
or by the process ID of a process in that namespace.

Since init generally lives in the root namespace, one could use a command like:
```
ip link set vethX netns 1
```
That would put a (presumably newly created) veth device into the root namespace.

Container implementations also use network namespaces to give each container its own view of the network, 
untrammeled by processes outside of the container. 


