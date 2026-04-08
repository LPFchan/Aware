# Agent Worklogs

This directory stores execution history for runs, sessions, agents, and subagents.

## Naming

Create one file per run or workstream:

- `LOG-YYYYMMDD-NNN-short-title.md`

## Worklog Hygiene

- Worklogs are append-only.
- If a correction is needed, append a new entry rather than rewriting old history.
- Do not turn worklogs into decision records or truth docs.
- Do not create a new `LOG-*` just because a new commit exists.
- Prefer appending to the current relevant `LOG-*` until a new file would materially improve clarity.

## Required Opening

Each worklog should begin with:

- `# LOG-YYYYMMDD-NNN: <Short Run Or Task Title>`
- `Opened: YYYY-MM-DD HH-mm-ss KST`
- `Recorded by agent: <agent-id>`

## Default Shape

- Metadata
- Task
- Scope
- Timestamped entries with actions, files touched, checks run, outputs, blockers, and next steps

Use that structure by default so worklogs stay scan-friendly and comparable across runs.

## When To Reuse vs Create

Append to the current relevant `LOG-*` when:

- the same goal or workstream is continuing
- the same agent run or bounded task is still active
- a new timestamped entry is enough to preserve clarity

Create a new `LOG-*` when:

- the task is materially different from the current log's scope
- a new agent or subagent owns a separate execution thread
- reusing the old log would make provenance harder to follow

## Canonical Example

```md
# LOG-20260409-001: Tighten Artifact Writing Discipline

Opened: 2026-04-09 10-30-00 KST
Recorded by agent: agent-example-001

## Metadata

- Run type: orchestrator
- Goal: make durable artifact writing more consistent across agents
- Related ids: DEC-20260409-001, RSH-20260409-001

## Task

Add examples and writing rules so agents stop inventing document structure from scratch.

## Scope

- In scope: research, decision, worklog, and upstream-report guidance
- In scope: agent guidance updates that tell writers to consult local directory guides
- Out of scope: changing the routing ladder or provenance scheme

## Entry 2026-04-09 10-31-00 KST

- Action: audited scaffold directories that only had lightweight shape guidance
- Files touched: none
- Checks run: `find scaffold -type f | sort`
- Output: confirmed where artifact writing rules needed to be made more concrete
- Blockers: none
- Next: draft canonical examples into the local guides

## Entry 2026-04-09 10-42-00 KST

- Action: drafted canonical examples for `RSH-*`, `DEC-*`, and `LOG-*` artifacts
- Files touched: local directory `README.md` guides
- Checks run: none
- Output: created concrete shapes agents can mirror
- Blockers: none
- Next: align the skills and instruction entrypoints with the new guides

## Entry 2026-04-09 10-55-00 KST

- Action: updated writing rules so local guides are treated as part of the artifact contract
- Files touched: `REPO.md`, `AGENTS.md`, `CLAUDE.md`, and the touched local directory guides
- Checks run: `rg -n "example\\.md|Repo Template|repo-template" .`
- Output: naming normalized and writing guidance tightened
- Blockers: none
- Next: verify references and summarize the change
```
