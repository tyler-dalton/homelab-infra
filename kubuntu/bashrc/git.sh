# =========================
# Git
# =========================
alias g='git'

# Repository
alias gini='git init'
alias gcl='git clone'

# Status / Inspection
alias gst='git status'
alias gss='git status --short'
alias gdi='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --decorate --graph'
alias gla='git log --oneline --decorate --graph --all'

# Stage
alias ga='git add'
alias gaa='git add .'

# Commit
alias gc='git commit -s'
alias gcm='git commit -s -m'
alias gca='git commit -s --amend'
alias gcan='git commit -s --amend --no-edit'

# Branches
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'

alias gsw='git switch'
alias gcb='git checkout -b'

# Remote
alias gr='git remote -v'
alias gfo='git fetch origin'
alias gfom='git fetch origin main'

# Pull / Push
alias gpl='git pull'
alias gplo='git pull origin'
alias gpo='git push origin'
alias gpu='git push'

# Push current branch
alias gpc='git push origin "$(git branch --show-current)"'

# Push current branch and set upstream
alias gpcu='git push -u origin "$(git branch --show-current)"'

# Undo
alias gundo='git reset --soft HEAD~1'
alias gunstage='git restore --staged'
alias greset='git restore'

# Stash
alias gstow='git stash'
alias gstowl='git stash list'
alias gpop='git stash pop'
alias gstowu='git stash -u'

# =========================
# Git Completion
# =========================

# ATTATCH COMPLETION ENGINE TO ALL ALIASES
# Base Aliases
__git_complete g __git_main

# Status & Diff
__git_complete gst _git_status
__git_complete gss _git_status
__git_complete gdi _git_diff

# Log
__git_complete gl _git_log
__git_complete gla _git_log

# Stage & Commit
__git_complete ga _git_add
__git_complete gaa _git_add
__git_complete gc _git_commit
__git_complete gcm _git_commit
__git_complete gca _git_commit
__git_complete gcan _git_commit

# Branch & Switch
__git_complete gb _git_branch
__git_complete gba _git_branch
__git_complete gbd _git_branch
__git_complete gbD _git_branch
__git_complete gsw _git_switch
__git_complete gcb _git_checkout

# Remote & Fetch
__git_complete gr _git_remote
__git_complete gfo _git_fetch
__git_complete gfom _git_fetch

# Pull & Push
__git_complete gpl _git_pull
__git_complete gplo _git_pull
__git_complete gpo _git_push
__git_complete gpu _git_push
__git_complete gpc _git_push
__git_complete gpcu _git_push

# Undo & Stash
__git_complete gunstage _git_restore
__git_complete greset _git_restore
__git_complete gstow _git_stash
__git_complete gstowl _git_stash
__git_complete gpop _git_stash
__git_complete gstowu _git_stash
