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
| **Sentinel** (morning analyst) | Runs the weekday premarket UPDATE: full intel refresh plus clear price levels. Re-checks every watching setup instead of dropping it. | Add new names, re-level watching setups (keep, re-anchor, cool off, or move to radar, with the reason logged), save a premarket options snapshot, sync the watchlist | Run unattended unless the week's plan is approved, or touch the levels of open positions |
| **Scout** (floor runner) | Watches the tape during market hours in three stages: **far** from entry (cheap checks), **approaching** (adds options and news), **at entry** (adds a count of rejections at the level) | Send an evidence package to the chief of staff when a name reaches entry; warn the human directly when an open position nears its stop | Arm a setup, call Red Team itself, or place orders |
| **Quartermaster** (operations) | Drafts and reconciles broker orders | Stage reviewable order drafts after a setup is armed and passed | Send a live order. The human fires. |
| **Cartographer** (chart reader) | Reads market structure: higher lows for longs, lower highs for shorts, on weekly, daily and 1H | Report structure facts | Give options opinions or make trade calls |
| **Options** (options analyst) | Handles options flow, expected-move bands and gamma regime, on its own rate-limited queue | Report EM bands, gamma flip, flow | Exceed the data provider's rate budget. It owns that queue so no one else does. |

## Workers

| Agent | Job | May | May not |
|-------|-----|-----|---------|
| **Architect** (planner) | Runs the weekend BUILD: reads how last week went, archives it, then scans to a draft weekly plan | Draft setups, score them against a bar that moves with market conditions, size them by condition, read past lessons first | Confirm its own plan. Only the human does that. |
| **Red Team** (the agent that says no) | Runs a 7-point go / no-go on every setup at the moment it would arm | Return **Pass** or **Fail**. Nothing else. One failed check is a Fail. | Return "conditional", confirm plans, or place orders |
| **Coach** (performance coach) | Runs end-of-day and weekly reviews, grades each prediction, writes lessons, and lists every trade the human took outside a Pass | Grade outcomes, write or archive lessons, check recorded trades against the broker | Edit a prediction after it's locked |
| **Pulse** (social intel) | Reads X/Twitter for the week's names and themes | Write structured intel into the week's context | Count vibes as signal. Intel must be structured. |
| **Archivist** (librarian) | Ingests community channels and research packs every morning, and archives each finished week | Upload packs, clean up superseded files, archive last week before the new BUILD | Leave orphaned or duplicate files behind |

## The three worth calling out

1. **Red Team.** Its only output is Pass or Fail, from a fixed 7-point checklist (see [CONTRACT.md](CONTRACT.md) §3). A Fail blocks the arm *and* blocks order staging. It reads past lessons on the name before it rules.
2. **Coach.** It grades every trade against a prediction that was locked *before* entry. Real misses become lessons that Architect and Red Team must read next time. It also grades the human: every trade taken outside a Pass is tagged as an override, and on Saturday the human is asked why.
3. **Wolf.** The only agent allowed to write `armed`, and only after a Pass. Everything else reports to Wolf instead of acting on its own.

## A day on the desk (Pacific time)

| Time | Who | What |
|------|-----|------|
| ~03:35 to 03:40 | Archivist, plus a video-ingest routine | Pull overnight research into the week's context |
| ~04:00 | Sentinel (+ Cartographer, Options, Pulse) | Full premarket UPDATE: levels, new names, watchlist sync, one phone notification |
| 06:45 to 12:45 hourly | Scout | Staged tape checks: far → approaching → at entry. A name at entry goes to Wolf with its evidence; Wolf checks the prediction is locked and calls Red Team (Pass/Fail only). Stop-risk warnings go straight to the human. |
| After close | Coach | Grade the day against locked predictions and write lessons |
| Saturday | Coach, then Wolf | Weekly grade. Wolf asks the human "why" for each override trade; the answers go back to Coach. |
| Weekend | Archivist, then Architect (whole team) | Archive last week, then BUILD next week's plan. It waits for the human to CONFIRM. |

Every agent posts a compact finish line to the Floor (`[Agent] [mode] status · deltas · blocker`). No silent finishes.

---

The rules every agent follows are in [CONTRACT.md](CONTRACT.md). To build your own desk, start from [templates/](templates/).
