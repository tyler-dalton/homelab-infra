# Portainer Overview

## What this service is
Portainer is a web-based management interface for Docker. It provides a GUI for handling containers, images, volumes, networks, and stacks without relying entirely on the command line.

## Why I am using it
I am using Portainer to simplify Docker administration inside my homelab. Instead of managing every Docker action through shell commands, Portainer gives me a centralized dashboard where I can deploy, inspect, troubleshoot, and maintain Docker-based services more efficiently.

## How I am using it in this environment
In this build, Portainer is installed directly as part of the Docker helper-script deployment. That means it is tightly tied to the Docker host and becomes available immediately after Docker finishes provisioning.

After deployment, I use it as the management layer for Docker so I can:
- view running containers
- manage images and volumes
- deploy future applications
- reduce the amount of direct CLI work needed for routine administration

## Why this fits my homelab
Portainer is useful here because it lowers operational friction. In a homelab where I am documenting builds and iterating often, having a clear web interface makes it easier to:
- verify services are running
- manage deployments faster
- visualize container resources
- troubleshoot issues without remembering every Docker command from scratch

It also gives Docker a more polished operational layer, which is useful both for day-to-day management and for showcasing the environment to employers reviewing the project.

## Key deployment details
- **Parent host:** Docker running in Proxmox LXC
- **Docker LXC hostname:** `dockerlxc` & `dockervm`
- **Install method:** automatic through the Docker LXC helper script

## Issues I ran into or decisions I had to make

### 1. Portainer was bundled into the Docker installation flow
One thing that needed attention was understanding that Portainer was not being installed as a separate standalone process in this setup. It appears as an option during the Docker helper-script workflow.

**How I handled it:**
I treated Portainer as a dependent service and enabled it when the helper script asked whether to create the Portainer UI.

### 2. Misleading SSH-related prompt during install
A key point during installation was a prompt related to SSH control of Docker. This could easily be misunderstood as something required for Portainer.

**How I handled it:**
I selected **No** because I already had access through Proxmox and did not want to introduce extra access methods that were not necessary.

This was both an operational and security-minded decision.

### 3. First access depends on network correctness
Portainer is only useful if the Docker host is reachable and correctly addressed.

**How I handled it:**
I made sure the Docker LXC had a static IP, correct gateway, and correct VLAN placement during the earlier Docker setup. That made Portainer reachable immediately at the expected address.

## Security and operational considerations
Even though Portainer makes Docker easier to manage, it also becomes a sensitive administrative surface. That means:
- the admin password should be strong
- access should stay limited to the intended management network
- unnecessary remote-control options should be avoided
- Proxmox-side access control still matters

## Outcome
The final result is a working Portainer instance layered on top of the Docker LXC, providing a clean and practical web UI for container administration.

## Why this matters for my portfolio
Portainer is more than just a convenience tool in this project. It demonstrates that I am thinking about:
- manageability
- operator workflow
- service dependencies
- security tradeoffs
- how to make self-hosted infrastructure usable over time

That makes it a strong companion piece to the Docker documentation because it shows both the backend service layer and the admin tooling used to operate it.
