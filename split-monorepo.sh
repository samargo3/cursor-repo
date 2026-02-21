#!/usr/bin/env bash
#
# split-monorepo.sh
#
# Extracts each project from cursor-repo into its own standalone Git repository,
# preserving full commit history via `git subtree split`.
#
# Usage:
#   ./split-monorepo.sh                  # Extract ALL projects
#   ./split-monorepo.sh demo-igniters    # Extract ONE project by key
#   ./split-monorepo.sh --list           # List configured projects
#   ./split-monorepo.sh --dry-run        # Show what would happen, no changes
#
# Prerequisites:
#   - Clean working tree (commit or stash pending changes)
#   - Destination directories must not already exist
#   - Create the GitHub repos before running (links are printed at the end)
#
# After extraction:
#   1. Verify each new repo (cd, git log, ls)
#   2. Push:  git push -u origin main
#   3. Clean up split branches in cursor-repo (optional):
#      git branch -d <split-branch>
#

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_PARENT="${DEST_PARENT:-$HOME}"
GITHUB_USER="${GITHUB_USER:-samargo3}"

# ---------------------------------------------------------------------------
# Project configuration
# Format: "KEY|PREFIX_IN_REPO|DEST_DIR_NAME|GITHUB_SLUG"
# Slug is used to build: https://github.com/GITHUB_USER/SLUG.git
# ---------------------------------------------------------------------------
declare -A PROJECT_PREFIX
declare -A PROJECT_DEST
declare -A PROJECT_SLUG
declare -A PROJECT_BRANCH

PROJECT_PREFIX["demo-igniters"]="projects/demo-igniters"
PROJECT_DEST["demo-igniters"]="demo-igniters"
PROJECT_SLUG["demo-igniters"]="demo-igniters"
PROJECT_BRANCH["demo-igniters"]="split/demo-igniters"

PROJECT_PREFIX["argo-energy-solutions"]="projects/argo-energy-solutions"
PROJECT_DEST["argo-energy-solutions"]="argo-energy-solutions"
PROJECT_SLUG["argo-energy-solutions"]="argo-energy-solutions"
PROJECT_BRANCH["argo-energy-solutions"]="split/argo-energy-solutions"

PROJECT_PREFIX["project-data-pipeline"]="projects/project-data-pipeline"
PROJECT_DEST["project-data-pipeline"]="project-data-pipeline"
PROJECT_SLUG["project-data-pipeline"]="project-data-pipeline"
PROJECT_BRANCH["project-data-pipeline"]="split/project-data-pipeline"

PROJECT_PREFIX["agentforce-contract-analysis"]="projects/Agentforce Contract Analysis"
PROJECT_DEST["agentforce-contract-analysis"]="agentforce-contract-analysis"
PROJECT_SLUG["agentforce-contract-analysis"]="agentforce-contract-analysis"
PROJECT_BRANCH["agentforce-contract-analysis"]="split/agentforce-contract-analysis"

PROJECT_PREFIX["my-sandbox"]="projects/My Sandbox"
PROJECT_DEST["my-sandbox"]="my-sandbox"
PROJECT_SLUG["my-sandbox"]="my-sandbox"
PROJECT_BRANCH["my-sandbox"]="split/my-sandbox"

PROJECT_PREFIX["pizza-chart-project"]="projects/Pizza Chart Project"
PROJECT_DEST["pizza-chart-project"]="pizza-chart-project"
PROJECT_SLUG["pizza-chart-project"]="pizza-chart-project"
PROJECT_BRANCH["pizza-chart-project"]="pizza-chart-project"

ALL_KEYS=(
  demo-igniters
  argo-energy-solutions
  project-data-pipeline
  agentforce-contract-analysis
  my-sandbox
  pizza-chart-project
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo "[INFO]  $*"; }
ok()   { echo "[OK]    $*"; }
warn() { echo "[WARN]  $*"; }
err()  { echo "[ERROR] $*" >&2; }

DRY_RUN=false

run() {
  if $DRY_RUN; then
    echo "  DRY-RUN: $*"
  else
    "$@"
  fi
}

list_projects() {
  echo ""
  echo "Configured projects:"
  echo "-----------------------------------------------------------"
  printf "  %-35s  %s\n" "KEY" "SOURCE PREFIX"
  echo "-----------------------------------------------------------"
  for key in "${ALL_KEYS[@]}"; do
    printf "  %-35s  projects/%s\n" "$key" "${PROJECT_PREFIX[$key]#projects/}"
  done
  echo ""
}

