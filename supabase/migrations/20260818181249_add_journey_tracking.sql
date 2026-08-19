-- GPS samples are stored only for the owner of a journey. They support the
-- active journey map and are intentionally rate-limited by the Flutter client.
alter table public.eco_journeys
  drop constraint eco_journeys_status_check;

alter table public.eco_journeys
  add constraint eco_journeys_status_check
  check (status in ('preview', 'in_progress', 'paused', 'completed', 'cancelled'));

create table public.eco_journey_track_points (
  id uuid primary key default gen_random_uuid(),
  journey_id uuid not null references public.eco_journeys (id) on delete cascade,
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  recorded_at timestamptz not null default now()
);

create index eco_journey_track_points_journey_recorded_at_idx
  on public.eco_journey_track_points (journey_id, recorded_at);

grant select, insert on public.eco_journey_track_points to authenticated;

alter table public.eco_journey_track_points enable row level security;

create policy "Users can view their own journey track points"
  on public.eco_journey_track_points for select to authenticated
  using (
    exists (
      select 1 from public.eco_journeys journeys
      where journeys.id = eco_journey_track_points.journey_id
        and journeys.user_id = (select auth.uid())
    )
  );

create policy "Users can add their own journey track points"
  on public.eco_journey_track_points for insert to authenticated
  with check (
    exists (
      select 1 from public.eco_journeys journeys
      where journeys.id = eco_journey_track_points.journey_id
        and journeys.user_id = (select auth.uid())
    )
  );
