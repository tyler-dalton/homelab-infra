# Olympus GitOps

This directory is the public GitOps source of truth for the Olympus RKE2
cluster. Argo CD's root Application discovers approved child definitions under
`apps/` and reconciles them to the cluster.

## Layout

```text
olympus-gitops/
├── bootstrap/
│   └── olympus-root.yaml  # The one manifest applied manually to begin GitOps
└── apps/
    ├── argocd/resources/project.yaml
    ├── cilium-networking/
    │   ├── application.yaml
    │   └── resources/
    └── cert-manager/application.yaml
```

## Bootstrap boundary

`bootstrap/olympus-root.yaml` is intentionally the only application manifest
applied by hand after Argo CD itself is installed. It creates the root
application, which makes Argo CD manage the contents of
`apps/`. New applications are self-contained under `apps/<app-name>/`; adding
one does not require changing a central Kustomization. Use `resources/` for
base manifests and add `patches/` only for real overlays.

## Migration from the legacy root path

The live root may still watch `olympus-gitops/clusters/olympus`; changing this
file in Git does not change that live Application. Legacy `clusters/` and
`infrastructure/` paths are retained until this migration is verified.

After this layout is merged and available to the cluster, re-apply the root:

```sh
kubectl apply -f olympus-gitops/bootstrap/olympus-root.yaml
kubectl -n argocd get application olympus-root -o jsonpath='{.spec.source.path}{"\\n"}'
kubectl -n argocd get application olympus-cilium-networking olympus-cert-manager
kubectl -n argocd get application olympus-cilium-networking olympus-cert-manager -o jsonpath='{range .items[*]}{.metadata.name}{": "}{.status.sync.status}{" / "}{.status.health.status}{"\\n"}{end}'
```

Confirm the root path is `olympus-gitops/apps` and both child Applications are
`Synced / Healthy` before removing the legacy paths in a later change. Do not
delete or recreate Applications during this migration.

## Public repository policy

This repository is public. Do not commit plaintext Kubernetes `Secret`
objects, kubeconfigs, private keys, passwords, tokens, or Ansible Vault
material. Encrypted `SealedSecret` manifests may be committed only after the
Sealed Secrets controller is installed and its key is backed up securely.
