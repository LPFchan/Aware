# DEC-20260409-005: Adopt Append-First Worklog Policy

Opened: 2026-04-09 22-10-00 KST
Recorded by agent: 019d6ebe-3413-78d3-bdae-c7af38845b64

## Metadata

- Status: accepted
- Deciders: operator, orchestrator
- Related ids: DEC-20260409-003, LOG-20260409-006

## Decision

Aware will keep strict commit provenance but stop treating a brand-new `LOG-*` file as the default companion artifact for meaningful commits. The repo now follows an append-first worklog policy: normal commits may reference an existing updated artifact, and ongoing execution should append to the latest relevant `LOG-*` unless a separate worklog materially improves clarity.

## Context

Aware already enforces commit provenance through local hooks and CI. That enforcement correctly requires linked artifacts, but the surrounding repo wording still leaned toward creating new `LOG-*` files often enough that agents could mistake document creation for the main goal.

The newer repo-template guidance is stricter about provenance usefulness and lighter about document churn. Aware should follow that direction without weakening commit linkage or losing the ability to create separate worklogs when distinct execution records are genuinely helpful.

## Options Considered

### Keep The Older New-Log-Leaning Guidance

- Upside: every meaningful change tends to have a fresh execution record
- Downside: encourages bureaucratic `LOG-*` churn and weakens retrieval by scattering one workstream across many tiny files

### Make Worklogs Append-First While Keeping Strict Artifact Linkage

- Upside: preserves provenance without forcing unnecessary document creation
- Upside: keeps continuing workstream history in one place until a split would improve clarity
- Upside: matches the newer repo-template guidance more closely
- Downside: requires agents to exercise judgment about when reuse stops helping

### Stop Requiring Artifact Linkage On Some Commits

- Upside: less process overhead
- Downside: weakens the provenance graph and conflicts with the repo's current enforcement model

## Rationale

The best balance is to keep artifact linkage mandatory while removing the implicit pressure to mint a new `LOG-*` for routine continuation of the same work. Provenance is useful when it helps a future operator recover the execution story, not when it produces extra files that fragment it.

## Consequences

- Normal commits may reference an existing updated `LOG-*`, `DEC-*`, `RSH-*`, or other relevant artifact.
- Agents should append to the current relevant `LOG-*` when the same workstream continues.
- New `LOG-*` files should be created only when the work is materially distinct, a separate agent or subagent owns it, or reuse would reduce clarity.
- Commit provenance rules remain strict; this decision changes reuse guidance, not enforcement strength.
