#!/bin/sh

set -eu

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <base> <head>" >&2
  exit 2
fi

base=$1
head=$2
zero_sha=0000000000000000000000000000000000000000

repo_root=$(cd "$(dirname "$0")/.." && pwd)
checker="$repo_root/scripts/check-commit-standards.sh"

if [ "$base" = "$zero_sha" ] || ! git -C "$repo_root" cat-file -e "$base^{commit}" 2>/dev/null; then
  echo "Base commit is unavailable; checking head commit only: $head"
  commits=$head
else
  commits=$(git -C "$repo_root" rev-list "$base..$head")
fi

if [ -z "$commits" ]; then
  echo "No commits to check in range $base..$head"
  exit 0
fi

for commit in $commits; do
  tmp=$(mktemp)
  git -C "$repo_root" log -1 --format=%B "$commit" > "$tmp"
  if ! CHECK_COMMIT_STANDARDS_IGNORE_SHA="$commit" "$checker" "$tmp"; then
    echo >&2
    echo "Offending commit: $commit" >&2
    rm -f "$tmp"
    exit 1
  fi
  rm -f "$tmp"
done

echo "Commit standards passed for range $base..$head"
