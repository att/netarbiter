# NVMe over Fabrics/RoCE
Author: Hee Won Lee <knowpd@research.att.com>

### RoCE Deployment
Refer to [RoCE_Deployment.md](./RoCE_Deployment.md)

### Configure NVMe over Fabrics
Ref: <https://community.mellanox.com/docs/DOC-2504>

- Prerequisites   
   * Install [MLNX_OFED_LINUX-4.3-1.0.1.0-ubuntu16.04-x86_64.tgz](http://www.mellanox.com/page/products_dyn?product_family=26): 
   ```
   tar xzvf MLNX_OFED_LINUX-4.2-1.0.0.0-ubuntu16.04-x86_64.tgz
   cd MLNX_OFED_LINUX-4.2-1.0.0.0-ubuntu16.04-x86_64
   sudo ./mlnxofedinstall --add-kernel-support --with-nvmf --force
   sudo /etc/init.d/openibd restart

   # Note:
   #   - In order to load the new nvme-rdma and nvmet-rdma modules, the nvme module must be reloaded.
   #   - You may need to reboot.
   sudo modprobe -rv nvme
   sudo modprobe nvme
   ```

   * For target offload  
   Ref: <https://community.mellanox.com/docs/DOC-2918>
   ```
   sudo modprobe -rv nvme
   sudo modprobe nvme
   sudo modprobe nvme num_p2p_queues=1

   sudo modprobe nvmet
   sudo modprobe nvmet-rdma
   sudo modprobe nvmet_rdma offload_mem_start=0xf00000000 offload_mem_size=2048 offload_buffer_size=256
   ```
      - Note: Currently, an offloaded subsystem can be associated with only one namespace.

- NVME Target Configuration
   * Insert modules
   ```
   modprobe mlx5_core
   modprobe nvmet
   modprobe nvmet-rdma
   ```

   * Set up target
   ```
   # Set up a port
   #   - Usage: ./setup-nvmet-port.sh <traddr> <portid>
   ./setup-nvmet-port.sh 10.154.0.61 1

   # Set up subsystems (each of which is mapped to a nvme drive)
   #   - Usage: ./setup-nvmet-subsystem.sh <dev> <subnqn> <ns-num> <portid>
   ./setup-nvmet-subsystem.sh /dev/nvme0n1 subsys0 10 1
   ./setup-nvmet-subsystem.sh /dev/nvme1n1 subsys1 10 1

   # To check
   dmesg | grep "enabling port"
   ```
  
   * Tear down target
   ```
   # Remove subsystems
   # Usage: ./teardown-nvmet-subsystem.sh <subnqn> <ns-num> <portid>
   ./teardown-nvmet-subsystem.sh subsys0 10 1
   ./teardown-nvmet-subsystem.sh subsys1 10 1

   # Remove port
   # Usage: sudo rmdir /sys/kernel/config/nvmet/ports/<portid>
   sudo rmdir /sys/kernel/config/nvmet/ports/1

   # [Optional] Remove kernel modules
   sudo modprobe -rv nvmet_rdma
   ```

- NVMe Client (Initiator) Configuration
   * Insert a module
      ```
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
   sudo nvme connect -t rdma -n subsys0 -a 10.154.0.61 -s 4420
   sudo nvme connect -t rdma -n subsys1 -a 10.154.0.61 -s 4420
   
   # To check if it is connected
   sudo nvme list
   
   # To disconnect
   sudo nvme disconnect -d /dev/nvme2n1
   sudo nvme disconnect -d /dev/nvme3n1
   ```

### Troubleshooting
Refer to [TROUBLESHOOT.md](./TROUBLESHOOT.md)

### References
- [HowTo Configure NVMe over Fabrics](https://community.mellanox.com/docs/DOC-2504)  
- [HowTo Enable, Verify and Troubleshoot RDMA](https://community.mellanox.com/docs/DOC-2086)
- [HowTo Get Started with Mellanox switches](https://community.mellanox.com/docs/DOC-2172)
- [HowTo Upgrade MLNX-OS Software on Mellanox switches](https://community.mellanox.com/docs/DOC-1448)
