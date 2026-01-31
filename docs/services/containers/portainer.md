# Portainer

## Overview
Portainer is the primary container management interface for the homelab.
All Docker workloads are created, modified, and monitored through Portainer rather than
direct CLI usage.

This ensures:
- consistent deployments
- visibility into running services
- reduced configuration drift

---

## Role in the Homelab
Portainer acts as the **control plane** for containerized services.

It is used to:
- deploy single containers
- deploy multi-service stacks
- manage volumes and networks
- inspect logs and container health
- safely restart or redeploy services

---

## Location / Access
**Host:** Raspberry Pi
**Access method:** LAN or via Tailscale
**WAN exposure:** none

---

## Deployment

### Platform
- Docker (ARM64)
- Managed via Docker socket binding


### Ports
- `9000` → Web UI
- (Optional) `9443` → HTTPS UI

### Restart Policy
- `unless-stopped`

---

## Data Persistence

Portainer state is stored in a Docker volume:
- `portainer_data` → `/data`

This volume contains:
- endpoint configuration
- stack definitions
- user accounts
- access control metadata

---

## Usage Conventions

### Container Creation
- Simple, single-purpose services may be deployed as individual containers
- Any service with:
  - multiple components
  - shared configuration
  - long-term importance  
  should be deployed as a **Portainer Stack**

---

### Stack Usage
Stacks are used for:
- Monitoring stack (Prometheus, exporters, Grafana)
- Any future multi-service applications

Benefits:
- Single source of truth
- Easier redeploys
- Clear documentation alignment

---

## Monitoring
Portainer is monitored via Uptime Kuma

---

## Security Notes
- Portainer is not exposed to the internet
- Admin access restricted to trusted users
- SSH access to the host is hardened separately
- Future improvements may include:
  - HTTPS-only access
  - role-based access controls

---

## Operational Notes
- Portainer UI is the authoritative source for container state
- CLI use is reserved for diagnostics only


