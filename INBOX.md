# Aware Inbox

This file is an ephemeral scratch disk for capture waiting to be triaged.

Rules:

- Keep it easy to append to from external capture, operator notes, or agent capture.
- Use it as a pressure valve for untriaged capture, not as a backlog or brainstorm graveyard.
- Group related raw source events into one meaningful inbox entry when possible.
- Triage meaningful capture packets or clusters, not every raw source event and not an entire external history.
- During daily review, route, research, plan, discard, or leave capture; do not produce a giant project digest.
- It is okay to report counts or clusters of held, noisy, stale, or discarded items without summarizing every item.
- Do not update truth docs directly from inbox. Route through the orchestrator or an operator-approved decision.
- Remove entries once they are reflected into durable repo artifacts.
- Keep the stable `IBX-*` id even after the inbox entry itself is later deleted.
- Do not treat this file as durable truth.

## Active Capture

No active capture items are currently recorded.

When the next item arrives, use this default shape:

### IBX-YYYYMMDD-NNN

- Opened: `YYYY-MM-DD HH-mm-ss KST`
- Recorded by agent:
- Source:
- Source / capture ids:
- Capture packet:
- Received:
- Summary:
- Confidence: `low` | `medium` | `high`
- Triage status: `new` | `held` | `in review` | `reflected` | `dropped`
- Triage decision: `route` | `research` | `plan` | `discard` | `leave`
- Suggested destination:
- Related ids:
- Notes:

## Daily Pressure Review Scratch

Use this section during a daily IBX review, then clear it after entries are routed, held, discarded, or escalated.

- Review date:
- Reviewer:
- Inbox pressure summary:
- Clusters reviewed:
- Promotion candidates:
- Research candidates:
- Plan candidates:
- Discard or purge candidates:
- Held without full summary:
- Operator route questions:

## Purge Rule

Once an item has been reflected into `SPEC.md`, `STATUS.md`, `PLANS.md`, `research/`, `records/decisions/`, `records/agent-worklogs/`, a future `upstream-intake/` module if the repo later adds one, or a deliberate discard/hold note, remove the inbox entry.
