# VPN

This document describes how I deployed Tailscale as a 
subnet router on a Raspberry Pi to provide secure remote access 
to an entire home lab network, even behind double NAT / ISP-locked routers.

## End Goal

Ideally, the plan is to set up a VPN on the Raspberry Pi
so that I can have remote acess to any local services 
that I may need. This is including but not limited to:
my routers admin page, Pihole management, and Uptime Kuma
mobile interface monitoring.

## This setup gives me the ability to:
- SSH into any LAN device from any location
- Access router, switch, and any service admin page
- Cut out port forwarding
- Not have any headaches with ISP router

## Host Details:

- Device: Raspberry Pi (ARM64)
- OS: Raspberry Pi OS (64-bit)
- VPN: Tailscale (installed on host OS)

## Design Benchmarks:

- No inbound ports
- Full LAN remote access
- No changes to ISP router
- Set up subnet routing to access any client on the home IP subnet

## Summary:

This setup turns my Pi into a secure, always available 
gateway to my home network for ease of access, without dealing with any ISP restrictions.
