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

default_branch_ref() {
  if ref=$(git -C "$repo_root" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null); then
    printf '%s\n' "$ref"
    return 0
  fi

  if git -C "$repo_root" show-ref --verify --quiet refs/remotes/origin/main; then
    printf '%s\n' "origin/main"
    return 0
  fi

  if git -C "$repo_root" show-ref --verify --quiet refs/remotes/origin/master; then
    printf '%s\n' "origin/master"
    return 0
  fi

  if ref=$(git -C "$repo_root" symbolic-ref -q --short HEAD 2>/dev/null); then
    printf '%s\n' "$ref"
    return 0
  fi

  return 1
}

extract_commit_ids_from_value() {
  printf '%s\n' "$1" | tr ',' '\n' | sed 's/^ *//; s/ *$//'
}

# Local divergence: allow historical backfill validation when the base commit is
# unavailable, while still checking the head commit and duplicate LOG ids.
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
  # Local divergence: pass the commit currently under test so the standards checker
  # can skip self-collisions during historical range validation.
  if ! CHECK_COMMIT_STANDARDS_IGNORE_SHA="$commit" "$checker" "$tmp"; then
    echo >&2
    echo "Offending commit: $commit" >&2
    rm -f "$tmp"
    exit 1
  fi
  rm -f "$tmp"
done

default_ref=$(default_branch_ref || true)
scan_refs="$head"

if [ -n "$default_ref" ] && [ "$default_ref" != "$head" ]; then
  scan_refs="$scan_refs $default_ref"
fi

seen_file=$(mktemp)
trap 'rm -f "$seen_file"' EXIT HUP INT TERM

for commit in $(git -C "$repo_root" rev-list $scan_refs); do
  commit_value=$(git -C "$repo_root" log -1 --format=%B "$commit" | sed -n 's/^commit: //p' | tail -n 1)
  [ -n "$commit_value" ] || continue

  for commit_id in $(extract_commit_ids_from_value "$commit_value"); do
    printf '%s %s\n' "$commit_id" "$commit" >> "$seen_file"
  done
done

if ! awk '
  {
    if (!first_sha[$1]) {
      first_sha[$1] = $2
      next
    }

    if (first_sha[$1] != $2) {
      printf "commit standards check failed: duplicate LOG id across history: %s\n", $1 > "/dev/stderr"
      printf "First commit: %s\n", first_sha[$1] > "/dev/stderr"
      printf "Second commit: %s\n", $2 > "/dev/stderr"
      exit 1
    }
  }
' "$seen_file"; then
  exit 1
fi

echo "Commit standards passed for range $base..$head"
