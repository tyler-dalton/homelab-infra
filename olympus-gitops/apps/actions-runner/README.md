# Olympus GitHub Actions runner

GitOps-managed Actions Runner Controller (ARC) scale set for `tyler-dalton/homelab-infra`.

The controller is installed by `apps/actions-runner-controller/application.yaml`; the ephemeral runner scale set is installed by `apps/actions-runner/application.yaml`. Both charts are pinned to 0.15.0. Runners scale from zero to one, and GitHub workflows select them using `runs-on: olympus-ansible`.

## Required one-time credentials

**Do not commit any credentials to this public repository.**

Create a GitHub App with repository access to `homelab-infra` and **Actions: Read and write** plus **Metadata: Read** permissions. Install it on this repository. In the `arc-runners` namespace, create a Secret named `olympus-arc-github-auth` with keys `github_app_id`, `github_app_installation_id`, and `github_app_private_key`. See GitHub's official ARC documentation for app permissions and authentication. Create the namespace first if necessary. The Argo application will remain unhealthy until the Secret exists.

In repository Actions secrets, create `OLYMPUS_SSH_PRIVATE_KEY` (dedicated key authorized for `dalt` on all three RKE2 servers) and `OLYMPUS_SSH_KNOWN_HOSTS` (verified SSH host keys, collected out-of-band). The deploy job writes these only to the ephemeral runner filesystem, never the repository. Configure non-interactive sudo for the SSH identity on target servers. Review privilege scope carefully.

GitHub repository environment `olympus-production` must exist. For unattended deploys, it cannot require manual reviewers.

## Network prerequisites

Runner pods need outbound HTTPS to GitHub and TCP/22 to `192.168.33.11-13`. This assumes Olympus's existing Cilium policy and VLAN routing permit the traffic. The runner is an ephemeral pod inside the Kubernetes cluster; do not grant it Kubernetes API permissions or mount the host filesystem. Never execute untrusted pull requests on this runner.

## Bootstrap caveat

The Argo root Application must already point to `olympus-gitops/apps`. If it still points at the legacy path, this app will not be discovered. Installing the controller and scale set does **not** itself run the deployment playbook; a push to `main` or manual workflow dispatch will queue it after registration.

## Verify

- Argo CD: `olympus-actions-runner-controller` and `olympus-actions-runner` should be Healthy/Synced.
- GitHub Settings → Actions → Runners: look for the `olympus-ansible` scale set.
- GitHub Actions: manually dispatch the `Ansible kubectl access` workflow on `main`, then confirm validation and deployment succeed.
