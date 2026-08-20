-- Completed journeys retain actual GPS-derived outcomes separately from the
-- pre-departure route estimates. Nullable values distinguish existing legacy
-- completed records from journeys completed after live tracking was added.
alter table public.eco_journeys
  add column if not exists actual_duration_minutes integer
    check (actual_duration_minutes >= 0),
  add column if not exists actual_walking_distance_meters integer
    check (actual_walking_distance_meters >= 0),
  add column if not exists actual_transit_distance_meters integer
    check (actual_transit_distance_meters >= 0),
  add column if not exists actual_step_count integer
    check (actual_step_count >= 0),
  add column if not exists actual_calories_burned integer
    check (actual_calories_burned >= 0),
  add column if not exists actual_carbon_saved_kg numeric(8, 3)
    check (actual_carbon_saved_kg >= 0);

comment on column public.eco_journeys.actual_step_count is
  'GPS walking-distance-derived step estimate; it is not a hardware pedometer count.';
