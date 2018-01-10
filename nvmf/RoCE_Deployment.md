## RoCE Deployment

### Guide  
- [Recommended Network Configuration Examples for RoCE Deployment](https://community.mellanox.com/docs/DOC-2855)

### Option One: Layer 2
Lossless fabric (requires PFC)
- Adapter: [RoCE Configuration on Mellanox Adapters (PCP-Based Lossless Traffic)](https://community.mellanox.com/docs/DOC-2843) 
- Switch: [Lossless RoCE Configuration for MLNX-OS Switches in PCP-Based QoS Mode](https://community.mellanox.com/docs/DOC-3018)

Lossy fabric (requires ECN)
- Adapter: [RoCE Configuration for Mellanox Adapters (PCP-Based)](https://community.mellanox.com/docs/DOC-2883)
- Switch: [RoCE Configuration for MLNX-OS Switches in PCP-Based QoS Mode](https://community.mellanox.com/docs/DOC-3016)

### Option Two: Layer 3
Lossless fabric (requires PFC)
- Adapter: [Lossless RoCE Configuration for Linux Drivers in DSCP-Based QoS Mode](https://community.mellanox.com/docs/DOC-2881)
- Switch: [Lossless RoCE Configuration for MLNX-OS Switches in DSCP-Based QoS Mode](https://community.mellanox.com/docs/DOC-3017)

Lossy fabric (requires ECN)
- Adapter: [RoCE Configuration for Linux Drivers in DSCP-Based QoS Mode](https://community.mellanox.com/docs/DOC-2882)
- Switch: [RoCE Configuration for MLNX-OS Switches in PCP-Based QoS Mode](https://community.mellanox.com/docs/DOC-3016)


### Tutorials
- [RoCE v2 Considerations](https://community.mellanox.com/docs/DOC-1451)
   * What is RoCE?
   * Difference between RoCE v1 and RoCE v2
   * [Resilient RoCE](https://community.mellanox.com/docs/DOC-2499)

- Terminology
source: https://community.mellanox.com/docs/DOC-2321  
   * RP (Reaction Point, injector): the end node that performs rate limitation to prevent congestion
   * NP (Notification Point): the end node that receives the packets from the injector and sends back notifications to the injector for indications regarding the congestion situation
   * CP (Congestion Point): the switch queue in which congestion happens
   * CNP (The RoCEv2 Congestion Notification Packet): The notification message an NP sends to the RP when it receives CE marked packets.


