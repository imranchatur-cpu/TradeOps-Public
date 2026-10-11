# Cadence: who runs when

Public design refreshed 2026-10-11. All times Pacific. This is the intended cadence, not an
inventory of enabled app routines. NYSE holidays, half days, approved-plan state and per-event
freshness are code gates; waking a model is the result of a gate, not the default.

| Time | Work | Gate |
|---|---|---|
| ~03:35 | New videos: captions first, transcript-provider fallback | New IDs only, no historical backfill |
| ~03:40 | Archivist research ingest | Day/channel-change gates; empty channels are fine |
| ~04:00 weekdays | Sentinel + specialists: full UPDATE, levels/claims, new names, watchlist | Approved plan; frozen active-position levels |
| ~06:35 | Consolidated scripted options pull | Owned provider budget; reuse the morning snapshot |
| 06:00–13:00 every 5 min | `scout-far`: fresh tape, numeric checks, pre-entry/entry/Wait recheck | Watching setups, calendar/plan gates, no stale tape |
| :44, before 06:45–12:45 | `scout-slot`: decide each slot | Quiet finishes in code; approaching is only a label |
| :45 when woken | Scout reviews entry/armed-entry/stop-risk/promote/missing-level work | Receiver receipt + fresh evidence; no provider-error wake |
| :52 when needed | Catch-up | Missing finish/unrelayed work; stable key, no repeated effects |
| ~10:15 | Pulse material-news check | Market/plan gate, scoped news reads |
| ~13:13 | Coach EOD | Market calendar; grades original revisions |
| Saturday | Weekly Coach review, pilot table, human override questions | Recorded trades reconciled; legacy unversioned decisions excluded from accuracy |
| Weekend when enabled | Archive + Architect BUILD | Draft only; human CONFIRM required |

Half-day monitoring ends at the shortened close. Avoid enabling old scheduled and new webhook
routines for the same slot. A failed delivery is not an entry signal: re-read current tape.
Unknown acceptance is reconciled rather than replayed automatically.

Workers write compact database finishes; Wolf relays actionable items to the thin Floor.
Gated routines end silently. No acknowledgement-only posts or automatic group-chat analysis.
BUILD/UPDATE remain full intelligence; intraday work stays scoped, with options/news only where
the relevant review needs them. [CONTRACT](../CONTRACT.md) governs the boundaries.
