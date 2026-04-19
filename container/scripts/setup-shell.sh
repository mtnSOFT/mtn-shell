#!/usr/bin/env bash
set -euo pipefail

# Append PS1 and helper to global bashrc in a way safe for Docker build layering

# Helper to print current git branch if in a git repository
cat >> /etc/bash.bashrc <<'BASH'
__mtn_git_branch() {
  # Only attempt if git is available
  command -v git >/dev/null 2>&1 || return
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    printf " \001\e[0;35m\002(%s)\001\e[0m\002" "$branch"
  fi
}
BASH

# Helper to show lock status based on BW_SESSION
cat >> /etc/bash.bashrc <<'BASH'
__mtn_lock_status() {
  if [ -n "${BW_SESSION:-}" ]; then
    printf " \001\e[0;32m\002●\001\e[0m\002"  # Green dot
  else
    printf " \001\e[0;31m\002●\001\e[0m\002"  # Red dot
  fi
}
BASH

# PS1: bold MTN — M and N bright yellow, T bold blue; lock status, git branch printed immediately after MTN on same line
# user is shown in bold white, path in bright yellow; no cyan used
cat >> /etc/bash.bashrc <<'BASH'
export PS1='\[\e[1;93m\]M\[\e[1;34m\]T\[\e[1;93m\]N\[\e[0m\]$(__mtn_lock_status)$(__mtn_git_branch) \[\e[1;34m\]\w\[\e[0m\]\$ '
BASH

cat >> /etc/bash.bashrc <<'BASH'
source /opt/mtn-shell/bin/findup.sh
source /opt/mtn-shell/bin/ssh.sh
BASH

# Start ssh-agent
cat >> /etc/bash.bashrc <<'BASH'
eval $(ssh-agent -s) > /dev/null
BASH
