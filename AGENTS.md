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
- `skills/README.md`

Before running a repeatable repo workflow, read the relevant `skills/<name>/SKILL.md`. Treat skills as repo-native procedures even when the agent runtime does not auto-load them.

When writing into a file-backed artifact directory, read that directory's `README.md` first. If it includes a prescriptive shape, follow it. If it is intentionally lightweight, keep the output lightweight too. For commit-backed execution records, follow `REPO.md` and the commit validator instead of inventing a file guide.

## Repo-Specific Notes

- Build verification: `xcodebuild -scheme Aware -configuration Debug -derivedDataPath build build`
- Commit provenance setup: `scripts/install-hooks.sh` configures the tracked `commit-msg` hook locally.
- Commit provenance checks: `scripts/check-commit-standards.sh <commit-message-file>` and `scripts/check-commit-range.sh <base> <head>`
- There is no dedicated automated test suite in the repo today. For runtime changes, use the build plus focused manual validation.
- Preserve the product and workflow constraints in `SPEC.md`: menu bar-only UX, local presence detection, no telemetry or analytics, and safe failure when camera access is denied or unavailable.
- `AWARE-AGENT-PROMPT.md` is a legacy bootstrap helper. Do not treat it as a second policy layer.

## Operating Rules

- Keep durable truth in repo files, not only in external tools.
- Route work using the routing ladder in `REPO.md`.
- Preserve the boundary between `SPEC.md`, `STATUS.md`, `PLANS.md`, `INBOX.md`, `research/`, `records/decisions/`, commit-backed execution history, and `upstream-intake/`.
- Worker agents should prefer evidence, proposals, and compliant commit-backed execution records. The orchestrator or operator owns truth-doc updates unless the operator explicitly allows a different flow.
- Treat `INBOX.md` as pressure, not a backlog. During inbox review, cluster capture and promote only survived triage.
- Promote sparsely. Do not mirror one evolving thought into research, decisions, plans, spec, status, or execution records.
- When creating artifacts or commits, follow the stable-ID and provenance rules in `REPO.md`.
- Use `skills/<name>/SKILL.md` for repeatable repo procedures instead of copying one-off instructions into repo-wide policy.
- If hooks or CI are enabled, normal commits must satisfy the provenance checks; bootstrap or migration exceptions must be explicit exceptions only.
- Prefer the local surface template or directory `README.md` shape over ad hoc formatting when it defines one.

## Enforcement

When you write or update repo artifacts, adherence to the repo's ruleset is required.

- Do not invent a new document shape when the repo already provides a canonical surface, directory `README.md`, or explicit template.
- Do not collapse truth, plans, decisions, research, inbox capture, and execution history into one mixed artifact.
- Do not promote exploratory debate into `SPEC.md`, `STATUS.md`, `PLANS.md`, or `records/decisions/` until there is a concise accepted outcome for that layer.
- Do not turn an inbox review into a giant digest of every low-confidence idea. Report counts or clusters when full detail does not protect focus.
- Do not write chatty transcripts where the repo expects normalized records.
- If an artifact guide is intentionally lightweight, do not over-structure the document just to make it look uniform.
- If the repo guidance and the requested output appear to conflict, follow the repo rules and explain the tension in the artifact or handoff.
- Do not bypass commit provenance checks by omitting required trailers unless the commit is an explicit bootstrap or migration exception.
- Do not put `LOG-*` ids inside `artifacts:`.

## Skills

`skills/<name>/SKILL.md` files are reusable procedures for bounded workflows.

- Keep them procedural.
- Do not duplicate canonical repo policy inside them.
- Use them to standardize repeatable tasks, escalation triggers, and output shape.
