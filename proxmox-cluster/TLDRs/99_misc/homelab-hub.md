# Homelab Hub Overview

## What is Homelab Hub?

Homelab Hub is a lightweight dashboard designed to centralize access to
services in a homelab environment.

## Why I Use It

-   Central visibility into services
-   Manage inventory
-   Clean UI for navigation
-   Lightweight compared to alternatives

## How It Fits Into My Homelab

-   Runs inside Docker LXC
-   Acts as a service dashboard layer
-   Complements monitoring tools like Uptime Kuma

## Issues Encountered

### Port Conflict

-   Error: port already allocated
-   Cause: another container using port `xxxx`

### Fix

-   Checked active containers using: docker ps
-   Changed port to `xxxx`
-   Removed failed container: docker rm homelab-hub
-   Redeployed successfully

## Final Result

-   Service accessible via browser
-   Integrated into homelab dashboard layer