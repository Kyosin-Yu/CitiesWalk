-- Rewards MVP policy v1
--
-- A completed journey earns round(30 * walking distance in km +
-- 45 * CO2 saved in kg). The trusted Rewards Edge Function chooses actual
-- tracking metrics when present and otherwise falls back to route estimates.
--
-- Prerequisite: the shared Authentication module provides public.profiles
-- with id, full_name, and public_profile columns. It already exists in the
-- shared Supabase project and is used only to build/filter public rankings.

-- Do not recreate the Authentication-owned profile table here. This guard
-- makes the cross-module dependency explicit and stops a fresh environment
-- with a useful error instead of creating an incomplete or duplicate table.
do $$
begin
  if to_regclass('public.profiles') is null then
    raise exception
      'Rewards migration requires public.profiles from Authentication.'
      using hint =
        'Apply the Authentication profiles migration before this migration.';
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'id'
      and udt_name = 'uuid'
  ) then
    raise exception 'Rewards migration requires public.profiles.id as uuid.';
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'full_name'
      and data_type = 'text'
  ) then
    raise exception 'Rewards migration requires public.profiles.full_name.';
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'public_profile'
      and data_type = 'boolean'
  ) then
    raise exception
      'Rewards migration requires public.profiles.public_profile as boolean.';
  end if;
end;
$$;

create table public.reward_point_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  journey_id uuid not null references public.eco_journeys (id) on delete restrict,
  points integer not null check (points >= 0),
  walking_distance_km numeric(10, 3) not null
    check (walking_distance_km >= 0),
  carbon_saved_kg numeric(10, 3) not null
    check (carbon_saved_kg >= 0),
  calories_burned integer not null check (calories_burned >= 0),
  metric_source text not null
    check (metric_source in ('actual', 'estimated', 'mixed')),
  policy_version text not null default 'v1',
  journey_completed_at timestamptz not null,
  awarded_at timestamptz not null default now(),
  unique (journey_id)
);

