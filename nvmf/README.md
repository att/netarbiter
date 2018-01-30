# NVMe over Fabrics/RoCE
Author: Hee Won Lee <knowpd@research.att.com>

### RoCE Deployment
Refer to [RoCE_Deployment.md](./RoCE_Deployment.md)

### Configure NVMe over Fabrics
Ref: <https://community.mellanox.com/docs/DOC-2504>
- NVME Target Configuration
```
./setup-nvme-target.sh <target-address> <nvme-dev> <nvme-subsystem-name> <port-id>
./setup-nvme-target.sh 10.154.0.61 /dev/nvme0n1 nvme-eris101 1	# for instance
```

- NVMe Client (Initiator) Configuration
   * Prerequisites  
   ```
   # If nvme-rdma is not loaded
   modprobe nvme-rdma
   ```

   * Install nvmecli
   ```
   git clone https://github.com/linux-nvme/nvme-cli.git
   cd nvme-cli
   make
   make install
   ```

   * Connect
   ```
   # Discover available subsystems on NVMF target.
   sudo nvme discover -t rdma -a 10.154.0.61 -s 4420
   
   # Connect to the discovered subsystems
   sudo nvme connect -t rdma -n nvme-eris101 -a 10.154.0.61 -s 4420
   
   # To check if it is connected
   sudo nvme list
   
   # To disconnect
   sudo nvme disconnect -d /dev/nvme2n1
   ```

### Troubleshooting
Refer to [TROUBLESHOOT.md](./TROUBLESHOOT.md)

### References
- [HowTo Configure NVMe over Fabrics](https://community.mellanox.com/docs/DOC-2504)  
- [HowTo Enable, Verify and Troubleshoot RDMA](https://community.mellanox.com/docs/DOC-2086)
- [HowTo Get Started with Mellanox switches](https://community.mellanox.com/docs/DOC-2172)
- [HowTo Upgrade MLNX-OS Software on Mellanox switches](https://community.mellanox.com/docs/DOC-1448)
