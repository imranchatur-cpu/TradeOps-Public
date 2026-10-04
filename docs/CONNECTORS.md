# Connectors and data sources

Every tool the desk can reach, what each one is for, who uses it, and how far it is trusted. The **Access** column is the important one. Each connector gets the least it needs, and the riskiest one (the broker) can only draft.

> Names are the products TradeOps uses today. None of this is an endorsement, and the pattern works with any equivalent.

---

## MCP connectors (agents call these as tools)

| Connector | What it provides | Used by | Access | Guardrail |
|-----------|------------------|---------|--------|-----------|
| **Supabase MCP** | SQL on the system-of-record database, file storage, logs | Every agent, via Wolf | Read + write (service role) | One database is the only source of truth. Schema constraints and triggers enforce the hard rules (locked predictions, no deleting live positions). |
| **TVRemix MCP** | Headless TradingView data: quotes, OHLCV, multi-timeframe and smart-money structure, screeners, option chains, expected move, earnings, financials, news | Cartographer, Options, Sentinel, Architect | Read-only | Rate budget of 20 calls/min, 200/hr and 1,500/day per key. **Options owns its own queue** so one agent can't starve the rest. Back off on 429. |
| **TradingView MCP** | Watchlists, symbol data, alerts on the user's own account | Architect, Sentinel, Quartermaster | Read + watchlist sync | Syncs the week's trade-ideas watchlist. It does **not** push chart levels; the human pastes those into the indicator. |
| **IBKR MCP** (Interactive Brokers) | Contract search, account positions and orders, order *instructions* | Quartermaster | **Draft only** | Creates reviewable order instructions after an armed setup gets a Red Team Pass. It never sends a live order. The human fires. |
| **X (Twitter) MCP** | Search of posts by cashtag and standing handles | Pulse; Scout for news on names approaching entry | Read-only | Output must be structured intel written to the week's context. Sentiment alone is not a signal. |
| **YouTube transcript MCP** | Transcripts from a short list of market-commentary channels | Video-ingest routine | Read-only | New videos only, no backfill. Written to a table, never straight into a plan. |
| **OpenRouter: decision model** | A typed decision model (TypeSafe Jev) called through the Decisions API | Scout gate, later Red Team assist, Pulse classification | Call-only | **Gates, classifies, verifies. Never decides.** It is barred from plan synthesis, score maths, zone arithmetic and broker risk. Model version is pinned. |
| **Vercel MCP** | Dashboard project status, logs, environment | Wolf (inspect) | Read-only in practice | Agents **cannot deploy**. Deploys happen on a git push. |
| **GitHub** | The repo: code, skills, design docs | Wolf, human | Read; pushes reviewed | The `main` branch is the production source of truth for skills and docs. |

## Other inputs (not MCP)

| Source | What it provides | How it gets in |
|--------|------------------|----------------|
| **Paid community research** | Zone document, weekly stock-market report (regime, gamma side, momentum), daily/weekly/monthly expected-move levels, watchlists | Archivist reads the community's Discord channels each morning and uploads the packs to file storage. No Discord API: it runs as a browser session. |
| **Web search** | News, macro and earnings calendar, VIX, put/call, sector moves | Called inside research steps; cited in the plan |
| **Yahoo Finance** (public chart endpoint, no key) | Live prices, 1-minute, hourly, daily and weekly OHLC bars | Two edge functions only, never an agent: `bars` (dashboard charts, cached in the database, serves stale data rather than nothing if Yahoo fails) and `scout-far` (the 5-minute entry check). Free data can lag a few minutes, so it notices levels; it doesn't do analysis. |
| **TradingView indicator** | Real-time ENTRY / STOP / T1 / T2 / gamma-flip / IN ZONE alerts on the pasted levels | Alert webhook → `tv-webhook` edge function → database → Telegram. Alerts are set by hand, so they're a bonus path, not the plan. |
| **Grok Bot webhook routine** | A routine with a webhook trigger that wakes Scout for one setup | Called by `scout-far` or `tv-webhook` when a watching setup reaches its zone. Runs Scout's checks, Wolf and Red Team in one run. Key held in function secrets. |
| **Claude Code (`grok-floor` mod)** | A read-out of the agents' group chat outside Grok | Every Floor post is mirrored to a `floor_events` table. The human's Claude Code session reads it and can post advisory notes back, which Wolf relays. Advisory only: a human gate counts only when the human types it in the Floor itself. |
| **Scheduler (`pg_cron` + `pg_net`)** | Timed calls from inside the database | Runs `scout-far` every 5 minutes in market hours. Makes no call at all until its secret is set, so a half-finished setup doesn't error every 5 minutes. |

