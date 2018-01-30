# NVMe over Fabrics/RoCE
Author: Hee Won Lee <knowpd@research.att.com>

### RoCE Deployment
Refer to [RoCE_Deployment.md](./RoCE_Deployment.md)

### Configure NVMe over Fabrics
Ref: <https://community.mellanox.com/docs/DOC-2504>
- NVME Target Configuration
```
./setup-nvme-target.sh <target-address> <nvme-dev> <nvme-subsystem-name> <port-id>
#  target-address:      e.g. 10.154.0.61
#  nvme-dev:            e.g. /dev/nvme0n1
#  nvme-subsystem-name: e.g. nvme-eris101
#  port-id:             e.g. 1
```

- NVMe Client (Initiator) Configuration
```
git clone https://github.com/linux-nvme/nvme-cli.git
cd nvme-cli
make
make install
```
Re-check that nvme-rdma module is loaded. If not, load it using `modprobe nvme-rdma`.
```
sudo nvme discover -t rdma -a 10.154.0.61 -s 4420
sudo nvme connect -t rdma -n nvme-eris101 -a 10.154.0.61 -s 4420
```

### Troubleshooting
Refer to [TROUBLESHOOT.md](./TROUBLESHOOT.md)

### References
- [HowTo Configure NVMe over Fabrics](https://community.mellanox.com/docs/DOC-2504)  
- [HowTo Enable, Verify and Troubleshoot RDMA](https://community.mellanox.com/docs/DOC-2086)
- [HowTo Get Started with Mellanox switches](https://community.mellanox.com/docs/DOC-2172)
- [HowTo Upgrade MLNX-OS Software on Mellanox switches](https://community.mellanox.com/docs/DOC-1448)
