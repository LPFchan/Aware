---
name: repo-orchestrator
description: "Route work into the correct artifact layer in Aware's repo operating model."
argument-hint: "Task, intake item, or maintenance request"
---

# Repo Orchestrator

Use this skill with:

- [../../repo-operating-model.md](../../repo-operating-model.md)
- [../../SPEC.md](../../SPEC.md)
- [../../STATUS.md](../../STATUS.md)
- [../../PLANS.md](../../PLANS.md)
- [../../INBOX.md](../../INBOX.md)

## Local Conventions

- Project id: `aware`
- `upstream-intake/` is not present in this repo right now; do not route work there unless the module is explicitly added later.

## What This Skill Produces

- correctly routed repo artifacts
- clear separation between truth, plans, research, decisions, worklogs, and inbox intake
- stable IDs plus lightweight provenance
- operator escalation only when a real judgment call exists

## Procedure

1. Classify the work in routing order.
   - Is this untriaged intake?
   - Is this durable truth?
   - Is this current operational reality?
   - Is this accepted future direction?
   - Is this reusable research?
   - Is this a durable decision?
   - Is this execution history?

2. Route it to the correct artifact layer.
   - `SPEC.md`
   - `STATUS.md`
   - `PLANS.md`
   - `INBOX.md`
   - `research/`
   - `records/decisions/`
   - `records/agent-worklogs/`

3. Assign stable IDs when needed.
   - `IBX-*`
   - `RSH-*`
   - `DEC-*`
   - `LOG-*`
   - Use the least available `NNN` for that date and artifact type.

4. Write the artifact with provenance.
   - Include `Opened: YYYY-MM-DD HH-mm-ss KST`
   - Include `Recorded by agent: <agent-id>`

5. Preserve the separation rules.
   - Do not write speculation straight into `PLANS.md`.
   - Do not let worklogs masquerade as decisions.
   - Do not let inbox entries become long-term truth.
   - Do not treat research memos as raw transcripts.

6. If the task crosses layers, create multiple artifacts deliberately.
   - Example: `RSH-*` plus `LOG-*`
   - Example: `DEC-*` plus `PLANS.md`
   - Example: `LOG-*` plus `STATUS.md`

7. If Git commits are created, add commit trailers.
   - `project: aware`
   - `agent: <agent-id>`
   - `role: orchestrator|worker|subagent|operator`
   - `artifacts: <artifact-id>[, ...]`

## Escalation Triggers

Escalate instead of guessing when the work:

- changes durable product or system truth
- changes public contracts or compatibility posture
- resolves a real policy conflict
- changes operator-facing workflow in a non-obvious way
- overrides a security-sensitive local policy

## Quality Bar

- clear routing
- clear provenance
- clean separation of layers
- reusable artifacts instead of chat-only outcomes

