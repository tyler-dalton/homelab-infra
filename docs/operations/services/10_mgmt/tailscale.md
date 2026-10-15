# Tailscale Installation Guide (Proxmox LXC)

## 1. Create LXC Container
- Node: hyprboxx
- CT ID: 1102
- Hostname: tailscale
- Template: debian-13-standard
- Disk: 4 GiB
- CPU: 1 core
- Memory: 512 MiB (Swap: 256 MiB)

### Network
- Bridge: vmbr0
- VLAN Tag: 10
- IP: 192.168.10.x/24
- Gateway: 192.168.10.1
- DNS: Use host

---

## 2. Initial Setup
```bash
apt update && apt upgrade -y
apt install curl -y
```

## 3. Install Tailscale
```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

---

## 4. Enable IP Forwarding
```bash
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' >> /etc/sysctl.conf
sysctl -p
```

---

## 5. Fix TUN Device (Proxmox Host)
Edit container config:
```bash
nano /etc/pve/lxc/1102.conf
```

Add:
```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```

Restart container:
```bash
pct stop 1102 && pct start 1102
```

---

## 6. Start Tailscale
```bash
systemctl start tailscaled
tailscale up --advertise-routes=192.168.10.0/24,192.168.20.0/24,192.168.30.0/24,192.168.40.0/24,192.168.90.0/24 --accept-routes
```

- Open provided URL
- Authenticate device
- Approve routes in Tailscale admin panel

---

## 7. Fix Routing Issues
```bash
pct exec 1102 -- sysctl -w net.ipv4.ip_forward=1
```

Re-run:
```bash
tailscale up --advertise-routes=192.168.10.0/24,192.168.20.0/24,192.168.30.0/24,192.168.40.0/24,192.168.90.0/24 --accept-routes
```

---

## 8. GRO Optimization Fix
```bash
nano /etc/network/if-up.d/tailscale-gro
```

Add:
```bash
#!/bin/sh
ethtool -K eth0 rx-udp-gro-forwarding on rx-gro-list off
```

---

## 9. Final Steps
- Disable key expiry in Tailscale UI
- Test connectivity (e.g., access Uptime Kuma via VPN)