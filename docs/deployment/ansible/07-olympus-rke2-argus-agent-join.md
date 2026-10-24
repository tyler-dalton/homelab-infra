# Olympus RKE2 Argus Agent Join

## Outcome

`argus` joined Olympus successfully as the first dedicated RKE2 worker. It is
`Ready` and does not participate in the control plane or embedded etcd.

| Node | Address | Roles | RKE2 release |
| --- | --- | --- | --- |
| `talos` | `192.168.33.11` | `control-plane,etcd` | `v1.37.1+rke2r1` |
| `helios` | `192.168.33.12` | `control-plane,etcd` | `v1.37.1+rke2r1` |
| `orion` | `192.168.33.13` | `control-plane,etcd` | `v1.37.1+rke2r1` |
| `argus` | `192.168.33.14` | `<none>` (worker) | `v1.37.1+rke2r1` |

The `<none>` role for Argus is expected. RKE2 agents register as schedulable
workers without an etcd or control-plane role.

## Cluster scheduling policy

Talos has the declarative control-plane taint:

```text
node-role.kubernetes.io/control-plane:NoSchedule
```

Talos remains a healthy Kubernetes node, but normal workloads without a
matching toleration will not be scheduled there. Helios and Orion remain
schedulable RKE2 servers, and Argus is the first dedicated worker.

## Shared Vault scope

`vault_rke2_token` is a cluster-wide join secret. It belongs in the encrypted
parent-group Vault file so both servers and agents inherit it:

```text
inventories/prod/group_vars/k8s/vault.yml
```

The server-only Vault file must not retain a duplicate copy:

```text
inventories/prod/group_vars/rke2_servers/vault.yml
```

Never place the resolved token in inventory, role defaults, documentation, or
terminal captures.

## Agent configuration

Argus joins through the shared registration endpoint and uses the existing
Vault-backed token:

```yaml
server: "https://olympus-api.tylerdalton.dev:9345"
token: "{{ rke2_token }}"
node-ip: "{{ ansible_host }}"
```

The agent automation uses `INSTALL_RKE2_TYPE=agent` and manages
`rke2-agent.service`. It must not use the server role or start
`rke2-server.service`.

## Deployment sequence

Before installation, validate the target node and the stable endpoint:

```bash
ansible argus -m ping
ansible argus -b -m command \
  -a 'resolvectl query olympus-api.tylerdalton.dev'
ansible argus -b -m shell \
  -a "timeout 5 bash -c '</dev/tcp/olympus-api.tylerdalton.dev/9345'"
ansible-playbook --check --diff playbooks/rke2-agent.yml
```

The DNS name must resolve to `192.168.33.10`, and TCP port `9345` must be
reachable through that VIP. The live deployment is then:

```bash
ansible-playbook playbooks/rke2-agent.yml
```

## Validation

Run validation from an RKE2 server using its kubeconfig:

```bash
sudo /var/lib/rancher/rke2/bin/kubectl \
  --kubeconfig /etc/rancher/rke2/rke2.yaml \
  get nodes -o wide
```

Successful validation shows Argus as `Ready` at `192.168.33.14` alongside the
three established `control-plane,etcd` servers.

## Next step

Deploy `daedalus` as the second dedicated RKE2 worker using the same agent
playbook and preflight sequence.

## References

- [RKE2 agent installation](https://docs.rke2.io/install/quickstart)
- [RKE2 HA Registration Endpoint](../kubernetes/rke2-ha-endpoint.md)
