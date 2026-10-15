# Nginx Proxy Manager --- Service Overview

## Overview

Nginx Proxy Manager provides a centralized reverse proxy layer for
accessing services via domain names.

---

## Why I Use It

-   Simplifies access (no ports)
-   Central routing layer
-   Clean user experience

---

## Architecture Role

-   Reverse proxy gateway
-   Entry point for all services

---

## Networking Design

Deployed on **Management VLAN (10)** to provide access across all VLANs.

---

## Use Cases

-   Route \*.home.lan domains
-   Centralize service access
-   Abstract backend services

---

## Challenges

No major issues encountered during deployment.

---

## Benefits

-   Easy UI-based management
-   Scales with homelab growth
-   Improves usability

---

## Conclusion

Nginx Proxy Manager acts as the front door to the homelab.