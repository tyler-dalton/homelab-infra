# Heimdall (Homelab Dashboard)

## Overview
Heimdall is the homelab start page / dashboard used as a centralized landing hub for all internal services (Portainer, Uptime Kuma, Pi-hole, router admin, etc.). 
Eventually I plan to make this my starting page when I boot my computer.

## Network / Access
**Host:** Raspberry Pi 4B
**Remote access:** via Tailscale, no WAN exposure required

## Deployment
**Platform:** Docker via Portainer (Container UI)
**Image:** `lscr.io/linuxserver/heimdall:latest`
**Restart policy:** `unless-stopped`

### Port mappings
Host `8085` → Container `80`
(Optional) Host `8443` → Container `443`

## Persistence (Volumes)
Two Docker volumes are used:
- `heimdall-config` → `/config` required (apps, settings, icons, DB)
- `heimdall-data` → `/data`      (optional / future-proof)

## Environment Variables
- `PUID=1000`
- `PGID=1000`
- `TZ=America/New_York`

## UI Setup Notes

### Web Search Bar
Heimdall supports a browser search bar (DuckDuckGo/Google/etc.) as a page element:
- Enable Search Providers / Web Search Bar in Heimdall settings
- Set preferred provider (DuckDuckGo recommended)


## Apps Added (baseline)
- Portainer
- Uptime Kuma 
- Pi-hole 
- Netgear router admin
- Tailscale admin

## Monitoring (Uptime Kuma)
- HTTP monitor:
  - Name: `Heimdall`
  - Interval: 60s, Retries: 3, Timeout: 10s

## Future Enhancements
- Convert Heimdall deployment to a Portainer Stack (low priority)
- Configure as ladning page for my computer
