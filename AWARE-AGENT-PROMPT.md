# Aware Agent Bootstrap

Use this file as a pointer, not as the canonical product spec.

## Canonical Docs

- `REPO.md` defines routing, provenance, and artifact rules.
- `SPEC.md` holds durable product truth.
- `STATUS.md` holds current operational reality.
- `PLANS.md` holds accepted future direction only.
- `INBOX.md` is the scratch surface for untriaged capture.
- git commit history via `commit: LOG-*` stores canonical execution history.
- `skills/README.md` and `skills/<name>/SKILL.md` store required repo-native procedures.

## Working Rules

- Do not duplicate product truth here; update the canonical repo docs instead.
- Use stable IDs when creating artifacts: `IBX-*`, `RSH-*`, and `DEC-*`.
- For normal post-bootstrap commits, include commit trailers: `project: aware`, `agent: <agent-id>`, `role: orchestrator|worker|subagent|operator`, and `commit: LOG-*`.
- Keep `artifacts:` optional and free of `LOG-*`.
- For continuing work, prefer the current relevant commit-backed execution record when the same workstream continues.
- Treat `README.md`, `docs/`, and `release-notes/` as user-facing or release-facing surfaces, not the canonical operating record.

## Codebase Orientation

- `Aware/` contains the Swift and AppKit runtime.
- `Aware.xcodeproj/` contains project settings and build metadata.
- `.github/workflows/` contains build, release, and appcast automation.
- `docs/` and `release-notes/` contain Sparkle setup and release-publishing docs.

## Bootstrap Records

- Decision: `DEC-20260409-001`
