# AdGuard Home Installation Guide (Proxmox LXC)

## Overview

Deploy AdGuard Home as a centralized DNS resolver and internal domain
controller.This will be a dual-purpose system that handles two very important features.

---

## 1. Create LXC Container

-   Template: debian-13-standard\
-   CPU: 1 core\
-   RAM: 512 MiB\
-   Swap: 512 MiB\
-   Disk: 2G\
-   Network VLAN: 10 (Management)\
-   IP: 192.168.10.x

### Design Decision

Placed on **Management VLAN (10)** to serve DNS across all VLANs.

---

## 2. Install AdGuard

Access container and follow web setup: http://192.168.10.x:3000

Set admin credentials.

---

## 3. Configure OPNsense DNS

### System DNS

System → Settings → General\
Set DNS to: 192.168.10.x

### DHCP DNS (per VLAN)

Services → ISC DHCPv4\
Set DNS server to: 192.168.10.x

---

## 4. Configure DNS Rewrites

AdGuard GUI → Filters → DNS Rewrites

-   Domain: \*.home.lan\
-   Answer: 192.168.10.x (Tailscale IP)

---

## 5. Validation

-   Resolve \*.home.lan domains\
-   Confirm routing to reverse proxy

---

## Result

AdGuard now provides centralized DNS and internal domain resolution.