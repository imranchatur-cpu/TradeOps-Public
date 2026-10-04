# Architecture

How TradeOps is wired: who thinks, where state lives, and where the human sits. Every diagram is [Mermaid](https://mermaid.js.org), so it renders on GitHub and you can copy it into your own docs.

The short version: **agents read and write a database. A dashboard and your phone read the database. A broker sits behind a human.**

---

## 1. System overview

```mermaid
flowchart LR
    subgraph IN["Inputs (read-only)"]
        direction TB
        MKT["Market data<br/>quotes · OHLCV · structure<br/>options · EM · earnings"]
        SOC["Social intel<br/>X / Twitter"]
        VID["Video commentary<br/>YouTube transcripts"]
        PACK["Research packs<br/>zones · weekly report · EM levels"]
        WEB["Web search<br/>news · macro calendar"]
    end

    subgraph DESK["The desk: 11 agents on Grok Bot"]
        direction TB
        WOLF(["Wolf<br/>chief of staff"])
        PLAN["Planning<br/>Architect · Sentinel"]
        ANALYSTS["Analysts<br/>Cartographer · Options<br/>Pulse · Archivist"]
        RT{{"Red Team<br/>Pass | Fail"}}
        SCOUT["Scout<br/>market-hours tape"]
        COACH["Coach<br/>grades + lessons"]
        QM["Quartermaster<br/>order drafts"]
        WOLF --- PLAN & ANALYSTS & RT & SCOUT & COACH & QM
    end

    subgraph SOR["System of record: Postgres (Supabase)"]
        direction TB
        DB[("plans · setups · positions<br/>lessons · alerts · context<br/>floor_events · scout_wakes")]
        FILES[("file storage<br/>research packs")]
        FN["Edge functions<br/>tv-webhook · notify · bars<br/>scout-far (5-min price check)"]
        CRON["Scheduler<br/>pg_cron, every 5 min"]
    end

    subgraph OUT["Human surfaces"]
        direction TB
        DASH["Dashboard<br/>static site, live updates"]
        TG["Telegram<br/>phone push"]
        FLOOR["Floor<br/>agent group chat"]
        CC["Claude Code<br/>grok-floor mod (advisory)"]
    end

    HUMAN(("Human"))
    TV["TradingView<br/>indicator + alerts"]
    YF["Yahoo Finance<br/>prices + OHLC bars"]
    BROKER["Broker<br/>IBKR"]

    IN --> DESK
    DESK <-->|"read / write"| DB
    ANALYSTS --> FILES
    DB --> DASH
    DB -->|"notification row"| FN --> TG
    DESK --> FLOOR
    TV -->|"alert webhook"| FN --> DB
    CRON --> FN
    YF -->|"prices, bars"| FN
    FN -->|"wake: price reached entry"| SCOUT
    FLOOR -->|"mirrored rows"| DB
    DB -->|"floor_events"| CC
    QM -.->|"draft only"| BROKER
    DASH & TG & FLOOR & CC --> HUMAN
    HUMAN ==>|"CONFIRM plan"| DB
    HUMAN ==>|"fire order"| BROKER
    HUMAN ==>|"paste levels"| TV
```

**Read it like this:**

- Thin arrows are automated. **Thick arrows are human-only.** There are three, and they match the three human decisions in [CONTRACT.md](../CONTRACT.md).
- The dotted arrow is the closest any agent gets to money: Quartermaster can stage a *draft* order. It cannot send it.
- Agents never talk to the dashboard or the phone directly. They write a row, and the database does the rest. That gives one place to look when something goes wrong.
- Code does the watching. Yahoo Finance prices feed two functions: `bars` for the dashboard charts and `scout-far`, which checks every watching setup every 5 minutes and wakes Scout when price reaches an entry. No agent polls prices.
- The Floor (the agents' group chat) is mirrored row for row into `floor_events`, so the human can follow it from Claude Code. Notes posted from there are advisory; Wolf relays them, and they never count as a human gate.

---

## 2. The three planes

TradeOps separates **thinking**, **state** and **execution**, so a failure in one does not leak into the others.

```mermaid
flowchart TB
    subgraph P1["Intelligence plane: probabilistic"]
        A["11 Grok Bot agents<br/>read sources, draft plans,<br/>argue, grade"]
    end
    subgraph P2["State plane: deterministic"]
        B[("Postgres<br/>the only source of truth")]
        C["Row-level security<br/>agents write with a service role<br/>dashboard reads with an anon key"]
    end
    subgraph P3["Execution plane: deterministic + human"]
        D["TradingView indicator<br/>fires alerts on fixed levels"]
        E["Webhook function<br/>parses alert, updates status"]
        Y["5-min price check<br/>Yahoo Finance vs entry zones"]
        F["Broker<br/>human submits"]
    end
    A -->|"structured writes"| B
    B --> C
    D --> E --> B
    Y -->|"wake log"| B
    Y -.->|"wakes Scout"| A
    B -.->|"armed + Pass"| F
```

| Plane | What lives there | Can it be wrong? | What stops it |
|-------|------------------|------------------|---------------|
| Intelligence | Agents, prompts, skills | Yes, often | Red Team, kill gates, the human CONFIRM |
| State | Tables, constraints, triggers | Only if the schema is wrong | Check constraints, immutability triggers, guards on deleting live rows |
| Execution | Price alerts, webhook, 5-min price check, broker | Only on bad levels or a lagging feed | Levels are pasted by a human; orders are fired by a human; a wake only starts checks, it never arms |

The rule that falls out: **anything that has to be exactly right (maths, status changes, money) is code or a constraint, never a prompt.**

---

## 3. A week on the desk

```mermaid
flowchart LR
    B["BUILD<br/>weekend<br/>Architect + whole team"] --> G{"Human<br/>CONFIRM?"}
    G -->|"no"| B
    G -->|"yes: plan approved"| U["UPDATE<br/>~04:00 PT weekdays<br/>Sentinel + whole team"]
    U --> S2["Scout hourly<br/>06:45 → 12:45<br/>far → approaching → at entry"]
    S2 -->|"at entry"| W{"Wolf<br/>prediction locked?"}
    U --> PX["Price check<br/>every 5 min, 06:00 → 13:00<br/>Yahoo Finance"]
    PX -->|"reached entry zone"| WK["Instant wake<br/>Scout at-entry checks"]
    WK --> W
    W --> RT{{"Red Team<br/>Pass | Fail"}}
    S2 -->|"stop risk"| H(("Human"))
    S2 --> C["Coach<br/>after close"]
    C -->|"lessons"| U
    C -->|"Saturday weekly grade"| B
```

The full schedule is in [CADENCE.md](CADENCE.md).

---

## 4. The arm path

The most important sequence in the system. A setup goes from *watching* to *armed* only through this path, and nobody can skip a step.

```mermaid
sequenceDiagram
    autonumber
    participant SC as Scout / Sentinel
    participant W as Wolf
    participant DB as Database
    participant RT as Red Team
    participant QM as Quartermaster
    participant H as Human
    participant BR as Broker

    SC->>W: arm condition met + evidence package (rejections, options vs snapshot, news)
    Note over SC: never arms itself
    W->>DB: read active lessons for this symbol
    W->>DB: lock expected_outcome (immutable from here)
    W->>RT: verify, 1:1 (no pitch, only setup + lessons)
    RT-->>W: Pass or Fail (7-point checklist)
    alt Fail
        W->>DB: verdict = fail, stays watching
        W-->>H: Telegram names the failed check
    else Pass
        W->>DB: verdict = pass
        W->>DB: status = armed (trigger checks R:R, prediction, Pass)
        W->>QM: stage draft
        QM->>BR: create draft order (not sent)
        DB-->>H: Telegram + dashboard
        H->>BR: review and fire, or don't
    end
```

Two details that matter:

1. **The prediction is locked at step 3, before Red Team sees anything.** A database trigger rejects any later edit, so the grade at the end is against what was actually claimed.
2. **Red Team gets the setup, the evidence and the lessons, not the argument for it.** It judges the trade fresh.
3. **The database has the last word.** The `armed` write fails unless reward-to-risk is at least 2:1, the prediction is locked and the verdict is `pass`.

---

## 5. Instant wake: price reaches a level between Scout's slots

Scout's hourly slots would miss a name that dips into its zone at 08:10 and leaves by 08:40. So a deterministic check watches prices and wakes the agents only when it matters.

```mermaid
sequenceDiagram
    autonumber
    participant CR as Scheduler (every 5 min)
    participant FN as scout-far function
    participant YF as Yahoo Finance
    participant DB as Database
    participant RT as Wake routine (Scout → Wolf → Red Team)
    participant H as Human

    CR->>FN: run (weekdays 06:00–13:00 PT)
    FN->>DB: read watching setups (zone, stop, T1, prediction locked?)
    FN->>YF: live price + 1-minute bars since the last check
    alt price reached the entry zone
        FN->>DB: claim wake (once per setup per stage per hour)
        FN->>RT: webhook: setup, price, zone, prediction_locked
        alt no locked prediction
            RT-->>H: "at entry but no prediction locked, not sent to Red Team"
        else prediction locked
            RT->>RT: Scout at-entry checks → evidence package
            RT->>DB: Red Team Pass | Fail (armed only on Pass, DB checks)
            RT-->>H: Telegram verdict
        end
        FN->>DB: wake sent / failed
    else within reach (1.5 × daily ATR)
        FN->>DB: proximity = approaching (hourly slot checks it)
    end
    Note over FN,DB: A failed wake sends one ops alert a day,<br/>and the next hourly slot treats the name as at entry
```

| Rule | Why |
|------|-----|
| A TradingView ENTRY / IN ZONE alert reaches the same routine | Alerts are set by hand, so most names don't have one. Yahoo is the main path; alerts are a bonus. Both share one hourly dedupe. |
| Price has to *reach* the zone, judged on 1-minute bars | Entry zones are tight. A quick dip and bounce between two checks still counts. |
| A setup is marked at entry only once its wake was delivered | Otherwise a failed wake would never be retried. |
| It's inert until its secrets are set | The scheduler makes no call, the function skips quietly, and the TradingView path skips the wake. Safe to deploy first and switch on later. |

---

## 6. The prediction loop

```mermaid
flowchart LR
    L["Lock prediction<br/>expected_outcome"] --> T["Trade plays out"]
    T --> G["Coach grades<br/>HIT · MISS · PARTIAL · VOID"]
    G --> W["Write lesson<br/>symbol · regime · failure mode"]
    W --> R["Architect + Red Team<br/>must read active lessons"]
    R --> L
```

Details and the record format: [PREDICTION-LOG.md](PREDICTION-LOG.md).

---

## 7. Data model (simplified)

The tables an agent touches. Column names are simplified; the point is the shape.

```mermaid
erDiagram
    PLANS ||--o{ SETUPS : contains
    SETUPS ||--o| POSITIONS : "becomes when filled"
    SETUPS ||--o{ ALERTS : "receives"
    SETUPS ||--o{ LESSONS : "teaches"
    PLANS ||--o{ NOTIFICATIONS : "announces"
    SETUPS ||--o{ SCOUT_WAKES : "wakes Scout"
    SETUPS }o--|| ASSET_PRICES : "charted from"

    PLANS {
        date week_of
        text status "draft | approved | archived"
        text bias
        text gamma_regime
        jsonb risk_config "human-only"
    }
    SETUPS {
        text ticker
        text direction
        text status "radar | watching | armed | active | closed"
        numeric entry_stop_t1_t2
        text arm_condition "observable event"
        text red_team_verdict "pass | fail"
        text expected_outcome "immutable once set"
        jsonb evidence "dated log: rejections, re-anchors, news"
        text outcome_grade "hit | miss | partial | void"
        text proximity "far | approaching | at_entry"
    }
    SCOUT_WAKES {
        text stage "approaching | at_entry"
        text trigger "yahoo_timer | tv_alert"
        timestamptz hour_bucket "one per setup per stage per hour"
        text status "pending | sent | failed"
    }
    ASSET_PRICES {
        text ticker
        numeric current_price
        jsonb bars "daily · weekly · hourly, from Yahoo"
    }
    FLOOR_EVENTS {
        text author
        text via "grok | mod"
        text kind "finish | alert | verdict"
        text body
    }
    POSITIONS {
        text ticker
        numeric qty
        numeric avg_price
        text status
        text entry_source "system | override"
    }
    LESSONS {
        text symbol
        text_array regime_tags
        text failure_mode
        text lesson
        boolean active
    }
    ALERTS {
        text kind "entry | stop | t1 | t2 | gamma flip"
        timestamptz fired_at
    }
    NOTIFICATIONS {
        text message
        text status "sent | failed"
    }
```

---

## 8. Setup lifecycle

```mermaid
stateDiagram-v2
    [*] --> radar: scan finds it
    radar --> watching: promoted (score + structure)
    watching --> radar: demoted
    watching --> armed: arm condition + locked prediction + Red Team Pass
    armed --> watching: invalidated before fill
    armed --> active: entry alert / fill
    active --> closed: stop or target
    closed --> [*]: Coach grades vs prediction
    note right of armed
        Only Wolf writes this,
        and only after a Pass
    end note
    note right of active
        Levels frozen.
        No agent edits entry/stop.
    end note
```

---

## 9. Design choices worth stealing

| Choice | Why |
|--------|-----|
| **One database is the only source of truth** | Agents disagree. Rows don't. Every agent reads the same state and every failure has one place to look. |
| **Notifications are rows, not API calls** | An agent inserts a row; a trigger sends the Telegram message and writes back `sent` or `failed`. Agents need no phone credentials, and a missing message is visible. |
| **Deterministic execution, probabilistic analysis** | Price alerts fire from an indicator on fixed levels, and a 5-minute Yahoo Finance check wakes Scout when a zone is reached. The model never decides *when* a level is hit. |
| **Event-driven agents, with a schedule as the safety net** | Agents run when something happens (price reaches a zone), not just on a clock. The hourly slots still run and pick up anything a failed wake missed. |
| **Least-privilege connectors** | The broker connector can draft but not send. The dashboard key can read but not write. See [CONNECTORS.md](CONNECTORS.md). |
| **The human is graded too** | Trades taken outside a Pass are tagged `override`. Coach lists them and the human answers "why" every Saturday. |
| **Every finish posts a line** | Silent failure was the root cause of every bug in six months ([WHAT-BROKE.md](WHAT-BROKE.md)). Now every agent run ends with a status line in the group chat. |
| **Deploys are git pushes** | The dashboard is a static site. No agent can deploy it. |
