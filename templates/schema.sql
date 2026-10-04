-- TradeOps-style system of record: a minimal starter schema (Postgres / Supabase).
--
-- This is the smallest schema that enforces the CONTRACT in the database itself,
-- instead of trusting prompts:
--   * a plan can't go live until a human approves it          (plans.status)
--   * a setup can't be armed without a Pass, a locked
--     prediction and reward-to-risk >= 2                      (check constraint)
--   * the human's own trades are tagged, not blocked          (setups.entry_source)
--   * a prediction can't be edited once locked                (trigger)
--   * a live position can't be deleted by an agent            (trigger)
--   * notifications are rows; a relay function sends them     (notifications)
--   * a price-reached wake fires at most once per setup/hour  (scout_wakes)
--
-- Adapt freely. Rename "setup" to "deal", "PO", "claim", whatever your desk works on.
-- License: CC BY 4.0 (Imran Chatur / Lift Off)

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- plans: one per period (a trading week here). Only a human sets 'approved'.
-- ---------------------------------------------------------------------------
create table if not exists plans (
  id            uuid primary key default gen_random_uuid(),
  week_of       date not null unique,
  status        text not null default 'draft'
                check (status in ('draft', 'approved', 'closed', 'archived')),
  bias          text,
  regime        text,
  risk_config   jsonb not null default '{}'::jsonb,  -- human-only: equity, risk %, max concurrent
  approved_by   text,                                -- the human, never an agent
  approved_at   timestamptz,
  created_at    timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- setups: the units of work. Status moves radar -> watching -> armed -> active -> closed.
-- ---------------------------------------------------------------------------
create table if not exists setups (
  id                  uuid primary key default gen_random_uuid(),
  plan_id             uuid not null references plans(id) on delete cascade,
  ticker              text not null,
  direction           text not null check (direction in ('long', 'short')),
  status              text not null default 'watching'
                      check (status in ('radar', 'watching', 'armed', 'active', 'closed', 'invalidated', 'removed')),
  score               numeric,
  entry_low           numeric,
  entry_high          numeric,
  stop                numeric,
  t1                  numeric,
  t2                  numeric,
  rr_t1               numeric,       -- reward-to-risk to the first target
  arm_condition       text,          -- an observable event: "4H close above 33.75", never "wait for confirmation"
  red_team_verdict    text check (red_team_verdict is null or red_team_verdict in ('pass', 'fail')),
  red_team_note       text,
  expected_outcome    text,          -- the locked prediction
  expected_outcome_at timestamptz,
  evidence            jsonb not null default '[]'::jsonb,  -- dated log: rejections, re-anchors, news
  entry_source        text not null default 'system'
                      check (entry_source in ('system', 'override')),  -- override = the human's own call
  outcome_grade       text check (outcome_grade is null or outcome_grade in ('hit', 'miss', 'partial', 'void')),
  proximity           text check (proximity is null or proximity in ('far', 'approaching', 'at_entry')),
  proximity_price     numeric,       -- last price the 5-minute check saw
  proximity_at        timestamptz,
  updated_at          timestamptz not null default now(),
  created_at          timestamptz not null default now(),

  -- Contract, enforced: nothing is armed (or goes live through the system) without a
  -- Pass, a locked prediction and reward-to-risk >= 2. The human's own trades are not
  -- blocked; they go live tagged entry_source = 'override' and get reviewed instead.
  constraint armed_requires_pass_prediction_rr check (
    not (status = 'armed' or (status = 'active' and entry_source = 'system'))
    or (red_team_verdict = 'pass' and expected_outcome is not null and rr_t1 >= 2)
  )
);

create index if not exists setups_plan_status_idx on setups (plan_id, status);

-- For a database built from an earlier copy of this file: add the proximity columns.
alter table setups add column if not exists proximity text
  check (proximity is null or proximity in ('far', 'approaching', 'at_entry'));
alter table setups add column if not exists proximity_price numeric;
alter table setups add column if not exists proximity_at timestamptz;

-- Locked predictions: once expected_outcome is set it can never change.
create or replace function protect_expected_outcome() returns trigger
language plpgsql as $$
begin
  if old.expected_outcome is not null
     and new.expected_outcome is distinct from old.expected_outcome then
    raise exception 'expected_outcome is locked for setup %', old.id;
  end if;
  if old.expected_outcome_at is not null
     and new.expected_outcome_at is distinct from old.expected_outcome_at then
    raise exception 'expected_outcome_at is locked for setup %', old.id;
  end if;
  if new.expected_outcome is not null and new.expected_outcome_at is null then
    new.expected_outcome_at := now();
  end if;
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists setups_protect_expected_outcome on setups;
create trigger setups_protect_expected_outcome
  before update on setups
  for each row execute function protect_expected_outcome();

-- Live positions are frozen: no deleting an active setup.
create or replace function guard_active_setup_delete() returns trigger
language plpgsql as $$
begin
  if old.status = 'active' then
    raise exception 'cannot delete active setup % (close it first)', old.id;
  end if;
  return old;
end $$;

drop trigger if exists setups_guard_active_delete on setups;
create trigger setups_guard_active_delete
  before delete on setups
  for each row execute function guard_active_setup_delete();

-- ---------------------------------------------------------------------------
-- lessons: what the desk learned. Planner and Red Team must read active rows.
-- ---------------------------------------------------------------------------
create table if not exists lessons (
  id            uuid primary key default gen_random_uuid(),
  symbol        text not null,
  direction     text check (direction is null or direction in ('long', 'short')),
  regime_tags   text[] not null default '{}',
  failure_mode  text,               -- short label: false_break, late_chase, stop_tight, thesis_wrong
  lesson        text not null,
  source        text not null default 'coach' check (source in ('coach', 'red_team', 'manual')),
  setup_id      uuid references setups(id) on delete set null,
  active        boolean not null default true,  -- archive, don't delete
  created_at    timestamptz not null default now()
);

create index if not exists lessons_active_symbol_idx on lessons (symbol) where active;

-- ---------------------------------------------------------------------------
-- notifications: the outbox. Insert a row; a relay (edge function / worker)
-- sends it and stamps the result. "Did it send?" is a query, not a guess.
-- ---------------------------------------------------------------------------
create table if not exists notifications (
  id          uuid primary key default gen_random_uuid(),
  channel     text not null default 'telegram',
  source      text not null
              check (source in ('build', 'update', 'confirm', 'scout_alert', 'red_team',
                                'disarm', 'coach', 'ops_alert', 'manual')),
  message     text not null,
  status      text not null default 'pending' check (status in ('pending', 'sent', 'failed')),
  error       text,
  sent_at     timestamptz,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- scout_wakes: one row per attempt to wake an agent because price reached a
-- setup (5-minute price check or a TradingView alert). The partial unique
-- index is the dedupe: one live wake per setup, per stage, per clock hour.
-- A failed wake doesn't block a retry, and the next scheduled run reads
-- today's failed rows to pick those names up.
-- ---------------------------------------------------------------------------
create table if not exists scout_wakes (
  id          bigint generated always as identity primary key,
  setup_id    uuid not null references setups(id) on delete cascade,
  ticker      text not null,
  stage       text not null check (stage in ('approaching', 'at_entry')),
  trigger     text not null check (trigger in ('tv_alert', 'yahoo_timer')),
  price       numeric,
  hour_bucket timestamptz not null default date_trunc('hour', now()),
  status      text not null default 'pending' check (status in ('pending', 'sent', 'failed')),
  error       text,
  created_at  timestamptz not null default now()
);

create unique index if not exists scout_wakes_once_per_hour
  on scout_wakes (setup_id, stage, hour_bucket)
  where status in ('pending', 'sent');

-- ---------------------------------------------------------------------------
-- Permissions (Supabase-style). Agents write with the service role, which
-- bypasses RLS. The dashboard's public key can only read.
-- ---------------------------------------------------------------------------
alter table plans          enable row level security;
alter table setups         enable row level security;
alter table lessons        enable row level security;
alter table notifications  enable row level security;   -- no public policy: service role only
alter table scout_wakes    enable row level security;   -- no public policy: service role only

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    execute 'drop policy if exists plans_read on plans';
    execute 'create policy plans_read on plans for select to anon using (true)';
    execute 'drop policy if exists setups_read on setups';
    execute 'create policy setups_read on setups for select to anon using (true)';
    execute 'drop policy if exists lessons_read on lessons';
    execute 'create policy lessons_read on lessons for select to anon using (true)';
  end if;
end $$;
