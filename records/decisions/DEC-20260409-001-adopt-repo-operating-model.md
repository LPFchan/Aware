# DEC-20260409-001: Adopt Repo Operating Model
Opened: 2026-04-09 05-22-08 KST
Recorded by agent: 019d6ebe-3413-78d3-bdae-c7af38845b64

## Metadata

- Project: `Aware`
- Project id: `aware`
- Status: `accepted`
- Supersedes: none
- Related ids: `LOG-20260409-001`

## Decision

Aware adopts a repo-template-style operating model as an overlay on the existing macOS app repo. `repo-operating-model.md`, `SPEC.md`, `STATUS.md`, `PLANS.md`, `INBOX.md`, `research/`, `records/decisions/`, `records/agent-worklogs/`, and the repo-orchestrator skill become the canonical operational surfaces.

## Context

- The repo already had user-facing docs, release notes, CI workflows, and an agent prompt, but not a durable in-repo separation of truth, status, plans, decisions, and worklogs.
- Future operator and agent collaboration needs searchable repo-local context instead of relying on chat history or duplicated prompt text.
- The app runtime and release pipeline are already working and should not be restructured as part of this adoption.

## Options Considered

1. Keep the existing repo as-is and rely on `README.md` plus ad hoc chat context.
   - Rejected because durable truth, current status, decisions, and work history would remain mixed or external.
2. Adopt only lightweight docs without stable artifacts or commit provenance.
   - Rejected because it would improve discoverability but not establish durable routing or provenance discipline.
3. Adopt the full operating model as an overlay without changing the app or runtime structure.
   - Accepted.

## Rationale

- An overlay approach preserves the existing Xcode project, app code, release workflows, and user docs.
- Stable IDs and separated artifact layers give future work an explicit provenance trail.
- Keeping `upstream-intake/` out of the bootstrap avoids unused surface area while leaving room to add it later if the repo's operating needs change.
- This runtime provides a thread identifier via `CODEX_THREAD_ID`. When available, use that value as the `agent-id`. If a future environment does not provide one, the operator may assign a fallback agent ID and record the convention in the relevant decision or worklog.

## Consequences

- Future accepted work should be routed through `SPEC.md`, `STATUS.md`, `PLANS.md`, `INBOX.md`, `research/`, `records/decisions/`, or `records/agent-worklogs/` instead of being left only in chat.
- Normal post-bootstrap commits should include `project: aware`, `agent: <agent-id>`, `role: orchestrator|worker|subagent|operator`, and `artifacts: <artifact-id>[, ...]`.
- Legacy user-facing docs may still need deliberate follow-up updates when they drift from the canonical operating record.

