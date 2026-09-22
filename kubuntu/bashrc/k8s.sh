# =========================
# Kubernetes
# =========================

alias k='kubectl'

# ---------------------------------------------------------
# GET
# ---------------------------------------------------------
alias kg='kubectl get'

alias kgp='kubectl get pods'
alias kgd='kubectl get deployments'
alias kgss='kubectl get statefulsets'
alias kgds='kubectl get daemonsets'

alias kgsvc='kubectl get services'
alias kgi='kubectl get ingress'

alias kgsec='kubectl get secrets'
alias kgcm='kubectl get configmaps'

alias kgpvc='kubectl get pvc'
alias kgpv='kubectl get pv'

alias kgsa='kubectl get serviceaccount'

alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'

alias kga='kubectl get all'

# WIDE OUTPUT
alias kgpw='kubectl get pods -o wide'
alias kgpaw='kubectl get pods -A -o wide'
alias kgnw='kubectl get nodes -o wide'

# ---------------------------------------------------------
# GET - ALL
# ---------------------------------------------------------
alias kgpa='kubectl get pods'
alias kgda='kubectl get deployments'
alias kgssa='kubectl get statefulsets'
alias kgdsa='kubectl get daemonsets'

alias kgsvca='kubectl get services'
alias kgia='kubectl get ingress'

alias kgseca='kubectl get secrets'
alias kgcma='kubectl get configmaps'

alias kgpvca='kubectl get pvc'
alias kgpva='kubectl get pv'

alias kgsaa='kubectl get serviceaccount'

alias kgna='kubectl get nodes'
alias kgnsa='kubectl get namespaces'

# FIND ALL PODS FOR RESOURCE
function kpods() {
  kubectl get pods -A | grep -i "$1"
}

# ---------------------------------------------------------
# DESCRIBE
# ---------------------------------------------------------

alias kd='kubectl describe'

alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kdss='kubectl describe statefulset'
alias kdds='kubectl describe daemonset'

alias kdsvc='kubectl describe service'
alias kdi='kubectl describe ingress'

alias kdsec='kubectl describe secret'
alias kdcm='kubectl describe configmap'

alias kdpvc='kubectl describe pvc'
alias kdpv='kubectl describe pv'

alias kdsa='kubectl describe serviceaccount'

alias kdn='kubectl describe node'
alias kdns='kubectl describe namespace'

# ---------------------------------------------------------
# LOGS / EXEC
# ---------------------------------------------------------

alias kl='kubectl logs'
alias klf='kubectl logs -f'

alias ke='kubectl exec'
alias kei='kubectl exec -it'

# ---------------------------------------------------------
# APPLY / DELETE
# ---------------------------------------------------------

alias kdel='kubectl delete'

alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'

alias kak='kubectl apply -k'
alias kdk='kubectl delete -k'

# ---------------------------------------------------------
# ROLLOUTS
# ---------------------------------------------------------
alias kr='kubectl rollout'
alias krr='kubectl rollout restart'
alias krs='kubectl rollout status'
alias kru='kubectl rollout undo'

# ---------------------------------------------------------
# DEBUG / UTILITIES
# ---------------------------------------------------------

alias kctx='kubectl config current-context'
alias kctxs='kubectl config get-contexts'
alias kusectx='kubectl config use-context'

alias kev='kubectl get events --sort-by=.metadata.creationTimestamp'

alias ksetns='kubectl config set-context --current --namespace'
alias kprintns='kubectl config view --minify --output "jsonpath={..namespace}"; echo'

alias kpf='kubectl port-forward'
alias kcp='kubectl cp'
alias 'k?'='kubectl explain'

alias kapi='kubectl api-resources'
alias kapiv='kubectl api-versions'

alias ktopn='kubectl top nodes'
alias ktopp='kubectl top pods'

# ---------------------------------------------------------
# KUSTOMIZE
# ---------------------------------------------------------

alias kk='kubectl kustomize'
alias kkh='kubectl kustomize --enable-helm --load-restrictor LoadRestrictionsNone'

function kman() {
  local path="${1:-.}"
  local output="${2:-manifest.yaml}"

  kubectl kustomize "$path" \
    --enable-helm \
    --load-restrictor LoadRestrictionsNone \
    > "$output"

  echo "Rendered: $output"
}

# =========================
# Kubernetes Completions
# =========================

source <(kubectl completion bash)
complete -0 default -F __start_kubectl k
