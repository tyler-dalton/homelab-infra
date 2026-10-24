# Olympus Ansible CI/CD

Workflow: `.github/workflows/ansible-kubectl.yml`.

Pull requests affecting `ansible/**` are validated using GitHub-hosted runners. After changes land on `main`, the validation job runs again and a deployment job is scheduled on a dedicated **self-hosted** Linux runner with labels `self-hosted`, `linux`, and `olympus-ansible`. Manual dispatch is also supported on `main`.

## One-time runner setup (required before deployment can work)

1. Provision a dedicated, trusted Linux machine or VM with network reachability to `192.168.33.11-13` on TCP/22. Do **not** use a Kubernetes control-plane node as the runner. Install the GitHub Actions runner following the repository's **Settings → Actions → Runners → New self-hosted runner** instructions. Add the custom label `olympus-ansible`. Configure the runner as a persistent service.
2. Install a supported `ansible-core` release (tested syntax target: `2.18.10`) and OpenSSH client on that runner. Ensure its service account has a private SSH key authorized for `dalt` on each server, with strict host-key checking and pre-populated `known_hosts`. Never commit private keys or credentials.
3. Ensure `dalt` can use **non-interactive sudo** for the tasks this playbook requires, ideally with a tightly scoped sudoers policy. Do not use a password prompt or place sudo passwords in the repo.
4. In GitHub repository settings, create an environment named `olympus-production`. Configure deployment protections according to your risk tolerance. Required reviewers will **prevent fully automatic deployment**; omit them if unattended deployment is intentional.
5. Restrict who can push to `main` and who can administer the runner. Do not run untrusted pull-request code on the self-hosted runner. This workflow only uses the self-hosted runner for trusted `main` events.

## Operation and verification

- PR: YAML lint + Ansible syntax check + host targeting check; **no production changes**.
- Push to `main`: same validation, followed by SSH ping, Ansible check mode, then deployment. The role runs a read-only `kubectl get node` as `dalt` on each server as its final runtime check.
- If any check fails, the deployment job stops and GitHub marks the run failed.
- No workflow can deploy before the runner, network access, SSH credentials, and sudo privileges are provisioned.
- A successful GitHub merge is **not** proof of successful on-node deployment. Check the Actions run logs.

**Security:** The role gives `dalt` a local copy of the RKE2 cluster-admin kubeconfig. Protect both the user account and runner. A repository contributor with permission to merge changes to the deployment playbook effectively has infrastructure deployment privileges.
