# CONTRACT.md: the hard rules for all 11 agents

These are non-negotiable. Breaking one is a blocker, not a style note. The contract is what turns eleven capable models into a desk you can trust while you sleep.

> **The one-line version:** agents research, score, challenge and draft. A human confirms the plan and fires every live order.

---

## 1. Three decisions stay human. Everything else runs.

| Gate | Agents can | Agents can't |
|------|-----------|--------------|
| **01 · Approve the weekly plan** | Build it, research it, score every setup | Approve it. The planner is forbidden from approving its own work. No approval means no premarket run. |
| **02 · Fire a live order** | Arm a setup after a Red Team Pass, and stage a sized draft order at the broker | Send it. Ever. |
| **03 · Change capital or risk** | Read the limits and size positions inside them | Touch position sizing, max risk or the weekly circuit breaker |

Also human-only: turning on unattended schedules (the weekend BUILD stays paused until the human enables it) and editing this file.

![Human gates](images/06-human-gates.png)

## 2. Kill gates on a setup (binary, no scoring around them)

Any of these kills a setup no matter how good its score is:

- Reward-to-risk to the first target is **below 2:1**
- The week's game plan forbids that direction
- An earnings or event date clashes with the trade window
- **Red Team returns Fail** on the arm path

Gates are not points. A high score can't outweigh a failed gate.

## 3. The arm path (Watch → Armed)

A setup only becomes tradeable through this exact sequence:

1. **Scout or Sentinel** sees the arm condition met and **reports to the chief of staff**. It never arms on its own.
2. **Chief of staff** checks that past lessons for the name were read and that a prediction is **locked** (see section 4).
3. **Red Team** is dispatched one-to-one and returns **Pass or Fail**. Nothing else is allowed. "Conditional" is not an answer.
4. **Only on Pass** does the chief of staff write `armed`.
5. **Quartermaster** may then stage a broker draft. **The human fires it.**

A Fail blocks the arm *and* the order staging. The verdict summary is posted to the Floor.

### Intraday ALERTs

During market hours, any ALERT or possible entry from Scout **automatically** triggers a Red Team Pass/Fail. Nothing else is triggered: no extra analysts and no re-scans mid-session. Catch-up runs must not trigger Red Team again for an ALERT it has already ruled on. The human is notified either way.

## 4. Predictions are locked before entry

![Prediction loop](images/05-prediction-loop.png)

| Rule | Detail |
|------|--------|
| **Preregister** | Before a setup arms, write a concrete expected outcome: price, structure and time. No vibes. |
| **Immutable** | Once written, it's frozen at the database level. No editing after the fact. |
| **Grade against the claim** | Coach grades the result as HIT / MISS / PARTIAL / VOID against what was predicted, not what happened to work out. |
| **Lessons are mandatory reading** | A real miss becomes a lesson. The planner reads lessons before every BUILD, and Red Team reads them before every verdict. |
| **Archive, don't delete** | Retire a lesson by marking it inactive. History stays. |

## 5. Every price level is a concrete, observable event

- Every watching setup carries one **arm condition** stated as something you can see happen, for example "4H close holding above 33.75". "Wait for confirmation" doesn't count.
- Levels on **open positions are frozen**. Only their status changes.
- A stale arm condition is worse than none, so refresh it whenever the picture changes.

## 6. Communication

| Rule | Detail |
|------|--------|
| **No silent finishes** | Every agent posts a compact finish line to the Floor: `[Agent] [mode] status · deltas · blocker`. |
| **The Floor is not a trigger** | Posting in the shared room does not start analysis on its own. Work starts from the schedule or the chief of staff. |
| **One phone notification per run** | Each run sends one summary to the human's phone, after the data sync. Never a burst. |
| **Confirm delivery** | "Sent" means the notification shows as delivered, not that the insert succeeded. |

## 7. Data and tooling discipline

- **One owner per rate-limited source.** The Options agent owns the options-data queue so nobody else blows the budget.
- **Cheap models gate, strong models think.** Low-cost models may classify, gate and verify. They don't write the plan or do the risk math.
- **The database is the system of record.** The dashboard reads it live. If it isn't in the database, it didn't happen.
- **Failures must be visible.** A failed data pull is logged and reported, never swallowed. Every bug we hit came down to a silent failure (see [docs/WHAT-BROKE.md](docs/WHAT-BROKE.md)).
- **Clean up after yourself.** When a newer research pack replaces an older one, delete the old one.

## 8. What no agent will ever do

- Place, modify or cancel a live order
- Confirm a weekly plan
- Arm a setup without a Red Team Pass
- Edit a locked prediction
- Touch the levels of an open position
- Treat a vague condition as an arm trigger

---

*To adapt this for your own desk, copy [templates/CONTRACT.template.md](templates/CONTRACT.template.md).*
