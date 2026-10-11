# TradeOps: an AI trading desk where no agent can place a trade

![TradeOps](images/cover.png)

**11 AI agents run my trading desk overnight. None of them can place a trade.**

This is the public pack behind the Lift Off article [*I Gave 11 AI Agents My Trading Desk. None of Them Can Place a Trade.*](https://liftoffai.substack.com). It contains the agent roster, the hard rules every agent follows, and templates to build the same pattern for your own desk, trading or not.

**Public build refresh: 2026-10-11.** Current design: thesis-attack Red Team, code-gated wakes, durable delivery, independent chart freshness and revision-based grading. See [BUILD.md](docs/BUILD.md) for changes, publishing rules and deployment limits.

> Not financial advice. Nothing here places trades. See [DISCLAIMER.md](DISCLAIMER.md).

---

## What's inside

| File | What it is |
|------|------------|
| [**ROSTER.md**](ROSTER.md) | The 11 agents: one job each, what each may and may not do, and a day on the desk |
| [**CONTRACT.md**](CONTRACT.md) | The hard rules: human gates, kill gates, the arm path, locked predictions |
| [docs/BUILD.md](docs/BUILD.md) | Current build, activation limits and public publishing boundary |
| [**DESK-pack.pdf**](DESK-pack.pdf) | Both of the above on two shareable pages |
| [templates/](templates/) | Blank `CONTRACT`, `ROSTER` and agent-card templates to adapt |
| [docs/WHAT-BROKE.md](docs/WHAT-BROKE.md) | Six months of failures, plus what the redesign review caught, and the single pattern behind them |
| [docs/BEYOND-TRADING.md](docs/BEYOND-TRADING.md) | The same design mapped to due diligence, procurement, underwriting and more |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | How it's wired: system, planes, arm path, data model, setup lifecycle (Mermaid diagrams) |
| [docs/CONNECTORS.md](docs/CONNECTORS.md) | Every MCP connector and data source, who uses it, and how far it's trusted |
| [docs/CADENCE.md](docs/CADENCE.md) | Who runs when, from 03:35 PT to the weekend BUILD |
| [docs/PREDICTION-LOG.md](docs/PREDICTION-LOG.md) | How predictions are written, locked, graded and turned into lessons |
| [docs/CONCEPTS.md](docs/CONCEPTS.md) | The AI concepts behind the design (sycophancy, statelessness, handoffs, human-in-the-loop) and the rule each one produced |
| [docs/FAQ.md](docs/FAQ.md) | Common questions, including "can I run it?" and "does it make money?" |
| [templates/schema.sql](templates/schema.sql) | Starter Postgres schema that enforces the contract in the database |
| [images/](images/) | The diagrams from the article |

## The design

Agents research and challenge. Code owns exact math, freshness and scheduling gates. The database
preserves decisions and outcomes. Humans approve plans and submit live orders.

Current diagrams: [ARCHITECTURE](docs/ARCHITECTURE.md). The original [article illustrations](images/)
remain historical assets; they may show older seats, routes or binary verdicts.

## How it's wired

```mermaid
flowchart LR
    IN["Market data · social · video<br/>research packs · web"] --> DESK["11 agents<br/>(Grok Bot)"]
    DESK <--> DB[("Postgres<br/>system of record")]
    DB --> DASH["Dashboard"] & TG["Telegram"]
    TV["TradingView alerts"] --> DB
    YF["Yahoo Finance<br/>5-min price check"] -->|"fresh-data gates + durable Red Team / Scout wakes"| DESK
    DESK -.->|"draft only"| BR["Broker"]
    H(("Human")) ==>|"approve plan"| DB
    H ==>|"fire order"| BR
    DASH & TG --> H
```

Thick arrows are human-only. Full diagrams: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). Every tool and source: [docs/CONNECTORS.md](docs/CONNECTORS.md).

## The principles

1. **Agents prepare, humans commit.** Three decisions stay human: approving the plan, firing an order, and changing capital or risk.
2. **One job per agent.** If an agent's card doesn't fit in five lines, split the agent.
3. **A dedicated "no" agent.** Red Team attacks the thesis and returns Pass, Wait or Fail. Wait and Fail both block arming; code owns numeric gates.
4. **Lock the prediction before acting.** Grade the outcome against the recorded claim and revision, never a rewritten current card. The human's own overrides get graded too.
5. **Enforce the rules in the database, not just the prompt.** Nothing can be written `armed` without a Pass, a locked prediction and 2:1 reward-to-risk.
6. **Make failure loud.** Every bug in six months was a silent failure.

## Build your own

1. Copy [`templates/ROSTER.template.md`](templates/ROSTER.template.md) and name your agents.
2. Write one [`AGENT.template.md`](templates/AGENT.template.md) card per agent.
3. Fill in [`CONTRACT.template.md`](templates/CONTRACT.template.md). Start with the irreversible action and make it human-only.
4. Give each agent a short shared core and role card; keep the full contract as an authoritative reference. Use a database as the system of record. [`templates/schema.sql`](templates/schema.sql) is a starting point that enforces the hard rules in the database.

The pattern is model- and platform-agnostic. TradeOps currently runs on Grok Bot, with a Postgres database, a live dashboard, Yahoo Finance prices, TradingView alerts and Telegram notifications.

## What's not here

This is the operating design, not the private system. Plans, positions, levels, account data, credentials and internal identifiers are intentionally left out.

## Follow along

- Newsletter: **Lift Off** at [liftoffai.substack.com](https://liftoffai.substack.com)
- Author: Imran Chatur, Lift Consulting Ltd. (British Columbia, Canada)

## License

Docs, templates and images: [CC BY 4.0](LICENSE). Use and adapt freely with attribution to *Imran Chatur / Lift Off*.
