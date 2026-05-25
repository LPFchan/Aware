# Agent Instructions

`AGENTS.md` is the canonical editable agent-instructions file. It enforces repo behavior while deferring canonical policy to `records/REPO.md`.

## Read First

- `records/REPO.md`
- `records/SPEC.md`
- `records/STATUS.md`
- `records/PLANS.md`
- `records/INBOX.md`
- `skills/README.md`

Before writing into an artifact directory, read its `README.md` and follow its prescriptive shape when it defines one.

## Skills

Load the skill before the trigger condition fires. Each skill defines the procedure; follow it.

| Trigger | Skill |
| --- | --- |
| Before creating a normal commit | `skills/commit-generator/SKILL.md` |
| Before any destructive file edit (replace, delete, rewrite) | `skills/clean-correction-gate/SKILL.md` |
| When routing work or creating repo artifacts | `skills/repo-orchestrator/SKILL.md` |
| When reviewing inbox pressure | `skills/daily-inbox-pressure-review/SKILL.md` |
| When reviewing upstream changes | `skills/upstream-intake/SKILL.md` |
| When sharpening or iteratively refining an artifact | `skills/sharpen-the-tip/SKILL.md` |
| When prototyping, greenfield building, or working pre-MVP | `skills/prototype-mode/SKILL.md` |

## Rules

- Keep durable truth in repo files, not only in external tools.
- Route work using the routing ladder in `records/REPO.md`.
- Preserve the boundary between `records/SPEC.md`, `records/STATUS.md`, `records/PLANS.md`, `records/INBOX.md`, `records/research/`, `records/decisions/`, commit-backed `LOG-*`, and `records/upstream-intake/`.
- Worker agents produce evidence, proposals, and compliant `LOG-*` commits. The orchestrator or operator owns truth-doc updates unless the operator explicitly allows otherwise.
- Treat `records/INBOX.md` as pressure, not a backlog. Cluster capture; promote only survived triage.
- Promote sparsely. Do not mirror one thought into research, decisions, plans, spec, status, upstream, and execution records.
- Every normal commit must be created from a skeleton registered by `scripts/new-commit-message.sh` and must pass local and remote provenance checks.
- Follow the stable-ID and provenance rules in `records/REPO.md`.
- Do not put `LOG-*` ids inside `artifacts:`.
- Do not invent a document shape when the repo already provides a canonical surface, directory `README.md`, or template.
- Do not promote exploratory debate into truth docs or decisions until there is a concise accepted outcome.
- Do not turn an inbox review into a digest of every low-confidence idea. Report counts or clusters.
- Do not write chatty transcripts where the repo expects normalized records.
- Do not bypass commit provenance checks unless the commit is an explicit bootstrap or migration exception.

## Local Divergence

- Build verification: `xcodebuild -scheme Aware -configuration Debug -derivedDataPath build build`
- Commit provenance setup: `scripts/install-hooks.sh` configures the tracked `commit-msg` hook locally.
- Commit provenance checks: `scripts/check-commit-standards.sh <commit-message-file>` and `scripts/check-commit-range.sh <base> <head>`
- There is no dedicated automated test suite in the repo today. For runtime changes, use the build plus focused manual validation.
- Preserve the product and workflow constraints in `SPEC.md`: menu bar-only UX, local presence detection, no telemetry or analytics, and safe failure when camera access is denied or unavailable.
- `AWARE-AGENT-PROMPT.md` is a legacy bootstrap helper. Do not treat it as a second policy layer.
- `upstream-intake/` is omitted in Aware because the repo does not currently track upstream review.
