# DEC-20260409-004: Migrate Canonical Rules Doc To REPO.md

Opened: 2026-04-09 21-20-00 KST
Recorded by agent: 019d6ebe-3413-78d3-bdae-c7af38845b64

## Metadata

- Status: accepted
- Deciders: operator, orchestrator
- Related ids: DEC-20260409-001, DEC-20260409-002, LOG-20260409-004

## Decision

Use repo-root `REPO.md` as Aware's canonical repo contract. Rename the prior repo-root rules doc to `REPO.md`, point `AGENTS.md` to it, keep `CLAUDE.md` as a shim to `AGENTS.md`, and update active guidance surfaces to reference `REPO.md`.

## Context

Aware already uses repo-template, but the repo adopted the older `repo-operating-model.md` filename before the current scaffold naming settled on `REPO.md`. That drift makes the repo look older than the template it is following and creates unnecessary mismatch between local guidance, skills, and template-based expectations.

The repo also has append-only artifact rules for decisions and worklogs. Historical records should not be rewritten just to erase the older filename from preserved execution history.

## Options Considered

### Keep `repo-operating-model.md` As The Canonical File

- Upside: no migration work
- Downside: keeps the repo on a legacy filename that no longer matches the template contract

### Keep Both `repo-operating-model.md` And `REPO.md`

- Upside: easier transition for stale references
- Downside: creates competing canonical surfaces and invites drift

### Rename The Canonical File To `REPO.md` And Update Active Guidance

- Upside: aligns Aware with current repo-template naming
- Upside: keeps one canonical repo contract at the repo root
- Upside: preserves repo-specific workflow truth while letting thin entrypoints stay thin
- Downside: some historical records will still mention the older filename as part of preserved history

## Rationale

The rename path is the cleanest way to align the repo with current repo-template naming without introducing duplicate policy docs. Updating active guidance surfaces is enough to change future behavior, while preserved historical records can continue to reflect the filename that existed when those events were recorded.

## Consequences

- Future active guidance should reference `REPO.md` instead of `repo-operating-model.md`.
- `AGENTS.md` remains the main editable compatibility entrypoint for agents, and `CLAUDE.md` remains a shim.
- Append-only historical records may retain the older filename where it is part of preserved execution history.
- Agents should not recreate `repo-operating-model.md` unless the repo is intentionally diverging from repo-template naming again.
