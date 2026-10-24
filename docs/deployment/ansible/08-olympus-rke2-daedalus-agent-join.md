# Olympus RKE2 Daedalus Agent Join

## Outcome

`daedalus` joined Olympus successfully as the second dedicated RKE2 worker.
The cluster now has three embedded-etcd servers and two schedulable agent
nodes.

| Node | Address | Roles | RKE2 release |
| --- | --- | --- | --- |
| `talos` | `192.168.33.11` | `control-plane,etcd` | `v1.37.1+rke2r1` |
| `helios` | `192.168.33.12` | `control-plane,etcd` | `v1.37.1+rke2r1` |
| `orion` | `192.168.33.13` | `control-plane,etcd` | `v1.37.1+rke2r1` |
| `argus` | `192.168.33.14` | `<none>` (worker) | `v1.37.1+rke2r1` |
| `daedalus` | `192.168.33.15` | `<none>` (worker) | `v1.37.1+rke2r1` |

The `<none>` role is expected for RKE2 agent nodes. Both Argus and Daedalus
are schedulable workers; neither runs the Kubernetes control plane or etcd.

## Join configuration

Daedalus joins through Olympus's stable registration endpoint:

```yaml
server: "https://olympus-api.tylerdalton.dev:9345"
token: "{{ rke2_token }}"
node-ip: "{{ ansible_host }}"
```

| Setting | Value |
| --- | --- |
| Daedalus address | `192.168.33.15` |
| Registration DNS name | `olympus-api.tylerdalton.dev` |
| Registration VIP | `192.168.33.10` |
| Registration port | `9345` |
| Install type | `agent` |
| Managed service | `rke2-agent.service` |

The agent uses the existing Vault-backed `rke2_token`. The shared token is
stored in the encrypted parent-group Vault file at
`inventories/prod/group_vars/k8s/vault.yml`, making it available to both RKE2
servers and RKE2 agents without a duplicate server-group copy.

## Preflight and deployment

Before the live deployment, Daedalus passed all checks:

- Ansible connectivity succeeded.
- `olympus-api.tylerdalton.dev` resolved to `192.168.33.10`.
- TCP port `9345` was reachable through the VIP.
- The RKE2-agent playbook passed check mode without failures.

```bash
ansible daedalus -m ping
ansible daedalus -b -m command \
  -a 'resolvectl query olympus-api.tylerdalton.dev'
ansible daedalus -b -m shell \
  -a "timeout 5 bash -c '</dev/tcp/olympus-api.tylerdalton.dev/9345'"
ansible-playbook --check --diff playbooks/rke2-agent.yml
ansible-playbook playbooks/rke2-agent.yml
```

## Validation

Validate from an RKE2 server using its kubeconfig:

```bash
sudo /var/lib/rancher/rke2/bin/kubectl \
  --kubeconfig /etc/rancher/rke2/rke2.yaml \
  get nodes -o wide

sudo /var/lib/rancher/rke2/bin/kubectl \
  --kubeconfig /etc/rancher/rke2/rke2.yaml \
  get pods -A
```

Validation showed all five nodes `Ready`, with healthy Cilium and control-plane
components.

## Final node-role layout

| Group | Nodes | Purpose |
| --- | --- | --- |
| RKE2 servers | Talos, Helios, Orion | embedded etcd and Kubernetes control plane |
| Dedicated workers | Argus, Daedalus | application workload scheduling |

Talos has the `node-role.kubernetes.io/control-plane:NoSchedule` taint.
Helios and Orion remain schedulable RKE2 servers; Argus and Daedalus provide
dedicated worker capacity.

## References

- [RKE2 agent installation](https://docs.rke2.io/install/quickstart)
- [RKE2 HA Registration Endpoint](../kubernetes/rke2-ha-endpoint.md)
