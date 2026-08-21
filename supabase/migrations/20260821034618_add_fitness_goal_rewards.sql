-- Depends on the Rewards backend migration that owns
-- public.reward_point_transactions and the private reward refresh functions.

alter table public.fitness_goals
  add column status text not null default 'active'
    check (status in ('active', 'completed', 'cancelled')),
  add column completed_at timestamptz,
  add column cancelled_at timestamptz,
  add column completed_value numeric(10, 2)
    check (completed_value is null or completed_value >= 0),
  add column reward_points integer
    check (reward_points is null or reward_points >= 0),
  add column reward_policy_version text;

alter table public.fitness_goals
  add constraint fitness_goals_lifecycle_check check (
    (
      status = 'active'
      and completed_at is null
      and cancelled_at is null
      and completed_value is null
      and reward_points is null
      and reward_policy_version is null
    )
    or (
      status = 'completed'
      and completed_at is not null
      and cancelled_at is null
      and completed_value is not null
      and reward_points is not null
      and reward_policy_version is not null
    )
    or (
      status = 'cancelled'
      and completed_at is null
      and cancelled_at is not null
      and completed_value is null
      and reward_points is null
      and reward_policy_version is null
    )
  );

alter table public.fitness_goals
  drop constraint if exists fitness_goals_user_id_metric_period_key;

create unique index fitness_goals_one_active_metric_period_idx
  on public.fitness_goals (user_id, metric, period)
  where status = 'active';

alter table public.reward_point_transactions
  alter column journey_id drop not null,
  add column fitness_goal_id uuid
    references public.fitness_goals (id) on delete restrict,
  add column source_type text not null default 'journey'
    check (source_type in ('journey', 'fitness_goal'));

alter table public.reward_point_transactions
  add constraint reward_point_transactions_source_check check (
    (
      source_type = 'journey'
      and journey_id is not null
      and fitness_goal_id is null
    )
    or (
      source_type = 'fitness_goal'
      and journey_id is null
      and fitness_goal_id is not null
    )
  );

create unique index reward_point_transactions_fitness_goal_idx
  on public.reward_point_transactions (fitness_goal_id)
  where fitness_goal_id is not null;

revoke update, delete on table public.fitness_goals from authenticated;
revoke insert on table public.fitness_goals from authenticated;
grant insert (user_id, metric, period, target_value)
  on table public.fitness_goals to authenticated;

drop policy if exists "Users can update their own fitness goals"
  on public.fitness_goals;
drop policy if exists "Users can delete their own fitness goals"
  on public.fitness_goals;

