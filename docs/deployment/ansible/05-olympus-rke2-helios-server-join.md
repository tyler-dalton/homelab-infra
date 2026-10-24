# Olympus RKE2 Helios Server Join

## Outcome

`helios` joined the Olympus RKE2 cluster successfully as its second embedded-etcd
server. Both existing servers are `Ready` and run the same pinned RKE2 release.

| Node | Address | Roles | RKE2 release |
| --- | --- | --- | --- |
| `talos` | `192.168.33.11` | `control-plane,etcd` | `v1.37.1+rke2r1` |
| `helios` | `192.168.33.12` | `control-plane,etcd` | `v1.37.1+rke2r1` |

Cilium, the etcd members, and Kubernetes control-plane components were running
on both nodes after the join.

## Join contract

Helios joined through the stable RKE2 registration endpoint, not through the
Talos node address:

| Setting | Value |
| --- | --- |
| Registration endpoint | `https://olympus-api.tylerdalton.dev:9345` |
| Registration VIP | `192.168.33.10` |
| Helios node address | `192.168.33.12` |
| CNI | Cilium |
| Shared token | `vault_rke2_token` via Ansible Vault |

The shared RKE2 server configuration retains both endpoint forms as TLS SANs:

```yaml
tls-san:
  - olympus-api.tylerdalton.dev
  - 192.168.33.10
```

For a server joining an existing cluster, the rendered RKE2 configuration must
also contain:

```yaml
server: "https://olympus-api.tylerdalton.dev:9345"
node-ip: "192.168.33.12"
```

The original bootstrap server must not receive the `server` setting. The
configuration template should render it only when a host defines
`rke2_server`:

```jinja2
{% if rke2_server is defined %}
server: "{{ rke2_server }}"
{% endif %}
token: "{{ rke2_token }}"
```

Helios defines:

```yaml
ansible_host: 192.168.33.12
rke2_server: "https://olympus-api.tylerdalton.dev:9345"
```

Do not copy the resolved token into inventory, documentation, terminal output,
or a playbook. The existing Vault convention remains authoritative.

## DNS prerequisite

AdGuard Home at `192.168.10.23` provides the internal DNS rewrite:

```text
olympus-api.tylerdalton.dev -> 192.168.33.10
```

A joining node must use a resolver that can return this private answer. Verify
DNS and RKE2 registration-port reachability before an installation:

```bash
ansible helios -m ping
ansible helios -b -m command -a 'resolvectl query olympus-api.tylerdalton.dev'
ansible helios -b -m command -a 'bash -lc "timeout 5 bash -c '\''</dev/tcp/olympus-api.tylerdalton.dev/9345'\''"'
```

The expected DNS result is `192.168.33.10`. Do not mask a resolver failure
with an `/etc/hosts` entry.

## Deployment and verification

Use check mode and inspect the proposed changes before the live join:

```bash
ansible-playbook --check --diff playbooks/rke2-bootstrap.yml
ansible-playbook playbooks/rke2-bootstrap.yml
```

Use RKE2's kubeconfig explicitly for cluster validation. Without it, `kubectl`
falls back to `localhost:8080` and reports a refused connection.

```bash
sudo /var/lib/rancher/rke2/bin/kubectl \
  --kubeconfig /etc/rancher/rke2/rke2.yaml \
  get nodes -o wide

sudo /var/lib/rancher/rke2/bin/kubectl \
  --kubeconfig /etc/rancher/rke2/rke2.yaml \
  get pods -A
```

Successful validation shows both servers as `Ready`, with
`control-plane,etcd` roles, and the new server's etcd and control-plane pods
running.

## Availability boundary

Two embedded-etcd servers operate correctly but cannot tolerate losing either
server: two members require both for quorum. Add the planned third server
before treating Olympus as highly available.

## References

- [04 — Olympus RKE2 Bootstrap Preparation](./04-olympus-rke2-bootstrap-preparation.md)
- [RKE2 HA Registration Endpoint](../kubernetes/rke2-ha-endpoint.md)
- [RKE2 high-availability guidance](https://docs.rke2.io/install/ha)
- [RKE2 server configuration reference](https://docs.rke2.io/reference/server_config)
