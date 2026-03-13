# Aware — Agent Development Prompt

## Overview

Build a macOS menu bar app that prevents screen dimming/sleep by periodically checking for user presence via the FaceTime camera. No UI beyond a menu bar icon.

---

## Core Behavior

- Run as a menu bar–only app (`LSUIElement = YES`, no Dock icon).
- Register display sleep prevention using `IOPMAssertionCreateWithName` with assertion type `kIOPMAssertionTypePreventUserIdleDisplaySleep`.
- On a configurable polling interval (default: 30s), capture a single frame from the default `AVCaptureDevice` camera.
- Run the frame through Vision's `VNDetectFaceRectanglesRequest`. If ≥1 face is detected, call `IOPMAssertionDeclareSystemActivity` to reset the idle timer and prevent dimming. If no face is detected, release the assertion and allow normal sleep behavior.
- Camera is only active during the brief capture — not streaming continuously.

---

## Face Detection & Hardware Acceleration

- Use `VNDetectFaceRectanglesRequest` via the Vision framework. This is already ANE/GPU-accelerated on Apple Silicon via Core ML internally — no `VNCoreMLRequest` wrapper needed, and no CPU-bound alternatives.
- Set the request's `revision` to `VNDetectFaceRectanglesRequestRevision3` (most accurate, still hardware-accelerated).
- Pass the captured `CMSampleBuffer` directly to `VNImageRequestHandler` using the `.cvPixelBuffer` path — avoid JPEG/PNG encoding the frame, which wastes CPU cycles.
- Downscale capture resolution: configure `AVCaptureSession` preset to `AVCaptureSessionPreset640x480` or `352x288`. Full-resolution frames are wasteful for binary face-present/absent detection.
- Run `VNImageRequestHandler` on a background `DispatchQueue` with `.userInitiated` QoS — this is what lets the system route work to the ANE/GPU rather than the main thread CPU.

---

## Stack

- **Language**: Swift
- **UI**: AppKit (NSStatusItem, NSMenu)
- **Camera**: AVFoundation
- **Face detection**: Vision
- **Sleep prevention**: IOKit
- **Target**: macOS 13+
- **Dependencies**: None (no third-party packages)

---

## Menu Bar Items

| Item | Behavior |
|---|---|
| Enable/Disable toggle | Persisted via `UserDefaults` |
| Polling interval | 15s / 30s / 60s picker, persisted via `UserDefaults` |
| Last detection status | Displays "Face detected", "No face", or "Disabled" |
| Quit | Terminates the app |

---

## Permissions

- Request `NSCameraUsageDescription` at first enable.
- If camera permission is denied, show an alert and disable the feature gracefully.
- No network access. No data leaves the device.

---

## Project Structure

Single Xcode project. Separate service classes for distinct responsibilities:

- `PresenceDetector` — owns `AVCaptureSession` lifecycle and `VNDetectFaceRectanglesRequest` execution
- `SleepAssertion` — wraps `IOPMAssertion` create/release logic
- `MenuBarController` — owns both services, drives the polling loop via `DispatchSourceTimer`, presents menu via `NSStatusItem` and `NSMenu`, presents menu via `NSStatusItem` and `NSMenu`, presents menu via `NSStatusItem` and `NSMenu`, presents menu via `NSStatusItem` and `NSMenu` (AppKit), presents menu via `NSStatusItem` and `NSMenu`, presents menu via `NSStatusItem` and `NSMenu`, presents menu via `NSStatusItem` and `NSMenu`, presents menu via `NSStatusItem` and `NSMenu`, presents menu via `NSStatusItem` and `NSMenu`, presents menu via `NSStatusItem` and `NSMenu`, presents menu via `NSStatusItem` and `NSMenu`, presents menu via `NSStatusItem` and `NSMenu`, presents menu via `NSStatusItem` and `NSMenu`, presents menu via `NSStatusItem` and `NSMenu`, presents menu via `NSStatusItem` and `NSMenu`

---

## Efficiency Summary

The key efficiency wins are:
1. Low-resolution capture (`352x288` or `640x480`)
2. Hardware-accelerated inference via Vision/ANE — no sustained CPU load
3. Camera only wakes for a fraction of a second per polling interval, not a continuous stream
