# Cilium Service IPAM and L2 Announcements

## Purpose

Olympus uses Cilium's native service handling instead of `kube-proxy` and
uses Cilium L2 announcements to expose Kubernetes `LoadBalancer` Services on
the home LAN. This is the networking foundation for Gateway API routes such as
`argocd.tylerdalton.dev`.

The configuration is reconciled by Argo CD from the public repository. It
contains no credentials or secrets.

## Architecture

- Kubernetes nodes retain their static `192.168.33.x` addresses.
- The RKE2 API remains on the Keepalived VIP `192.168.33.10`.
- Cilium allocates service virtual IPs (VIPs) dynamically from
  `192.168.33.20-192.168.33.39`.
- The `olympus-services` L2 announcement policy advertises those VIPs over
  `eno1`. Cilium selects a leader node to answer ARP/NDP for each VIP and
  fails it over when necessary.

This is not DHCP. The range is static and reserved for Cilium, while the
allocation of a particular address to a Kubernetes Service is dynamic.

## Prerequisites

- Reserve or exclude `192.168.33.20-192.168.33.39` from the VLAN's DHCP
  scope. No other host may use an address in that range.
- All Olympus nodes expose the LAN on `eno1`.
- RKE2 has Cilium kube-proxy replacement, Gateway API, and L2 announcements
  enabled through the `rke2-cilium` HelmChartConfig.
- The Cilium DaemonSet is rolled out on all five nodes and no `kube-proxy`
  pods remain.

## GitOps manifests

The root Application discovers the Cilium networking child application:

```yaml
# olympus-gitops/apps/cilium-networking/application.yaml
spec:
  source:
    path: olympus-gitops/apps/cilium-networking/resources
```

That child application reconciles its own `resources/` directory, which
contains:

- `CiliumLoadBalancerIPPool/olympus-services` — `192.168.33.20-192.168.33.39`
- `CiliumL2AnnouncementPolicy/olympus-services` — advertises LoadBalancer
  VIPs through `eno1`

The policy intentionally has no Service selector, so all eligible
LoadBalancer Services can receive an address from the pool. No address is
claimed until a matching LoadBalancer Service exists.

## Verification

Run these commands on an RKE2 server. This example uses Talos's local
kubeconfig:

```bash
K=/var/lib/rancher/rke2/bin/kubectl
C=/etc/rancher/rke2/rke2.yaml

sudo "$K" --kubeconfig "$C" get applications -n argocd

sudo "$K" --kubeconfig "$C" get \
  ciliumloadbalancerippool olympus-services

sudo "$K" --kubeconfig "$C" get \
  ciliuml2announcementpolicy olympus-services
```

Expected state:

```text
olympus-cilium-networking   Synced   Healthy
olympus-root                Synced   Healthy

NAME               DISABLED   CONFLICTING IPS   AVAILABLE
olympus-services   false      False             20

NAME               AGE
olympus-services   <age>
```

An `AVAILABLE` count of `20` before a Gateway or other LoadBalancer Service
is created is correct.

## Argo CD refresh recovery

Argo CD polls Git periodically. If a pushed manifest is not detected promptly,
force the root application to refresh its repository cache:

```bash
sudo "$K" --kubeconfig "$C" annotate application olympus-root \
  -n argocd \
  argocd.argoproj.io/refresh=hard \
  --overwrite

sudo "$K" --kubeconfig "$C" get applications -n argocd -w
```

The child `olympus-cilium-networking` application should appear and become
`Synced` and `Healthy`.

## Next step

Install cert-manager, then declare a Cilium Gateway and HTTPRoute for the
Argo CD server. Creating the Gateway's LoadBalancer Service will claim the
first available VIP from this pool; DNS can then point
`argocd.tylerdalton.dev` to that VIP.

## References

- Cilium LoadBalancer IP Address Management: <https://docs.cilium.io/en/stable/network/lb-ipam/>
- Cilium L2 Announcements: <https://docs.cilium.io/en/stable/network/l2-announcements/>
- Cilium Gateway API: <https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/>
