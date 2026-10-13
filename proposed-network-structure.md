# Mapping out Refactored Network Topology

## VLAN 10 - Management (MGMT)

CIDR: `192.168.10.0/24`

| Address | Assignment |
|---|---|
| 192.168.10.1 | OPNsense gateway |
| 192.168.10.3 | Netgear 24p switch |
| 192.168.10.4 | Possible k8s switch |
| 192.168.10.10 | pve01 (hyprboxx) |
| 192.168.10.11 | pve02 (gridboxx) |
| 192.168.10.12 | pve03 (gateboxx |
| 192.168.10.20 | Tailscale VPN |
| 192.168.10.254 | RPI |

## VLAN 11 - Infrastructure (INFRA)

CIDR: `192.168.11.0/27`

| Address | Assignment |
|---|---|
| 192.168.11.1 | Infra Gateway |
| 192.168.11.2 | Reverse Proxy / Ingress VIP |
| 192.168.11.3 | Adguard DNS |
| 192.168.11.4-30 | Reserved Expansion |

## VLAN 20 - Monitoring (MON)

CIDR: `192.168.20.0/24`

| Address | Assignment |
|---|---|
| 192.168.20.1 | Monitoring Gateway |
| 192.168.20.xx | Uptime Kuma |
| 192.168.20.xx | Grafana |
| 192.168.20.xx | Prometheus |
| 192.168.20.xx | pve-exporter |

## VLAN 30 - Trusted Services (TRUST)

CIDR: `192.168.30.0/24`

## VLAN 33 - Kubernetes Nodes (KUBE)

CIDR: `192.168.33.0/28`

| Address | Assignment |
|---|---|
| 192.168.33.1 | Kubernetes Nodes Gateway |
| 192.168.33.2 | Kubernetes API Server VIP |
| 192.168.33.3 | k8sN1 |
| 192.168.33.4 | k8sN2 |
| 192.168.33.5 | k8sN3 |
| 192.168.33.6 | k8sN4 (expansion) |
| 192.168.33.7 | k8sN5 (expansion) |
| 192.168.33.8-14 | Reserved Expansion |

**Pod Network**: `10.42.0.0/16`
**Service Network**: `10.43.0.0/16`
**API VIP**: `192.168.33.2/32`
**Ingress VIP**: `192.168.11.2/32`

## VLAN 40 - Client Devices (CLIENT)

CIDR: `192.168.40.0/24`

## VLAN 41 - IoT (IOT)

CIDR: `192.168.41.0/24`

## VLAN 253 - Sandbox Lab (LAB)

CIDR: `192.168.253.0/24`

## VLAN 254 - DMZ (DMZ)

CIDR: `192.168.254.0/24`
