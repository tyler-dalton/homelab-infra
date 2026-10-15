# 1. Create the Grafana instance
Now that we have the script wrote to provision this setup just by running `start-metrics`, we now need to spin up a Grafana instance for it to populate to. We will do this with the help of the Proxmox VE Helper Scripts.

Helper Script: bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/grafana.sh)"

## Settings for Grafana install
- Advanced install
- Unprivileged
- No root password (Root SSH disabled)
- CT ID: xxxx
- Hostname: grafana
- Disk size: 4GB
- CPU cores: 1
- RAM: 512MiB
- Network bridge: vmbr0
- IPv4 assignment: static
- IP: 192.168.xx.xx/24
- Gateway: 192.168.xx.x
- IPv6: none
- MTU size: default (1500)
- DNS search domain: blank
- DNS server IP: 192.168.xx.xx (adguard)
- MAC address: auto-generate
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
- Timezone: America/New_York
- Container protection: no
- Device node creation: no
- Mount filesystems: blank
- Verbose mode: yes
Now we need to ensure we have web GUI access. Navigate to http://192.168.xx.xx:3000 in your browser, you should be greeted with the Grafana log-in screen. Log in with the basic credentials of admin, admin. Set your new user credentials now.