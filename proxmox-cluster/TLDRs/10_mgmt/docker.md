# Docker LXC Overview

## What this service is
Docker is a container runtime platform used to package and run applications in isolated containers. In this homelab build, Docker is deployed inside a Proxmox LXC as well as a VM. Both have their use cases.

## Why I am using it
I am using Docker LXC to create a lightweight application host for smaller services that do not need a full virtual machine. 

I use the Docker VM for my "mission-critical" resources - things that I want to ensure are stable.

## How this service fits into my homelab
Docker acts as a reusable service host. Instead of deploying every application directly as a separate OS instance, I can use Docker to standardize deployment and lifecycle management for container-based services. It also pairs well with Portainer, which gives me a GUI for managing Docker stacks, containers, images, and volumes.

## Build profile used
- **Platform:** Proxmox VE
- **Deployment type:** LXC container
- **Install method:** Proxmox VE helper script
- **Container type:** Unprivileged
- **Hostname:** `dockerlxc` & `dockervm`
- **CT ID:** `1107` & `1108`
- **Gateway:** `192.168.10.1`
- **VLAN:** `10`

## Issues I ran into or important concerns during install

### 1. Deciding between Docker VM and Docker LXC
One early design issue was not technical but architectural: should Docker live in a VM or an LXC?

I addressed that by defining a workload rule:
- smaller, lighter services can live in the LXC
- heavier or more critical services may deserve a VM

This gave the deployment a clear purpose instead of treating LXC and VM as interchangeable.

### 2. Docker inside LXC requires specific container options
A major install risk is forgetting that Docker in LXC is not a plain default container deployment. If nesting is not enabled, Docker can fail outright or behave unpredictably.

**How I fixed it:**
I explicitly enabled:
- nesting
- keyctl
- TUN/TAP

Out of those, nesting was the most critical setting to get right.

### 3. Network consistency matters
Because this host is meant to provide services over the network, DHCP would make future service management more annoying.

**How I fixed it:**
I configured the LXC with a static IP during provisioning and matched it to the correct bridge, subnet, gateway, and VLAN.

## Outcome
The end result is a Docker-ready Proxmox LXC and VM positioned on the management network. It gives me a clean base for self-hosted services while accomodating to both important and lighter workloads.

## Why this matters in my documentation journey
This service shows that I am not just installing tools blindly. I am making infrastructure design decisions based on:
- workload type
- isolation needs
- resource efficiency
- network segmentation
- operational simplicity

That makes this a useful portfolio example because it reflects both technical setup work and the reasoning behind infrastructure choices.
