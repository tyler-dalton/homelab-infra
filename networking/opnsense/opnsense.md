# OPNsense Step-by-Step Setup Guide

## Purpose

This document walks through the OPNsense VM deployment, interface correction, WAN recovery, VLAN creation, DHCP setup, and baseline firewall rules. Using OPNsense as a firewall/router allows for ultimate control of network communication, and will be essential to creating an at-home SOC.

## Target State

- OPNsense VM ID: `1101`
- LAN/MGMT gateway: `192.168.10.x`
- WAN IP: `192.168.1.x/24`
- WAN gateway: `192.168.1.1`

---

## 1. Deploy the OPNsense VM from the Proxmox Helper Script

1. Open the Proxmox shell.
2. Run the Proxmox VE helper script for OPNsense.
3. Use these settings during deployment:

- Create new VM: **Yes**
- Settings mode: **Advanced**
- VM ID: `1101`
- Machine type: `q35`
- CPU model: `host`
- Disk cache: `none`
- Hostname: `OPNsense`
- CPU cores: `4`
- RAM: `8192 MiB`
- LAN bridge: `vmbr0`
- LAN IP: `192.168.10.x`
- LAN gateway: `192.168.10.x`
- LAN netmask: `24`
- WAN bridge: `vmbr1`
- WAN IP: `192.168.1.x`
- WAN gateway: `192.168.1.1`
- WAN netmask: `24`

4. Let the installer finish.

---

## 2. Verify the Virtual NIC Mapping in Proxmox

In the OPNsense VM hardware page, confirm:

- `net0` -> `vmbr0`
- `net1` -> `vmbr1`

Inside OPNsense, the intended mapping is:

- `vtnet0` = LAN-side trunk
- `vtnet1` = WAN-side uplink

---

## 3. Correct the LAN Address from the Console

A major early issue was the LAN IP being set incorrectly.

### Fix from the OPNsense console

1. Open the VM console.
2. Log in.
3. Choose **Assign interfaces / Configure interfaces**.
4. Reconfigure LAN:
   - IPv4 via DHCP: `No`
   - LAN IP: `192.168.10.x`
   - Prefix: `24`
   - Upstream gateway for LAN: leave blank
   - Skip IPv6
5. Enable DHCP on LAN:
   - Start: `192.168.10.100`
   - End: `192.168.10.200`
6. Keep HTTPS enabled.
7. Skip self-signed certificate reconfiguration.

---

## 4. Fix the VLAN Handling Between Proxmox and OPNsense

The breakthrough fix was tagging the OPNsense LAN-side Proxmox NIC with VLAN 10.

### Command

```bash
qm set 1101 --net0 'virtio=02:BC:9E:75:E8:F9,bridge=vmbr0,tag=10'
qm stop 1101 && sleep 10 && qm start 1101
```

After this, pings to `192.168.10.x` started working.

A persistent hookscript was later used to keep the tap interface behavior intact across reboots.

---

## 5. Log In to the OPNsense GUI

Once management VLAN connectivity is working:

1. Set the management PC to an IP in `192.168.10.0/24`.
2. Browse to:

   `https://192.168.10.x`

3. Log in to the OPNsense web UI.

---

## 6. Configure WAN

### If DHCP does not work

The WAN interface came up without a usable lease, so a static configuration was used.

Go to **Interfaces > WAN** and set:

- Device: `vtnet1`
- IPv4 Configuration Type: `Static IPv4`
- IPv4 Address: `192.168.1.x/24`

Uncheck:

- **Block private networks**
- **Block bogon networks**

### Create the gateway

Go to **System > Gateways > Configuration** and add:

- Name: `WAN_GW`
- Interface: `WAN`
- Gateway IP: `192.168.1.1`

Then return to **Interfaces > WAN** and select `WAN_GW` as the IPv4 gateway.

---

## 7. Validate WAN Connectivity

From the OPNsense shell, test:

```bash
ping 192.168.1.1
ping 8.8.8.8
ping google.com
```

