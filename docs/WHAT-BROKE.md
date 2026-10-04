# What broke: six months of failures

![What broke](../images/07-what-broke.png)

| Area | What happened | Fix |
|------|---------------|-----|
| **Data** | Broker fills quietly went stale. It was the one job without a proper scheduler, and the dashboard stopped matching reality. | Every sync job runs on a schedule, with a timestamp you can see |
| **Notifications** | The update ran, but no Telegram arrived. The relay worked; the update never handed it anything to send. | Every run writes exactly one message and confirms delivery |
| **Stack** | I swapped the data provider, then n8n, then Claude. Each swap broke something downstream. | Built to be portable: database at the centre, agents swappable |
| **Code** | One JavaScript typo killed every dashboard button. A rule protecting live setups also froze old closed ones. | Audit log and error handling on every job |

**Root cause:** silent failure. Every fix made a failure visible.

## Caught the week this went public

The same pattern turned up again while redesigning the dashboard.

| Area | What happened | Fix |
|------|---------------|-----|
| **Charts** | Every chart on the board was blank. Price data only arrived when the weekly plan ran, and when it didn't, the panel just said "no data". | Missing price data is fetched on demand, and a chart with no candles still draws its levels to scale |
| **Numbers** | The week's result showed zero after a winning close. The summary only refreshed after the end-of-day grade. | The headline number is computed from the closed trades themselves |
| **Deploys** | A dashboard release was blocked because the commit came from a work email the host didn't recognise. | One identity for every commit |

Two of the three were silent. The loud one, the blocked deploy, was found and fixed in minutes.

## Caught in the redesign review

Before publishing, the chief-of-staff agent reviewed the redesign line by line. It found three more of the same kind.

| Area | What happened | Fix |
|------|---------------|-----|
| **The arm rule** | The public schema refused to arm a setup without a Red Team Pass. The live database didn't: it checked reward-to-risk and the prediction, but not the verdict. A prompt was the only thing standing between a Fail and an armed trade. | The live trigger now requires `pass` too. A skipped step is an error. |
| **Weekly rebuild** | Each weekend BUILD deleted the week's setups and wrote them again, which quietly wiped their locked predictions, grades and evidence. | Setups are updated in place, never deleted and re-inserted. Dropped names are marked removed. |
| **Alert noise** | Every intraday alert called Red Team, including warnings about open trades near their stop. That's a decision about a live trade, not an arm. | Scout checks in stages. Only a name at entry reaches Red Team; stop warnings go straight to the human. |

Same root cause again: nothing errored, so nothing looked wrong.

## Caught in the instant-wake review

Adding the 5-minute wake, the chief-of-staff agent reviewed the change before it went live. Two more of the same kind.

| Area | What happened | Fix |
|------|---------------|-----|
| **Predictions** | When a name reached entry with no prediction on record, the first draft had the wake routine write one on the spot. That passes the arm rule without predicting anything. | No locked prediction means no Red Team. The routine stops and tells the human. |
| **Retries** | A setup was marked "at entry" before its wake was confirmed. If the wake failed, the 5-minute check saw the name as already handled and never tried again. | A setup is marked only once its wake is delivered. A failed wake sends one ops alert a day, and the next hourly slot picks the name up. |

Same root cause: both would have failed quietly.
