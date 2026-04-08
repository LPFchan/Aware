# Aware Spec

This file is the canonical statement of what Aware is supposed to be.
Keep it durable. Do not use it as a changelog, inbox, or weekly narrative.

## Identity

- Project: `Aware`
- Canonical repo: `https://github.com/LPFchan/Aware`
- Project id: `aware`
- Operator: `LPFchan`
- Last updated: `2026-04-09`
- Related decisions: `DEC-20260409-001`

## Product Thesis

Aware is a macOS menu bar utility that keeps the display awake when someone is actually at the Mac. It favors a low-friction, local-first experience: brief presence checks, minimal UI, and immediate fallback to normal sleep behavior when presence is not established.

## Primary User And Context

- Primary operator: `LPFchan`
- Primary environment: macOS 13+ desktops and laptops with a built-in or default camera
- Primary problem being solved: keep the display awake while the user is present at their desk without requiring constant keyboard or mouse input
- Why this matters: passive screen dimming and screensavers are disruptive during reading, meetings, and other hands-off work

## Primary Workspace Object

The primary user-facing object is a menu bar app that manages display-idle prevention based on local presence signals.

## Canonical Interaction Model

1. The user launches Aware; it runs as an accessory app with a menu bar icon and no Dock presence.
2. The user enables detection and grants camera permission if prompted.
3. Aware polls on the selected interval and also treats recent keyboard or mouse activity as immediate presence.
4. If another process already holds a sleep-prevention assertion, Aware skips the camera check and preserves awake state.
5. If presence is confirmed, Aware resets the user-activity assertion; if not, it releases the assertion and updates the menu status.
6. The user manages polling interval, open-at-login, update checks, and quit behavior from the menu.

## Core Capabilities

- Presence-aware idle prevention:
  - Why it exists: keep the display awake only when the user is present.
  - What must remain true: the app must release its assertion when presence is not established or the feature is disabled.
- Menu bar-only control surface:
  - Why it exists: the feature should stay accessible without a persistent windowed UI.
  - What must remain true: enable or disable, status, interval selection, and quit must remain reachable from the menu bar.
- Distribution and update surface:
  - Why it exists: releases need a repeatable path for DMG distribution and Sparkle-based updates.
  - What must remain true: tagged releases produce an installable DMG, and update metadata remains publishable without changing the runtime interaction model.

## Invariants

- Aware is a macOS accessory app (`LSUIElement`) with no Dock icon as the normal interaction model.
- Presence detection uses local device signals only: recent HID activity, local camera capture, and on-device Vision face detection.
- The app does not include telemetry or analytics; any network use is limited to release and update distribution surfaces such as Sparkle feeds and GitHub-hosted assets.
- Camera-denied or camera-unavailable states must fail safe by disabling the feature and surfacing the condition to the user.

## Non-Goals

- Continuous video recording, remote monitoring, or person identification.
- Full window-based productivity features beyond onboarding and menu bar control.
- Cross-platform support outside macOS.

## Main Surfaces

- `Aware/`
  - Purpose: Swift/AppKit runtime, presence detection, sleep assertions, localization, and updater integration.
  - Notes: single Xcode project with direct system-framework integration.
- `.github/workflows/`, `docs/`, and `release-notes/`
  - Purpose: build, release, Sparkle and appcast publishing, and operator-facing release documentation.
  - Notes: these remain user or release-facing surfaces; repo truth lives in the operating-model overlay docs.

## Success Criteria

- Aware prevents display sleep when the user is present and allows normal idle behavior when they are not.
- The app remains lightweight to operate: menu bar only, clear status, bounded camera usage, and graceful permission handling.
- The repo can ship repeatable DMG releases and localized update notes without losing the canonical product and process record.

