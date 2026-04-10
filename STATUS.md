# Aware Status

This document tracks current operational truth.
Update it when the project's real state changes.
Do not use it as a transcript or a scratchpad.

## Snapshot

- Last updated: `2026-04-10`
- Overall posture: `active`
- Current focus: use repo-root `REPO.md`, local writing guides, commit-backed execution records, and enforced commit provenance to keep future repo changes aligned with repo-template while maintaining the shipping macOS app and release automation
- Highest-priority blocker: no runtime blocker is currently known; the main risks are unsigned distribution friction and documentation drift
- Next operator decision needed: whether to widen remote commit-provenance checks beyond default-branch pushes and pull requests once the current workflow has settled
- Related decisions: `DEC-20260409-001`, `DEC-20260409-002`, `DEC-20260409-003`, `DEC-20260409-004`, `DEC-20260409-005`

## Current State Summary

Aware is a shipping macOS 13+ menu bar app at version `1.4.2` and build `6`. The runtime includes configurable polling, open-at-login support, a welcome window, sleep-assertion handling, localization, and Sparkle updater wiring. GitHub Actions builds on push and pull request; tagged releases build `Aware.dmg`, publish GitHub Releases, and can publish localized Sparkle release notes to GitHub Pages. The repo now also has repo-root `REPO.md`, `AGENTS.md`, and `CLAUDE.md` entrypoints, normalized local writing guides for touched repo artifacts, commit-backed execution history, and tracked commit-provenance enforcement through local hooks plus CI.

## Active Phases Or Tracks

### Runtime And Distribution Maintenance

- Goal: keep the shipped app buildable, releasable, and behaviorally stable
- Status: `in progress`
- Why this matters now: the current product value depends on reliable detection and predictable release packaging
- Current work: maintain the Swift and AppKit runtime, release notes, localized Sparkle notes, and GitHub Actions packaging
- Exit criteria: debug builds stay green on CI and release tags keep producing DMGs and appcast assets when enabled
- Dependencies: Xcode and macOS GitHub Actions runners, camera permission flow, GitHub Releases and Pages, Sparkle EdDSA configuration
- Risks: unsigned distribution causes trust friction; updater and network behavior can drift away from older user-facing docs if not kept aligned
- Related ids: `DEC-20260409-001`

### Repo Operating Model Enforcement

- Goal: keep repo docs and future agent work aligned with repo-template surfaces and local writing guides
- Status: `in progress`
- Why this matters now: the repo now has canonical docs, but consistency depends on tools and humans using the entrypoints and local guides on future edits
- Current work: repo-root `REPO.md`, `AGENTS.md`, and `CLAUDE.md` now enforce the writing contract, touched guides have been normalized toward repo-template naming and structure, and continuing execution is expected to land in compliant commit-backed `LOG-*` records when a separate execution record improves clarity
- Exit criteria: future normal work consistently uses the correct surface, stable IDs, and local guide without ad hoc document shapes
- Dependencies: operator and agents following the entrypoints and local guides
- Risks: legacy docs and one-off edits can still drift if contributors bypass the repo-root entrypoints or local guides
- Related ids: `DEC-20260409-001`, `DEC-20260409-002`, `DEC-20260409-004`, `DEC-20260409-005`

### Commit Provenance Enforcement

- Goal: require provenance-bearing commit messages locally and in CI for normal repo work
- Status: `done`
- Why this matters now: repo-template commit provenance only works reliably when the trailers are enforced instead of treated as optional guidance
- Current work: tracked `commit-msg` hook, validator scripts, install helper, and CI workflow now enforce `project`, `agent`, `role`, and `commit` trailers with structured commit bodies while allowing normal commits to reference existing updated artifacts instead of forcing extra execution-record churn
- Exit criteria: local clones use `scripts/install-hooks.sh`, PR commits pass CI, and direct pushes to default branches pass remote checks
- Dependencies: local git configuration via `core.hooksPath`, GitHub Actions, and contributors using explicit bootstrap or migration exceptions only when truly needed
- Risks: contributors who do not install hooks will rely on CI feedback, and branch or tag-specific CI scope may need revisiting later
- Related ids: `DEC-20260409-003`, `DEC-20260409-005`

