# Decisions

This directory stores durable decision records.

## Naming

Create one file per meaningful decision:

- `DEC-YYYYMMDD-NNN-short-title.md`

## Decision Hygiene

- Decision records are append-only by new file.
- If a decision changes later, create a new `DEC-*` that supersedes the old one.
- Do not fold raw execution history into a decision record.

## Required Opening

Each decision file should begin with:

- `# DEC-YYYYMMDD-NNN: <Short Decision Title>`
- `Opened: YYYY-MM-DD HH-mm-ss KST`
- `Recorded by agent: <agent-id>`

## Default Shape

- Metadata
- Decision
- Context
- Options considered
- Rationale
- Consequences

Use that section order by default unless the decision genuinely needs a different structure.

## Canonical Example

```md
# DEC-20260409-001: Add Example Artifacts Beside Shape READMEs

Opened: 2026-04-09 10-15-00 KST
Recorded by agent: agent-example-001

## Metadata

- Status: accepted
- Deciders: operator, orchestrator
- Related ids: RSH-20260409-001, LOG-20260409-001

## Decision

Add a canonical example section to each durable artifact directory guide and instruct agents to use it as the default output shape.

## Context

The macro structure of the repo is clear, but agents still have too much freedom in how individual artifacts are written. README guidance alone leaves room for inconsistent section order, tone, and detail level.

## Options Considered

### Keep README-Only Guidance Without An Embedded Example

- Upside: fewer words in the guide
- Downside: agents still have to infer the final artifact shape from prose

### Keep One README And Embed A Canonical Example

- Upside: gives agents a concrete finished document to imitate
- Upside: reduces stylistic drift without creating a second file to maintain
- Downside: the guide becomes longer

### Add A Separate Writing Guide Only

- Upside: centralizes style rules
- Downside: still leaves agents guessing what a finished artifact should look like

## Rationale

An embedded example closes the gap between abstract rules and real output without introducing a separate file split the operator dislikes.

## Consequences

- Artifact directories become easier for new agents to use correctly.
- The local guide becomes the single place to read before drafting.
- Skills and agent entrypoints should point to directory guides before drafting.
```