create or replace function public.cancel_fitness_goal(target_goal_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_id uuid := (select auth.uid());
  cancelled_goal public.fitness_goals%rowtype;
begin
  if caller_id is null then
    raise exception 'Authentication is required.' using errcode = '42501';
  end if;

  update public.fitness_goals
  set
    status = 'cancelled',
    cancelled_at = now(),
    updated_at = now()
  where id = target_goal_id
    and user_id = caller_id
    and status = 'active'
  returning * into cancelled_goal;

  if cancelled_goal.id is null then
    raise exception 'Only an active goal owned by the user can be cancelled.'
      using errcode = 'P0002';
  end if;

  return to_jsonb(cancelled_goal);
end;
$$;

revoke execute on function public.cancel_fitness_goal(uuid)
  from public, anon;
grant execute on function public.cancel_fitness_goal(uuid)
  to authenticated;

create or replace function private.process_fitness_goal_completion()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  goal_record public.fitness_goals%rowtype;
  period_start timestamptz;
  progress_start timestamptz;
  current_progress numeric(10, 2);
  completion_walking_km numeric(10, 3);
  completion_carbon_kg numeric(10, 3);
  completion_calories integer;
  completion_source text;
  completion_points integer;
  completed_goal_id uuid;
begin
  if new.status <> 'completed' or new.ended_at is null then
    return new;
  end if;

  completion_walking_km := round(
    coalesce(
      new.actual_walking_distance_meters,
      new.estimated_walking_distance_meters
    )::numeric / 1000,
    3
  );
  completion_carbon_kg := round(
    coalesce(new.actual_carbon_saved_kg, new.estimated_carbon_saved_kg),
    3
  );
  completion_calories := round(
    coalesce(new.actual_calories_burned, new.estimated_calories)
  )::integer;
  completion_source := case
    when new.actual_walking_distance_meters is not null
      and new.actual_carbon_saved_kg is not null then 'actual'
    when new.actual_walking_distance_meters is not null
      or new.actual_carbon_saved_kg is not null then 'mixed'
    else 'estimated'
  end;
  completion_points := round(
    30 * completion_walking_km + 45 * completion_carbon_kg
  )::integer;

  for goal_record in
    select *
    from public.fitness_goals
    where user_id = new.user_id
      and status = 'active'
      and created_at <= new.started_at
    order by created_at, id
    for update
  loop
    period_start := case goal_record.period
      when 'daily' then
        date_trunc('day', new.ended_at at time zone 'Asia/Kuala_Lumpur')
          at time zone 'Asia/Kuala_Lumpur'
      when 'weekly' then
        date_trunc('week', new.ended_at at time zone 'Asia/Kuala_Lumpur')
          at time zone 'Asia/Kuala_Lumpur'
      when 'monthly' then
        date_trunc('month', new.ended_at at time zone 'Asia/Kuala_Lumpur')
          at time zone 'Asia/Kuala_Lumpur'
    end;
    progress_start := greatest(period_start, goal_record.created_at);

    select case goal_record.metric
      when 'walking_distance' then coalesce(sum(
        coalesce(
          journeys.actual_walking_distance_meters,
          journeys.estimated_walking_distance_meters
        )::numeric / 1000
      ), 0)
      when 'calories' then coalesce(sum(
        coalesce(
          journeys.actual_calories_burned,
          journeys.estimated_calories
        )
      ), 0)
      when 'carbon_saved' then coalesce(sum(
        coalesce(
          journeys.actual_carbon_saved_kg,
          journeys.estimated_carbon_saved_kg
        )
      ), 0)
    end
    into current_progress
    from public.eco_journeys journeys
    where journeys.user_id = goal_record.user_id
      and journeys.status = 'completed'
      and journeys.started_at >= progress_start
      and journeys.ended_at <= new.ended_at;

    current_progress := round(current_progress, 2);
    if current_progress < goal_record.target_value then
      continue;
    end if;

    completed_goal_id := null;
    update public.fitness_goals
    set
      status = 'completed',
      completed_at = new.ended_at,
      completed_value = current_progress,
      reward_points = completion_points,
      reward_policy_version = 'goal-v1-journey-v1',
      updated_at = now()
    where id = goal_record.id
      and status = 'active'
    returning id into completed_goal_id;

    if completed_goal_id is null then
      continue;
    end if;

    insert into public.reward_point_transactions (
      user_id,
      fitness_goal_id,
      source_type,
      points,
      walking_distance_km,
      carbon_saved_kg,
      calories_burned,
      metric_source,
      policy_version,
      journey_completed_at
    )
    values (
      new.user_id,
      completed_goal_id,
      'fitness_goal',
      completion_points,
      completion_walking_km,
      completion_carbon_kg,
      completion_calories,
      completion_source,
      'goal-v1-journey-v1',
      new.ended_at
    )
    on conflict do nothing;
  end loop;

  return new;
end;
$$;

revoke execute on function private.process_fitness_goal_completion()
  from public, anon, authenticated;

create trigger fitness_goals_complete_after_journey_insert
after insert on public.eco_journeys
for each row
when (new.status = 'completed')
execute function private.process_fitness_goal_completion();

create trigger fitness_goals_complete_after_journey_update
after update of status on public.eco_journeys
for each row
when (new.status = 'completed' and old.status is distinct from new.status)
execute function private.process_fitness_goal_completion();

create or replace function private.process_new_reward_transaction()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.source_type = 'journey' then
    perform private.refresh_user_badges(
      new.user_id,
      new.journey_id,
      new.journey_completed_at
    );
  end if;

  perform private.refresh_weekly_leaderboard(
    private.week_start_in_malaysia(new.journey_completed_at)
  );
  return new;
end;
$$;

revoke execute on function private.process_new_reward_transaction()
  from public, anon, authenticated;