Successful replies confirm:

- Layer 2 WAN connectivity
- Upstream routing
- DNS resolution

---

## 8. Create VLAN Interfaces

Go to **Interfaces > Other Types > VLAN** and create:

| VLAN | Parent | Description |
|---|---|---|
| 10 | `vtnet0` | MGMT |
| 20 | `vtnet0` | MON |
| 30 | `vtnet0` | TRUST |
| 40 | `vtnet0` | IOT |
| 90 | `vtnet0` | DMZ |

Then go to **Interfaces > Assignments** and add all VLAN interfaces.

---

## 9. Assign Interface IPs

### Management interface

Instead of using a separate OPT interface for management, the working configuration used the existing LAN as MGMT.

- Rename `LAN` to `MGMT`
- IP: `192.168.10.x/24`

### Other interfaces

Configure the remaining interfaces as static IPv4:

- `MON` -> `192.168.20.1/24`
- `TRUST` -> `192.168.30.1/24`
- `IOT` -> `192.168.40.1/24`
- `DMZ` -> `192.168.90.1/24`

---

## 10. Configure DHCP

Go to **Services > ISC DHCPv4**.

### Do not configure DHCP for MGMT

The management VLAN is intended for infrastructure with static addresses.

### Configure DHCP for the others

- `MON`: `192.168.20.100` to `192.168.20.200`
- `TRUST`: `192.168.30.100` to `192.168.30.200`
- `IOT`: `192.168.40.100` to `192.168.40.200`
- `DMZ`: `192.168.90.100` to `192.168.90.200`

---

## 11. Configure Firewall Alias

Go to **Firewall > Aliases** and create:

- Name: `RFC1918`
- Type: `Network`
- Content:
  - `10.0.0.0/8`
  - `172.16.0.0/12`
  - `192.168.0.0/16`
- Description: `Private IP ranges`

This alias is used to keep IoT and DMZ networks from reaching internal RFC1918 space.

---

## 12. Configure Baseline Firewall Rules

Go to **Firewall > Rules**.

### MGMT

Create a pass rule:

- Action: `Pass`
- Interface: `MGMT`
- Direction: `In`
- Protocol: `Any`
- Source: `MGMT net`
- Destination: `Any`
- Description: `MGMT allow all`

### TRUST

Create a pass rule:

- Action: `Pass`
- Interface: `TRUST`
- Direction: `In`
- Protocol: `Any`
- Source: `TRUST net`
- Destination: `Any`
- Description: `TRUST allow internet and MGMT`

### MON

Create a pass rule:

- Action: `Pass`
- Interface: `MON`
- Direction: `In`
- Protocol: `Any`
- Source: `MON net`
- Destination: `Any`
- Description: `MON allow all`

### IOT

Create a pass rule:

- Action: `Pass`
- Interface: `IOT`
- Direction: `In`
- Protocol: `Any`
- Source: `IOT net`
- Destination: `RFC1918`
- Invert destination: `Checked`
- Description: `IOT internet only`

### DMZ

Create a pass rule:

- Action: `Pass`
- Interface: `DMZ`
- Direction: `In`
- Protocol: `Any`
- Source: `DMZ net`
- Destination: `RFC1918`
- Invert destination: `Checked`
- Description: `DMZ internet only`

---

## 13. Test the Build

After configuration:

1. Confirm GUI access to `https://192.168.10.x`
2. Confirm OPNsense can ping the upstream router
3. Confirm OPNsense can ping the internet
4. Confirm OPNsense can resolve DNS
5. Confirm VLAN clients receive DHCP where expected
6. Confirm IoT and DMZ cannot reach internal RFC1918 networks
7. Confirm MGMT and TRUST behave as intended

---

## 14. Closing Note

This OPNsense setup was not a straight-line install. It was earned. After 15+ attempts of refactoring, miswired logic, VLAN edge cases, and interface weirdness, getting the GUI up, the WAN stable, and the VLANs routing cleanly is the kind of finish that feels ridiculously satisfying.
