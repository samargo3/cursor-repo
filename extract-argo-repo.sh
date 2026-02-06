#!/usr/bin/env bash
#
# Extract projects/argo-energy-solutions into a standalone Git repo with full history.
# Run this from the cursor-repo root: ./extract-argo-repo.sh
#

set -e

REPO_ROOT="${1:-$HOME/cursor-repo}"
PREFIX="projects/argo-energy-solutions"
SPLIT_BRANCH="argo-split-branch"
NEW_DIR="$HOME/argo-energy-solutions"
NEW_REPO_URL="https://github.com/samargo3/argo-energy-solutions.git"

echo "=== Argo Energy Solutions – Repo Extract (subtree split) ==="
echo "Repo root:    $REPO_ROOT"
echo "Prefix:       $PREFIX"
echo "Split branch: $SPLIT_BRANCH"
echo "New dir:      $NEW_DIR"
echo ""

# --- Safety: clean working tree ---
cd "$REPO_ROOT"
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "ERROR: $REPO_ROOT is not a Git repository."
  exit 1
fi

STATUS=$(git status --porcelain)
if [ -n "$STATUS" ]; then
  echo "ERROR: Working tree is not clean. Commit or stash changes first."
  echo ""
  git status --short
  exit 1
fi
echo "[OK] Working tree is clean."
echo ""

# --- Subtree split ---
echo "Running: git subtree split --prefix=$PREFIX -b $SPLIT_BRANCH"
git subtree split --prefix="$PREFIX" -b "$SPLIT_BRANCH"
echo "[OK] Subtree split complete. Branch '$SPLIT_BRANCH' created."
echo ""

# --- New directory ---
if [ -d "$NEW_DIR" ]; then
  echo "ERROR: Directory already exists: $NEW_DIR"
  echo "Remove or rename it, then run this script again."
  exit 1
fi
mkdir -p "$NEW_DIR"
echo "[OK] Created $NEW_DIR"
echo ""

# --- Init and pull split history ---
cd "$NEW_DIR"
git init
git pull "$REPO_ROOT" "$SPLIT_BRANCH"
git branch -m main
echo "[OK] Initialized repo and pulled $SPLIT_BRANCH (branch renamed to main)."
echo ""

# --- Remote ---
git remote add origin "$NEW_REPO_URL"
echo "[OK] Remote 'origin' set to: $NEW_REPO_URL"
echo ""

echo "=== Done ==="
echo ""
echo "VERIFY BEFORE PUSH:"
echo "  1. cd $NEW_DIR"
echo "  2. ls -la                    # expect project files at root (no 'projects/argo-energy-solutions')"
echo "  3. git log --oneline -10     # confirm commits look correct"
echo "  4. git status                # should be clean"
echo "  5. git remote -v             # origin -> $NEW_REPO_URL"
echo ""
echo "When satisfied, push:  git push -u origin main"
echo ""
