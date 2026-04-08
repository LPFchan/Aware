# LOG-20260409-006: Adopt Append-First Worklog Policy

Opened: 2026-04-09 22-10-00 KST
Recorded by agent: 019d6ebe-3413-78d3-bdae-c7af38845b64

## Metadata

- Run type: orchestrator
- Goal: align Aware's active repo guidance with repo-template's append-first worklog policy without weakening commit provenance
- Related ids: DEC-20260409-005

## Task

Update the repo's canonical rules, worklog guidance, and agent-facing instructions so artifact linkage stays strict while new `LOG-*` creation stops being the default for continuing work.

## Scope

- In scope: `REPO.md`, `AGENTS.md`, the worklog guide, agent bootstrap guidance, and the repo-orchestrator skill
- In scope: one decision record and one worklog for the migration
- Out of scope: rewriting historical logs just to rebalance old file counts
- Out of scope: weakening commit-trailer enforcement or hook behavior

## Entry 2026-04-09 22-00-00 KST

- Action: audited the current repo rules against the newer repo-template wording for worklog reuse and commit provenance
- Files touched: none
- Checks run: comparison of `REPO.md`, `AGENTS.md`, `records/agent-worklogs/README.md`, `AWARE-AGENT-PROMPT.md`, and `skills/repo-orchestrator/SKILL.md` against the current repo-template references
- Output: confirmed that commit provenance enforcement was already strict enough, but local wording still implied new-log creation often enough to justify an append-first migration
- Blockers: none
- Next: patch the active guidance surfaces and record the policy decision

## Entry 2026-04-09 22-10-00 KST

- Action: updated the canonical rules and active guidance surfaces to prefer appending to the current relevant `LOG-*` and to allow normal commits to reference existing updated artifacts
- Files touched: `REPO.md`, `AGENTS.md`, `records/agent-worklogs/README.md`, `AWARE-AGENT-PROMPT.md`, `skills/repo-orchestrator/SKILL.md`, `records/decisions/DEC-20260409-005-adopt-append-first-worklog-policy.md`, `records/agent-worklogs/LOG-20260409-006-adopt-append-first-worklog-policy.md`
- Checks run: none
- Output: the repo now states explicitly that useful artifact linkage matters more than one-log-per-commit churn, while preserving strict commit provenance and allowing separate logs when they materially improve clarity
- Blockers: none
- Next: verify that no active guidance still implies a brand-new `LOG-*` for normal continuing work
