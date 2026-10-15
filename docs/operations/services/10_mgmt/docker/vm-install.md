# Docker VM Installation Guide

## Step-by-step provisioning notes for a Debian 12 Docker virtual machine on Proxmox.





## Purpose and placement

• This build uses a dedicated Debian 12 VM for Docker workloads that benefit from stronger isolation or host-like behavior.

• The source notes place this VM on the management subnet with VLAN tag 10 and a target static IP of 192.168.10.24/24.

• Cloud-init is enabled so the VM can be automated later with Terraform and Ansible.

### Provision the VM

1. Run the Proxmox helper script: bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/vm/docker-vm.sh)".

2. When the wizard opens, choose Advanced settings and use the Debian 12 Bookworm template.

3. Enable cloud-init, select the detected SSH key, and pick the desired key for administrator access.

4. Set the VM ID to match your numbering plan. The source notes use 1106.

5. Choose machine type q35, set disk size to 20 GiB, keep disk cache default, and name the VM dockervm.

6. Use Host CPU, 2 vCPUs, and reduce memory to 2 GiB for a lighter footprint.

7. Attach the VM to vmbr0, keep the auto-generated MAC address, set VLAN tag 10, and start the VM after provisioning.

#### Resolve the Proxmox enterprise repository issue if provisioning stalls

1. SSH to the Proxmox host and identify the hung installer process with ps aux | grep bash.

2. Kill the matching installer PID with pkill -9 <PID>, then stop any child apt activity with pkill -9 -f "apt-get".

3. Disable the enterprise repository entries by editing /etc/apt/sources.list.d/pve-enterprise.sources and /etc/apt/sources.list.d/ceph.sources so Enabled: no is set.

4. Create the community repository file /etc/apt/sources.list.d/pve-community.list with the no-subscription Bookworm repository, then run apt-get update.

5. If the two source files do not change cleanly, overwrite them directly and rerun apt-get update before rerunning the Docker VM helper script.

#### Apply networking inside the VM

1. Open the VM console, confirm the hostname with hostnamectl, and verify time sync with timedatectl.

2. Inspect the current interfaces with ip a. If the VM has no assigned address, edit the netplan file under /etc/netplan/*.yaml.

3. Set eth0 to 192.168.10.x/24, define the default route via 192.168.10.1, and use AdGuard (192.168.10.x) as the DNS server.

4. Run netplan apply. If permissions warnings appear, fix them with chmod 600 /etc/netplan/50-cloud-init.yaml and apply again.

5. Confirm the configuration with ip a show eth0 and ip route.

### Validate Docker inside the VM

1. Ping 192.168.10.1, 8.8.8.8, and google.com to verify gateway reachability, internet connectivity, and DNS resolution.

2. Verify Docker installation with docker --version, docker compose version, and systemctl status docker.

3. Run docker run hello-world to confirm the engine can pull and start a test container successfully.