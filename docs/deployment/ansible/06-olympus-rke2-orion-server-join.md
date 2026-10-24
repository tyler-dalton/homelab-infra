# Olympus RKE2 Orion Server Join

## Outcome

`orion` joined Olympus as the third embedded-etcd server. Olympus now has a
three-server RKE2 control plane, and all members are `Ready`.

| Node | Address | Roles | RKE2 release |
| --- | --- | --- | --- |
| `talos` | `192.168.33.11` | `control-plane,etcd` | `v1.37.1+rke2r1` |
| `helios` | `192.168.33.12` | `control-plane,etcd` | `v1.37.1+rke2r1` |
| `orion` | `192.168.33.13` | `control-plane,etcd` | `v1.37.1+rke2r1` |

The etcd members, Kubernetes API servers, controller managers, schedulers,
kube-proxy, and Cilium components were running after the join.

## Join contract

Orion joined through the shared registration endpoint:

| Setting | Value |
| --- | --- |
| Registration endpoint | `https://olympus-api.tylerdalton.dev:9345` |
| Registration VIP | `192.168.33.10` |
| Orion node address | `192.168.33.13` |
| CNI | Cilium |
| Shared token | `vault_rke2_token` via Ansible Vault |

Orion's inventory variables include the host-specific join setting:

```yaml
ansible_host: 192.168.33.13
rke2_server: "https://olympus-api.tylerdalton.dev:9345"
```

The shared RKE2 configuration retains the endpoint DNS name and VIP in its
TLS SAN list. The Vault-backed token, pinned RKE2 version, CNI, and any other
critical server configuration must remain identical across all three servers.

## Automation correction

The reusable RKE2 role now verifies the node being deployed rather than a
hard-coded bootstrap host. Its post-install checks use `inventory_hostname`:

```yaml
get node {{ inventory_hostname }}
```

```yaml
wait --for=condition=Ready node/{{ inventory_hostname }} --timeout=600s
```

This ensures a future server deployment cannot pass merely because an older
server is already healthy. The deployment playbook targeted only `orion`; no
existing cluster member was reconfigured.

## Preflight and deployment

Orion passed the expected preflight checks before installation:

- Ansible connectivity succeeded.
- `olympus-api.tylerdalton.dev` resolved to `192.168.33.10`.
- TCP port `9345` was reachable through the VIP.
- Ansible check mode completed without failures.

Use the same sequence for future joining servers:

```bash
ansible <host> -m ping
ansible <host> -b -m command -a 'resolvectl query olympus-api.tylerdalton.dev'
ansible <host> -b -m shell \
  -a "timeout 5 bash -c '</dev/tcp/olympus-api.tylerdalton.dev/9345'"
ansible-playbook --check --diff playbooks/rke2-bootstrap.yml
ansible-playbook playbooks/rke2-bootstrap.yml
```

## Validation

Use RKE2's kubeconfig explicitly. Without it, `kubectl` defaults to
`localhost:8080` and reports a refused connection.

```bash
sudo /var/lib/rancher/rke2/bin/kubectl \
  --kubeconfig /etc/rancher/rke2/rke2.yaml \
  get nodes -o wide

sudo /var/lib/rancher/rke2/bin/kubectl \
  --kubeconfig /etc/rancher/rke2/rke2.yaml \
  get pods -A
```

The validation showed Talos, Helios, and Orion as `Ready`, each with
`control-plane,etcd` roles.

## Availability state

With three embedded-etcd servers, Olympus can maintain etcd quorum after the
loss of one server. The stable VIP and its load-balancer configuration must
also remain available for continued registration and API access.

## References

- [RKE2 high-availability guidance](https://docs.rke2.io/install/ha)
- [RKE2 server configuration reference](https://docs.rke2.io/reference/server_config)
