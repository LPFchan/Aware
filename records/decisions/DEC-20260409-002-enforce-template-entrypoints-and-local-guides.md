# DEC-20260409-002: Enforce Template Entry Points And Local Guides
Opened: 2026-04-09 06-10-26 KST
Recorded by agent: 019d6ebe-3413-78d3-bdae-c7af38845b64

## Metadata

- Status: accepted
- Deciders: operator, orchestrator
- Related ids: DEC-20260409-001, LOG-20260409-002

## Decision

Add thin repo-root `AGENTS.md` and `CLAUDE.md` entrypoints and treat the matching local surface template or directory `README.md` as the binding formatting contract whenever touched repo docs are edited. Normalize touched docs incrementally instead of rewriting the whole repo.

## Context

Aware has already adopted repo-template, but some local docs still use thinner or ad hoc formatting. Agentic tools also need repo-root instruction entrypoints that point them to the canonical rules and the correct writing guides.

## Options Considered

### Leave Existing Docs As-Is And Add No Entry Point Files

- Upside: smallest immediate diff
- Downside: tools miss the repo rules and doc formatting drifts continue

### Add Entry Points And Normalize Only Touched Docs

- Upside: converges toward repo-template without rewriting historical or untouched docs
- Upside: preserves repo-specific truth, IDs, and intentional local divergence
- Downside: convergence is gradual rather than immediate

### Rewrite All Repo Docs At Once

- Upside: full uniformity immediately
- Downside: large style churn and higher risk of unnecessary wording changes or lost local nuance

## Rationale

Incremental normalization through thin entrypoints matches the operator request and preserves the distinction between policy, truth, and history. Local surface guides are the safest place to standardize document shape because they live next to the artifacts they govern.

## Consequences

- Agent tools can now discover repo rules through root `AGENTS.md` and `CLAUDE.md`.
- Touched docs should follow the matching local guide or surface template by default.
- Untouched docs may still carry older formatting until they are next legitimately edited.

