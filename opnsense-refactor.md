# Kubernetes VLAN 33 — Network Configuration

## Overview

Configured VLAN 33 (`KUBE`) as a dedicated network for the physical Kubernetes cluster. OPNsense handles inter-VLAN routing and firewall rules, while the Netgear GS728TPP provides Layer 2 connectivity.

### Network Configuration

| Setting | Value |
| --- | --- |
| VLAN ID | 33 |
| VLAN Name | KUBE |
| Subnet | `192.168.33.0/24` |
| Gateway | `192.168.33.1` |
| Kubernetes API VIP (Reserved) | `192.168.33.10` |
| Physical Nodes | `192.168.33.11-15` |
| Switch | Netgear GS728TPP |

## OPNsense Backups

Before editing the configuration of the firewall, ensure that there is backups of configs.

**Take a snapshot of the OPNsense config**:

```text
System -> Configuration -> Backups -> Download Configuration
```

![opnsense config backup](opn-bak)

**Take a snapshot of the OPNsense VM**:

```text
OPNsense VM -> Backups -> Backup now -> Backup
```

![snapshot opnsense vm](pve-opn-bak)

## OPNsense Configuration

1. Created VLAN 33 using the existing LAN-facing VLAN parent interface.
2. Assigned the VLAN to a new interface named `KUBE`.
3. Enabled the interface with static IPv4 address `192.168.33.1/24`.
4. Configured a temporary IPv4 allow-all firewall rule for initial connectivity testing.
5. Verified the gateway using **Interfaces → Diagnostics → Ping**.

**Validation:** 27 packets transmitted, 27 received, 0% packet loss.

This confirms the gateway is operational locally, but does not validate physical node connectivity.

## Netgear GS728TPP Configuration

Reserved switch ports 17–21 for Kubernetes nodes.

| Port | Node | Planned IP | VLAN | PVID |
|---|---|---|---|---|
| 17 | k8sN1 | `192.168.33.3` | 33 | 33 |
| 18 | k8sN2 | `192.168.33.4` | 33 | 33 |
| 19 | k8sN3 | `192.168.33.5` | 33 | 33 |
| 20 | k8sN4 | `192.168.33.6` | 33 | 33 |
| 21 | k8sN5 | `192.168.33.7` | 33 | 33 |

**Planned switch settings:**
- Create VLAN 33 (`KUBE`).
- Configure node ports as untagged members with PVID 33.
- Tag VLAN 33 on the Proxmox/OPNsense LAN uplink.
- Preserve existing VLAN 10 management connectivity.

*Switch configuration and end-to-end connectivity have not yet been confirmed.*

## Remaining Tasks

- [x] Create VLAN 33 in OPNsense.
- [x] Configure and verify the OPNsense gateway.
- [x] Confirm VLAN 33 switch membership and PVID settings.
- [x] Configure tagged VLAN 33 on the OPNsense uplink.
- [x] Assign static IP addresses to Kubernetes nodes.
- [x] Verify node-to-gateway and internet connectivity.
- [ ] Replace temporary allow-all firewall rules with least-privilege policies.
- [x] Configure Tailscale subnet routing for VLAN 33.

## Management Network Protection

VLAN 10 (`192.168.10.0/24`) remains the existing management network for OPNsense, Proxmox, and infrastructure administration. No changes to VLAN 10 are required for this deployment.
