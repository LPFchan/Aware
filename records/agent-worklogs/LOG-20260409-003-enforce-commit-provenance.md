# LOG-20260409-003: Enforce Commit Provenance
Opened: 2026-04-09 06-10-26 KST
Recorded by agent: 019d6ebe-3413-78d3-bdae-c7af38845b64

## Metadata

- Run type: orchestrator
- Goal: add local and remote commit-provenance enforcement without weakening Aware's existing workflows
- Related ids: DEC-20260409-003, DEC-20260409-001, DEC-20260409-002

## Task

Introduce tracked hook and CI enforcement for repo-template commit provenance, then merge the commit-compliance requirement into the repo's thin agent entrypoints.

## Scope

- In scope: `.githooks/commit-msg`, commit-check scripts, hook installer, commit-standards CI workflow, `AGENTS.md`, `CLAUDE.md`, `repo-operating-model.md`, and current-truth docs affected by the workflow change
- Out of scope: app runtime behavior, release packaging behavior, and full-repo doc rewrites

## Entry 2026-04-09 06-10-26 KST

- Action: inspected existing hooks, workflows, and agent entrypoints and compared them to the repo-template enforcement assets
- Files touched: none
- Checks run: repo file inventory, `git config --get core.hooksPath`, reads of current workflows and template hook scripts
- Output: confirmed there was no tracked hook path, no commit-standards workflow, and no stronger existing enforcement to preserve
- Blockers: none
- Next: add the tracked hook, scripts, CI workflow, and merged instruction updates

## Entry 2026-04-09 06-10-26 KST

- Action: added the tracked `commit-msg` hook, commit validator scripts, install helper, commit-standards CI workflow, and merged commit-compliance requirements into `AGENTS.md` and `CLAUDE.md`
- Files touched: `.githooks/commit-msg`, `scripts/check-commit-standards.sh`, `scripts/check-commit-range.sh`, `scripts/install-hooks.sh`, `.github/workflows/commit-standards.yml`, `AGENTS.md`, `CLAUDE.md`, `repo-operating-model.md`, `STATUS.md`, `records/decisions/DEC-20260409-003-enforce-commit-provenance.md`
- Checks run: none
- Output: Aware now has tracked local and remote provenance enforcement without changing the runtime or release workflows
- Blockers: none
- Next: install the local hooks and run focused validator checks

## Entry 2026-04-09 06-10-26 KST

- Action: installed the tracked hook path in this clone and ran focused validation for the new enforcement
- Files touched: local git config via `core.hooksPath=.githooks`
- Checks run: `scripts/install-hooks.sh`, `git config --get core.hooksPath`, positive and negative `scripts/check-commit-standards.sh` temp-file checks, `scripts/check-commit-range.sh` in a throwaway repo for both a normal range and a zero-base fallback range, `git diff --check`
- Output: local hook installation succeeded, the standards checker accepted valid trailers and rejected a wrong `project:` trailer, the range checker passed in both test scenarios, and the working tree remained free of whitespace or patch-format issues
- Blockers: none
- Next: let the new CI workflow run on the next PR or direct push to the default branches
