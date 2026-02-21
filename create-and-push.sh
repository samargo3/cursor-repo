#!/usr/bin/env bash
#
# create-and-push.sh
#
# Run this on your LOCAL machine after running split-monorepo.sh.
# For each extracted project it will:
#   1. Create a private GitHub repo (via gh CLI)
#   2. Push the local 'main' branch to it
#
# Prerequisites:
#   - gh CLI installed and authenticated (gh auth login)
#   - split-monorepo.sh has already been run (extracted dirs exist)
#   - SSH configured with 'github-personal' host alias in ~/.ssh/config
#
# Usage:
#   ./create-and-push.sh               # All projects
#   ./create-and-push.sh demo-igniters # Single project

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_PARENT="${DEST_PARENT:-$HOME}"
GITHUB_USER="${GITHUB_USER:-samargo3}"

ALL_KEYS=(
  demo-igniters
  argo-energy-solutions
  project-data-pipeline
  agentforce-contract-analysis
  my-sandbox
  pizza-chart-project
)

get_dest() {
  case "$1" in
    demo-igniters)                echo "demo-igniters" ;;
    argo-energy-solutions)        echo "argo-energy-solutions" ;;
    project-data-pipeline)        echo "project-data-pipeline" ;;
    agentforce-contract-analysis) echo "agentforce-contract-analysis" ;;
    my-sandbox)                   echo "my-sandbox" ;;
    pizza-chart-project)          echo "pizza-chart-project" ;;
    *) echo ""; return 1 ;;
  esac
}

get_slug() { get_dest "$1"; }

log()  { echo "[INFO]  $*"; }
ok()   { echo "[OK]    $*"; }
err()  { echo "[ERROR] $*" >&2; }

push_project() {
  local key="$1"
  local dest_dir="$DEST_PARENT/$(get_dest "$key")"
  local slug
  slug="$(get_slug "$key")"

  echo ""
  echo "=================================================================="
  echo "  Creating & pushing: $key"
  echo "  Dir:    $dest_dir"
  echo "  Repo:   github.com/${GITHUB_USER}/${slug}"
  echo "=================================================================="

  if [[ ! -d "$dest_dir/.git" ]]; then
    err "Extracted repo not found at: $dest_dir"
    err "Run split-monorepo.sh first."
    return 1
  fi

  if gh repo view "${GITHUB_USER}/${slug}" &>/dev/null 2>&1; then
    log "Repo ${GITHUB_USER}/${slug} already exists on GitHub, pushing..."
    git -C "$dest_dir" push -u origin main
  else
    log "Creating ${GITHUB_USER}/${slug} on GitHub..."
    gh repo create "${GITHUB_USER}/${slug}" \
      --private \
      --source="$dest_dir" \
      --remote=origin \
      --push
  fi

  ok "Done: https://github.com/${GITHUB_USER}/${slug}"
}

TARGETS=()
for arg in "$@"; do
  TARGETS+=("$arg")
done
[[ ${#TARGETS[@]} -eq 0 ]] && TARGETS=("${ALL_KEYS[@]}")

FAILED=()
for key in "${TARGETS[@]}"; do
  if ! push_project "$key"; then
    FAILED+=("$key")
  fi
done

echo ""
echo "=================================================================="
if [[ ${#FAILED[@]} -eq 0 ]]; then
  echo "  All repos created and pushed successfully."
else
  echo "  Completed with errors. Failed:"
  for f in "${FAILED[@]}"; do echo "    - $f"; done
fi
echo "=================================================================="
echo ""
