# Docker LXC Documentation

## Purpose
This guide documents how to recreate a Docker LXC container in Proxmox using the Proxmox VE community helper script workflow.

## What this deployment is for
This Docker deployment is intended for a lightweight LXC-based container host rather than a full virtual machine. In this setup, Docker is used for smaller, non-production-essential services where an LXC makes sense from a resource and management perspective.

## Important planning note
Docker can be installed either in a VM or an LXC. In this build, the LXC route was chosen because it is better suited for lighter workloads. For services that have broader system impact or need stricter isolation, a VM may be the better choice.

## Prerequisites
- A working Proxmox VE host
- Access to the Proxmox shell
- A management bridge available as `vmbr0`
- A management subnet using VLAN 10
- Planned static IP information
- An SSH public key already available in Proxmox

## Helper script used
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/docker.sh)"
```

## Step-by-step installation

### 1. Open the Proxmox shell
Log into the Proxmox host and open the shell for the node where you want the Docker LXC to live.

### 2. Run the Docker LXC helper script
Paste and run:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/docker.sh)"
```

### 3. Choose advanced install
When the script starts, choose **Advanced Install** so you can control all container settings manually.

### 4. Use an unprivileged container
Select **Unprivileged Container**.

This improves isolation and is the preferred option for this build.

### 5. Set the root password
Set the container root password to your desired password.

Store it in your password manager and physical notebook if you are tracking your homelab build there.

### 6. Set the container ID
Assign the CT ID.

For this documented build, the Docker LXC container uses:
- **CT ID:** `1107`

### 7. Name the container
Name the container:
- **Hostname:** `dockerlxc`

This naming helps distinguish it from a Docker VM deployment.

### 8. Set disk size
Set the disk size to:
- **Disk:** `20 GB`

### 9. Set CPU allocation
Assign:
- **Cores:** `2`

### 10. Set memory
Assign:
- **RAM:** `2048 MiB`

### 11. Set the network bridge
Choose:
- **Bridge:** `vmbr0`

### 12. Configure a static IP
Use a static address so you do not need to reconfigure services later.

Set:
- **IPv4:** `192.168.10.x/24`
- **Gateway:** `192.168.10.1`

### 13. Disable IPv6
Set:
- **IPv6:** `none`

This was not needed for the homelab environment.

### 14. Leave MTU at default
Accept the default MTU and continue.

### 15. Leave DNS search domain blank
No DNS search domain is needed for this build.

### 16. Set the DNS server
Set DNS to the internal resolver used in the environment:
- **DNS:** `adgaurd (192.168.20.x)`

### 17. Auto-generate the MAC address
Allow the script to auto-generate the MAC address.

### 18. Set the VLAN tag
Assign:
- **VLAN Tag:** `10`

This places the container on the management subnet.

### 19. Apply optional Proxmox tags
Add tags for easier organization in Proxmox:
- `node-1`
- `lxc`
- `mgmt`

### 20. Select the SSH key source
Choose the option to use **detected keys**.

Then:
- Press **Space** to select the desired key
- Press **Enter** to continue

### 21. Enable root SSH access
Enable **root SSH access** when prompted.

### 22. Disable FUSE support
Set:
- **FUSE support:** `No`

### 23. Enable TUN/TAP support
Set:
- **TUN/TAP support:** `Yes`

### 24. Enable nesting
Set:
- **Nesting:** `Yes`

This is one of the most important settings in the build. Docker inside an LXC typically requires nesting to function correctly.

### 25. Skip GPU passthrough
Set:
- **GPU passthrough:** `No`

### 26. Enable keyctl support
Set:
- **keyctl support:** `Yes`

### 27. Skip apt-cacher proxy
Set:
- **Apt cacher proxy:** `No`

### 28. Set timezone
Set:
- **Timezone:** `America/New_York`

### 29. Disable container protection
Set:
- **Container protection:** `No`

### 30. Disable device node creation
Set:
- **Device node creation:** `No`

### 31. Leave mount filesystems blank
No custom mount filesystems are needed for this deployment.

### 32. Enable verbose mode
Turn on **verbose mode** if you want to watch the full installation process.

### 33. Let the installation complete
Allow the script to finish creating and configuring the Docker LXC.

## Post-install validation
After installation completes:

### 1. Confirm the LXC exists in Proxmox
Verify the container appears in the Proxmox node inventory with the expected CT ID and hostname.

### 2. Start the container if needed
If it does not auto-start, start it from Proxmox.

### 3. Verify network connectivity
Check that the container is reachable at:
- `192.168.10.x`

### 4. Verify Docker is installed
Open the LXC console or SSH into the container and run:
```bash
docker --version
```

You can also test:
```bash
docker ps
```

## Configuration summary
- **Type:** Docker in LXC
- **Install method:** Proxmox VE helper script
- **Container type:** Unprivileged
- **Hostname:** `dockerlxc`
- **CT ID:** `1107`
- **Disk:** `20 GB`
- **CPU:** `2 cores`
- **RAM:** `2048 MiB`
- **Bridge:** `vmbr0`
- **IP:** `192.168.10.x/24`
- **Gateway:** `192.168.10.1`
- **DNS:** `192.168.20.x`
- **VLAN:** `10`
- **Timezone:** `America/New_York`
- **TUN/TAP:** enabled
- **Nesting:** enabled
- **keyctl:** enabled

## Troubleshooting notes

### Docker in LXC will break or behave inconsistently if nesting is not enabled
If Docker commands fail, container creation fails, or workloads behave strangely, check the LXC options first.

The three settings most worth verifying are:
- **Unprivileged container**
- **Nesting enabled**
- **keyctl enabled**

### Static IP mistakes can cause access issues later
If the container installs successfully but is unreachable, verify:
- the bridge is correct
- the VLAN tag is correct
- the IP is in the correct subnet
- the gateway matches the subnet router
- DNS points to a valid internal resolver

### Choose LXC only when it fits the workload
If you later deploy heavier or more sensitive services and run into stability or compatibility concerns, consider rebuilding Docker as a VM instead.

## Final result
At the end of this process, you have a Docker-capable LXC running in Proxmox and ready to host lightweight containerized services.
