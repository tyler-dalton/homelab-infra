# OPNsense -- Service Overview

## Executive Summary

OPNsense is deployed as a virtual firewall router on Proxmox and acts as the central routing, NAT, DHCP, and policy enforcement point for the lab.

It connects:

- **Upstream/WAN** to the existing Spectrum-side network on `192.168.1.0/24`
- **Downstream/LAN trunk** to the internal managed switch using VLAN segmentation

This build ended up succeeding after more than 15 attempts of refactoring and reworking the topology. That matters because the final result is not just functional — it is battle-tested by failure.

---

## Topology Overview

### Virtual placement

- Platform: Proxmox
- VM ID: `1101`
- Machine type: `q35`
- CPU model: `host`
- vCPU: `4`
- RAM: `8192 MiB`

### Virtual NIC design

- `net0` on `vmbr0` -> LAN-side VLAN trunk
- `net1` on `vmbr1` -> WAN uplink

### OPNsense interface design

- `vtnet0` -> Internal trunk parent
- `vtnet1` -> WAN

---

## Addressing Overview

### WAN

- WAN IP: `192.168.1.x/24`
- WAN gateway: `192.168.1.1`

### Internal VLAN gateways

| VLAN | Name  | Gateway |
|---|---|---|
| 03 | KUBE  | `192.168.3.1`  |
| 10 | MGMT  | `192.168.10.1` |
| 20 | MON   | `192.168.20.1` |
| 30 | TRUST | `192.168.30.1` |
| 40 | IOT   | `192.168.40.1` |
| 90 | DMZ   | `192.168.90.1` |

---

## Functional Responsibilities

OPNsense is responsible for:

1. **Routing**
   - Inter-VLAN routing between internal networks
   - Default routing toward the upstream router

2. **NAT**
   - Translating internal VLAN traffic to the WAN IP
   - Operating behind the ISP router in a double-NAT design

3. **DHCP**
   - Providing DHCP for MON, TRUST, IOT, and DMZ
   - Leaving MGMT static-only

4. **Firewall policy**
   - Allowing administrative freedom on MGMT
   - Allowing normal access on TRUST
   - Restricting IOT and DMZ to internet-only style access

5. **Segmentation**
   - Establishing clear boundaries between infrastructure, trusted workloads, monitoring, IoT, and DMZ services

---

## Why Double NAT Was Used

This design intentionally keeps the ISP router for roomates connections in place and lets OPNsense sit behind it. This works so that I can have an isolated lab enviornment without disturbing the entire wifi connection.

### Benefits

- No risky bridge-mode changes on ISP equipment
- Easier rollback if something breaks
- Faster initial deployment
- Safe for iterative lab development

### Tradeoffs

- Inbound services require two layers of forwarding if exposed
- Slightly more complexity in WAN troubleshooting
- Not ideal for every production use case, but practical for a homelab

---

## VLAN Breakdown

### VLAN 03 - KUBE

Used for:

- Kubernentes Cluster

Gateway: `192.168.3.1`

### VLAN 10 - MGMT

Used for:

- Proxmox management
- Switch management
- OPNsense GUI
- Infrastructure administration

Gateway: `192.168.10.1`  

### VLAN 20 - MON

Used for:

- Monitoring systems
- Observability tooling
- Infrastructure telemetry

Gateway: `192.168.20.1`  
DHCP scope: `192.168.20.100-192.168.20.200`

### VLAN 30 - TRUST

Used for:

- Trusted clients
- Internal service consumers
- Administrative workstations as needed

Gateway: `192.168.30.1`  
DHCP scope: `192.168.30.100-192.168.30.200`

### VLAN 40 - IOT

Used for:

- Lower-trust connected devices
- Devices that should reach the internet but not the rest of the lab

Gateway: `192.168.40.1`  
DHCP scope: `192.168.40.100-192.168.40.200`

Policy intent:
- Internet allowed
- RFC1918/internal destinations blocked by rule design

### VLAN 90 - DMZ

Used for:

- Exposed or semi-exposed services
- Services that should remain isolated from internal networks

Gateway: `192.168.90.1`  
DHCP scope: `192.168.90.100-192.168.90.200`

Policy intent:
- Internet allowed as needed
- Internal RFC1918 destinations blocked

---

## Key Implementation Insight

The single biggest implementation detail was that the internal OPNsense side needed to operate through a VLAN-aware Proxmox/switch path, and the LAN-side VM NIC needed correct tagging behavior for VLAN 10 before management access became stable.

In other words, the problem was not just “install OPNsense.” The hard part was making Proxmox bridging, VLAN tagging, and switch behavior all agree with each other.

---

## Baseline Security Model

### Restricted

- IOT -> internet-only style egress using inverted `RFC1918`
- DMZ -> internet-only style egress using inverted `RFC1918`

---

## Final Reflection

There is a different kind of satisfaction in finishing something that kept breaking for 15+ rounds of refactoring. This one was not clean, and that is exactly why the ending feels so good. The final build is more valuable because it was fought for, understood, and fixed layer by layer until the whole stack finally clicked into place.
