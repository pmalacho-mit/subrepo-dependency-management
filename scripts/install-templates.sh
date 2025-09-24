#!/usr/bin/env bash
set -euo pipefail

# --- Config: template file URLs ---
MAIN_DEVCONTAINER_URL="https://raw.githubusercontent.com/pmalacho-mit/subrepo-dependency-management/refs/heads/main/templates/main/.devcontainer/devcontainer.json"
MAIN_WORKFLOW_URL="https://raw.githubusercontent.com/pmalacho-mit/subrepo-dependency-management/refs/heads/main/templates/dependency/main/.github/workflows/subrepo-push-dist.yml"
DIST_WORKFLOW_URL="https://raw.githubusercontent.com/pmalacho-mit/subrepo-dependency-management/refs/heads/main/templates/dependency/dist/.github/workflows/subrepo-pull-into-main.yml"

echo "[1/9] Checking prerequisites..."
if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is not installed." >&2; exit 1
fi
if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is not installed." >&2; exit 1
fi

if ! git subrepo --version >/dev/null 2>&1; then
  echo "Error: 'git subrepo' is not available. Install git-subrepo and ensure it's on PATH." >&2
  echo "       See: https://github.com/ingydotnet/git-subrepo" >&2
  exit 1
fi

echo "[2/9] Verifying we are inside a Git repository..."
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: not inside a Git repository." >&2; exit 1
fi

echo "[3/9] Making sure your working tree is clean..."
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: you have uncommitted changes. Please commit or stash them first." >&2
  exit 1
fi

# Remember the branch to go back to, even on errors.
ORIG_BRANCH="$(git rev-parse --abbrev-ref HEAD || echo "")"
cleanup() {
  if [[ -n "$ORIG_BRANCH" ]]; then
    echo "Restoring original branch: $ORIG_BRANCH"
    git checkout -q "$ORIG_BRANCH" || true
  fi
}
trap cleanup EXIT

# --- MAIN branch work ---
echo "[4/9] Switching to 'main' (creating if needed)..."
if git show-ref --verify --quiet refs/heads/main; then
  git checkout -q main
else
  # Create 'main' pointing at current commit if it doesn't exist.
  git branch main
  git checkout -q main
fi

echo "[5/9] Downloading template files into 'main'..."
mkdir -p .devcontainer .github/workflows
curl -fL "$MAIN_DEVCONTAINER_URL" -o .devcontainer/devcontainer.json
curl -fL "$MAIN_WORKFLOW_URL"      -o .github/workflows/subrepo-push-dist.yml

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Committing changes on 'main'..."
  git add .devcontainer/devcontainer.json .github/workflows/subrepo-push-dist.yml
  git commit -m "Adding subrepo dependency management template files (main)"
  echo "Pushing 'main'..."
  git push -u origin main
else
  echo "No changes to commit on 'main'."
fi

# --- DIST branch work ---
echo "[6/9] Preparing 'dist' branch (orphan if new)..."
if git show-ref --verify --quiet refs/heads/dist; then
  git checkout -q dist
else
  git checkout --orphan dist
  # Clear index and working tree for a true orphan start
  git rm -r -q --cached . 2>/dev/null || true
  git clean -fdq
fi

echo "[7/9] Downloading template file into 'dist'..."
mkdir -p .github/workflows
curl -fL "$DIST_WORKFLOW_URL" -o .github/workflows/subrepo-pull-into-main.yml

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Committing changes on 'dist'..."
  git add .github/workflows/subrepo-pull-into-main.yml
  git commit -m "Adding subrepo dependency management template files (dist)"
  echo "Pushing 'dist'..."
  git push -u origin dist
else
  echo "No changes to commit on 'dist'."
fi

echo "[8/9] Returning to 'main'..."
git checkout -q main

# --- git subrepo clone of dist into ./dist on main ---
echo "[9/11] Getting origin URL..."
ORIGIN_URL="$(git remote get-url origin 2>/dev/null || true)"
if [[ -z "$ORIGIN_URL" ]]; then
  echo "Error: could not find 'origin' remote URL." >&2
  exit 1
fi

echo "[10/11] Cloning 'dist' branch into ./dist via git subrepo..."
# Safety: avoid clobbering an existing non-empty ./dist directory
if [[ -d "dist" && -n "$(ls -A dist 2>/dev/null)" ]]; then
  echo "Error: './dist' already exists and is not empty. Remove it or choose another directory before running." >&2
  exit 1
fi

git subrepo clone --branch=dist "$ORIGIN_URL" dist
echo "Pushing 'main'..."
git push -u origin main

echo "[9/9] Done."
