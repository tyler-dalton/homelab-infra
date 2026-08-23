# Uptime Kuma Installation Guide

This document captures the step-by-step deployment and installation process for **Uptime Kuma** as an LXC container on Proxmox VE, including the VLAN troubleshooting that was required before the application install.

## Purpose

Uptime Kuma is deployed as an LXC on **PVE01** to provide uptime monitoring across the network. This container also serves as a validation point for VLAN behavior through OPNsense.

---

## 1. Create the LXC Container in Proxmox

In the Proxmox web UI, click **Create CT** in the top-right corner.

### General tab
Configure the container with these values:

- **Node:** `hyprboxx`
- **CT ID:** `1201`
- **Hostname:** `uptimekuma`
- **Password:** set a password

### Template tab
Use the **Debian 13 standard template**.

### Disk tab
- Set disk size to **4 GiB**
- Leave everything else at default

### CPU tab
- **1 core** is sufficient

### Memory tab
- Set memory to **1024 MiB**
- Leave swap at **512 MiB**

### Network tab
Configure networking as follows:

- **Bridge:** `vmbr0`
- **VLAN tag:** `20`
- **IPv4:** `Static`
- **IP address:** `192.168.20.x`
- **Gateway:** `192.168.20.1`

### DNS / Host settings
Leave host settings as default.

---

## 2. Validate Initial Network Connectivity

From the Uptime Kuma container console, test external connectivity:

```bash
ping 8.8.8.8
```

This failed.

Next, test connectivity to OPNsense:

```bash
ping 192.168.20.1
```

This also failed, indicating a VLAN or bridge issue.

---

## 3. Inspect VLAN Tagging on Proxmox

From the Proxmox shell:

```bash
bridge vlan show
```

The issue observed was that the LXC veth interface showed **PVID 1** instead of **20**.

### Remove the incorrect PVID
```bash
bridge vlan del dev veth1201i0 vid 1
```

### Add the correct VLAN/PVID
```bash
bridge vlan add dev veth1201i0 vid 20 pvid untagged
```

---

## 4. Re-test Connectivity from the Container

Use `pct exec` from the Proxmox host:

```bash
pct exec 1201 -- ping -c 4 192.168.20.1
```

The result was still **Destination Host Unreachable**.

Run `bridge vlan show` again and confirm the interface now has **PVID 20**.

---

## 5. Verify Routing Inside the Container

From inside the container, check routes:

```bash
ip route show
```

The route looked correct, with default traffic going via `192.168.20.1`.

Run a verbose ping:

```bash
ping -c 4 -v 192.168.20.1
```

At the same time, from the Proxmox shell run:

```bash
tcpdump -i veth1201i0 -n
```

Observation:
- ARP “who-has” traffic was visible from the container
- OPNsense was not replying

---

## 6. Confirm Traffic Was Not Reaching OPNsense Correctly

Run packet capture from OPNsense as well.

The traffic was not properly reaching OPNsense on VLAN 20.

Running ARP checks on `vmbr0` showed the response behavior was effectively landing on **VLAN 10**, not VLAN 20. That meant VLAN 20 traffic was being treated incorrectly.

---

## 7. Review the LXC Network Configuration

From the Proxmox shell:

```bash
cat /etc/pve/lxc/1201.conf
```

The configuration showed `tag=20`, but it also included:

```text
firewall=1
```

This Proxmox firewall setting was interfering with VLAN tagging and routing.

### Disable the Proxmox firewall on the container NIC
```bash
pct set 1201 -net0 name=eth0,bridge=vmbr0,firewall=0,gw=192.168.20.1,hwaddr=BC:24:11:A8:92:14,ip=192.168.20.x/24,tag=20,type=veth
```

### Restart the container
```bash
pct stop 1201 && pct start 1201
```

After restart, the container still showed unreachable responses, but `bridge vlan show` now correctly reflected **PVID 20**.

---

## 8. Continue VLAN Investigation on OPNsense

On OPNsense, verify the VLAN interface name.

Running:

```bash
ifconfig vlan20
```

showed no interface, but:

```bash
ifconfig vlan0.20
```

returned the correct VLAN configuration.

Next, run:

```bash
tcpdump -i vlan0.20 -n arp
```

while pinging from the container again.

No packets appeared, meaning the traffic still was not getting to OPNsense correctly.

It also was not appearing on `tap1101i0`.

---

## 9. Fix VLAN Availability on tap1101i0

The resolution was to add the other VLANs to `tap1101i0` so the interface consistently carried the required VLAN traffic.

After that fix:
- Pings to OPNsense succeeded
- Pings to `8.8.8.8` succeeded
- DNS resolution to `google.com` succeeded

This confirmed both **internal VLAN connectivity** and **internet access** were working.

---

## 10. Persist the OPNsense VLAN Script Changes

Edit the Proxmox snippet used for OPNsense VLAN handling:

```bash
nano /var/lib/vz/snippets/opnsense-vlan.sh
```

Add the missing PVID lines for:

- VLAN 20
- VLAN 30
- VLAN 40
- VLAN 90

Also correct the noted typo involving VLAN 10 / PVID 90 as appropriate.

At this point, the screenshots confirmed the environment was working, with only minor packet loss.

---

## 11. Update the Container

Before installing Uptime Kuma, update the OS:

```bash
apt update && apt upgrade -y
```

---

## 12. Install Node.js

Add the NodeSource repository for Node.js 20:

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
```

Install Node.js:

```bash
apt install -y nodejs
```

---

## 13. Install Uptime Kuma Dependencies

Install PM2 globally:

```bash
npm install -g pm2
```

---

## 14. Clone and Set Up Uptime Kuma

Clone the repository:

```bash
GIT_TERMINAL_PROMPT=0 git clone https://github.com/louislam/uptime-kuma.git
```

Change into the project directory and run setup:

```bash
cd uptime-kuma
npm run setup
```

---

## 15. Start Uptime Kuma with PM2

Start the server:

```bash
pm2 start server/server.js --name uptime-kuma
```

Save the PM2 process list:

```bash
pm2 save
```

Enable PM2 startup:

```bash
pm2 startup
```

---

## 16. First Login

Open the Uptime Kuma web UI:

```text
http://192.168.20.x:3001
```

On first launch:

1. Choose **SQLite**
2. Sign in with **admin**
3. Set an admin password

You are then inside the Uptime Kuma dashboard and can begin creating monitors.

---

## 17. Initial Monitor Added

The first monitor created was the **Spectrum router**.

---

## Final State

By the end of this process:

- The LXC container was deployed successfully
- VLAN tagging issues were identified and resolved
- OPNsense connectivity was restored
- Internet access worked from the container
- Uptime Kuma was installed and reachable on port `3001`
- Initial monitoring setup began successfully
