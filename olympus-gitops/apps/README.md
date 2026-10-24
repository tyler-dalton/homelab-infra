# Applications

Argo CD-managed components live in self-contained `apps/<app-name>/`
directories. Put each Application definition in `application.yaml`; put base
manifests in `resources/`, and use `patches/` only for actual overlays. The
root Application discovers these definitions recursively, so adding an app
does not require editing a central Kustomization.
