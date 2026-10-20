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
| Endpoint placement | A floating virtual IP across `talos`, `helios`, and `orion` |
| Proxy type | Layer 4 (TCP) |
| Registration backend port | `9345` on `talos`, `helios`, and `orion` |
| Kubernetes API backend port | `6443` on `talos`, `helios`, and `orion` |
| RKE2 server TLS SAN | `olympus-api.tylerdalton.dev` and `192.168.33.10` |

## Why this endpoint exists

`olympus-api.tylerdalton.dev` is the shared doorway for the five-node cluster,
not a host or a sixth node. All three servers and both agents use it to reach
cluster services without depending on the address of any particular node.

RKE2 servers and agents must join through a fixed registration address. The
proxy presents one address while forwarding TCP traffic only to the three
RKE2 **server** nodes. It must forward both ports:

| Client traffic | Endpoint | Backends |
| --- | --- | --- |
| RKE2 server and agent registration | `olympus-api.tylerdalton.dev:9345` | `talos`, `helios`, `orion` on `9345` |
| Kubernetes API access | `olympus-api.tylerdalton.dev:6443` | `talos`, `helios`, `orion` on `6443` |

The proxy must be TCP pass-through. It must not terminate TLS or rewrite HTTP.

`argus` and `daedalus` are RKE2 agents. They join through port `9345` and run
workloads, but they do not run the RKE2 server process and therefore do not
listen for registration or serve the Kubernetes API on these ports. They must
not be load-balancer backends for this endpoint.

## Implementation model

The endpoint will be implemented on the three RKE2 server nodes:

- HAProxy runs on `talos`, `helios`, and `orion`, performing TCP health checks
  and forwarding ports `9345` and `6443` to the healthy RKE2 servers.
- Keepalived/VRRP owns `192.168.33.10` as a floating address. Exactly one
  server advertises the address at a time; it moves to another server if the
  current owner fails.

This makes Olympus highly available without creating a separate host. A
failure of one server removes one RKE2 and proxy backend but leaves the VIP and
the remaining healthy server backends available, provided etcd quorum remains.

Olympus is only the RKE2 registration and API endpoint. Kubernetes workload
traffic will later need its own ingress or service load-balancer design; it is
not automatically carried by this endpoint.

## Required changes before bootstrap

1. Reserve `192.168.33.10` exclusively for the Olympus virtual IP. It must
   not be permanently assigned to any node interface.
2. Add an explicit AdGuard DNS rewrite for `olympus-api.tylerdalton.dev` to
   `192.168.33.10`. Do not rely on the existing wildcard rewrite, which is
   documented to target the Tailscale/reverse-proxy address.
3. Configure HAProxy and Keepalived on `talos`, `helios`, and `orion` before
   RKE2 bootstrap. HAProxy must health-check server backends on both `9345`
   and `6443`; Keepalived must fail over the virtual IP.
4. Replace the current temporary allow-all VLAN 33 firewall policy with rules
   that permit all five nodes to reach the virtual IP on `9345` and `6443`,
   and allow the three proxy instances to reach the RKE2 server backends on
   those ports.
5. Before installing RKE2, verify that DNS resolves to the virtual IP from
   every node and that the virtual IP fails over between server nodes. Verify
   the RKE2 backend ports only after the first server has started.

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
- The virtual IP reaches `9345` and `6443` through every available RKE2
  server backend.
- A server joined through the endpoint has a certificate valid for both the
  DNS name and VIP.
- Stopping Keepalived on the active VIP owner moves the virtual IP to another
  RKE2 server and leaves the endpoint usable through the remaining servers.

## Sources

- Current VLAN 33 implementation: `networking/opnsense/opnsense-refactor.md`
- Earlier, superseded addressing proposal: `networking/vlans/proposed-network-structure.md`
- RKE2 high-availability guidance: <https://docs.rke2.io/install/ha>
