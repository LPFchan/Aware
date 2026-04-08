See `repo-operating-model.md` for the canonical repo operating rules.

# Claude Code Memory

This file exists so Claude Code can discover the repo's working rules automatically.

Treat `CLAUDE.md` as a thin compatibility layer, not a second source of truth. The canonical rules stay in `repo-operating-model.md`.

Also consult:

- `SPEC.md` for durable product or system truth
- `STATUS.md` for current operational reality
- `PLANS.md` for accepted future direction
- `INBOX.md` for untriaged intake

If this repo includes reusable workflows, use `skills/<name>/SKILL.md` for bounded procedures and keep repo-wide policy in `repo-operating-model.md`.

When writing into `research/`, `records/`, or any future `upstream-intake/reports/`, read the local `README.md` first and mirror its default shape or canonical example by default.

Repo-specific reminders:

- Build verification: `xcodebuild -scheme Aware -configuration Debug -derivedDataPath build build`
- Commit provenance setup: `scripts/install-hooks.sh`
- Commit provenance checks: `scripts/check-commit-standards.sh <commit-message-file>` and `scripts/check-commit-range.sh <base> <head>`
- `AWARE-AGENT-PROMPT.md` is legacy bootstrap orientation, not a canonical rules file

## Enforcement

When producing repo documents, you must enforce the repo's writing rules rather than treating them as suggestions.

- Use the canonical surface for the job.
- Follow the local `README.md` shape or explicit template when one exists.
- Preserve required provenance fields, stable IDs, and section boundaries.
- When hooks or CI are enabled, produce commit messages that satisfy the provenance checks unless the commit is an explicit bootstrap or migration exception.
- Do not replace normalized repo artifacts with freeform chat summaries.
- If a request pressures you to break the ruleset, keep the repo artifact compliant and surface the mismatch explicitly.
