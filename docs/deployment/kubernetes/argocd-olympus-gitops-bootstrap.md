# Argo CD Bootstrap for Olympus

## Purpose

Olympus uses Argo CD to reconcile Kubernetes configuration from the public
[`tyler-dalton/homelab-infra`](https://github.com/tyler-dalton/homelab-infra)
repository. The GitOps source is kept in `olympus-gitops/` at the repository
root so its platform configuration and application definitions are visible as
portfolio work alongside the Ansible infrastructure code.

The initial installation is deliberately a two-step bootstrap:

1. Install Argo CD once with `kubectl`.
2. Apply one root `Application`. From then on, Argo CD reconciles the Olympus
   configuration from Git.

## Public repository rules

The repository is public. Never commit plaintext Kubernetes `Secret` objects,
kubeconfigs, private keys, passwords, tokens, or Ansible Vault files.

Encrypted `SealedSecret` manifests are acceptable only after the Sealed
Secrets controller has been installed and its controller key has been backed
up outside Git. Non-sensitive manifests, Helm values, Argo Applications, and
operational configuration belong in the repository.

## Repository layout

```text
olympus-gitops/
├── bootstrap/
│   └── olympus-root.yaml       # The only Application applied manually
└── apps/
    ├── argocd/resources/project.yaml
    ├── argocd-access/
    │   ├── application.yaml
    │   └── resources/
    ├── cilium-networking/
    │   ├── application.yaml
    │   └── resources/
    ├── gateway/
    │   ├── application.yaml
    │   └── resources/
    ├── internal-pki/
    │   ├── application.yaml
    │   └── resources/
    └── cert-manager/application.yaml
```

The root Application recursively discovers `*/application.yaml` and the
Olympus AppProject at `argocd/resources/project.yaml`. Each managed component
is self-contained under `apps/<app-name>/`; base manifests belong in
`resources/`, while `patches/` is reserved for actual overlays.

## Prerequisites

- Olympus is healthy: three Ready RKE2 servers (`talos`, `helios`, `orion`)
  and two Ready agents (`argus`, `daedalus`).
- `olympus-gitops/` is committed and pushed to the `main` branch.
- Administration is performed from an RKE2 server using its local kubeconfig.

The examples below run on `talos`:

```bash
K=/var/lib/rancher/rke2/bin/kubectl
C=/etc/rancher/rke2/rke2.yaml
```

## Install Argo CD in high-availability mode

Olympus uses Argo CD's HA installation manifest. It has multiple replicas for
the components that support it and is appropriate for a production-style
cluster rather than an evaluation-only installation.

```bash
sudo "$K" --kubeconfig "$C" create namespace argocd \
  --dry-run=client -o yaml | \
  sudo "$K" --kubeconfig "$C" apply -f -

sudo "$K" --kubeconfig "$C" apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/ha/install.yaml
```

### ApplicationSet CRD annotation-size correction

The initial client-side manifest application can fail for
`applicationsets.argoproj.io` with:

```text
metadata.annotations: Too long: may not be more than 262144 bytes
```

This does not mean the Argo CD installation failed. Apply the Argo CD CRDs
server-side to avoid client-side last-applied annotation size limits:

```bash
sudo "$K" --kubeconfig "$C" apply --server-side --force-conflicts -k \
  'https://github.com/argoproj/argo-cd/manifests/crds?ref=stable'
```

Verify the missing CRD exists:

```bash
sudo "$K" --kubeconfig "$C" get crd applicationsets.argoproj.io
```

## Validate Argo CD

Wait for the HA Redis StatefulSet, then check every Argo CD pod:

```bash
sudo "$K" --kubeconfig "$C" rollout status \
  statefulset/argocd-redis-ha-server \
  -n argocd \
  --timeout=5m

sudo "$K" --kubeconfig "$C" get pods -n argocd
```

All long-running pods must be `Running` with their full ready count. In
particular, the Redis StatefulSet should show all three pods ready before the
GitOps root application is created.

## Hand Olympus to Argo CD

Apply the one bootstrap manifest from the public `main` branch:

```bash
sudo "$K" --kubeconfig "$C" apply -f \
  https://raw.githubusercontent.com/tyler-dalton/homelab-infra/main/olympus-gitops/bootstrap/olympus-root.yaml
```

The root Application initially uses Argo CD's built-in `default` project. This
is intentional: the `olympus` AppProject is created by the repository that
the root Application syncs, so it cannot be required before the first sync.

Watch reconciliation:

```bash
sudo "$K" --kubeconfig "$C" get applications -n argocd -w
```

Expected result:

```text
olympus-root   Synced   Healthy
```

At this point Argo CD continuously discovers Application definitions from
`olympus-gitops/apps` in Git. No workload is deployed by this bootstrap alone.

### Migrating an existing root Application

If the live root still points to `olympus-gitops/clusters/olympus`, updating
the bootstrap file in Git does not modify it. After the new layout has been
merged, apply the bootstrap manifest again, then verify the root source and
both child Applications before retiring legacy paths:

```bash
sudo "$K" --kubeconfig "$C" apply -f olympus-gitops/bootstrap/olympus-root.yaml
sudo "$K" --kubeconfig "$C" -n argocd get application olympus-root \
  -o jsonpath='{.spec.source.path}{"\\n"}'
sudo "$K" --kubeconfig "$C" -n argocd get application \
  olympus-cilium-networking olympus-cert-manager \
  -o jsonpath='{range .items[*]}{.metadata.name}{": "}{.status.sync.status}{" / "}{.status.health.status}{"\\n"}{end}'
```

The root path must be `olympus-gitops/apps`; both children must be `Synced /
Healthy`. Do not delete or recreate Applications during this migration.

## Next GitOps component

Install the Sealed Secrets controller as the first Argo-managed platform
component. Back up its controller key before relying on encrypted secrets;
without that key, existing `SealedSecret` resources cannot be recovered after
a controller loss.

## References

- Argo CD HA installation: <https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/>
- Argo CD declarative setup: <https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/>
- Sealed Secrets: <https://github.com/bitnami-labs/sealed-secrets>
