## RoCE Deployment

### Guide  
- [Recommended Network Configuration Examples for RoCE Deployment](https://community.mellanox.com/docs/DOC-2855)

### Option One: Layer 3 (DSCP-based)
Lossless fabric (requires PFC)
- Adapter: [Lossless RoCE Configuration for Linux Drivers in DSCP-Based QoS Mode](https://community.mellanox.com/docs/DOC-2881)
   ```
   # Find a mapping between interface and device by:
   lshw -c network -businfo
   ls -al /sys/class/infiniband 
   
   # Set up
   ./setup-nic-lossless-layer3.sh <interface> <device>
   ```

- Switch (advanced mode): [Lossless RoCE Configuration for MLNX-OS Switches in DSCP-Based QoS Mode (advanced mode)](https://community.mellanox.com/docs/DOC-2884)
   * For basic mode, refer to [Lossless RoCE Configuration for MLNX-OS Switches in DSCP-Based QoS Mode](https://community.mellanox.com/docs/DOC-3017)
   ```
   switch (config) # interface ethernet 1/13-1/16 traffic-class 3 congestion-control ecn minimum-absolute 150 maximum-absolute 1500
   switch (config) # pool ePool1 size 16777000 type dynamic
   switch (config) # pool ePool0 size 5242880 type dynamic
   switch (config) # pool iPool1 size 5242880 type dynamic
   switch (config) # pool iPool0 size 5242880 type dynamic
   
   switch (config) # interface ethernet 1/13-1/16 ingress-buffer iPort.pg6 bind switch-priority 6
   switch (config) # interface ethernet 1/13-1/16 ingress-buffer iPort.pg3 bind switch-priority 3
   
   switch (config) # interface ethernet 1/13-1/16 ingress-buffer iPort.pg3 map pool iPool1 type lossless reserved 67538 xoff 18432 xon 18432 shared alpha 2
   switch (config) # interface ethernet 1/13-1/16 ingress-buffer iPort.pg6 map pool iPool0 type lossy reserved 10240 shared alpha 8
   switch (config) # interface ethernet 1/13-1/16 egress-buffer ePort.tc3 map pool ePool1 reserved 1500 shared alpha inf
   switch (config) # interface ethernet 1/13-1/16 traffic-class 6 dcb ets strict
   switch (config) # interface ethernet 1/13-1/16 qos trust L3
   switch (config) # interface ethernet 1/13-1/16 dcb priority-flow-control mode on force
   ```

Lossy fabric (requires ECN)
- Adapter: [RoCE Configuration for Linux Drivers in DSCP-Based QoS Mode](https://community.mellanox.com/docs/DOC-2882)
- Switch: [RoCE Configuration for MLNX-OS Switches in PCP-Based QoS Mode](https://community.mellanox.com/docs/DOC-3016)


### Option Two: Layer 2 (PCP-based)
Lossless fabric (requires PFC)
- Adapter: [RoCE Configuration on Mellanox Adapters (PCP-Based Lossless Traffic)](https://community.mellanox.com/docs/DOC-2843) 
- Switch: [Lossless RoCE Configuration for MLNX-OS Switches in PCP-Based QoS Mode](https://community.mellanox.com/docs/DOC-3018)

Lossy fabric (requires ECN)
- Adapter: [RoCE Configuration for Mellanox Adapters (PCP-Based)](https://community.mellanox.com/docs/DOC-2883)
- Switch: [RoCE Configuration for MLNX-OS Switches in PCP-Based QoS Mode](https://community.mellanox.com/docs/DOC-3016)


### Tutorials
- [RoCE v2 Considerations](https://community.mellanox.com/docs/DOC-1451)
   * Difference between RoCE v1 and RoCE v2
      - RoCE v2 runs on UDP/IP.
   * [Resilient RoCE](https://community.mellanox.com/docs/DOC-2499) 
      - the ability to send RoCE traffic over a lossy network (a network without flow control enabled), without the need to enable flow control on the network
      - Resilient RoCE is supported on ConnectX-4/Lx adapters and onward on the hardware level.
      - It is recommended to enable RoCE congestion control (ECN) as well as PFC. However, PFC or general flow control is not a must requirement.
   * Lossless RoCE: requires PFC or global pause, but recommend PFC

- Terminology  
source: https://community.mellanox.com/docs/DOC-2321  
   * RP (Reaction Point, injector): the end node that performs rate limitation to prevent congestion
   * NP (Notification Point): the end node that receives the packets from the injector and sends back notifications to the injector for indications regarding the congestion situation
   * CP (Congestion Point): the switch queue in which congestion happens
   * CNP (The RoCEv2 Congestion Notification Packet): The notification message an NP sends to the RP when it receives CE marked packets.


