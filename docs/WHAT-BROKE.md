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
