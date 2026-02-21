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

declare -A PROJECT_DEST
declare -A PROJECT_SLUG

PROJECT_DEST["demo-igniters"]="demo-igniters"
PROJECT_SLUG["demo-igniters"]="demo-igniters"

PROJECT_DEST["argo-energy-solutions"]="argo-energy-solutions"
PROJECT_SLUG["argo-energy-solutions"]="argo-energy-solutions"

PROJECT_DEST["project-data-pipeline"]="project-data-pipeline"
PROJECT_SLUG["project-data-pipeline"]="project-data-pipeline"

PROJECT_DEST["agentforce-contract-analysis"]="agentforce-contract-analysis"
PROJECT_SLUG["agentforce-contract-analysis"]="agentforce-contract-analysis"

PROJECT_DEST["my-sandbox"]="my-sandbox"
PROJECT_SLUG["my-sandbox"]="my-sandbox"

PROJECT_DEST["pizza-chart-project"]="pizza-chart-project"
PROJECT_SLUG["pizza-chart-project"]="pizza-chart-project"

ALL_KEYS=(
  demo-igniters
  argo-energy-solutions
  project-data-pipeline
  agentforce-contract-analysis
  my-sandbox
  pizza-chart-project
)

log()  { echo "[INFO]  $*"; }
ok()   { echo "[OK]    $*"; }
err()  { echo "[ERROR] $*" >&2; }

push_project() {
  local key="$1"
  local dest_dir="$DEST_PARENT/${PROJECT_DEST[$key]}"
  local slug="${PROJECT_SLUG[$key]}"

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

  # Create the GitHub repo and push in one step
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

# Parse args
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
