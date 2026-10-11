# Current public build and publishing boundary

Refreshed 2026-10-11 from the authoritative private main branch. This is a sanitized operating
design and teaching pack, not a copy of the private application or a runnable trading system.

## What changed

| Area | Current design |
|---|---|
| Red Team | Live thesis attack, Pass / Wait / Fail; numbers checked in code; no shadow week |
| Agent coordination | Thin Floor, worker database finishes, direct entry-review route, no repeated Fail chatter |
| Context | Shared core plus one role card, bounded evidence, scripts for exact calculations |
| Monitoring | Complete ticker coverage, bounded provider calls, 120-second tape gate, cached completed-session indicators |
| Delivery | Stable keys, owner leases, receiver receipts, bounded definite retries, uncertain acceptance reconciled |
| Dashboard | Coalesced/selectively invalidated reads, quote-only board refresh, lazy charts and frame-specific TTLs |
| Grading | Immutable thesis revisions with matching outcomes; no invented legacy accuracy; pilot results separate |
| Validation | The private implementation passed 206 regression tests and Edge typechecking; this pack is checked separately |

## Code versus activation

The implementation and dashboard deployment were verified during the build review. Live database,
function and stored bot prompt activation was not verified in this publishing session. This pack
does not assert that all routines are enabled or that a merge applied migrations. It publishes
no account state, returns or measured hosted token savings. Free-source additions remain proposals.

For an equivalent deployment: inspect current versions, apply schema dependencies, install
receiver guards before enabling senders, deploy functions, check overlapping schedules, then
smoke-test a dry run, chart load and one controlled event. Reconcile unknown effects rather than
replaying them. These are design steps, not instructions against a supplied live project.

## Public sync rules

The exclusions in [README](../README.md#whats-not-here) apply to every document, template and PDF:

- Never publish real plans, positions, trade levels, account information, credentials or internal identifiers.
- Use fictional examples and generic component names. Do not copy production configuration or private migrations.
- Do not publish paid/community research content, private channel lists or model conversations.
- Label starter schemas as incomplete; never claim they enforce permissions supplied only by prompts.
- Keep the contract, roster, architecture, templates and shareable PDF consistent.
- Preserve article illustrations as historical assets; current wiring is in the editable Mermaid diagrams.
- Distinguish implemented code, verified deployments and proposals. Preserve license and attribution.

## Public pack history

The original article pack described a binary Red Team checklist and six Floor seats. Those are
superseded by this revision. Article images remain historical illustrations, not current instructions;
see [images/README](../images/README.md). The two-page PDF is refreshed for this build.
