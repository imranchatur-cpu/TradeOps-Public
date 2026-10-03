# The AI concepts behind TradeOps

TradeOps wasn't designed from trading theory. Most of its rules exist because of how AI agents behave, and each rule answers a specific, named problem. This page maps those concepts to the part of the desk they shaped.

Term names and definitions follow Matt Pocock's **[Dictionary of AI Coding](https://github.com/mattpocock/dictionary-of-ai-coding)** ([aicodingdictionary.com](https://www.aicodingdictionary.com/)). Each term links to its entry there for the full definition. The explanations below are mine and describe how TradeOps applies the idea. No text from the dictionary is reproduced.

---

## 1. What the model can't be trusted with

| Concept | The problem in one line | How TradeOps answers it |
|---------|------------------------|-------------------------|
| [Non-determinism](https://github.com/mattpocock/dictionary-of-ai-coding#non-determinism) | The same question can get a different answer. | Anything that must be exact (score maths, zone arithmetic, status changes, alert firing) is code or a database constraint, never a prompt. See the three planes in [ARCHITECTURE.md](ARCHITECTURE.md#2-the-three-planes). |
| [Hallucination](https://github.com/mattpocock/dictionary-of-ai-coding#hallucination) | Confident output that isn't true. | Levels come from live data pulls and deterministic zone maths, and a failed pull is reported as missing, never filled in. ([CONTRACT.md](../CONTRACT.md) §7, [CONNECTORS.md](CONNECTORS.md#rules-every-connector-follows) rule 3) |
| [Sycophancy](https://github.com/mattpocock/dictionary-of-ai-coding#sycophancy) | Models lean towards agreeing with you. | The reason Red Team exists. A desk of helpful agents talks itself into trades, so one agent's only job is to find the reason not to, and it can only say Pass or Fail. |
| [Parametric knowledge](https://github.com/mattpocock/dictionary-of-ai-coding#parametric-knowledge) / [Knowledge cutoff](https://github.com/mattpocock/dictionary-of-ai-coding#knowledge-cutoff) | What the model "remembers" from training is stale for markets. | Agents work only from [contextual knowledge](https://github.com/mattpocock/dictionary-of-ai-coding#contextual-knowledge) pulled fresh each run: quotes, structure, options, news. |
| [Stateless](https://github.com/mattpocock/dictionary-of-ai-coding#stateless) | Nothing carries over between sessions unless it's written down. | The database is the memory. Plans, setups, predictions and lessons are rows that every run reads back. |

## 2. How agents are wired

| Concept | How TradeOps applies it |
|---------|-------------------------|
| [Agent](https://github.com/mattpocock/dictionary-of-ai-coding#agent) | Eleven of them, each with one job and a may / may-not card ([ROSTER.md](../ROSTER.md)). |
| [Harness](https://github.com/mattpocock/dictionary-of-ai-coding#harness) | Grok Bot today, Claude before it. The design moved across almost unchanged because the rules live in docs and the database, not in one harness's settings. |
| [Subagent](https://github.com/mattpocock/dictionary-of-ai-coding#subagent) | Wolf, the chief of staff, dispatches specialists (Cartographer, Options, Red Team) with a narrow brief, and only their result comes back. |
| [Tool](https://github.com/mattpocock/dictionary-of-ai-coding#tool) / [MCP](https://github.com/mattpocock/dictionary-of-ai-coding#mcp) | Every data source and the broker are MCP connectors. Each gets the least access it needs ([CONNECTORS.md](CONNECTORS.md)). |
| [Permission mode](https://github.com/mattpocock/dictionary-of-ai-coding#permission-mode) | Set by connector, not by trust in the agent. The broker connector can draft but not send. The dashboard key can read but not write. |
| [Skill](https://github.com/mattpocock/dictionary-of-ai-coding#skill) | The weekly trading-plan procedure (BUILD, UPDATE, CONFIRM) is one skill file that any agent running a plan follows. |

## 3. Keeping agents sharp

| Concept | How TradeOps applies it |
|---------|-------------------------|
| [Smart zone](https://github.com/mattpocock/dictionary-of-ai-coding#smart-zone) / [Attention degradation](https://github.com/mattpocock/dictionary-of-ai-coding#attention-degradation) | Long runs get sloppy. So work is split into short, scheduled runs (03:35 ingest, 04:00 UPDATE, hourly Scout) instead of one session that runs all day. |
| [Progressive disclosure](https://github.com/mattpocock/dictionary-of-ai-coding#progressive-disclosure) | Agents start from a one-page map and a read order, not the whole manual. The full skill is loaded only when a run actually needs it. |
| [Context pointer](https://github.com/mattpocock/dictionary-of-ai-coding#context-pointer) | The map says what each doc is for ("hard gates → CONTRACT", "score maths → SCORE"), so an agent knows when it's worth opening. |
| [AGENTS.md](https://github.com/mattpocock/dictionary-of-ai-coding#agentsmd) | The always-loaded layer: a short map plus [CONTRACT.md](../CONTRACT.md) as a standing instruction for every agent. |
| [Memory system](https://github.com/mattpocock/dictionary-of-ai-coding#memory-system) | The lessons table. Coach writes lessons, and the planner and Red Team must read the active ones. Old lessons are archived, not deleted, so stale beliefs don't keep loading. ([PREDICTION-LOG.md](PREDICTION-LOG.md)) |

## 4. Passing work between runs

| Concept | How TradeOps applies it |
|---------|-------------------------|
| [Handoff](https://github.com/mattpocock/dictionary-of-ai-coding#handoff) / [Handoff artifact](https://github.com/mattpocock/dictionary-of-ai-coding#handoff-artifact) | Agents don't hand off through chat. Every run ends by writing rows (the plan, the setups, the arm condition) and one status line on the Floor. The next run starts from those. |
| [Spec](https://github.com/mattpocock/dictionary-of-ai-coding#spec) | Every setup card is a small spec: entry, stop, targets, and an `arm_condition` written as an observable event, never "wait for confirmation". |
| [Primary source](https://github.com/mattpocock/dictionary-of-ai-coding#primary-source) / [Secondary source](https://github.com/mattpocock/dictionary-of-ai-coding#secondary-source) | Levels are checked against live data (primary), not against yesterday's plan (secondary). When they disagree, live data wins and the plan is updated. |

## 5. Where the human sits

| Concept | How TradeOps applies it |
|---------|-------------------------|
| [Human-in-the-loop](https://github.com/mattpocock/dictionary-of-ai-coding#human-in-the-loop) | Exactly three decisions: approve the plan, fire the order, change capital or risk. Everything else runs without waiting. ([CONTRACT.md](../CONTRACT.md) §1) |
| [AFK](https://github.com/mattpocock/dictionary-of-ai-coding#afk) | The overnight and premarket runs happen while I'm asleep. Ambiguity is settled up front instead: the plan is approved before any weekday run is allowed to start. |
| [Software factory](https://github.com/mattpocock/dictionary-of-ai-coding#software-factory) | Schedules and alerts start the runs, not me. That's what lets a desk run from 03:35. |
| [Dark factory](https://github.com/mattpocock/dictionary-of-ai-coding#dark-factory) | What TradeOps refuses to be. Nothing reaches money without a human reading it, and the one time plans ran without approval (6 of 11 weeks) is written up as a failure in [WHAT-BROKE.md](WHAT-BROKE.md). |
| [Automated check](https://github.com/mattpocock/dictionary-of-ai-coding#automated-check) | The database's constraints and triggers: nothing arms without a Pass, a locked prediction and reward-to-risk of at least 2:1, and a locked prediction can't be edited ([schema.sql](../templates/schema.sql)). |
| [Automated review](https://github.com/mattpocock/dictionary-of-ai-coding#automated-review) | Red Team. It reviews with a fresh context: it gets the setup and the lessons, never the pitch, so it isn't reading the planner's reasoning back as proof. |
| [Human review](https://github.com/mattpocock/dictionary-of-ai-coding#human-review) | Kept for the step that can't be undone: the order. And it runs both ways: trades the human takes outside a Pass are tagged as overrides, and the human explains each one on Saturday. |

---

## The short version

> Agents are non-deterministic, agreeable and forgetful. So the desk puts maths in code, puts a "no" agent before every arm, puts memory in a database, keeps runs short, and keeps the one irreversible step human.

*Credit: concept names and linked definitions are from the [Dictionary of AI Coding](https://github.com/mattpocock/dictionary-of-ai-coding) by Matt Pocock. This page is independent commentary and is not affiliated with or endorsed by the author.*
