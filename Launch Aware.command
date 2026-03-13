#!/bin/bash
# Double-click this file to build and launch Aware

cd "$(dirname "$0")"
APP_PATH="build/Build/Products/Debug/Aware.app"

# Build (errors will be visible)
if ! xcodebuild -scheme Aware -configuration Debug -derivedDataPath build build 2>&1; then
    osascript -e 'display dialog "Build failed. Check the Terminal output for errors." with title "Aware" buttons {"OK"} default button 1 with icon stop'
    exit 1
fi

# Clear quarantine so Gatekeeper allows first run
xattr -cr "$APP_PATH" 2>/dev/null || true

# Launch and verify the app started
open "$APP_PATH" || {
    osascript -e 'display dialog "Failed to launch Aware.app" with title "Aware" buttons {"OK"} default button 1 with icon stop'
    exit 1
}

# Wait and check if process is still running (crash = exits quickly)
sleep 2
if ! pgrep -x "Aware" >/dev/null; then
    osascript -e 'display dialog "Aware launched but exited immediately (possible crash).\n\nRun from Xcode (Product → Run) to see crash logs, or check Console.app for errors." with title "Aware" buttons {"OK"} default button 1 with icon stop'
    exit 1
fi

