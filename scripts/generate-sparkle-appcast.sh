#!/bin/bash

set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Usage: $0 <archive-path> <output-dir> [release-notes-path]" >&2
    exit 1
fi

ARCHIVE_PATH="$1"
OUTPUT_DIR="$2"
RELEASE_NOTES_PATH="${3:-}"

SPARKLE_TOOL_PATH="${SPARKLE_GENERATE_APPCAST:-build/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast}"
DOWNLOAD_URL_PREFIX="${DOWNLOAD_URL_PREFIX:-}"
PROJECT_URL="${PROJECT_URL:-}"
FULL_RELEASE_NOTES_URL="${FULL_RELEASE_NOTES_URL:-}"
EXISTING_APPCAST_URL="${EXISTING_APPCAST_URL:-}"
SPARKLE_PRIVATE_ED_KEY="${SPARKLE_PRIVATE_ED_KEY:-}"

if [[ ! -f "$ARCHIVE_PATH" ]]; then
    echo "Archive not found: $ARCHIVE_PATH" >&2
    exit 1
fi

if [[ ! -x "$SPARKLE_TOOL_PATH" ]]; then
    echo "Sparkle generate_appcast tool not found: $SPARKLE_TOOL_PATH" >&2
    exit 1
fi

if [[ -z "$DOWNLOAD_URL_PREFIX" ]]; then
    echo "DOWNLOAD_URL_PREFIX is required" >&2
    exit 1
fi

if [[ -z "$PROJECT_URL" ]]; then
    echo "PROJECT_URL is required" >&2
    exit 1
fi

if [[ -z "$FULL_RELEASE_NOTES_URL" ]]; then
    FULL_RELEASE_NOTES_URL="$PROJECT_URL/releases"
fi

if [[ -z "$SPARKLE_PRIVATE_ED_KEY" ]]; then
    echo "SPARKLE_PRIVATE_ED_KEY is required" >&2
    exit 1
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

ARCHIVE_NAME="$(basename "$ARCHIVE_PATH")"
ARCHIVE_STEM="${ARCHIVE_NAME%.*}"

cp "$ARCHIVE_PATH" "$WORK_DIR/$ARCHIVE_NAME"

if [[ -n "$RELEASE_NOTES_PATH" ]]; then
    if [[ ! -f "$RELEASE_NOTES_PATH" ]]; then
        echo "Release notes file not found: $RELEASE_NOTES_PATH" >&2
        exit 1
    fi

    cp "$RELEASE_NOTES_PATH" "$WORK_DIR/$ARCHIVE_STEM.md"
fi

if [[ -n "$EXISTING_APPCAST_URL" ]]; then
    curl --fail --silent --show-error --location "$EXISTING_APPCAST_URL" -o "$WORK_DIR/appcast.xml" || true
fi

printf '%s' "$SPARKLE_PRIVATE_ED_KEY" | "$SPARKLE_TOOL_PATH" \
    --ed-key-file - \
    --download-url-prefix "$DOWNLOAD_URL_PREFIX" \
    --link "$PROJECT_URL" \
    --full-release-notes-url "$FULL_RELEASE_NOTES_URL" \
    --embed-release-notes \
    --maximum-deltas 0 \
    "$WORK_DIR"

mkdir -p "$OUTPUT_DIR"
cp "$WORK_DIR/appcast.xml" "$OUTPUT_DIR/appcast.xml"