# DEC-20260409-003: Enforce Commit Provenance
Opened: 2026-04-09 06-10-26 KST
Recorded by agent: 019d6ebe-3413-78d3-bdae-c7af38845b64

## Metadata

- Status: accepted
- Deciders: operator, orchestrator
- Related ids: DEC-20260409-001, DEC-20260409-002, LOG-20260409-003

## Decision

Enforce repo-template commit provenance in Aware through a tracked local `commit-msg` hook, shared validator scripts, and a GitHub Actions workflow that checks pull-request commits and direct pushes to the default branches.

## Context

Aware already adopted repo-template and its commit-trailer rules, but those rules were still guidance-only. The repo needs enforcement that is strong enough to catch missing provenance locally and remotely without weakening the existing build, release, or tag-based workflows.

## Options Considered

### Keep Commit Provenance As Documentation-Only Guidance

- Upside: no new tooling or friction
- Downside: normal commits can keep drifting away from the required provenance format

### Enforce Locally With Hooks Only

- Upside: immediate feedback before a commit is created
- Upside: simple to add
- Downside: unenforced in clones that do not install the hook, and remote pushes can still bypass the rule

### Enforce Locally And In CI

- Upside: gives fast local feedback and remote backstop enforcement
- Upside: keeps pushed and pull-request commits aligned with repo-template provenance
- Downside: CI scope needs to account for Aware's existing default-branch and release-tag workflow layout

## Rationale

Local hooks plus CI provide the safest balance. The local hook catches mistakes before commit creation, while CI prevents provenance-free commits from landing remotely. The remote workflow is intentionally scoped to pull requests and default-branch pushes so it does not interfere with the existing tag-driven release automation or rely on awkward zero-base push handling for every possible branch scenario.

## Consequences

- Contributors should run `scripts/install-hooks.sh` in local clones to activate the tracked `commit-msg` hook.
- Normal commits must include `project: aware`, `agent: <agent-id>`, `role: orchestrator|worker|subagent|operator`, and `artifacts: <artifact-id>[, <artifact-id>...]`.
- Bootstrap or migration exceptions remain allowed only when they are explicit exceptions.
- If broader remote enforcement is needed later, the CI workflow can be widened deliberately rather than by accident.

