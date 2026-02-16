# Vaultwarden (Bitwarden-compatible) — Homelab Deployment

Self-hosted Vaultwarden deployed on Proxmox as a dedicated Debian LXC, 
running Vaultwarden via Docker Compose with HTTPS enabled (self-signed for now). 
Reverse proxy + proper TLS planned later.

---

## Service Summary

- **Service:** Vaultwarden
- **Purpose:** Password manager backend (Bitwarden-compatible)
- **Host:** Proxmox (bare metal) → LXC container
- **Container Hostname:** `vaultwarden`
- **DNS:** Planned (reverse proxy + friendly name later)
- **Remote Access:** Via Tailscale subnet routing

---

## Prereqs / Dependencies

- Proxmox installed and updated
- Debian 12 LXC template available
- LXC features:
  - **Nesting: enabled** (required for Docker inside LXC)
- Docker + Compose plugin installed inside the LXC
- HTTPS enabled using Vaultwarden’s built-in TLS (Rocket TLS)

---

## Proxmox LXC Configuration

- **Type:** Unprivileged container
- **Nesting:** Enabled
- **CPU:** 2 cores
- **RAM:** 2048 MB
- **Disk:** 8 GB (LVM-thin)

---

## On-Container Setup

### Install Docker (inside LXC)

```bash
apt update
apt -y upgrade
apt -y install ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" \
  > /etc/apt/sources.list.d/docker.list

apt update
apt -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
docker version
