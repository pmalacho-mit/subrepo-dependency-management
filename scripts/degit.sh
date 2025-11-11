#!/usr/bin/env bash
# Minimal, bash-only “degit”-style fetcher for GitHub tarballs.
# Usage:
#   ghdegit OWNER/REPO [ref] [dest]
# Examples:
#   ghdegit vercel/next.js
#   ghdegit sveltejs/svelte v5.0.0 svelte-src
#   ghdegit torvalds/linux 5c3f1b2 ./linux-snapshot
#
# Notes:
# - Supports GitHub only.
# - If $GITHUB_TOKEN or $GH_TOKEN is set, uses it to avoid rate limits.
# - Extracts archive contents into dest (default: repo name), stripping the top folder.
# - Fails if dest exists and is non-empty (to avoid clobbering).

set -euo pipefail

usage() {
  printf "Usage: %s OWNER/REPO [ref] [dest]\n" "$(basename "$0")" >&2
  exit 1
}

# ---- Args ----
[[ $# -ge 1 ]] || usage
REPO="$1"; shift || true
REF="${1:-}"; [[ $# -gt 0 ]] && shift || true
DEST="${1:-}"; [[ $# -gt 0 ]] && shift || true

# Infer dest from repo name if not provided.
if [[ -z "${DEST:-}" ]]; then
  DEST="${REPO##*/}"
fi

# Basic validation
if [[ "$REPO" != */* ]]; then
  printf "Error: REPO must be OWNER/REPO (got %s)\n" "$REPO" >&2
  exit 2
fi

# ---- Dependencies ----
command -v curl >/dev/null 2>&1 || { echo "Error: curl not found" >&2; exit 3; }
command -v tar  >/dev/null 2>&1 || { echo "Error: tar not found"  >&2; exit 3; }

# ---- Rate-limit-friendly headers ----
AUTH_HEADER=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  AUTH_HEADER+=( -H "Authorization: Bearer ${GITHUB_TOKEN}" )
elif [[ -n "${GH_TOKEN:-}" ]]; then
  AUTH_HEADER+=( -H "Authorization: Bearer ${GH_TOKEN}" )
fi

# GitHub’s API prefers a User-Agent.
UA_HEADER=( -H "User-Agent: ghdegit-bash" )
ACCEPT_HEADER=( -H "Accept: application/vnd.github+json" )

# ---- URL construction ----
# If REF is empty, GitHub serves the default branch tip.
# Otherwise pass branch/tag/commit SHA in the URL.
BASE_URL="https://api.github.com/repos/${REPO}/tarball"
URL="$BASE_URL"
if [[ -n "$REF" ]]; then
  URL="${BASE_URL}/${REF}"
fi

# ---- Destination checks ----
mkdir -p "$DEST"
if [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
  echo "Error: destination '$DEST' is not empty. Choose an empty dir or remove it." >&2
  exit 4
fi

# ---- Fetch & extract ----
# -fLSS : fail on HTTP errors, follow redirects, be quiet on success but show errors
# Retry a couple times to be nice on flaky connections.
curl -fLSS --retry 3 --connect-timeout 10 \
  "${UA_HEADER[@]}" "${ACCEPT_HEADER[@]}" "${AUTH_HEADER[@]}" \
  "$URL" \
| tar -xz --strip-components=1 -C "$DEST"

# Done
printf "✓ Fetched %s %s into %s\n" "$REPO" "${REF:-(default)}" "$DEST"
