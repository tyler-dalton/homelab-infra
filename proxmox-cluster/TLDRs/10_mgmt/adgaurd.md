# AdGuard Home --- Service Overview

## Overview

AdGuard Home is a DNS-based filtering and resolution service used as the
backbone for internal domain routing.

---

## Why I Use It

-   Central DNS authority
-   Ad/tracker blocking
-   Internal domain resolution

---

## Architecture Role

-   Primary DNS server
-   Domain rewrite engine

---

## Networking Design

Deployed on **Management VLAN (10)** so all VLANs can consistently query
DNS.

---

## Use Cases

-   Resolve \*.home.lan domains
-   Network-wide ad blocking

---

## Challenges

No major issues encountered during deployment.

---

## Benefits

-   Centralized DNS control
-   Improves privacy and performance
-   Enables reverse proxy integration

---

## Conclusion

AdGuard acts as the foundation of internal name resolution in the
homelab.