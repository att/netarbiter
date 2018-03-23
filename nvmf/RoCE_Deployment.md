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
   You can take a look at the [output sample](OUTPUTSAMPLE.setup-nic-lossless-layer3.sh.md).

- Switch (advanced mode): [Lossless RoCE Configuration for MLNX-OS Switches in DSCP-Based QoS Mode (advanced mode)](https://community.mellanox.com/docs/DOC-2884)
   * For basic mode, refer to [Lossless RoCE Configuration for MLNX-OS Switches in DSCP-Based QoS Mode](https://community.mellanox.com/docs/DOC-3017)
   ```
   # First, run `enable` and `config t`.
   # Enable ECN for RoCE traffic over traffic class 3.
   #   - Traffic over DSCP 26 is mapped to traffic class 3 by default.
   interface ethernet 1/13-1/16 traffic-class 3 congestion-control ecn minimum-absolute 150 maximum-absolute 1500

   # Configure the buffer pool allocating
   #   - pool 1 for lossless RoCE traffic, and 
   #   - pool 0 for lossy traffic.
   advanced buffer management force
   pool iPool1 size 5242880 type dynamic
   pool ePool1 size 16777000 type dynamic
   pool iPool0 size 5242880 type dynamic
   pool ePool0 size 5242880 type dynamic

   # Bind the interfaces to switch-priority. Bind switch priorities 3 and 6 to ingress PG group 3 and 6.
   #   - Traffic over DSCP 26 is mapped to switch-priority 3 by default.
   #   - Traffic over DSCP 48 is mapped to switch-priority 6 by default.   
   interface ethernet 1/13-1/16 ingress-buffer iPort.pg3 bind switch-priority 3
   interface ethernet 1/13-1/16 ingress-buffer iPort.pg6 bind switch-priority 6

   # Map ingress/egress interface to pool configuration by: 
   #   - allocating buffer to priority 3 and mapping it to a lossless pool, and 
   #   - allocating buffer to priority 6 and mapping it to a lossy pool.
   interface ethernet 1/13-1/16 ingress-buffer iPort.pg3 map pool iPool1 type lossless reserved 67538 xoff 18432 xon 18432 shared alpha 2
   interface ethernet 1/13-1/16 egress-buffer ePort.tc3 map pool ePool1 reserved 1500 shared alpha inf
   interface ethernet 1/13-1/16 ingress-buffer iPort.pg6 map pool iPool0 type lossy reserved 10240 shared alpha 8

   # Set a strict priority to CNPs over traffic class 6.
   #   - Traffic over DSCP 48 is mapped to switch-priority 6 by default.
   interface ethernet 1/13-1/16 traffic-class 6 dcb ets strict

   # Set trust mode L3 (DSCP).
   interface ethernet 1/13-1/16 qos trust L3

   # Enable receive PFC on priority 3 on all ports.
   dcb priority-flow-control enable force
   dcb priority-flow-control priority 3 enable
   interface ethernet 1/13-1/16 dcb priority-flow-control mode on force
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


### Terminologies  
- Ref: https://community.mellanox.com/docs/DOC-2321  
   * RP (Reaction Point, injector): the end node that performs rate limitation to prevent congestion
   * NP (Notification Point): the end node that receives the packets from the injector and sends back notifications to the injector for indications regarding the congestion situation
   * CP (Congestion Point): the switch queue in which congestion happens
   * CNP (The RoCEv2 Congestion Notification Packet): The notification message an NP sends to the RP when it receives CE marked packets.

- IEEE 802.1Q
   * Priority code point (PCP): 3bits

- Explicit Congestion Notification (ECN)
   * ECN-Echo (ECE) and Congestion Window Reduced (CWR)  
     00 – Non ECN-Capable Transport, Non-ECT  
     10 – ECN Capable Transport, ECT(0)  
     01 – ECN Capable Transport, ECT(1)  
     11 – Congestion Encountered, CE.  

### References 
- [RoCE v2 Considerations](https://community.mellanox.com/docs/DOC-1451)
   * Difference between RoCE v1 and RoCE v2
      - RoCE v2 runs on UDP/IP.
   * [Resilient RoCE](https://community.mellanox.com/docs/DOC-2499) 
      - the ability to send RoCE traffic over a lossy network (a network without flow control enabled), without the need to enable flow control on the network
      - Resilient RoCE is supported on ConnectX-4/Lx adapters and onward on the hardware level.
      - It is recommended to enable RoCE congestion control (ECN) as well as PFC. However, PFC or general flow control is not a must requirement.
   * Lossless RoCE: requires PFC or global pause, but recommend PFC

