# homelab-infra
This is my page to document all major steps in my homelab as I progress. This will act as my refrence point, to keep track of my journey. Follow along if you would like!

## Overview
This repository documents the design, teardown, and rebuild of my personal homelab
centered around a Raspberry Pi acting as a network infrastructure node.

The goal of this project is to document the foundation of my homelab. Some of the first
projects I will focus on are rebuilding my VPN, and restablishing the containers I previously had installed.
I plan to acheive a basic network infrastructure with this setup, and continue to build as I grow in IT.

## Goals
- Basic network infra
- Clean separation between host and application services
- Containerized, reproducible deployments
- Clear documentation of design decisions and trade-offs

## Architecture (Current Direction)
- Raspberry Pi OS (With static IP)
- Host-level VPN
- Docker-based services (DNS, monitoring, management)

## Why This Project Exists
Rather than following isolated tutorials, this homelab is being built intentionally,
with a focus on understanding *why* each component exists and how they interact.

## Why the rebuild?
Well, one of the most obvious reasons would be so that I can 
bring Github into the jounrney. I also have hit some roadblocks that 
caused for some revamps to the phsyical networking. I had aquired a router along with my 
Raspberry Pi to start my homelab journey. Recently, I had come across that the router I was given
had an outdated WiFi card, but had much more control over settings. This led me to bringing back the old router,
and etherneting my Netgear router with more control so that I can benefit from faster speeds, but everything 
on the homelab network has ulimate control.

## Status
- Static IP configured and verified
- Clean-slate rebuild in progress
- Services being reintroduced incrementally and documented
