# Aware Spec

Aware is a macOS menu bar utility that keeps the display awake when the user is present at the Mac. Presence detection is local-first: recent keyboard or mouse activity is enough, and camera capture is brief, in-memory, and followed by on-device Vision face detection.

## Identity

- Project: `Aware`
- Canonical repo: `https://github.com/LPFchan/Aware`
- Project id: `aware`
- Operator: `LPFchan`
- Last updated: `2026-04-09`
- Related decisions: `DEC-20260409-001`

## Product Contract

Aware should prevent disruptive display dimming, screensavers, and display idle sleep during reading, meetings, calls, and other hands-off desk work. It should get out of the way when presence is not established.

The normal product shape is:

- menu bar accessory app, not a Dock app
- local presence checks, not remote monitoring
- short camera sessions, not continuous recording
- clear menu status
- safe disablement when camera permission or camera capture is unavailable
- ordinary macOS sleep behavior when the feature is disabled or presence is not confirmed

## User-Facing Surface

- Launch: Aware launches as an accessory app and creates an `NSStatusItem` with a person-style status icon.
- Welcome: a small first-run welcome window may appear; it is onboarding, not the primary control surface.
- Menu status: the menu reports disabled, paused, external assertion, face detected, or no face.
- Enable or disable: the menu toggle is persisted in `UserDefaults`.
- Polling interval: users can pick from 15s, 30s, 1m, 2m, 3m, 5m, and 10m intervals; the selection is persisted.
- Open at login: on macOS 13+, users can toggle `SMAppService.mainApp` from the menu.
- Updates: when Sparkle is configured, the menu exposes a check-for-updates item.
- Quit: the menu provides a quit item.

## Presence Loop

When detection is enabled, Aware polls immediately and then repeats on the selected interval unless display sleep has paused polling.

On each detection pass:

1. If the user pressed a key or moved the mouse in the last 30 seconds, declare local user activity and skip camera capture.
2. If another process already holds a display- or system-sleep-prevention assertion, declare local user activity, show the external-assertion state, and skip camera capture.
3. Otherwise, start an `AVCaptureSession`, prefer the front built-in camera, capture video frames briefly, and run on-device Vision face detection on a valid pixel buffer.
4. If at least one face is found, declare local user activity and show the face-detected state.
5. If no face is found, release Aware's previous assertion and show the no-face state.
6. If permission is denied or capture is unavailable, disable detection and surface the permission or camera condition instead of continuing blindly.

During display sleep, Aware should pause polling, cancel pending capture, release its assertion, show a paused state when enabled, and resume detection after display wake.

## Capture And Detection Contract

- Camera permission is requested only when the user enables detection and macOS has not already resolved permission.
- Captured frames are processed in memory; do not write camera frames to temp files, logs, caches, or analytics systems.
- The detector should pass `CVPixelBuffer` data from the capture sample buffer to `VNImageRequestHandler`; avoid JPEG/PNG encoding as an intermediate step.
- The detector uses `VNDetectFaceRectanglesRequest` for binary face-present or face-absent detection; it does not identify people.
- Capture should be bounded. The current detector skips initial warm-up frames, discards predominantly black frames while the camera warms up, and stops once a usable detection result is available.
- The capture session should use a modest video preset appropriate for reliable face detection; current behavior prefers 720p and falls back to 640x480.
- Vision work and camera sample handling run off the main thread on a user-initiated queue.

## Sleep-Prevention Contract

Aware's own awake signal is user-activity based: when presence is established, `SleepAssertion` declares local user activity through IOKit so display-sleep and screensaver idle timers are reset. Repeated acquisition should release the previous assertion before replacing it, and no-face, disabled, paused, or shutdown paths should release the assertion.

Aware also observes external assertions. If another process is already preventing display or system sleep, Aware should avoid an unnecessary camera check and avoid fighting that process.

## Privacy, Network, And Storage Contract

- Presence detection uses local signals only: HID idle time, local camera frames, local power assertions, and on-device Vision.
- Aware does not include telemetry, analytics, remote camera access, image upload, person identification, or continuous video recording.
- Camera frames should be discarded after each detection pass.
- Networking is not part of presence detection. Network access is limited to explicit distribution/update surfaces such as Sparkle feeds, hosted release notes, and GitHub-hosted release assets.

## Runtime And Repo Surfaces

- `Aware/`: Swift/AppKit runtime using AVFoundation, Vision, IOKit, ServiceManagement, and Sparkle.
- `Aware/PresenceDetector.swift`: owns capture lifecycle and Vision face-presence checks.
- `Aware/MenuBarController.swift`: owns the menu, persisted settings, polling timer, open-at-login toggle, permission flow, power-state pause/resume, and detection result handling.
- `Aware/SleepAssertion.swift`: wraps IOKit user-activity declaration and external sleep-assertion detection.
- `Aware/AppDelegate.swift`: configures accessory activation, optional Sparkle updater, menu-bar controller, and first-run welcome window.
- `.github/workflows/`, `docs/`, and `release-notes/`: build, release, Sparkle/appcast publishing, and operator-facing release documentation.
- `REPO.md`, `STATUS.md`, `PLANS.md`, `INBOX.md`, `research/`, `records/decisions/`, and `records/agent-worklogs/`: repo operating-model surfaces; keep process truth there instead of mixing it into the product spec.

## Distribution And Updates

- Debug verification uses `xcodebuild -scheme Aware -configuration Debug -derivedDataPath build build`.
- Tagged releases are expected to produce an installable `Aware.dmg`.
- Release automation may publish GitHub Releases, GitHub Pages appcast assets, and localized Sparkle release notes.
- Sparkle should remain optional at runtime: if updater configuration is incomplete, the app should still launch and the updater surface should be disabled.
- Release builds may be unsigned in the current distribution workflow; trust, notarization, Sparkle keys, appcast setup, and localized release-note publishing belong in `STATUS.md`, `docs/SPARKLE_SETUP.md`, and `release-notes/README.md`.

## Non-Goals

- Continuous video recording.
- Remote monitoring.
- Face recognition, person identification, or attendance tracking.
- Telemetry or analytics.
- Full window-based productivity features beyond onboarding and menu bar control.
- Cross-platform support outside macOS.

## Success Criteria

- Aware prevents display sleep and screensaver activation when the user is present.
- Aware lets the Mac return to normal idle behavior when the user is absent, the display is sleeping, permission is unavailable, or detection is disabled.
- The menu remains enough to understand status and control the feature.
- Presence detection remains local, brief, and explainable from this spec plus the source code.
- Releases remain repeatable without mixing product truth, release status, plans, decisions, research, and execution history into one document.
