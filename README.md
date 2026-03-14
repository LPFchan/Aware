# Aware

<p align="center">
  <img src="assets/icon.png" alt="Aware" width="128" />
</p>

A macOS menu bar app that keeps your Mac awake by detecting your presence with the FaceTime camera.

## How It Works

- **Local & private** — No networking, telemetry, third-party dependencies, or even temp-directory writes; captured frames are processed in memory and discarded immediately.
- **Hardware-accelerated** — Uses Vision on Apple Silicon; face detection runs on GPU or Apple Neural Engine, not CPU.
- **Smart presence detection** — Skips camera checks when you've used the keyboard or mouse in the last 30 seconds. Does not consume any power or resource during active use.
- **Menu bar only** — No Dock icon; runs quietly in the background.

## Quick Start

**Download:** [GitHub Releases](https://github.com/LPFchan/Aware/releases) — download `Aware.zip`, unzip, and drag `Aware.app` to Applications.

**Build from source:**
```bash
xcodebuild -scheme Aware -configuration Debug -derivedDataPath build build
open build/Build/Products/Debug/Aware.app
```
Or double-click **Launch Aware.command** to build and launch in one step.

Grant camera access when prompted, then click the person icon in the menu bar to enable.

**Create a release:** `git tag v1.3 && git push origin v1.3` — GitHub Actions builds and attaches `Aware.zip`.

## Updates

Sparkle 2 is wired for the direct-download build.

- The default setup is hobby or private distribution using Sparkle's own signing, GitHub Releases, and GitHub Pages.
- Apple Developer signing and notarization are optional hardening for broader public distribution.
- Maintainer setup steps are documented in [docs/SPARKLE_SETUP.md](docs/SPARKLE_SETUP.md).

## Requirements

- macOS 13+
- Camera access (requested on first launch)
