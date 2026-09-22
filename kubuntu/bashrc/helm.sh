# =========================
# Helm
# =========================

alias h='helm'

# ---------------------------------------------------------
# REPOSITORY MANAGEMENT
# ---------------------------------------------------------
alias hr='helm repo'
alias hra='helm repo add'
alias hru='helm repo update'
alias hrl='helm repo list'

# ---------------------------------------------------------
# RELEASES
# ---------------------------------------------------------
alias hlist='helm list'
alias hlista='helm list -A'
alias hs='helm status'
alias hh='helm history'

# ---------------------------------------------------------
# INSTALL / UPGRADE / UNINSTALL
# ---------------------------------------------------------
alias hi='helm install'
alias hu='helm upgrade'
alias hui='helm upgrade --install'
alias hun='helm uninstall'

# ---------------------------------------------------------
# CHART DEVELOPMENT
# ---------------------------------------------------------
alias hdep='helm dependency'
alias hdepu='helm dependency update'
alias hdepb='helm dependency build'

alias hl='helm lint'
alias hl.='helm lint .'
alias ht='helm template'
alias hp='helm package'

# ---------------------------------------------------------
# INSPECTION
# ---------------------------------------------------------
alias hsv='helm show values'
alias hsc='helm show chart'
alias hsa='helm show all'

alias hgv='helm get values'
alias hgm='helm get manifest'

# ---------------------------------------------------------
# DEBUG / DRY-RUN / SEARCH / VERSION
# ---------------------------------------------------------
alias hdry='helm install --dry-run --debug'
alias hudry='helm upgrade --install --dry-run --debug'
alias hsr='helm search repo'
alias hv='helm version'
alias hsrv='helm search repo --versions'

# ---------------------------------------------------------
# OCI / CHARTS
# ---------------------------------------------------------
alias hpl='helm pull'
alias hpush='helm push'

# ---------------------------------------------------------
# HELM UNITTEST
# ---------------------------------------------------------
alias htest='helm unittest'

# ---------------------------------------------------------
# PLUGINS
# ---------------------------------------------------------
alias hplugins='helm plugin list'

# =========================
# Kubernetes + Helm Development Helpers
# =========================

# RENDER CHART LOCALLY
function hrender() {
  helm template "$@"
}

# LINT & UNITTEST A CHART
function hcheck() {
  local chart="${1:-.}"

  echo "==> Helm lint"
  helm lint "$chart" || return 1

  echo
  echo "==> Helm unit tests"
  helm unittest "$chart"
}

# FULL HELM DEVELOPMENT CHECK
function hvalidate() {
  local chart="${1:-.}"

  echo "==> Updating dependencies"
  helm dependency build "$chart" || return 1

  echo
  echo "==> Lint"
  helm lint "$chart" || return 1

  echo
  echo "==> Unit tests"
  helm unittest "$chart" || return 1

  echo
  echo "==> Template render"
  helm template test "$chart" >/dev/null || return 1

  echo
  echo "Helm validation passed! Attaboy dalt"
}

# =========================
# Helm Completion
# =========================

source <(helm completion bash)
complete -0 default -F __start_helm h
