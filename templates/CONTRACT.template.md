# CONTRACT.md: <your desk name>

> Copy this file and fill in the `<…>` blanks. Keep it short; agents follow short rules.
> The rule of thumb: **agents prepare, humans commit.**

## 1. Human gates

| Gate | Agents can | Agents can't |
|------|-----------|--------------|
| **01 · <Approve the plan / brief / budget>** | <draft, research, score> | <approve their own work> |
| **02 · <The irreversible action: send, sign, pay, file, order>** | <stage a reviewable draft> | <execute it. Ever.> |
| **03 · <Change limits: capital, risk, authority>** | <read limits, work inside them> | <change them> |

## 2. Kill gates (binary, no scoring around them)

- <Hard threshold, e.g. "reward-to-risk < 2:1", "margin < X%", "vendor not on approved list">
- <Policy conflict, e.g. "this quarter's plan forbids this">
- <Date/event clash>
- **Red Team returns Fail**

## 3. The promotion path (<idea> → <ready to act>)

1. <Detector agent> sees the condition met and **reports to <chief of staff>**. It never promotes on its own.
2. <Chief of staff> confirms that lessons were read and a prediction is locked.
3. **Red Team** returns **Pass, Wait or Fail** from an evidence-backed thesis challenge. Wait names a specific unresolved condition and blocks promotion; "Conditional Pass" is not allowed. Put deterministic checks in code.
4. On **Pass only**, <chief of staff> writes the new status.
5. <Ops agent> stages the draft. **A human executes.**

## 4. Predictions are locked first

- Before acting, write a concrete expected outcome (number, condition, date).
- Preserve an immutable decision snapshot. An explicit new revision keeps the old one; grade HIT / MISS / PARTIAL / VOID against the matching claim, never the current rewritten item.
- Misses become lessons, which <planner> and Red Team must read before their next call.

## 5. Human overrides

- The human can act outside the path. It's tagged `override`, never blocked.
- <Reviewer agent> lists every override each <week> and the human records why. The answers are graded like any other claim.

## 6. Communication

- Workers record a one-line database finish; <chief of staff> relays actionable work. Code-gated no-work runs may end silently. Finish: `[Agent] [mode] status · deltas · blocker`. No silent finishes.
- One summary notification to the human per run, with delivery confirmed.

## 7. Data discipline

- <One owner per rate-limited source>
- The <database / system of record> is the truth. If it isn't there, it didn't happen.
- Failures are logged and reported, never swallowed. Stale/unavailable required data blocks action.
- Claim stable event keys at sender and receiver; record completion. Bound definite retries and reconcile uncertain effects before replay.
- Recurring runs read a small shared core and role card; references load only as needed.
- Enforce the promotion rule in the database where you can, so a skipped step is an error, not a quiet success.

## 8. Never

- <Execute the irreversible action>
- <Approve a plan>
- <Promote without a Red Team Pass>
- <Edit a locked prediction>
