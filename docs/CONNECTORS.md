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
| **X (Twitter) MCP** | Search of posts by cashtag and standing handles | Pulse | Read-only | Output must be structured intel written to the week's context. Sentiment alone is not a signal. |
| **YouTube transcript MCP** | Transcripts from a short list of market-commentary channels | Video-ingest routine | Read-only | New videos only, no backfill. Written to a table, never straight into a plan. |
| **OpenRouter: decision model** | A typed decision model (TypeSafe Jev) called through the Decisions API | Scout gate, later Red Team assist, Pulse classification | Call-only | **Gates, classifies, verifies. Never decides.** It is barred from plan synthesis, score maths, zone arithmetic and broker risk. Model version is pinned. |
| **Vercel MCP** | Dashboard project status, logs, environment | Wolf (inspect) | Read-only in practice | Agents **cannot deploy**. Deploys happen on a git push. |
| **GitHub** | The repo: code, skills, design docs | Wolf, human | Read; pushes reviewed | The `main` branch is the production source of truth for skills and docs. |

## Other inputs (not MCP)

| Source | What it provides | How it gets in |
|--------|------------------|----------------|
| **Paid community research** | Zone document, weekly stock-market report (regime, gamma side, momentum), daily/weekly/monthly expected-move levels, watchlists | Archivist reads the community's Discord channels each morning and uploads the packs to file storage. No Discord API: it runs as a browser session. |
| **Web search** | News, macro and earnings calendar, VIX, put/call, sector moves | Called inside research steps; cited in the plan |
| **Public quote endpoint** | OHLC bars for the dashboard charts | The `bars` edge function fetches, caches in the database, and serves stale data rather than nothing if the upstream fails |
| **TradingView indicator** | Real-time ENTRY / STOP / T1 / T2 / gamma-flip alerts on the pasted levels | Alert webhook → `tv-webhook` edge function → database → Telegram |

## Edge functions (deterministic code, not agents)

| Function | Trigger | Job |
|----------|---------|-----|
| `tv-webhook` | TradingView alert | Parse the alert, record it, promote `armed → active` on entry or `active → closed` on stop, update the live gamma regime, send a Telegram message |
| `notify` | Database trigger on a new `notifications` row | Relay the message to Telegram and stamp `sent` or `failed` back on the row |
| `bars` | Dashboard request | Serve cached OHLC bars, refreshing when stale, for an allow-listed set of tickers |

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
3. **No silent fallbacks.** If a source fails, the run says so in its finish line and keeps going with what it has. It never invents the missing number.
4. **Secrets stay server-side.** Telegram, broker and model keys live in function secrets or the platform's connector settings. No agent prompt or repo file contains them.
5. **Every write lands in the database.** If it isn't in a row, it didn't happen.

## Build your own: the minimum set

You don't need all of this. To run the pattern on any desk:

| Need | TradeOps uses | Any equivalent works |
|------|---------------|----------------------|
| A system of record | Supabase (Postgres) | Any database with row-level permissions |
| Domain data | TVRemix, TradingView | Your CRM, ERP, document store, APIs |
| A place to stage, not commit, the irreversible action | IBKR order instructions | Draft PO, draft email, draft contract, pull request |
| A push channel to the human | Telegram via a database trigger | Slack, SMS, email |
| A room for the agents | Grok Bot group chat | Any chat the agents can post to |
