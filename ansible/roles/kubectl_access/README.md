# kubectl_access

Configures ordinary `kubectl` commands for the Ansible SSH user on Olympus RKE2 **server** nodes. Uses RKE2's bundled kubectl binary rather than downloading a second version. Installs a symlink at `/usr/local/bin/kubectl` and a private copy of the local RKE2 admin kubeconfig at `~/.kube/config` (mode 0600).

From the `ansible/` directory:

```bash
ansible-playbook playbooks/kubectl-access.yml --syntax-check
ansible-playbook playbooks/kubectl-access.yml --check --diff
ansible-playbook playbooks/kubectl-access.yml
```

Then log into a server as `dalt` and run `kubectl get nodes` or `kubectl get pods -A`.

**Security:** This copies the RKE2 cluster-admin credential to the user's home directory. Treat that account and file as privileged. The copy is a snapshot: if RKE2 rotates or rewrites the kubeconfig, rerun this playbook. The kubeconfig's API endpoint is the node-local endpoint from RKE2; commands work on each server while its local API is available. This role deliberately does not configure agents, which lack the server admin kubeconfig. No RKE2 service restart is performed.

**Validation limitations:** Syntax and check mode do not prove API connectivity. The final task runs a real `kubectl get node` as the target user after deployment; it is read-only. Run the playbook from an Ansible controller with SSH and sudo access to the servers.
