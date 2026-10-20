# RKE2 HA Registration Endpoint

## Decision

The RKE2 cluster will use `olympus-api.tylerdalton.dev` as its single, stable
registration and Kubernetes API endpoint. The name will resolve to
`192.168.33.10`, the address reserved as the Kubernetes API VIP in the
current VLAN 33 implementation.

| Item | Decision |
| --- | --- |
| DNS name | `olympus-api.tylerdalton.dev` |
| Stable endpoint address | `192.168.33.10` |
| Initial endpoint host | `olympus` |
| Proxy type | Layer 4 (TCP) |
| Registration backend port | `9345` on `talos`, `helios`, and `orion` |
| Kubernetes API backend port | `6443` on `talos`, `helios`, and `orion` |
| RKE2 server TLS SAN | `olympus-api.tylerdalton.dev` and `192.168.33.10` |

## Why this endpoint exists

RKE2 servers and agents must join through a fixed registration address. The
proxy presents one address while forwarding TCP traffic to the five RKE2
servers. It must forward both ports:

| Client traffic | Endpoint | Backends |
| --- | --- | --- |
| RKE2 server and agent registration | `olympus-api.tylerdalton.dev` | `talos`, `helios`, `orion`, `argus`, `daedalus` on `9345` |
| Kubernetes API access | `olympus-api.tylerdalton.dev:6443` | `talos`, `helios`, `orion`, `argus`, `daedalus` on `6443` |

The proxy must be TCP pass-through. It must not terminate TLS or rewrite HTTP.

## Initial implementation boundary

The first endpoint implementation on `olympus` provides a stable name and
backend health checks, but `olympus` is itself a single point of failure. This
is acceptable only as an initial homelab implementation: it preserves RKE2
server and etcd quorum during a single server-node failure, but it does not
make the entry point highly available.

End-to-end endpoint HA is a later enhancement. It requires a second proxy and
a floating address mechanism (for example, Keepalived/VRRP) or an equivalent
high-availability load-balancer design. Do not advertise the endpoint as fully
HA until that second component has been added and failover tested.

## Required changes before bootstrap

1. Assign `192.168.33.10` to the endpoint service on `olympus`; no other host
   may use that address.
2. Add an explicit AdGuard DNS rewrite for `olympus-api.tylerdalton.dev` to
   `192.168.33.10`. Do not rely on the existing wildcard rewrite, which is
   documented to target the Tailscale/reverse-proxy address.
3. Configure the TCP proxy with health checks for each server backend on both
   `9345` and `6443`.
4. Replace the current temporary allow-all VLAN 33 firewall policy with rules
   that permit the required client and node traffic to the endpoint and allow
   the endpoint to reach the three RKE2 servers on these ports.
5. Before installing RKE2, verify DNS and TCP connectivity from every planned
   server and agent node to both `olympus-api.tylerdalton.dev:9345` and
   `olympus-api.tylerdalton.dev:6443`.

## RKE2 configuration contract

Every RKE2 server must use the same critical cluster configuration and include
the endpoint in its TLS SAN list. Servers after the first and all agents must
register through the DNS name, never a direct server address.

```yaml
# shared server settings; token value will be stored in Ansible Vault
tls-san:
  - olympus-api.tylerdalton.dev
  - 192.168.33.10
```

```yaml
# additional RKE2 servers and all RKE2 agents
server: https://olympus-api.tylerdalton.dev:9345
```

The first RKE2 server initializes the cluster. Its generated join token is a
secret and must be copied into encrypted Ansible variables before additional
servers or agents are enrolled.

## Acceptance checks

- `olympus-api.tylerdalton.dev` resolves to `192.168.33.10` from all five nodes.
- TCP health checks report the intended RKE2 server backends healthy.
- The endpoint reaches `9345` and `6443` with every available backend.
- A server joined through the endpoint has a certificate valid for both the
  DNS name and VIP.
- Temporarily removing one backend leaves the endpoint usable through the
  remaining servers.

## Sources

- Current VLAN 33 implementation: `networking/opnsense/opnsense-refactor.md`
- Earlier, superseded addressing proposal: `networking/vlans/proposed-network-structure.md`
- RKE2 high-availability guidance: <https://docs.rke2.io/install/ha>
