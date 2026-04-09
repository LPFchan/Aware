# Skills

This directory is part of Aware's repo-template operating layer.

Use it as repo-native procedural documentation.
Agents should read the relevant workflow even when their runtime does not auto-load skills.

Each reusable workflow should live at `skills/<name>/SKILL.md`.

## Required Baseline Skills

- `repo-orchestrator/`
  - Routes work into `SPEC.md`, `STATUS.md`, `PLANS.md`, `INBOX.md`, `research/`, `records/decisions/`, and `records/agent-worklogs/`.
- `daily-inbox-pressure-review/`
  - Focus-protecting daily triage for `IBX-*` capture and capture packets.

## Conditional Skills

- `upstream-intake/`
  - Companion workflow for the optional upstream-review module.
  - Omitted because Aware is not currently using the optional upstream-review module.

Keep skills procedural.
Do not duplicate the canonical rules from `REPO.md` inside them.

Use `SKILL.md` for:

- step-by-step procedures
- required inputs and expected outputs
- escalation triggers
- links to supporting templates or reference docs

Do not use `SKILL.md` for:

- repo-wide policy
- general project truth
- local or personal preferences that belong in tool-specific memory files
