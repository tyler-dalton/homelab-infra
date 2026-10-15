# Uptime Kuma -- Service Overview

This document provides a high-level overview of the **Uptime Kuma** deployment, what it does in the environment, how it is connected, and the key troubleshooting lessons from the build.

## What Uptime Kuma Is Doing

Uptime Kuma is deployed as an **LXC container** on **Proxmox VE** to provide uptime and reachability monitoring across the network.

It serves two purposes:

1. **Operational monitoring** for infrastructure and services
2. **Network validation** for VLAN behavior through the OPNsense environment

Because the container lives on a tagged VLAN, it also acts as a practical test case for whether the Proxmox ↔ OPNsense VLAN path is working correctly.

---

## Deployment Summary

### Platform
- **Hypervisor:** Proxmox VE
- **Container type:** LXC
- **Node:** `hyprboxx`
- **Container ID:** `1201`
- **Hostname:** `uptimekuma`

### Template and Resources
- **Template:** Debian 13 standard
- **Disk:** 4 GiB
- **CPU:** 1 core
- **Memory:** 1024 MiB
- **Swap:** 512 MiB

### Application Access
- **Application:** Uptime Kuma
- **Web URL:** `http://192.168.20.x:3001`

---

## Why This Container Matters

This is not just an application container. It is also a **network proof point**.

The deployment verifies that:

- VLAN 20 can reach OPNsense correctly
- ARP and routing behave as expected
- The container can reach internal services
- The container can reach external internet destinations
- DNS resolution works properly
- The Proxmox LXC network model is configured correctly for tagged traffic

That makes this container useful both as a monitoring platform and as a troubleshooting reference for future VLAN-aware LXCs.

---

## Key Networking Issue Encountered

The main issue during deployment was **broken connectivity on VLAN 20**.

### Symptoms
- Could not ping `8.8.8.8`
- Could not ping the VLAN gateway `192.168.20.1`
- ARP traffic was visible, but replies were missing
- Traffic was not arriving at OPNsense as expected

### What was found
Several issues surfaced during troubleshooting:

1. The LXC veth interface had the wrong **PVID** (`1` instead of `20`)
2. The Proxmox container NIC had **`firewall=1`**, which interfered with VLAN tagging/routing
3. OPNsense-side traffic handling still needed adjustment so the correct VLANs were present on the required tap interface

### What fixed it
The working path involved:

- Manually correcting the bridge VLAN PVID on the LXC veth interface
- Disabling the Proxmox firewall for the container NIC
- Ensuring the required VLANs were added to the OPNsense tap interface
- Updating the VLAN helper script to persist the correct VLAN/PVID handling

Once these changes were made, the container could:

- Ping OPNsense
- Reach `8.8.8.8`
- Resolve and reach `google.com`

---

## Operational Notes

### Monitoring Role
Once live, Uptime Kuma can be used to monitor:

- Routers and firewalls
- Internal hosts
- Ports and protocols
- Internet reachability
- Other lab or production systems

### First Configured Monitor
- **Spectrum router**

### Database Choice
- **SQLite**

That makes the deployment simple and self-contained, which is a good fit for an initial monitoring LXC.

---

## Important Lessons Learned

### 1. VLAN tags alone are not enough
Even when `tag=20` was present in the container config, traffic still failed until the bridge and tap behavior were corrected.

### 2. Proxmox firewall settings can affect VLAN behavior
The `firewall=1` option on the LXC NIC caused interference and had to be disabled.

### 3. Packet capture is essential
Using `tcpdump`, ARP visibility, and route inspection made it possible to isolate where traffic was disappearing.

### 4. This container is a good baseline template
Now that the networking path is understood, this deployment can serve as a repeatable pattern for future VLAN-aware service containers.

---

## Recommended Structure for GitLab Documentation

This Uptime Kuma material fits well into GitLab as two separate docs:

### 1. Installation / Build Document
Use the step-by-step guide for:
- Container creation
- VLAN troubleshooting
- Package installation
- App setup
- First login

### 2. Service Overview Document
Use this overview for:
- Purpose of the service
- Architecture and placement
- Network dependencies
- Known issues and lessons learned
- Operational role in the environment

---

## Current State

At the end of the documented process, the environment had:

- A working Uptime Kuma LXC
- Functional VLAN 20 connectivity
- Confirmed internet access from the container
- A persistent PM2-managed Uptime Kuma service
- Web access on `192.168.20.x:3001`
- At least one active monitor already configured

This makes Uptime Kuma both a functioning monitoring service and a validated reference deployment for future network-aware containers.
