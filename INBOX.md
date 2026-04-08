# Aware Inbox

This file is an ephemeral scratch disk for intake waiting to be triaged.

Rules:

- Keep it easy to append to from messenger, operator notes, or agent capture.
- Remove entries once they are reflected into durable repo artifacts.
- Keep the stable `IBX-*` id even after the inbox entry itself is later deleted.
- Do not treat this file as durable truth.

## Active Intake

No active intake items are currently recorded.

When the next item arrives, use this default shape:

### IBX-YYYYMMDD-NNN

- Opened: `YYYY-MM-DD HH-mm-ss KST`
- Recorded by agent:
- Source:
- Received:
- Summary:
- Triage status: `new` | `in review` | `reflected` | `dropped`
- Suggested destination:
- Related ids:
- Notes:

## Purge Rule

Once an item has been reflected into `SPEC.md`, `STATUS.md`, `PLANS.md`, `research/`, `records/decisions/`, `records/agent-worklogs/`, or a future `upstream-intake/` module if the repo later adds one, remove the inbox entry.
