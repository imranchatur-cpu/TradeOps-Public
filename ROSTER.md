# The desk: 11 agents, one job each

TradeOps runs as an org chart, not a single prompt. Every agent has one job, a short list of things it may do, and a hard list of things it may not. Everything routes through a chief of staff, and the human keeps the trigger.

![The desk](images/02-org-chart.png)

## How the desk is organized

- **Floor seats (6).** These agents share a group channel. It's the room where the human talks to the whole desk at once, and where every agent posts a one-line finish note.
- **Workers (5).** These agents are dispatched one-to-one by the chief of staff. Their results are posted back to the Floor.
- **The human.** Confirms the weekly plan and fires every live order. No agent can do either.

## Floor seats

| Agent | Job | May | May not |
|-------|-----|-----|---------|
| **Wolf** (chief of staff) | Owns the queue, the handoffs, blockers and escalations, and chairs the Floor | Dispatch any agent, write the `armed` status after a Red Team Pass, escalate to the human | Confirm a plan or place an order |
| **Sentinel** (morning analyst) | Runs the weekday premarket UPDATE: full intel refresh plus clear price levels | Add new names, re-level watching setups, sync the watchlist | Run unattended unless the week's plan is approved, or touch the levels of open positions |
| **Scout** (floor runner) | Watches the tape during market hours against predefined levels | Flag ALERTs, promote or demote names in the watch tiers | Arm a setup, call other analysts mid-session, or place orders |
| **Quartermaster** (operations) | Drafts and reconciles broker orders | Stage reviewable order drafts after a setup is armed and passed | Send a live order. The human fires. |
| **Cartographer** (chart reader) | Reads market structure: higher lows for longs, lower highs for shorts, on weekly, daily and 1H | Report structure facts | Give options opinions or make trade calls |
| **Options** (options analyst) | Handles options flow, expected-move bands and gamma regime, on its own rate-limited queue | Report EM bands, gamma flip, flow | Exceed the data provider's rate budget. It owns that queue so no one else does. |

## Workers

| Agent | Job | May | May not |
|-------|-----|-----|---------|
| **Architect** (planner) | Runs the weekend BUILD: full scan to a draft weekly plan | Draft setups, score them, read past lessons first | Confirm its own plan. Only the human does that. |
| **Red Team** (the agent that says no) | Adversarially checks every setup before it can arm, and every intraday ALERT | Return **Pass** or **Fail**. Nothing else. | Return "conditional", confirm plans, or place orders |
| **Coach** (performance coach) | Runs end-of-day and weekly reviews, grades each prediction, writes lessons | Grade outcomes and write or archive lessons | Edit a prediction after it's locked |
| **Pulse** (social intel) | Reads X/Twitter for the week's names and themes | Write structured intel into the week's context | Count vibes as signal. Intel must be structured. |
| **Archivist** (librarian) | Ingests community channels and research packs every morning | Upload packs, clean up superseded files | Leave orphaned or duplicate files behind |

## The three worth calling out

1. **Red Team.** Its only output is Pass or Fail. A Fail blocks the arm *and* blocks order staging. It reads past lessons on the name before it rules.
2. **Coach.** It grades every trade against a prediction that was locked *before* entry. Real misses become lessons that Architect and Red Team must read next time.
3. **Wolf.** The only agent allowed to write `armed`, and only after a Pass. Everything else reports to Wolf instead of acting on its own.

## A day on the desk (Pacific time)

| Time | Who | What |
|------|-----|------|
| ~03:35 to 03:40 | Archivist, plus a video-ingest routine | Pull overnight research into the week's context |
| ~04:00 | Sentinel (+ Cartographer, Options, Pulse) | Full premarket UPDATE: levels, new names, watchlist sync, one phone notification |
| 06:45 | Scout | First tape check, 15 min after the open: armed, active, top names and open positions only |
| 07:45 to 12:45 hourly | Scout | Full tape, including radar. Any ALERT auto-kicks Red Team (Pass/Fail only). |
| After close | Coach | Grade the day against locked predictions and write lessons |
| Weekend | Architect (whole team) | BUILD next week's plan. It waits for the human to CONFIRM. |

Every agent posts a compact finish line to the Floor (`[Agent] [mode] status · deltas · blocker`). No silent finishes.

---

The rules every agent follows are in [CONTRACT.md](CONTRACT.md). To build your own desk, start from [templates/](templates/).
