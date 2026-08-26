-- Applied to the shared Supabase project as migration 20260826202001.
-- Award journey points inside the same database transaction that completes the
-- journey. This removes the client-side gap where the journey PATCH could
-- succeed but the later Rewards Edge Function invocation could be interrupted.
create or replace function private.process_completed_journey_reward()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  reward_walking_km numeric(10, 3);
  reward_carbon_kg numeric(10, 3);
  reward_calories integer;
  reward_metric_source text;
  reward_points integer;
begin
  if new.status <> 'completed' or new.ended_at is null then
    return new;
  end if;

  reward_walking_km := round(
    coalesce(
      new.actual_walking_distance_meters,
      new.estimated_walking_distance_meters
    )::numeric / 1000,
    3
  );
  reward_carbon_kg := round(
    coalesce(
      new.actual_carbon_saved_kg,
      new.estimated_carbon_saved_kg
    )::numeric,
    3
  );
  reward_calories := round(
    coalesce(
      new.actual_calories_burned,
      new.estimated_calories
    )::numeric
  )::integer;
  reward_metric_source := case
    when new.actual_walking_distance_meters is not null
      and new.actual_carbon_saved_kg is not null then 'actual'
    when new.actual_walking_distance_meters is not null
      or new.actual_carbon_saved_kg is not null then 'mixed'
    else 'estimated'
  end;
  reward_points := round(
    30 * reward_walking_km + 45 * reward_carbon_kg
  )::integer;

  -- Zero-point journeys are deliberately recorded. They remain visible in
  -- Points History and count as a completed journey without changing totals.
  insert into public.reward_point_transactions (
    user_id,
    journey_id,
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
    new.id,
    'journey',
    reward_points,
    reward_walking_km,
    reward_carbon_kg,
    reward_calories,
    reward_metric_source,
    'v1',
    new.ended_at
  )
  on conflict (journey_id) do nothing;

  return new;
end;
$$;

revoke execute on function private.process_completed_journey_reward()
  from public, anon, authenticated;

create trigger rewards_award_after_journey_insert
after insert on public.eco_journeys
for each row
when (new.status = 'completed')
execute function private.process_completed_journey_reward();

create trigger rewards_award_after_journey_update
after update of status on public.eco_journeys
for each row
when (new.status = 'completed' and old.status is distinct from new.status)
execute function private.process_completed_journey_reward();

comment on function private.process_completed_journey_reward() is
  'Atomically awards an idempotent v1 reward when an eco journey completes.';
