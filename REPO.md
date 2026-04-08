# Repo Operating Model

This document is the canonical repo contract for Aware.

## Purpose

Use this model when the repo is managed by one operator plus many agents and you want the repo itself to remain legible over time.

The goal is simple:

- keep canonical truth in-repo
- keep noisy activity out of truth docs
- keep provenance explicit
- let the orchestrator route work without inventing new storage rules each time

## Aware Conventions

- Project id: `aware`
- Canonical user-facing docs remain in `README.md`, `docs/`, and `release-notes/`.
- Canonical repo-operating docs live in `SPEC.md`, `STATUS.md`, `PLANS.md`, `INBOX.md`, `research/`, `records/decisions/`, and `records/agent-worklogs/`.
- `AGENTS.md` is the canonical editable agent-instructions entrypoint for tools that require one.
- `CLAUDE.md` is a thin compatibility shim that points to `AGENTS.md`.
- `AWARE-AGENT-PROMPT.md` is a legacy bootstrap pointer, not a second policy layer.
- `upstream-intake/` is intentionally omitted for now. Add it only if Aware later needs recurring upstream review.

## Core Surfaces

Every repo using this system should separate these surfaces:

| Surface | Role | Mutability |
| --- | --- | --- |
| `SPEC.md` | Durable statement of what the project is supposed to be. | rewritten |
| `STATUS.md` | What is true right now operationally. | rewritten |
| `PLANS.md` | Accepted future direction that is not current truth yet. | rewritten |
| `INBOX.md` | Ephemeral intake waiting for triage. | append then purge |
| `research/` | Curated research memos worth keeping. | append by new file |
| `records/decisions/` | Durable decision records with rationale. | append-only by new file |
| `records/agent-worklogs/` | Execution history for runs, agents, and subagents. | append-only |

## Separation Rules

These boundaries are mandatory:

- `SPEC.md` is not a changelog.
- `STATUS.md` is not a transcript.
- `PLANS.md` is not a brainstorm dump.
- `INBOX.md` is not durable truth.
- `research/` is not raw execution history.
- `records/decisions/` is not the same as `records/agent-worklogs/`.
- Off-Git memory is not a substitute for repo-local canonical docs.

That separation gives future operators and future agents fast answers to different questions:

- What is the project? -> `SPEC.md`
- What is true right now? -> `STATUS.md`
- What future work is actually accepted? -> `PLANS.md`
- What did we learn from exploration? -> `research/`
- What did we decide and why? -> `records/decisions/`
- What actually happened during execution? -> `records/agent-worklogs/`

## Roles

### Operator

The operator is the final authority for product direction, escalation outcomes, and acceptance of truth changes.

### Orchestrator Agent

The orchestrator owns synthesis and routing.

It may:

- triage inbox items
- classify work into the right artifact layer
- update `SPEC.md`, `STATUS.md`, and `PLANS.md`
- create research memos
- create decision records
- append or create worklogs
- translate messenger intake into repo artifacts
- escalate non-obvious product, architecture, workflow, or policy calls

### Worker Agents

Worker agents execute bounded tasks.

They may:

- append to worklogs
- propose truth changes through the orchestrator
- create evidence, summaries, and implementation outputs

They should not update `SPEC.md`, `STATUS.md`, or `PLANS.md` directly unless the operator explicitly allows that flow.

### Messenger Surfaces

Messenger surfaces are intake and control channels.

They may:

- create or append inbox intake
- request approvals
- deliver summaries
- surface blocked states

They must not write truth docs directly.

## Orchestrator Routing Ladder

When new work arrives, the orchestrator should classify it in this order:

1. Is this untriaged intake?
   - Route to `INBOX.md`.
2. Is this durable truth about what the project is?
   - Route to `SPEC.md`.
3. Is this current operational reality?
   - Route to `STATUS.md`.
4. Is this accepted future direction?
   - Route to `PLANS.md`.
5. Is this reusable exploration or horizon-expansion work?
   - Route to `research/`.
6. Is this a meaningful decision with rationale?
   - Route to `records/decisions/`.
7. Is this execution history?
   - Route to `records/agent-worklogs/`.

One task may legitimately touch multiple layers. For example:

- a research session can create `RSH-*` plus a `LOG-*`
- a product choice can create `DEC-*` and update `PLANS.md`
- implementation progress can append `LOG-*` and update `STATUS.md`

## Write Rules

- `SPEC.md`, `STATUS.md`, and `PLANS.md` should be updated only by the operator or orchestrator.
- `INBOX.md` is an aggressive scratch disk. Purge entries once they are reflected elsewhere.
- `research/` keeps curated findings only.
- `records/decisions/` is append-only by new decision file.
- `records/agent-worklogs/` is append-only by new log file or appended entries.
- Truth docs should reflect the latest accepted state, not every intermediate thought.

## Local Writing Guides

- Before editing a repo document, read the matching surface template or local directory `README.md` first.
- When a local guide defines scope, default section order, or a canonical example, treat that guide as part of the artifact contract.
- Prefer the local guide over ad hoc formatting and make the smallest justified deviation when repo-specific truth needs extra structure.

## Stable IDs

This model assumes:

- `project-id` identifies the repo or workspace. For Aware, use `aware`.
- `agent-id` identifies one conversation or run, 1:1.
- subagents receive their own `agent-id`
- Off-Git systems resolve parent-child lineage, messages, events, and commit history from `agent-id`

Recommended prefixes:

- `IBX-YYYYMMDD-NNN`
- `RSH-YYYYMMDD-NNN`
- `DEC-YYYYMMDD-NNN`
- `LOG-YYYYMMDD-NNN`

Numbering is per day and per artifact type. Any agent may claim the next ID by checking the least available `NNN`.

Every stable-ID-bearing artifact should open with:

- `Opened: YYYY-MM-DD HH-mm-ss KST`
- `Recorded by agent: <agent-id>`

## Commit Provenance

After this repo adopts the system, every normal commit should include these trailers:

- `project: aware`
- `agent: <agent-id>`
- `role: orchestrator|worker|subagent|operator`
- `artifacts: <artifact-id>[, <artifact-id>...]`

Rules:

- `artifacts:` may list more than one stable ID, comma-separated.
- A normal commit should always reference at least one artifact.
- Artifact-less commits should be treated as bootstrap or migration exceptions only.
- The commit side and the repo-artifact side should reinforce the same provenance graph.

Local enforcement surfaces:

- `.githooks/commit-msg`
- `scripts/check-commit-standards.sh`
- `scripts/check-commit-range.sh`
- `scripts/install-hooks.sh`
- `.github/workflows/commit-standards.yml`

## Off-Git Provenance

Repo artifacts stay lightweight on purpose.

In-repo provenance answers:

- what artifact this is
- when it was opened
- which agent wrote the record

The Off-Git runtime should answer:

- which conversation or run the `agent-id` maps to
- whether the agent was top-level or a subagent
- which messages or events produced the artifact
- which commits belong to that `agent-id`

## Scaffold Rule

This repo uses the repo-template skeleton as a canonical layout, not a loose grab-bag of snippets.

Keep the operating surfaces recognizable so future operators and agents can recover context quickly.
