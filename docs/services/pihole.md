# Pihole

## Overview

Pihole is used as an authoritative DNS server for my Netgear LAN. This service
provides network-wide ad blocking at the DNS level (all devices) It is run through my Pi
and monitored on Uptime Kuma

## Why Pihole?
- Locally hosted DNS control
- Network-wide ad blocking with no client config
- Foundation to run recursive DNS (unbound)

## Static IP Design
- The Pi uses a static Ethernet IP configured via NetworkManager, not router DHCP reservation.
### Why?
- Netgear DHCP reservations were unreliable behind Spectrum
- Avoids IP reassignment during network outages
- Prevents DNS outages when network fails

## Deployment Method
Platfrom: Docker via Portainer
Image: pihole/pihole:latest
Network mode: host
Restart policy: unless-stopped

## Persistent Storage
/etc/pihole ---> pihole-data
/etc/dnsmasq.d ---> dnsmasq-data

## Environment Variables
TZ = America/New_York
DNSMASQ_LISTENING = all
FTLCONF_LOCAL_IPV4 = <pi-ip>
WEBPASSWORD = (set password)

## Monitoring (Uptime Kuma)
2 interfaces being monitored:
- Pihole web UI
- Pihole DNS
