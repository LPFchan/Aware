# Aware

macOS menu bar app that **intelligently** keeps the display awake by **efficiently** detecting your face with the FaceTime camera.

## How it works

- Runs as a menu bar–only app (no Dock icon)
- Periodically captures a single frame from the FaceTime camera on a configurable interval
- Uses Vision's face detection to determine presence
- Skips camera checks when you've recently used the keyboard or mouse (within 30 seconds)
- Holds a sleep assertion while you're present; releases it when no face is detected

## Requirements

- macOS 13+
- Camera access (granted on first run)

## Build & run

```bash
xcodebuild -scheme Aware -configuration Debug -derivedDataPath build build
open build/Build/Products/Debug/Aware.app
```

Or double-click **Launch Aware.command** after building.

## License

MIT
