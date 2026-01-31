# Docker

This document covers Docker installation and container management decisions.

## Goals

My goal for this project is to create a system that allows me to easily 
manage the applications on my Raspberry Pi. Others use this interface 
directly in the command line, but I will be using Portainer to have 
access to a UI.

## Host

- **Device**: Raspberry Pi (SentinelPi)
- **OS**: Raspberry Pi OS (Debian-based)
- **Docker runtime**: Docker Engine (standalone)
- **Architecture**: ARM64

### Portainer

**Container**
- Image: `portainer/portainer-ce:latest`
- Restart policy: `always`
- Ports:
  - `9000` (legacy HTTP)
  - `9443` (HTTPS, primary)
- Volume:
  - `portainer_data` → `/data`
- Docker socket:
  - `/var/run/docker.sock:/var/run/docker.sock`

Portainer connects to Docker using **socket mode** and manages a single local environment:

- **Environment name**: `SentinelPiDock`
- **Endpoint**: `/var/run/docker.sock`
