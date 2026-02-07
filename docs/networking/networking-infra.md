# Networking

This document covers the networking setup for SentinelPi, my Raspberry PI, including static IP
configuration using NetworkManager.

---

## Overview

Being in a college house, living with multiple roomates, can cause
for a homelab setup to have some workarounds. On the bright side, it definetly 
improves critical thinking and shows true application of skills

---

## Overall Network Topology

My home network infrastructure is definetly not ideal, but it makes the house happy 
and I still get to work on the skills I need to. I have a Spectrum router with a WiFi 7 card
attatched to the modem, from there I have my Pi and Netgear router (WiFi 5 Card) 
etherneted into the Spectrum router. I want the control of the Netgear, but the speeds of 
the Spectrum, so I settled for this configuration.

---

## Topology (Current)

- **ISP:** Spectrum
- **Upstream router:** Spectrum router (WAN gateway)
- **Homelab router:** Netgear router (LAN edge)

All homelab services live *behind* the Netgear router.
No services are directly exposed to the WAN.

---

## Addressing & IP Strategy

- **Static IPs:** Only for infrastructure (Pi, router, switch)
- **DHCP:** Used for client devices
- **No WAN port forwards**
- **Remote access:** Tailscale only

## Current Project

- Installing Arch Linux as a daily driver OS on a new machine
- Will use Arch to manage my servers from home, will SSH in when on-the-go
- Installing Proxmox on another new machine
- Host all servers/VM's on this machine

