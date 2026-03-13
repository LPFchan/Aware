#!/bin/bash
# Run this script to diagnose Aware launch issues.
# Usage: ./run-diagnostic.sh

set -e
SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR"

echo "=== Aware Launch Diagnostic ==="
echo ""

# Build
echo "1. Building Aware (Debug)..."
if ! xcodebuild -scheme Aware -configuration Debug -derivedDataPath build build -quiet 2>/dev/null; then
    echo "   Build failed. Run: xcodebuild -scheme Aware -configuration Debug -derivedDataPath build build"
    exit 1
fi
echo "   Build OK."
echo ""

# Path to app
APP_PATH="build/Build/Products/Debug/Aware.app"
LOG_TMP="/tmp/aware-launch-log.txt"
LOG_DESKTOP="$HOME/Desktop/aware-launch-log.txt"

# Remove old logs
rm -f "$LOG_TMP" "$LOG_DESKTOP"
echo "2. Removed old logs. Checking: $LOG_TMP (and $LOG_DESKTOP)"
echo ""

echo "3. Clearing quarantine (allows Gatekeeper to run the app via open)..."
xattr -cr "$APP_PATH" 2>/dev/null || true

echo "4. Launching Aware.app now..."
echo "   >>> You should hear a BEEP and see an alert dialog. <<<"
echo ""

open "$(pwd)/$APP_PATH"

echo "4. Waiting 3 seconds..."
sleep 3
echo ""

echo "5. Checking log files..."
for LOG_PATH in "$LOG_TMP" "$LOG_DESKTOP"; do
    if [ -f "$LOG_PATH" ]; then
        echo "   FOUND at $LOG_PATH:"
        echo "   ---"
        sed 's/^/   /' "$LOG_PATH"
        echo "   ---"
        break
    fi
done
if [ ! -f "$LOG_TMP" ] && [ ! -f "$LOG_DESKTOP" ]; then
    echo "   No log file found at $LOG_TMP or $LOG_DESKTOP"
    echo ""
    echo "6. Running executable DIRECTLY (bypassing LaunchServices)..."
    EXEC="$SCRIPT_DIR/$APP_PATH/Contents/MacOS/Aware"
    OUT_TMP="/tmp/aware-exec-output.txt"
    rm -f "$OUT_TMP"
    if [ -x "$EXEC" ]; then
        echo "   Starting... (will run 5 seconds)"
        "$EXEC" > "$OUT_TMP" 2>&1 &
        PID=$!
        sleep 5
        if [ -f "$LOG_TMP" ]; then
            echo "   LOG FOUND - app started! Contents:"
            sed 's/^/   /' "$LOG_TMP"
        else
            echo "   No log file."
        fi
        echo "   Executable output:"
        if [ -s "$OUT_TMP" ]; then
            sed 's/^/   /' "$OUT_TMP"
        else
            echo "   (none)"
        fi
        kill $PID 2>/dev/null || true
    else
        echo "   Executable not found: $EXEC"
    fi
fi
echo ""
echo "=== Done ==="