## Edge functions (deterministic code, not agents)

| Function | Trigger | Job |
|----------|---------|-----|
| `tv-webhook` | TradingView alert | Parse the alert, record it, promote `armed → active` on entry or `active → closed` on stop, update the live gamma regime, send a Telegram message. An ENTRY / IN ZONE alert on a **watching** setup also wakes Scout. |
| `scout-far` | Scheduler, every 5 min, weekdays 06:00–13:00 PT | Pull Yahoo Finance prices and the 1-minute bars since the last check for every watching setup. If price reached the entry zone, call the Grok Bot wake routine (once per setup per stage per hour, logged in `scout_wakes`). If it's only getting close, record that on the setup for the hourly slot. One Telegram line per run, only if it woke someone. A dry-run mode shows what it would do without writing anything. |
| `notify` | Database trigger on a new `notifications` row | Relay the message to Telegram and stamp `sent` or `failed` back on the row |
| `bars` | Dashboard request | Serve cached OHLC bars from Yahoo Finance, refreshing when stale, for an allow-listed set of tickers |
| Shared wake helper | Imported by `tv-webhook` and `scout-far` | One place for the wake call, the hourly dedupe and the once-a-day ops alert, so both triggers behave the same. Covered by tests that run before every deploy. |

## Retired, and why

| Was | Replaced by | Why |
|-----|-------------|-----|
| n8n workflows | Supabase Edge Functions | One less system to host and monitor. Alert handling now lives next to the data. |
| Finnhub (free tier) | TVRemix + TradingView MCP | Consolidated onto one data provider with a known rate budget |
| Bigdata.com | TVRemix + web search | Intentionally dropped; the plan ran fine without it |
| Claude cloud routines | Grok Bot routines under Wolf | Platform swap. The design docs moved over almost unchanged, which was the test of whether they were real. |

---

## Rules every connector follows

1. **Least privilege.** Read-only unless the job needs a write. The broker can only draft.
2. **Budgets are owned.** A rate-limited source has one owner and one queue.
3. **No silent fallbacks.** If a source fails, the run says so in its finish line and keeps going with what it has. It never invents the missing number. A broken connector also sends one ops alert to the human per connector per day: loud, but not a flood.
4. **Secrets stay server-side.** Telegram, broker and model keys live in function secrets or the platform's connector settings. No agent prompt or repo file contains them.
5. **Every write lands in the database.** If it isn't in a row, it didn't happen.

## Build your own: the minimum set

You don't need all of this. To run the pattern on any desk:

| Need | TradeOps uses | Any equivalent works |
|------|---------------|----------------------|
| A system of record | Supabase (Postgres) | Any database with row-level permissions |
| Domain data | TVRemix, TradingView | Your CRM, ERP, document store, APIs |
| A cheap, dumb watcher | A 5-minute Yahoo Finance price check | Any scheduled job that notices an event and wakes an agent: a new ticket, a filed document, a threshold crossed |
| A place to stage, not commit, the irreversible action | IBKR order instructions | Draft PO, draft email, draft contract, pull request |
| A push channel to the human | Telegram via a database trigger | Slack, SMS, email |
| A room for the agents | Grok Bot group chat | Any chat the agents can post to |
