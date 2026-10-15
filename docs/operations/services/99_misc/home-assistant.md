Home Assistant has endless capabilities. Managing IoT devices, or automation scripts. Home Assistant has a rabbit hole worth of customizations. This will provide the documentation with links to all the configurations i decided to incorporate.

Some basic details:
- deployed on node 2
- IoT VLAN
- IP: set by DHCP

 Helper Script: bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/vm/haos-vm.sh)"

## Installation Configuration

- Advanced install: yes
- OS Version: 17.2 (stable)
- CT ID: xxxx
- Machine type: q35
- Disk size: 32GB
- Disk cache: Writethrough (default)
- Hostname: homeassistant
- CPU model: Host
- CPU cores: 2
- RAM: 2048MiB
- Bridge: vmbr0
- MAC address: leave default auto-populate
- VLAN: xx
- MTU size: blank for default

### Small config after install:

- add tags to the VM
- change the picture to display home assistant logo
- check IP - set to 192.168.xx.xxxx

## Set Up:

- Go to IP address assigned by DHCP with port 8123 attatched. http://192.168.xx.xx:8123
- Home Assistant may ask that you temporarily change your DNS to a verified DNS like Google or Cloudflare. Change to the DNS of your choice, we will change back later.
- Create your smart home
	- Set username
	- Set password
	- Set home address