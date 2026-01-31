# Uptime Kuma
## Basic network infra monitoring


This directory will host all the nodes I am status checking through Uptime Kuma.

### Goals:
- Know WHEN a server goes down
- Get real-time alerts on mobile devices through discord
- keep a setup that has great scalability

### Enviroment:
- Hardware: Raspberry Pi (ARM64)
- OS: Raspberry Pi OS (64-bit)
- Container Runtime: Docker
- Container Manager: Portainer
- Mobile Notifications: Discord Webhooks

## Docker Compose Deployment:

services:
  uptime-kuma:
    image: louislam/uptime-kuma:1
    container_name: uptime-kuma
    restart: unless-stopped
    ports:
      - "3001:3001"
    volumes:
      - uptime-kuma-data:/app/data

      
### Current apps being monitored on Uptime:

- Portainer
- Raspberry Pi
- Raspberry Pi SSH
- Uptime Kuma (self-monitor)
- Tailscale (gateway)
- Pihole UI
- Pihole DNS Server
- Heimdall (dashboard)
- Grafana
- Prometheus

As more applications are added, this list will grow in size.

