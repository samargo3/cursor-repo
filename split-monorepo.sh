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
#   - SSH configured with 'github-personal' host alias in ~/.ssh/config
#
# After extraction:
#   1. Verify each new repo (cd, git log, ls)
#   2. Run: ./create-and-push.sh
#      (creates GitHub repos and pushes)
#

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

# ---------------------------------------------------------------------------
# Project config lookups (bash 3.2 compatible — no associative arrays)
# ---------------------------------------------------------------------------
get_prefix() {
  case "$1" in
    demo-igniters)               echo "projects/demo-igniters" ;;
    argo-energy-solutions)       echo "projects/argo-energy-solutions" ;;
    project-data-pipeline)       echo "projects/project-data-pipeline" ;;
    agentforce-contract-analysis) echo "projects/Agentforce Contract Analysis" ;;
    my-sandbox)                  echo "projects/My Sandbox" ;;
    pizza-chart-project)         echo "projects/Pizza Chart Project" ;;
    *) echo ""; return 1 ;;
  esac
}

get_dest() {
  case "$1" in
    demo-igniters)               echo "demo-igniters" ;;
    argo-energy-solutions)       echo "argo-energy-solutions" ;;
    project-data-pipeline)       echo "project-data-pipeline" ;;
    agentforce-contract-analysis) echo "agentforce-contract-analysis" ;;
    my-sandbox)                  echo "my-sandbox" ;;
    pizza-chart-project)         echo "pizza-chart-project" ;;
    *) echo ""; return 1 ;;
  esac
}

get_slug() { get_dest "$1"; }  # slug == dest for all projects

get_branch() {
  case "$1" in
    demo-igniters)               echo "split/demo-igniters" ;;
    argo-energy-solutions)       echo "split/argo-energy-solutions" ;;
    project-data-pipeline)       echo "split/project-data-pipeline" ;;
    agentforce-contract-analysis) echo "split/agentforce-contract-analysis" ;;
    my-sandbox)                  echo "split/my-sandbox" ;;
    pizza-chart-project)         echo "split/pizza-chart-project" ;;
    *) echo ""; return 1 ;;
  esac
}

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
    printf "  %-35s  %s\n" "$key" "$(get_prefix "$key")"
  done
  echo ""
}

extract_project() {
  local key="$1"

  local prefix
  prefix="$(get_prefix "$key")" || { err "Unknown project key: '$key'"; echo "Run with --list to see available keys."; exit 1; }

  local dest_dir="$DEST_PARENT/$(get_dest "$key")"
  local split_branch
  split_branch="$(get_branch "$key")"
  local slug
  slug="$(get_slug "$key")"
  local remote_url="git@github-personal:${GITHUB_USER}/${slug}.git"

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
  echo "  gh repo create ${GITHUB_USER}/${slug} --private --source=. --remote=origin --push"
  echo "------------------------------------------------------------------"
  echo ""
}

cleanup_split_branches() {
  echo ""
  log "Cleaning up split branches in cursor-repo ..."
  for key in "${ALL_KEYS[@]}"; do
    local branch
    branch="$(get_branch "$key")"
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
echo "  2. Run: ./create-and-push.sh"
echo "     (creates private GitHub repos and pushes)"
echo "  3. Optionally run:  $0 --cleanup"
echo "     (deletes the temporary split/* branches from cursor-repo)"
echo "  4. Once all repos are pushed, remove projects/ from cursor-repo"
echo "     and update README.md with links to the new repos."
echo "=================================================================="
echo ""
