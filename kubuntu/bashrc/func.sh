# =========================
# Common Functions
# =========================

# MAKE DIRECTORY & ENTER IT
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# COMMIT & PUSH CURRENT BRANCH
function gcp() {
    git add .
    git commit -m "$1" &&
    git push origin "$(git branch --show-current)"
}
