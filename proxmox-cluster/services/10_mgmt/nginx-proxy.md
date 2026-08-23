# Nginx Proxy Manager Installation Guide (Proxmox LXC)

## Overview

Deploy Nginx Proxy Manager to provide reverse proxy access to internal
services.

---

## 1. Create LXC Container

-   Template: debian-13-standard\
-   CPU: 2 cores\
-   RAM: 2048 MiB\
-   Swap: 512 MiB\
-   Disk: 8G\
-   Network VLAN: 10 (Management)\
-   IP: 192.168.10.x

### Design Decision

Placed on **Management VLAN (10)** to serve all VLANs.

---

## 2. Access Web UI

http://192.168.10.x:81

Login and initialize.

---

## 3. Configure Proxy Hosts

### Proxmox

-   Domain: hyprboxx.home.lan\
-   Scheme: https\
-   Forward: 192.168.10.x:8006

### Laptop

-   Domain: tp16.home.lan\
-   Scheme: http\
-   Forward: 192.168.10.x:80

### Uptime Kuma

-   Domain: kuma.home.lan\
-   Scheme: http\
-   Forward: 192.168.20.x:3001

### NPM UI

-   Domain: nginx.home.lan\
-   Scheme: http\
-   Forward: 192.168.10.x:81

---

## 4. Validation

-   Access services via domain names\
-   Confirm routing through proxy

---

## Result

All services are accessible through clean internal domains.
