# Homelab Hub Documentation (Step-by-Step)

## Overview

This guide walks through deploying Homelab Hub inside a Docker LXC
container in Proxmox.

## Prerequisites

-   Docker LXC container already running
-   Docker installed
-   Access to terminal inside container

## Step 1: Deploy Homelab Hub Container

Run the following command:

    docker run -d \
      --name homelab-hub \
      -p xxxx:xxxx \
      -v ./data:/data \
      --restart unless-stopped \
      raidowl/homelab-hub:latest

## Step 2: Handle Port Conflicts

If you see an error:

    port is already allocated

### Check Running Containers

    docker ps

### Identify Port Usage

Look for any container using port 8000.

## Step 3: Change Port

Modify the run command:

    -p xxxx:xxxx

## Step 4: Remove Failed Deployment

If partially deployed:

    docker rm homelab-hub

## Step 5: Redeploy

Run the updated command again.

## Step 6: Verify Deployment

    docker ps

## Step 7: Access UI

Open browser:

    http://<docker-lxc-ip>:xxxx

Homelab Hub should now be accessible.