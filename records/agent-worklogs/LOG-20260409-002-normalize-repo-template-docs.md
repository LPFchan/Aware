# LOG-20260409-002: Normalize Repo Template Docs
Opened: 2026-04-09 06-10-26 KST
Recorded by agent: 019d6ebe-3413-78d3-bdae-c7af38845b64

## Metadata

- Run type: orchestrator
- Goal: normalize touched repo docs toward repo-template without a full-repo rewrite
- Related ids: DEC-20260409-002, DEC-20260409-001

## Task

Introduce repo-root `AGENTS.md` and `CLAUDE.md`, then normalize the touched repo docs and writing guides toward repo-template while preserving Aware-specific truth.

## Scope

- In scope: repo-root entrypoints, touched root operating surfaces, local artifact `README.md` guides, and records for this change
- Out of scope: app runtime changes, release workflow changes, and untouched historical docs

## Entry 2026-04-09 06-10-26 KST

- Action: mapped the current repo docs to the nearest repo-template surfaces and compared them to the reference templates
- Files touched: none
- Checks run: `find . -maxdepth 3 -type f ...`, `sed -n` reads of local docs and repo-template scaffold files
- Output: identified the missing repo-root entrypoints and the main shape gaps in `PLANS.md`, `INBOX.md`, and the local artifact guides
- Blockers: none
- Next: patch the repo-root entrypoints and normalize the touched docs

## Entry 2026-04-09 06-10-26 KST

- Action: added `AGENTS.md` and `CLAUDE.md`, tightened `repo-operating-model.md`, normalized `PLANS.md`, `STATUS.md`, `INBOX.md`, and upgraded the touched local artifact guides to the repo-template writing contract
- Files touched: `AGENTS.md`, `CLAUDE.md`, `repo-operating-model.md`, `PLANS.md`, `STATUS.md`, `INBOX.md`, `research/README.md`, `records/decisions/README.md`, `records/agent-worklogs/README.md`
- Checks run: none
- Output: added thin enforcement entrypoints, preserved repo-specific truth, and normalized only the touched docs rather than rewriting the whole repo
- Blockers: a patch artifact briefly landed in `records/agent-worklogs/README.md` instead of separate files
- Next: clean up the misplaced patch text and write the new decision and worklog records properly

## Entry 2026-04-09 06-10-26 KST

- Action: cleaned the misplaced patch text from `records/agent-worklogs/README.md`, created `DEC-20260409-002` and this worklog, and verified the touched docs
- Files touched: `records/agent-worklogs/README.md`, `records/decisions/DEC-20260409-002-enforce-template-entrypoints-and-local-guides.md`, `records/agent-worklogs/LOG-20260409-002-normalize-repo-template-docs.md`
- Checks run: `git diff --check`, targeted `rg -n` verification across the touched docs
- Output: `git diff --check` passed and the new entrypoints, local guide contract, and related IDs were confirmed in the normalized docs
- Blockers: none
- Next: use the entrypoints and local guides on the next touched repo artifact

## Entry 2026-04-09 07-15-37 KST

- Action: converted `CLAUDE.md` from a repo-specific instruction file into a pure shim that points back to `AGENTS.md`, matching the repo-template scaffold shape
- Files touched: `CLAUDE.md`, `records/agent-worklogs/LOG-20260409-002-normalize-repo-template-docs.md`
- Checks run: `git diff -- CLAUDE.md`
- Output: `CLAUDE.md` is now a compatibility shim and `AGENTS.md` remains the single repo-specific instruction entrypoint
- Blockers: none
- Next: commit and push the shim update with provenance tied to `DEC-20260409-002` and `LOG-20260409-002`

## Entry 2026-04-09 17-35-24 KST

- Action: reconciled `SPEC.md` and the research guide against pre-adoption Aware docs, the current runtime, and the current lightweight repo-template guidance
- Files touched: `SPEC.md`, `research/README.md`, `records/agent-worklogs/LOG-20260409-002-normalize-repo-template-docs.md`
- Checks run: `git log --follow -- SPEC.md`, `git log --follow -- research/README.md`, `git show cd6ae1c^:README.md`, `git show cd6ae1c^:AWARE-AGENT-PROMPT.md`, `git show cd6ae1c:SPEC.md`, current `sed -n` reads of `Aware/PresenceDetector.swift`, `Aware/MenuBarController.swift`, `Aware/SleepAssertion.swift`, `Aware/AppDelegate.swift`, and `docs/SPARKLE_SETUP.md`, `git diff --check`, targeted `rg` for old rigid headings and stale implementation facts
- Output: replaced the generic spec outline with an Aware-native durable spec, preserved current accepted facts from the source tree, restored durable privacy/capture/detection contracts from the pre-adoption README and agent prompt where still current, and relaxed `research/README.md` to the current memo-oriented guidance because this repo has no `RSH-*` memos yet
- Blockers: none
- Next: hand off the reconciled docs and call out old-source facts that were intentionally not restored because they conflict with current runtime
