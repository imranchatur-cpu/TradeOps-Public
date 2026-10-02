# FAQ

**Can I download and run TradeOps?**
No. This repo is the operating design: the roster, the contract, the architecture, and templates. The private system holds account data, levels and credentials, and it's wired to my own data subscriptions. The pattern is the useful part, and it ports to any agent platform.

**Why can't any agent place a trade?**
Because the order is the one irreversible step. Agents are very good at preparing and very bad at knowing when they're wrong. So they prepare everything up to the order, and the human fires it. The broker connector can only create drafts. See [CONTRACT.md](../CONTRACT.md) §1.

**Isn't that just "human in the loop"?**
Partly. The difference is *where* the human sits and what the agents must do before reaching them. A setup reaches the human only after an observable arm condition, a locked prediction and a Red Team Pass. The human makes three decisions (approve the plan, fire the order, change capital or risk) and nothing else is waiting on them.

**Why a dedicated "no" agent?**
A desk of agents that all want to be helpful will talk itself into trades. Red Team's only job is to look for the reason not to, and it can only answer Pass or Fail. A Fail stops everything downstream. It doesn't see how the trade was pitched, only the setup and the lessons from past misses.

**What platform does it run on?**
Grok Bot today, with eleven agents under a chief-of-staff agent. It started on Claude and moved over; the design docs carried across almost unchanged. State lives in Postgres (Supabase), the dashboard is a static site on Vercel, alerts come from a TradingView indicator, and notifications go to Telegram. Full list: [CONNECTORS.md](CONNECTORS.md).

**Does it make money?**
That's not what this repo claims, and I don't publish returns. What it claims is narrower: every trade is graded against a prediction locked before entry, and misses become rules the desk has to read. That's measurable and honest. P&L over a few months is mostly noise.

**What went wrong?**
Plenty. At one point six of eleven weekly plans ran without my approval. Every bug in six months had the same root: something failed silently. The full list is in [WHAT-BROKE.md](WHAT-BROKE.md).

**Why not let a model decide when a price level is hit?**
Because a price check doesn't need judgement. The TradingView indicator fires alerts on fixed levels and a small function updates the database. Models do analysis; code does anything that has to be exactly right.

**Does this work outside trading?**
Yes. Any desk where agents prepare a decision and a person commits it: due diligence, procurement, underwriting, hiring, compliance review. See [BEYOND-TRADING.md](BEYOND-TRADING.md).

**Where do I start?**
1. Name the one irreversible action on your desk and make it human-only.
2. Put one database at the centre and make agents write to it, not to each other.
3. Add a Pass/Fail agent before anything reaches the human.
4. Lock predictions before acting. Use [`templates/schema.sql`](../templates/schema.sql) to enforce it in the database.

**Is this financial advice?**
No. See [DISCLAIMER.md](../DISCLAIMER.md).
