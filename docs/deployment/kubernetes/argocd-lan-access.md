# Argo CD LAN Gateway Access

## Scope and prerequisites

This configuration exposes the manually installed Olympus Argo CD server only
on the VLAN 33 Cilium LoadBalancer VIP `192.168.33.20`. It creates no
NodePort, host-network listener, WAN port forward, public tunnel, Ingress, or
internet-facing HTTP-01 challenge.

The live cluster was checked before this configuration was prepared:

- Cilium `GatewayClass/cilium` is accepted and its controller is healthy.
- Gateway API v1, including `Gateway`, `HTTPRoute`, `ReferenceGrant`, and
  `BackendTLSPolicy`, is installed.
- The `olympus-services` pool covers `192.168.33.20` through
  `192.168.33.39`, has no allocated addresses, and its L2 policy announces
  LoadBalancer addresses on `eno1`.
- cert-manager v1.21.1 is healthy; the `olympus-internal-ca` root Secret was
  created outside Git and the GitOps `ClusterIssuer`/leaf certificate are
  prepared for sync.
- The Argo CD server Service is ClusterIP-only and exposes ports 80 and 443
  to container port 8080.

## GitOps layout

`olympus-gitops/apps/gateway/` owns the shared Gateway, the shared
certificate, and HTTP redirects. `olympus-gitops/apps/argocd-access/` manages
only the Argo CD server setting and its HTTPS route; it does not manage the
AppProject, either Application object, or the manually installed Argo CD
installation.

The Gateway and certificate live in `gateway-system`. It provides exact
listeners for `argocd.tylerdalton.dev` and wildcard listeners for
`*.apps.tylerdalton.dev`, all on the same private VIP. Routes may attach from
application namespaces; backend Services remain in their respective route
namespaces, so this Argo CD route needs no `ReferenceGrant`.

## TLS and backend protocol

The Gateway terminates TLS with the `olympus-gateway-tls` Secret in
`gateway-system`. That certificate covers both `argocd.tylerdalton.dev` and
`*.apps.tylerdalton.dev`.
The HTTPS route then sends HTTP to the existing ClusterIP Service on port 80.
For that deliberate TLS-termination design, `server.insecure: "true"` is
managed as a server-side-applied key in the existing `argocd-cmd-params-cm`.
It prevents the server from redirecting the Gateway's HTTP backend connection
back to HTTPS, which would otherwise create a redirect loop.

This does **not** make Argo CD externally plaintext: the Service remains
ClusterIP and the only client-facing listener is the Gateway's HTTPS listener.
Because this setting is consumed as a Deployment environment variable, sync
alone does not restart existing Pods. Restart the Deployment after the child
Application has synced. Do not apply this child Application until the Gateway
certificate Secret can be created.

The Argo CD CLI may need `--grpc-web`, because the HTTPRoute transports the
web UI/API as HTTP through the Gateway rather than exposing native gRPC:

```sh
argocd login argocd.tylerdalton.dev --grpc-web
```

## Internal CA and DNS

`olympus-internal-pki` declares the non-secret `ClusterIssuer` named
`olympus-internal-ca`. Its CA keypair must be manually created as the
`olympus-internal-ca` TLS Secret in `cert-manager`; it is intentionally not
represented in Git. Run the following only from the secured RKE2 management
host after authorizing the cluster change:

```sh
K=/var/lib/rancher/rke2/bin/kubectl
C=/etc/rancher/rke2/rke2.yaml
umask 077
pki_tmp=$(mktemp -d)
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -days 3650 \
  -keyout "$pki_tmp/ca.key" -out "$pki_tmp/ca.crt" \
  -subj '/CN=Olympus Internal CA'
sudo "$K" --kubeconfig "$C" -n cert-manager create secret tls olympus-internal-ca \
  --cert="$pki_tmp/ca.crt" --key="$pki_tmp/ca.key"
```

Securely distribute `ca.crt` to every LAN client trust store, then remove the
temporary directory according to the management host's approved secret
handling procedure. Never commit the key, the Secret, or certificate data.
The shared Gateway `Certificate` requests the leaf Secret
`olympus-gateway-tls` from that issuer.

AdGuard Home at `192.168.10.23` is the DNS server used by the Olympus nodes.
Create rewrites for `argocd.tylerdalton.dev` and
`*.apps.tylerdalton.dev`, both to `192.168.33.20`. Kubernetes DNS does not
serve laptops or other LAN clients.

## Apply, verification, and recovery

After the CA Secret has been created and the Git revision is available to the
root Application, request a root refresh and let the child Applications'
automated sync policies reconcile them:

```sh
K=/var/lib/rancher/rke2/bin/kubectl
C=/etc/rancher/rke2/rke2.yaml

sudo "$K" --kubeconfig "$C" -n argocd annotate application olympus-root \
  argocd.argoproj.io/refresh=hard --overwrite
sudo "$K" --kubeconfig "$C" -n argocd get application olympus-internal-pki olympus-gateway olympus-argocd-access
sudo "$K" --kubeconfig "$C" get clusterissuer olympus-internal-ca
sudo "$K" --kubeconfig "$C" -n gateway-system get gateway olympus
sudo "$K" --kubeconfig "$C" -n gateway-system get httproute argocd-http-redirect apps-http-redirect
sudo "$K" --kubeconfig "$C" -n argocd get httproute argocd-https
sudo "$K" --kubeconfig "$C" -n gateway-system get certificate olympus-gateway-tls
sudo "$K" --kubeconfig "$C" -n argocd rollout restart deployment/argocd-server
sudo "$K" --kubeconfig "$C" -n argocd rollout status deployment/argocd-server
```

Check the Gateway `Accepted=True` and `Programmed=True`; check both routes for
`Accepted=True` and `ResolvedRefs=True`. From a LAN client using AdGuard:

```sh
dig +short argocd.tylerdalton.dev
curl -I http://argocd.tylerdalton.dev
curl -Iv https://argocd.tylerdalton.dev
argocd login argocd.tylerdalton.dev --grpc-web
```

DNS must return only `192.168.33.20`; HTTP must redirect to HTTPS; TLS must
validate for `argocd.tylerdalton.dev`; and the browser login must complete
without a redirect loop. In OPNsense, confirm there is no WAN NAT or firewall
port-forward rule for `192.168.33.20` on ports 80 or 443. To recover, revert
the access Application's Git change, allow it to sync, and restart
`argocd-server`; the manually installed Argo CD components remain intact.
