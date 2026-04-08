# Agent Instructions

This repo uses repo-template.

Treat `AGENTS.md` as the canonical editable agent-instructions file for the repo.
It should enforce repo behavior while deferring canonical policy details to `REPO.md`.

## Read First

- `REPO.md`
- `SPEC.md`
- `STATUS.md`
- `PLANS.md`
- `INBOX.md`

If the repo includes reusable workflows, also read `skills/README.md` and the relevant `skills/<name>/SKILL.md`.

When writing into a repo surface or artifact directory, read the matching local guide first. That means the surface template itself for `SPEC.md`, `STATUS.md`, `PLANS.md`, and `INBOX.md`, and the local `README.md` in directories such as `research/`, `records/decisions/`, and `records/agent-worklogs/`.

## Repo-Specific Notes

- Build verification: `xcodebuild -scheme Aware -configuration Debug -derivedDataPath build build`
- Commit provenance setup: `scripts/install-hooks.sh` configures the tracked `commit-msg` hook locally.
- Commit provenance checks: `scripts/check-commit-standards.sh <commit-message-file>` and `scripts/check-commit-range.sh <base> <head>`
- There is no dedicated automated test suite in the repo today. For runtime changes, use the build plus focused manual validation.
- Preserve the product and workflow constraints in `SPEC.md`: menu bar-only UX, local presence detection, no telemetry or analytics, and safe failure when camera access is denied or unavailable.
- `AWARE-AGENT-PROMPT.md` is a legacy bootstrap helper. Do not treat it as a second policy layer.

## Operating Rules

- Keep durable truth in repo files, not only in chat.
- Route work using the routing ladder in `REPO.md`.
- Preserve the boundary between `SPEC.md`, `STATUS.md`, `PLANS.md`, `INBOX.md`, `research/`, `records/decisions/`, and `records/agent-worklogs/`.
- Worker agents should prefer worklogs, evidence, and proposals. The orchestrator or operator owns truth-doc updates unless the operator explicitly allows a different flow.
- When creating artifacts or commits, follow the stable-ID and provenance rules in `REPO.md`.
- Prefer appending to the current relevant `LOG-*` instead of creating a new one unless the work is materially distinct or reuse would harm clarity.
- When hooks or CI are enabled, normal commits must satisfy the provenance checks; bootstrap or migration exceptions must be explicit exceptions only.
- Prefer the local surface template or directory `README.md` shape over ad hoc formatting when it defines one.

## Enforcement

When you write or update repo artifacts, adherence to the repo's ruleset is required.

- Do not invent a new document shape when the repo already provides a canonical surface, directory `README.md`, or explicit template.
- Do not collapse truth, plans, decisions, research, inbox intake, and worklogs into one mixed artifact.
- Do not replace normalized repo artifacts with freeform chat summaries.
- If an artifact needs a justified local variation, keep the core fields and section order intact and make the smallest possible deviation.
