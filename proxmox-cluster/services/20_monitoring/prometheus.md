# 1. Deploy Prometheus instance

Grafana by itself is just a UI dashboard to display metrics, we need something in the backend that will scrape hardware for these metrics. Prometheus will come into play as our backend scraper to retrieve all this data.

Helper Script: bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/prometheus.sh)"

## Settings for Prometheus install
- Advanced install
- Unprivileged
- Root password: blank
- CT ID: xxxx
- Hostname: prometheus
- Disk size: 4GB
- CPU cores: 1
- RAM: 2048 MiB
- Network bridge: vmbr0
- IPv4 assignment: static
- IP address: 102.168.xx.x/24
- Gateway: 192.168.xx.xx
- IPv6: none
- MTU size: default (1500)
- DNS search domain: blank
- DNS: 192.168.xx.xx (adguard)
- MAC address: auto-generate
- VLAN tag: xx
- Container tags: node-2;lxc;mon
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
Confirm access to web GUI at http://192.168.xx.xx:9090