extract_project() {
  local key="$1"

  if [[ -z "${PROJECT_PREFIX[$key]+x}" ]]; then
    err "Unknown project key: '$key'"
    echo "Run with --list to see available keys."
    exit 1
  fi

  local prefix="${PROJECT_PREFIX[$key]}"
  local dest_dir="$DEST_PARENT/${PROJECT_DEST[$key]}"
  local split_branch="${PROJECT_BRANCH[$key]}"
  local remote_url="git@github-personal:${GITHUB_USER}/${PROJECT_SLUG[$key]}.git"

  echo ""
  echo "=================================================================="
  echo "  Extracting: $key"
  echo "  Source:     $prefix"
  echo "  Dest:       $dest_dir"
  echo "  Branch:     $split_branch"
  echo "  Remote:     $remote_url"
  echo "=================================================================="
  echo ""

  # --- Verify prefix exists ---
  if [[ ! -d "$REPO_ROOT/$prefix" ]]; then
    err "Source directory not found: $REPO_ROOT/$prefix"
    return 1
  fi

  # --- Check destination doesn't already exist ---
  if [[ -d "$dest_dir" ]]; then
    err "Destination already exists: $dest_dir"
    err "Remove or rename it, then run again."
    return 1
  fi

  # --- Subtree split ---
  log "Running git subtree split --prefix=\"$prefix\" -b \"$split_branch\" ..."
  run git -C "$REPO_ROOT" subtree split --prefix="$prefix" -b "$split_branch"
  ok "Subtree split complete → branch '$split_branch' created in cursor-repo."
  echo ""

  # --- Create new repo ---
  run mkdir -p "$dest_dir"
  ok "Created $dest_dir"

  run git -C "$dest_dir" init
  run git -C "$dest_dir" pull "$REPO_ROOT" "$split_branch"
  run git -C "$dest_dir" branch -m main
  ok "Initialized repo and pulled history (branch → main)."

  run git -C "$dest_dir" remote add origin "$remote_url"
  ok "Remote 'origin' set to: $remote_url"

  echo ""
  echo "------------------------------------------------------------------"
  echo "  VERIFY & PUSH: $key"
  echo "------------------------------------------------------------------"
  echo "  cd $dest_dir"
  echo "  ls -la                    # project files should be at root"
  echo "  git log --oneline -10     # confirm history"
  echo "  git remote -v             # confirm remote"
  echo ""
  echo "  # Create the GitHub repo and push:"
  echo "  gh repo create ${GITHUB_USER}/${PROJECT_SLUG[$key]} --private --source=. --remote=origin --push"
  echo "------------------------------------------------------------------"
  echo ""
}

cleanup_split_branches() {
  echo ""
  log "Cleaning up split branches in cursor-repo ..."
  for key in "${ALL_KEYS[@]}"; do
    local branch="${PROJECT_BRANCH[$key]}"
    if git -C "$REPO_ROOT" rev-parse --verify "$branch" &>/dev/null; then
      run git -C "$REPO_ROOT" branch -d "$branch"
      ok "Deleted branch: $branch"
    fi
  done
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
cd "$REPO_ROOT"

# Parse args
TARGETS=()
DO_CLEANUP=false

for arg in "$@"; do
  case "$arg" in
    --list)     list_projects; exit 0 ;;
    --dry-run)  DRY_RUN=true ;;
    --cleanup)  DO_CLEANUP=true ;;
    --help|-h)
      echo "Usage: $0 [--dry-run] [--list] [--cleanup] [project-key ...]"
      echo "  No project keys = extract all projects"
      list_projects
      exit 0
      ;;
    --*)
      err "Unknown option: $arg"
      exit 1
      ;;
    *)
      TARGETS+=("$arg")
      ;;
  esac
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  TARGETS=("${ALL_KEYS[@]}")
fi

# Safety: clean working tree
STATUS=$(git -C "$REPO_ROOT" status --porcelain)
if [[ -n "$STATUS" && "$DRY_RUN" == false ]]; then
  err "Working tree is not clean. Commit or stash changes first."
  git -C "$REPO_ROOT" status --short
  exit 1
fi
ok "Working tree is clean."

$DRY_RUN && warn "DRY RUN MODE – no changes will be made."

FAILED=()
for key in "${TARGETS[@]}"; do
  if ! extract_project "$key"; then
    FAILED+=("$key")
  fi
done

if $DO_CLEANUP; then
  cleanup_split_branches
fi

echo ""
echo "=================================================================="
if [[ ${#FAILED[@]} -eq 0 ]]; then
  echo "  All extractions complete."
else
  echo "  Completed with errors. Failed:"
  for f in "${FAILED[@]}"; do echo "    - $f"; done
fi
echo ""
echo "  NEXT STEPS:"
echo "  1. Verify each new repo (see instructions above)."
echo "  2. Create GitHub repos (if not done) and push."
echo "  3. Optionally run:  $0 --cleanup"
echo "     (deletes the temporary split/* branches from cursor-repo)"
echo "  4. Once all repos are pushed, remove projects/ from cursor-repo"
echo "     and update README.md with links to the new repos."
echo "=================================================================="
echo ""