create table public.badges (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  title text not null,
  description text not null,
  icon_key text not null,
  criteria_key text not null
    check (
      criteria_key in (
        'completed_journeys',
        'walking_distance_km',
        'carbon_saved_kg',
        'calories_burned',
        'weekend_journeys'
      )
    ),
  target_value numeric(10, 3) not null check (target_value > 0),
  display_order smallint not null unique check (display_order > 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.user_badges (
  user_id uuid not null references auth.users (id) on delete cascade,
  badge_id uuid not null references public.badges (id) on delete restrict,
  progress numeric(10, 3) not null default 0 check (progress >= 0),
  unlocked_at timestamptz,
  unlocked_journey_id uuid references public.eco_journeys (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, badge_id),
  check (
    (unlocked_at is null and unlocked_journey_id is null)
    or (unlocked_at is not null and unlocked_journey_id is not null)
  )
);

create table public.leaderboard_snapshot_entries (
  week_start date not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  display_name text not null,
  initials text not null,
  total_points integer not null check (total_points >= 0),
  rank smallint not null check (rank > 0),
  generated_at timestamptz not null default now(),
  primary key (week_start, user_id),
  unique (week_start, rank)
);

create index reward_point_transactions_user_completed_at_idx
  on public.reward_point_transactions (user_id, journey_completed_at desc);

create index reward_point_transactions_completed_at_idx
  on public.reward_point_transactions (journey_completed_at desc);

create index user_badges_user_progress_idx
  on public.user_badges (user_id, progress desc);

create index leaderboard_snapshot_entries_week_rank_idx
  on public.leaderboard_snapshot_entries (week_start, rank);

-- The badge catalogue is intentionally database-owned. Flutter clients can
-- read it but cannot alter badge rules or unlock records.
insert into public.badges (
  code,
  title,
  description,
  icon_key,
  criteria_key,
  target_value,
  display_order
)
values
  (
    'first_step',
    'First Step',
    'Complete your first CitiesWalk journey.',
    'directionsWalk',
    'completed_journeys',
    1,
    1
  ),
  (
    'city_explorer',
    'City Explorer',
    'Complete 5 CitiesWalk journeys.',
    'city',
    'completed_journeys',
    5,
    2
  ),
  (
    'eco_warrior',
    'Eco Warrior',
    'Complete 10 eco-friendly city journeys.',
    'recycle',
    'completed_journeys',
    10,
    3
  ),
  (
    'green_commuter',
    'Green Commuter',
    'Complete 25 CitiesWalk journeys.',
    'directionsWalk',
    'completed_journeys',
    25,
    4
  ),
  (
    'walking_wanderer',
    'Walking Wanderer',
    'Walk 10 km across completed journeys.',
    'directionsWalk',
    'walking_distance_km',
    10,
    5
  ),
  (
    'urban_trekker',
    'Urban Trekker',
    'Walk 50 km across completed journeys.',
    'directionsWalk',
    'walking_distance_km',
    50,
    6
  ),
  (
    'carbon_saver',
    'Carbon Saver',
    'Save 5 kg of estimated CO2 emissions.',
    'globe',
    'carbon_saved_kg',
    5,
    7
  ),
  (
    'climate_champion',
    'Climate Champion',
    'Save 20 kg of estimated CO2 emissions.',
    'globe',
    'carbon_saved_kg',
    20,
    8
  ),
  (
    'calorie_burner',
    'Calorie Burner',
    'Burn 1,000 estimated calories on completed journeys.',
    'sunrise',
    'calories_burned',
    1000,
    9
  ),
  (
    'weekend_explorer',
    'Weekend Explorer',
    'Complete 3 journeys on a Saturday or Sunday.',
    'city',
    'weekend_journeys',
    3,
    10
  )
on conflict (code) do update
set
  title = excluded.title,
  description = excluded.description,
  icon_key = excluded.icon_key,
  criteria_key = excluded.criteria_key,
  target_value = excluded.target_value,
  display_order = excluded.display_order,
  updated_at = now();

-- Private, SECURITY DEFINER helpers avoid depending on the profile table's
-- own RLS policies when a public leaderboard row is evaluated. They are not
-- exposed through the Data API and are executable only by authenticated users
-- as part of the leaderboard RLS predicate.
create schema if not exists private;

revoke all on schema private from public;
grant usage on schema private to authenticated;

create or replace function private.is_profile_public(profile_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles profiles
    where profiles.id = profile_id
      and profiles.public_profile is true
  );
$$;

revoke all on function private.is_profile_public(uuid) from public;
grant execute on function private.is_profile_public(uuid) to authenticated;

create or replace function private.week_start_in_malaysia(
  completed_at timestamptz
)
returns date
language sql
stable
set search_path = ''
as $$
  select date_trunc(
    'week',
    completed_at at time zone 'Asia/Kuala_Lumpur'
  )::date;
$$;

revoke all on function private.week_start_in_malaysia(timestamptz) from public;
grant execute on function private.week_start_in_malaysia(timestamptz) to authenticated;

-- Keep the week boundary on the server. This avoids a user in another time
-- zone seeing a different "current week" around Monday midnight.
create or replace function public.get_current_weekly_leaderboard()
returns table (
  user_id uuid,
  display_name text,
  initials text,
  total_points integer,
  rank smallint,
  week_start date,
  generated_at timestamptz
)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    entries.user_id,
    entries.display_name,
    entries.initials,
    entries.total_points,
    entries.rank,
    entries.week_start,
    entries.generated_at
  from public.leaderboard_snapshot_entries entries
  where entries.week_start = private.week_start_in_malaysia(now())
  order by entries.rank;
$$;

revoke all on function public.get_current_weekly_leaderboard() from public;
grant execute on function public.get_current_weekly_leaderboard() to authenticated;

create or replace function private.refresh_user_badges(
  reward_user_id uuid,
  reward_journey_id uuid,
  completed_at timestamptz
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  badge_record public.badges%rowtype;
  calculated_progress numeric(10, 3);
begin
  for badge_record in
    select *
    from public.badges
    where is_active is true
    order by display_order
  loop
    select case badge_record.criteria_key
      when 'completed_journeys' then count(*)::numeric
      when 'walking_distance_km' then coalesce(sum(walking_distance_km), 0)
      when 'carbon_saved_kg' then coalesce(sum(carbon_saved_kg), 0)
      when 'calories_burned' then coalesce(sum(calories_burned), 0)
      when 'weekend_journeys' then count(*) filter (
        where extract(
          isodow from journey_completed_at at time zone 'Asia/Kuala_Lumpur'
        ) in (6, 7)
      )::numeric
    end
    into calculated_progress
    from public.reward_point_transactions transactions
    where transactions.user_id = reward_user_id;

    insert into public.user_badges (
      user_id,
      badge_id,
      progress,
      unlocked_at,
      unlocked_journey_id
    )
    values (
      reward_user_id,
      badge_record.id,
      least(calculated_progress, badge_record.target_value),
      case
        when calculated_progress >= badge_record.target_value then completed_at
        else null
      end,
      case
        when calculated_progress >= badge_record.target_value then reward_journey_id
        else null
      end
    )
    on conflict (user_id, badge_id) do update
    set
      progress = greatest(public.user_badges.progress, excluded.progress),
      unlocked_at = coalesce(
        public.user_badges.unlocked_at,
        excluded.unlocked_at
      ),
      unlocked_journey_id = coalesce(
        public.user_badges.unlocked_journey_id,
        excluded.unlocked_journey_id
      ),
      updated_at = now();
  end loop;
end;
$$;

revoke all on function private.refresh_user_badges(uuid, uuid, timestamptz)
  from public;

create or replace function private.refresh_weekly_leaderboard(
  leaderboard_week_start date
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.leaderboard_snapshot_entries
  where week_start = leaderboard_week_start;

  insert into public.leaderboard_snapshot_entries (
    week_start,
    user_id,
    display_name,
    initials,
    total_points,
    rank
  )
  with weekly_totals as (
    select
      transactions.user_id,
      profiles.full_name,
      sum(transactions.points)::integer as total_points
    from public.reward_point_transactions transactions
    join public.profiles profiles on profiles.id = transactions.user_id
    where profiles.public_profile is true
      and transactions.journey_completed_at >= (
        leaderboard_week_start::timestamp at time zone 'Asia/Kuala_Lumpur'
      )
      and transactions.journey_completed_at < (
        (leaderboard_week_start + 7)::timestamp at time zone 'Asia/Kuala_Lumpur'
      )
    group by transactions.user_id, profiles.full_name
  )
  select
    leaderboard_week_start,
    user_id,
    full_name,
    coalesce(
      nullif(
        upper(
          left(split_part(trim(full_name), ' ', 1), 1)
          || left(split_part(trim(full_name), ' ', 2), 1)
        ),
        ''
      ),
      'CW'
    ),
    total_points,
    row_number() over (order by total_points desc, user_id)::smallint
  from weekly_totals;
end;
$$;

revoke all on function private.refresh_weekly_leaderboard(date) from public;

create or replace function private.process_new_reward_transaction()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.refresh_user_badges(
    new.user_id,
    new.journey_id,
    new.journey_completed_at
  );
  perform private.refresh_weekly_leaderboard(
    private.week_start_in_malaysia(new.journey_completed_at)
  );
  return new;
end;
$$;

revoke all on function private.process_new_reward_transaction() from public;

create trigger reward_transactions_refresh_rewards
after insert on public.reward_point_transactions
for each row execute function private.process_new_reward_transaction();

alter table public.reward_point_transactions enable row level security;
alter table public.badges enable row level security;
alter table public.user_badges enable row level security;
alter table public.leaderboard_snapshot_entries enable row level security;

revoke all on table public.reward_point_transactions from anon, authenticated;
revoke all on table public.badges from anon, authenticated;
revoke all on table public.user_badges from anon, authenticated;
revoke all on table public.leaderboard_snapshot_entries from anon, authenticated;

grant select on table public.reward_point_transactions to authenticated;
grant select on table public.badges to authenticated;
grant select on table public.user_badges to authenticated;
grant select on table public.leaderboard_snapshot_entries to authenticated;

create policy "Users can view their own reward point transactions"
  on public.reward_point_transactions for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Authenticated users can view active badges"
  on public.badges for select to authenticated
  using (is_active is true);

create policy "Users can view their own badge progress"
  on public.user_badges for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can view their own or public weekly leaderboard entries"
  on public.leaderboard_snapshot_entries for select to authenticated
  using (
    (select auth.uid()) = user_id
    or private.is_profile_public(user_id)
  );

comment on table public.reward_point_transactions is
  'Immutable rewards ledger. Only the protected Rewards Edge Function writes it.';

comment on table public.leaderboard_snapshot_entries is
  'Weekly Malaysia-time leaderboard snapshot. Only public-profile users are included.';
