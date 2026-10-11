# Connectors and data sources

Public design refreshed 2026-10-11. These are the sources and boundaries described by the current
build, not a verified live connection inventory. No project IDs, account identifiers, URLs with
credentials, private channel lists or secret values are published.

## Agent tools

| Tool | Evidence/work | Boundary |
|---|---|---|
| Supabase MCP | Shared records, SQL, file storage, logs | Trusted backend roles; audit writes; approval/risk authority requires enforced permissions |
| TVRemix MCP | Quotes, OHLCV, structure, options, EM, earnings, fundamentals, news | Owned rate budgets; bounded evidence pulls and backoff; exact math in scripts |
| TradingView MCP | Watchlists, symbol data, alerts | Watchlist sync; the human pastes indicator levels |
| IBKR MCP | Contract/account reads and order instructions | Quartermaster stages drafts; live submission remains human-only |
| Grok built-in public X tools | Pulse news/chatter/cashtag evidence | Structured sources and timestamps; sentiment alone is not a trade signal |
| Account-linked X connector | Account timeline where authorized | Distinct from public X search; no public account configuration |
| YouTube transcript fallback | Captions unavailable to the caption-first helper | New videos only; no historical backfill |
| OpenRouter Decisions API (Jev) | Typed classification/sub-questions | Never plan synthesis, score/zone arithmetic, risk sizing or final Red Team verdict |
| GitHub / hosting inspection | Code/docs and deploy diagnostics | Main is source authority; dashboard deployment follows reviewed Git changes |

## Code inputs and jobs

| Component | Current behavior |
|---|---|
| Yahoo chart endpoint | Scanners and chart cache, not a model price-polling loop. Tape older than 120 seconds is skipped; daily indicators exclude the unfinished session. All eligible tickers, bounded calls/timeouts/backoff and coalesced daily misses |
| TradingView indicator/webhook | Deterministic alerts on human-pasted levels; watching ENTRY/IN ZONE events share the gated durable wake path |
| `scout-far` | Five-minute watching-card check; session/plan/freshness/numeric gates before pre-entry, entry or versioned Wait recheck |
| `scout-slot` | Code decides each :45 slot and :52 catch-up. Quiet results finish in code; provider failure is a health alert, not a model wake |
| Webhook transport/receiver | Stable keys, owner leases, receiver receipts. Definite rejection retries are bounded; uncertain effects are reconciled; acceptance is separate from completion |
| `bars` | Lazy chart cache with hourly 10m / daily 6h / weekly 24h TTLs, cross-isolate refresh leases, four-call provider bound and partial stale fallback. Does not overwrite quote freshness |
| `notify` | Database outbox relay to Telegram, with recorded send result |
| Captions helper / video routine | New upload IDs and clean captions first, transcript-provider fallback per video |
| Research ingest | Paid/community material stays private. Day/channel gates avoid unchanged reads; PDF text is extracted without rendering every page |
| Web/news research | Cited and timestamped evidence, scoped to the relevant review |

## Rules every connector follows

1. Give each tool only the permissions its job needs. The broker boundary is draft versus submit.
2. Own rate budgets; use small bounded pulls and scripts before model interpretation.
3. Required stale/missing inputs block price decisions. Never invent an unavailable value.
4. Secrets remain in server/platform stores, outside repositories and routine prompts.
5. Every meaningful result and finish lands in the database; advisory text is not human approval.
6. Verify deployed versions, stored prompts and trigger ownership separately from merged code.

The simplified starter schema has anonymous read policies for demonstration. Production dashboard
permissions are a separate deployment decision; this pack does not claim they are uniformly read-only.
Financing/trade data is never supplied here. Free-source additions remain research proposals.

## Retired patterns

Finnhub, n8n and Claude cloud routines were replaced in the described workflow. The current design
uses Grok specialists, code gates and database state. Equivalent tools can implement the same pattern.
Minimum components: system of record, domain evidence, deterministic watcher, durable dispatch,
reviewable draft surface, human approval channel and a revision-preserving decision log.
