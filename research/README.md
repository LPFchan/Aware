# Research

This directory stores curated research memos, not raw execution logs.

## Naming

Create one file per reusable exploration:

- `RSH-YYYYMMDD-NNN-short-title.md`

## When To Create One

Create an `RSH-*` memo when a session produces learning worth future retrieval.

Do not create one for:

- raw work trace that belongs in `records/agent-worklogs/`
- casual brainstorm fragments that still belong in `INBOX.md`

## Required Opening

Each memo should begin with:

- `# RSH-YYYYMMDD-NNN: <Short Research Title>`
- `Opened: YYYY-MM-DD HH-mm-ss KST`
- `Recorded by agent: <agent-id>`

## Default Shape

- Metadata
- Research question
- Why this belongs to this repo
- Findings
- Promising directions
- Dead ends or rejected paths
- Recommended routing

Use that section order by default unless the research genuinely needs a different structure.

## Canonical Example

```md
# RSH-20260409-001: Intake Routing For Mixed Operator Notes

Opened: 2026-04-09 10-00-00 KST
Recorded by agent: agent-example-001

## Metadata

- Status: completed
- Question: Where should mixed operator notes land when they include current-state observations and possible future work?
- Trigger: IBX-20260409-001
- Related ids: IBX-20260409-001, DEC-20260409-001

## Research Question

What is the safest repeatable routing pattern for mixed intake so future agents can recover the result without rereading chat history?

## Why This Belongs To This Repo

Reliable routing is part of the repo's operating system. If mixed notes are stored inconsistently, agents either lose them or contaminate truth docs with transcript noise.

## Findings

- Untriaged mixed notes should land in `INBOX.md` first.
- Current accepted reality belongs in `STATUS.md`, not in a worklog or research memo.
- Accepted future direction belongs in `PLANS.md`, not in `INBOX.md`.
- Reusable guidance about how to route these notes belongs in a research memo like this one.

## Promising Directions

- Normalize messenger intake into one `IBX-*` shape before triage.
- Teach orchestrator workflows to read local examples before drafting new artifacts.
- Keep routing rules in canonical docs and use examples to standardize writing style.

## Dead Ends Or Rejected Paths

- A single catch-all notes file was rejected because it collapses truth, planning, and execution history.
- Copying raw chat summaries into `STATUS.md` was rejected because it turns current truth into a transcript archive.

## Recommended Routing

- Route untriaged mixed notes to `INBOX.md`.
- Reflect accepted current-state changes into `STATUS.md`.
- Reflect accepted future direction into `PLANS.md`.
- Keep this memo as reusable routing guidance if the pattern keeps recurring.
```
