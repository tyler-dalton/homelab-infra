# Managed Switch Setup Guide

## Purpose

This document captures the managed switch configuration that supports:

- Proxmox management
- OPNsense WAN uplink
- VLAN trunking
- Segmented internal networks

## VLAN Plan

| VLAN | Name  | Subnet            | Purpose |
|---|---|---|---|
| 04 | KUBE | 192.168.3.0/24 | Kubernetes Cluster |
| 10 | MGMT  | 192.168.10.0/24 | Management |
| 20 | MON   | 192.168.20.0/24 | Monitoring |
| 30 | TRUST | 192.168.30.0/24 | Trusted clients/services |
| 40 | IOT   | 192.168.40.0/24 | IoT devices |
| 90 | DMZ   | 192.168.90.0/24 | Exposed/isolated services |

---

## 1. Initial Switch Access

1. Connect the management laptop to the switch.
2. Set the laptop to an IP in the same subnet as the switch's current address.
3. Log in to the switch web interface.
4. Change the switch management IP to:

- IP: `192.168.10.x`
- Subnet mask: `255.255.255.0`
- Gateway: `192.168.10.1`

This prepares the switch to live on the management VLAN once OPNsense is active.

---

## 2. Setting up VLANS
Go to:
```
Switching -> VLAN -> Advanced -> VLAN Configuration
```

Set the VLANs, respectivly.

---

## 3. Setup Kubernetes VLAN
Go to:
```
Switching -> VLAN -> Advanced -> VLAN Membership
```

Set these ports tagged:
- 1
- 3
- 4

Set these ports untagged:
- 17
- 18
- 19
- 20

---

## 4. VLAN 10 - Management
From `VLAN Membership`, select VLAN 10.

Set these ports tagged:
- 1
- 3
- 4

Set these ports untagged:
- 5
- 6
- 16
- 23

---

## 5. VLAN 20 - Monitoring
Set these ports tagged:
- 1
- 3
- 4

---

## 6. VLAN 30 - Services
Set these ports tagged:
- 1
- 3
- 4
- 6

---

## 7. VLAN 40 - IoT
Set these ports tagged:
- 1
- 3
- 4
- 6

---

## 8. VLAN 90 - DMZ
Set these ports tagged:
- 1
- 3
- 4
- 6

---

## 9. Configure PVIDs
Go to:
```
Switching -> VLAN -> Advanced -> Port PVID Configuration
```

| Port | PVID |
|------|------|
| 1 | 10 |
| 2 | 1 |
| 3 | 10 |
| 4 | 10 |
| 5 | 10 |
| 6 | 10 |
| 16 | 10 |
| 17 | 4 |
| 18 | 4 |
| 19 | 4 |
| 20 | 4 |
| 23 | 10 |
| 24 | 1 |

---

## 9. Closing Note

This switch configuration was not a one-shot setup. It came together through repeated refactors, failed reachability tests, and incremental corrections. Getting it stable was huge for the setup of my entire lab. Without this switch in the middle nothing would be able to truly communicate with each other. This is a great additive to my setup.
