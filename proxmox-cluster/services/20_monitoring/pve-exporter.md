# 1. Add PVE Exporter

## 1.1 Create Proxmox API

Inside of proxmox, go to datacenter, permissions, users, add
- username: prometheus-monitor
- realm: Proxmox VE authentication server

## 1.2 Add permissions for user

Go to datacenter, permissions, add
- User permission
- path: /
- user: prometheus-monitor@pve
- role: PVEAuditor
- propogate: checked

## 1.3 Create API token

Go to datacenter, permissions, API tokens, add
- user: REDACTED@pve
- token ID: REDACTED
Click create, and save the tokenID and secret in a safe place
- token ID: REDACTED
- Secret: REDACTED

# 2. Create the LXC, deploy the exporter

Helper Script: bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/prometheus-pve-exporter.sh)"

- Advanced install
- Unprivileged
- Root Password: blank
- CT ID: xxxx
- Hostname: pve-exporter
- Disk size: 2GB
- CPU Cores: 1
- RAM: 512 MiB
- Network bridge: vmbr0
- IPv4 assignment: static
- IP address: 192.168.xx.xx/24
- Gateway: 192.168.xx.x
- IPv6: none
- MTU size: blank/default (1500)
- DNS search domain: blank
- DNS: 192.168.xx.xx
- MAC address: auto-generate (leave-blank)
- VLAN tag: xx
- Container tags: node-1;lxc;mon
- SSH keys: none
- Root SSH access: no
- FUSE support: no
- TUN/TAP support: no
- Nesting: yes
- GPU passthrough: no
- Keyctl support: no
- APT cacher: no
- TImezone: America/New_York
- Container protection: no
- Device node creation: no
- Filesystem mounts: blank
- Verbose mode: yes