## Recent Changes To Project Reality

- Date: `2026-04-10`
  - Change: migrated the repo operating model, skills layer, and active agent guidance to commit-backed execution history
  - Why it matters: execution history now lives in git commits with structured provenance instead of a separate markdown file layer
  - Related ids: `DEC-20260409-001`, `DEC-20260409-002`, `DEC-20260409-003`, `DEC-20260409-004`, `DEC-20260409-005`
- Date: `2026-04-09`
  - Change: added tracked commit-provenance enforcement through `.githooks/commit-msg`, validator scripts, install helper, and CI checks on pull requests plus default-branch pushes
  - Why it matters: normal commits now have both local and remote enforcement for the required provenance trailers
  - Related ids: `DEC-20260409-003`, `DEC-20260409-005`
- Date: `2026-04-09`
  - Change: added repo-root `AGENTS.md` and `CLAUDE.md` entrypoints and normalized the touched repo docs and local guides toward repo-template
  - Why it matters: agent tools now have enforcement entrypoints, and touched repo docs now follow stronger local writing contracts
  - Related ids: `DEC-20260409-002`
- Date: `2026-04-09`
  - Change: added the repo operating model overlay at the repo root plus bootstrap decision records
  - Why it matters: the repo now has canonical in-repo truth and provenance surfaces for future work
  - Related ids: `DEC-20260409-001`
- Date: `2026-03-23`
  - Change: release automation switched to DMGMaker-based DMG creation and retained GitHub-hosted Sparkle and appcast publishing
  - Why it matters: releases no longer depend on paid Apple signing in CI and the distribution path is documented around unsigned builds
  - Related ids: none

## Active Blockers And Risks

- Blocker or risk: unsigned and unnotarized distribution can produce Gatekeeper friction for end users
  - Effect: install and update UX is less smooth than notarized public distribution
  - Owner: operator
  - Mitigation: keep docs explicit, reserve Sparkle for acceptable distribution contexts, and revisit notarization if broader public distribution is needed
  - Related ids: none
- Blocker or risk: legacy docs or one-off edits can still drift from repo-template surfaces or runtime truth if contributors skip the entrypoints and local guides
  - Effect: contributors and users may form incorrect assumptions about current product behavior
  - Owner: operator
  - Mitigation: use `AGENTS.md`, `CLAUDE.md`, `SPEC.md`, `STATUS.md`, and the local guides as the default contract for future touched docs
  - Related ids: `DEC-20260409-002`, `DEC-20260409-005`
- Blocker or risk: commit-provenance checks currently run remotely on pull requests and pushes, so contributors still rely on local hooks for fast feedback and on CI for remote validation
  - Effect: if a contributor bypasses hooks, CI remains the safety net before merge
  - Owner: operator
  - Mitigation: keep local hook installation easy and keep remote commit checks required
  - Related ids: `DEC-20260409-003`

## Immediate Next Steps

- Next: use `AGENTS.md`, `CLAUDE.md`, and the matching local guide on the next touched repo doc or artifact
  - Owner: operator or orchestrator
  - Trigger: next accepted implementation or decision task
  - Related ids: `DEC-20260409-002`, `DEC-20260409-005`
- Next: run `scripts/install-hooks.sh` in any local clone that should enforce provenance before commit creation
  - Owner: operator or contributor
  - Trigger: clone setup or the next local commit attempt in a clone without `core.hooksPath` configured
  - Related ids: `DEC-20260409-003`
- Next: on continuing workstreams, create or amend the current relevant commit-backed `LOG-*` before deciding whether a separate execution record is actually clearer
  - Owner: operator or orchestrator
  - Trigger: next normal change that already has an active or recent execution record
  - Related ids: `DEC-20260409-005`
- Next: decide later whether to widen remote commit-provenance checks beyond pull requests and default-branch pushes
  - Owner: operator
  - Trigger: once the current enforcement scope has been exercised on normal repo work
  - Related ids: `DEC-20260409-003`
