# CONTRACT.md: the hard rules for all 11 agents

Public design, refreshed 2026-10-11. Agents research, challenge and draft. A human approves
the plan and submits every live order. Private data and operational identifiers are excluded.

## 1. Human gates

| Gate | Agents can | Agents cannot |
|---|---|---|
| Approve the plan | Research, draft, score | Approve their own work |
| Submit an order | Stage a reviewable broker instruction after a Pass and arm | Place, modify or cancel a live order |
| Change capital or risk | Read limits, size within them | Change limits or grant themselves a waiver |

Enabling unattended schedules and changing these rules require human authorization.
The weekend BUILD remains paused until enabled. A plan must be approved before premarket UPDATE.

## 2. Kill gates

- Reward-to-risk to the first target must be at least 2:1 at the **planned limit**, not live price.
- Code checks entry-zone math, far-edge stop distance, risk cap, target and earnings window.
  A risk-cap waiver is a recorded human decision for one setup, never a blanket exception.
- The score threshold applies at BUILD; Red Team does not re-score at arm time.
- The game plan cannot forbid the direction or conflict with the holding window.
- Missing required data is a blocker. Code may write a Fail, never a Pass, Wait or arm.

No score can compensate for a hard failure. Tier A pilot entries stay separately identified,
require explicit human permission to arm, and are reported separately from main results.

## 3. The arm path (Watch → Armed)

1. Lock a concrete prediction at BUILD/UPDATE, before a price-triggered review.
2. Code checks fresh data, market/plan gates and numeric constraints before a model wake.
3. Scout supplies an evidence package; entry events can go directly to a Red Team-owned routine.
4. Red Team attacks the thesis using fresh structure, news, options, context and past lessons.
5. Only after **Pass** may Wolf write `armed`; the database still checks the numeric/prediction gates.
6. Quartermaster stages the planned-limit broker instruction. **The human reviews and submits.**

| Verdict | Meaning | Consequence |
|---|---|---|
| Pass | Fresh evidence does not break the thesis and code gates permit it | Wolf may arm; no automatic live order |
| Wait | One specific near-term print or named condition remains unresolved | No arm; a due recheck must pass fresh-data/session gates |
| Fail | A decisive contradiction or hard blocker breaks the setup | No arm or staging; repeat Fails do not produce repeated analysis/messages |

Red Team writes its strongest opposing case with evidence, not a confirmation of arithmetic.
"Conditional Pass" is forbidden. A standing same-day Fail on unchanged levels is not re-woken
unless its recorded unblock condition is met. Re-cutting levels clears the old verdict.
Open-position stop risk goes to the human, not to the entry thesis review.

### Between-slot monitoring and delivery

Fresh price inside the zone, or a one-minute close inside it during the last five minutes,
can qualify for an entry wake. A wick alone does not. The approach band can qualify for
a pre-entry review. A missing prediction stops the path; no bot invents one at entry.

Scanners cover all eligible tickers with bounded provider concurrency. Tape older than
120 seconds or unavailable is skipped with a code-owned health alert, not a model wake.
Daily indicators exclude the incomplete session; cached daily bars do not refresh quote time.

Webhook senders claim stable event keys before POSTing. Receivers claim the same key before
analysis and record completion. Definite rejection has bounded retries; timeout or expired
ownership is uncertain and requires evidenced reconciliation, never blind replay. Acceptance
by the transport is not proof that a bot finished. These controls do not guarantee exactly-once effects.

## 4. Predictions and grades preserve the original claim

Write an observable price/structure event, invalidation and time window before review.
The current claim changes only with an explicit level re-cut and a new claim in the same update;
the previous claim remains in history. Predictions on active trades remain locked.

Red Team decisions preserve an immutable snapshot of the thesis and levels. Coach grades the
matching revision, never an old decision against the current card. Legacy unversioned evidence
is context and is excluded from accuracy. Grades are HIT / PARTIAL / MISS / VOID; a profitable
MISS stays a MISS. Archive lessons rather than deleting them, and read active lessons at BUILD/review.

## 5. Observable levels and human overrides

Arm conditions name an observable event and timeframe. Refresh non-active setups with a recorded
keep/re-anchor/cool-off/radar decision. Open-position levels remain frozen. A human trade outside
the system path is tagged `override`; Coach reviews it and Wolf asks why. It is not hidden from grading.

## 6. Communication and context

Wolf and Quartermaster are the intended Floor seats. Workers record compact finishes in the
database; Wolf relays actionable items. An actual Floor post is mirrored. No acknowledgement-only
posts or repeated Fail DMs. Code handles quiet slots without waking a model; gated runs may end silently.
The Floor itself is not an analysis trigger. Each meaningful run produces one compact phone summary.

Recurring wakes read shared core plus one role card. Large playbooks/history are references opened
only when needed. Bounded evidence and script outputs replace repeated full-context reads.

## 7. Data and tooling discipline

One database is the system of record. Rate-limited sources have an owner and budget.
Cheap models classify typed questions; code owns exact math and strong models own judgment.
Missing data is recorded, not guessed. Operational failures are visible without alert floods.
Quote freshness and each chart timeframe have independent timestamps. Chart reads preserve quote time.
Secrets stay in platform stores. Stored payload bytes are not measured model tokens or cost.

## 8. Deployment is separate from code

Apply schema dependencies before deploying functions; install receiver guards before enabling
senders. Verify overlapping schedules, prompts, chart loads, dry runs and one controlled event.
A merge does not prove database or bot activation. See [BUILD.md](docs/BUILD.md).

## 9. Never

Submit a live order · approve the plan · self-waive risk · arm without Pass · rewrite an old
decision snapshot · grade an old thesis with a new outcome · act on stale tape · blindly replay
unknown side effects · treat advisory bot text as human authorization.

Adapt this with [the contract template](templates/CONTRACT.template.md). The
[starter schema](templates/schema.sql) is illustrative and intentionally smaller than production.
