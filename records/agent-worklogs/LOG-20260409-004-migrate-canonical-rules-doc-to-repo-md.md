# LOG-20260409-004: Migrate Canonical Rules Doc To REPO.md

Opened: 2026-04-09 21-20-00 KST
Recorded by agent: 019d6ebe-3413-78d3-bdae-c7af38845b64

## Metadata

- Run type: orchestrator
- Goal: align the repo's canonical rules doc name with current repo-template naming without losing repo-specific truth
- Related ids: DEC-20260409-004

## Task

Rename the repo-root canonical rules doc from `repo-operating-model.md` to `REPO.md`, repoint active guidance surfaces, and keep append-only historical records intact unless the touched file is itself a live guide or example.

## Scope

- In scope: repo-root canonical rules doc naming, agent entrypoints, active guidance docs, skill references, and status truth affected by the rename
- In scope: one decision record and one worklog for the migration
- Out of scope: rewriting untouched historical records just to erase old filename mentions
- Out of scope: changing runtime code, build automation, or release automation

## Entry 2026-04-09 21-06-00 KST

- Action: mapped repo-root contract files and searched the repo for `repo-operating-model.md` references
- Files touched: none
- Checks run: `rg --files -g 'repo-operating-model.md' -g 'REPO.md' -g 'AGENTS.md' -g 'CLAUDE.md' -g '*.md' .`, `rg -n "repo-operating-model\\.md|REPO\\.md" .`
- Output: confirmed that `repo-operating-model.md` existed, `REPO.md` did not, and the remaining live references were concentrated in entrypoints, skills, prompts, and one guide example
- Blockers: none
- Next: read the local guide files for any artifact directories that might be touched

## Entry 2026-04-09 21-14-00 KST

- Action: read the local guide files and applied a rename-first migration to the canonical rules doc plus the active reference surfaces
- Files touched: `REPO.md`, `AGENTS.md`, `AWARE-AGENT-PROMPT.md`, `PLANS.md`, `STATUS.md`, `skills/README.md`, `skills/repo-orchestrator/SKILL.md`, `records/agent-worklogs/README.md`, `records/decisions/DEC-20260409-004-migrate-canonical-rules-doc-to-repo-md.md`
- Checks run: none
- Output: the repo now uses `REPO.md` as the canonical contract, and active guidance points to the new path while append-only historical records remain preserved
- Blockers: none
- Next: verify that no stale live references remain and summarize any intentional divergence

## Entry 2026-04-09 21-26-00 KST

- Action: verified the migration and confirmed the remaining old-name references are historical or migration-context records rather than active guidance
- Files touched: `STATUS.md`, `records/agent-worklogs/LOG-20260409-004-migrate-canonical-rules-doc-to-repo-md.md`
- Checks run: `rg -n "repo-operating-model\\.md|REPO\\.md" .`, `git diff --check`
- Output: active guidance surfaces now point to `REPO.md`; preserved historical records and the migration decision/worklog still mention the older filename where that context matters
- Blockers: none
- Next: summarize the intentional divergence and hand off for review or commit
