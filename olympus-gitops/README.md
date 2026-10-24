# Olympus GitOps

This directory is the public GitOps source of truth for the Olympus RKE2
cluster. Argo CD watches this directory and reconciles the declared state to
the cluster.

## Layout

```text
olympus-gitops/
├── bootstrap/             # The one manifest applied manually to begin GitOps
├── clusters/olympus/      # Olympus-specific Argo CD configuration
├── infrastructure/        # Cluster services: cert-manager, storage, ingress, etc.
└── apps/                  # User-facing workloads
```

## Bootstrap boundary

`bootstrap/olympus-root.yaml` is intentionally the only application manifest
applied by hand after Argo CD itself is installed. It creates the root
application, which makes Argo CD manage the contents of
`clusters/olympus/`.

## Public repository policy

This repository is public. Do not commit plaintext Kubernetes `Secret`
objects, kubeconfigs, private keys, passwords, tokens, or Ansible Vault
material. Encrypted `SealedSecret` manifests may be committed only after the
Sealed Secrets controller is installed and its key is backed up securely.
