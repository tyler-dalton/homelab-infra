# Tailscale Overview

## Purpose
Tailscale is deployed as a subnet router inside the homelab to provide secure remote access to internal VLAN networks.

---

## Architecture Role
- Runs as LXC on Proxmox
- Connected to VLAN 10
- Advertises multiple VLAN subnets:
  - 192.168.10.0/24
  - 192.168.20.0/24
  - 192.168.30.0/24
  - 192.168.40.0/24
  - 192.168.90.0/24

---

## Key Features
- Remote VPN access without port forwarding
- Subnet routing across VLANs
- Secure WireGuard-based mesh networking

---

## Challenges Encountered

### 1. TUN Device Missing
- Tailscale failed to start
- Fixed by enabling /dev/net/tun in LXC config

### 2. IP Forwarding Disabled
- Subnet routing did not work
- Fixed via sysctl configuration

### 3. Routes Not Working
- Required re-advertising routes and approval in UI

### 4. Packet Handling Issues (GRO)
- Performance/packet issues
- Fixed via ethtool script

---

## Final Outcome
- Full remote access to all VLANs via Tailscale
- Stable subnet routing
- Integrated with homelab monitoring stack

---

## Validation
- Access internal services (e.g., Uptime Kuma) over VPN
- Confirm routing between VLANs works correctly