create table public.eco_journeys (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  status text not null default 'preview'
    check (status in ('preview', 'in_progress', 'completed', 'cancelled')),
  origin_name text not null,
  origin_latitude double precision not null
    check (origin_latitude between -90 and 90),
  origin_longitude double precision not null
    check (origin_longitude between -180 and 180),
  destination_name text not null,
  destination_category text,
  destination_latitude double precision not null
    check (destination_latitude between -90 and 90),
  destination_longitude double precision not null
    check (destination_longitude between -180 and 180),
  estimated_duration_minutes integer not null check (estimated_duration_minutes >= 0),
  estimated_walking_distance_meters integer not null
    check (estimated_walking_distance_meters >= 0),
  estimated_calories integer not null check (estimated_calories >= 0),
  estimated_carbon_saved_kg numeric(8, 3) not null
    check (estimated_carbon_saved_kg >= 0),
  started_at timestamptz,
  ended_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ended_at is null or started_at is not null),
  check (ended_at is null or ended_at >= started_at)
);

create table public.eco_route_steps (
  id uuid primary key default gen_random_uuid(),
  journey_id uuid not null references public.eco_journeys (id) on delete cascade,
  step_order smallint not null check (step_order >= 1),
  transport_mode text not null check (transport_mode in ('walk', 'transit')),
  line_name text,
  boarding_station text,
  alighting_station text,
  instruction text not null,
  distance_meters integer not null check (distance_meters >= 0),
  duration_minutes integer not null check (duration_minutes >= 0),
  route_polyline text,
  created_at timestamptz not null default now(),
  unique (journey_id, step_order),
  check (
    (transport_mode = 'walk' and line_name is null)
    or transport_mode = 'transit'
  )
);

create index eco_journeys_user_created_at_idx
  on public.eco_journeys (user_id, created_at desc);

create index eco_route_steps_journey_order_idx
  on public.eco_route_steps (journey_id, step_order);

grant select, insert, update, delete on public.eco_journeys to authenticated;
grant select, insert, update, delete on public.eco_route_steps to authenticated;

alter table public.eco_journeys enable row level security;
alter table public.eco_route_steps enable row level security;

create policy "Users can view their own eco journeys"
  on public.eco_journeys for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can create their own eco journeys"
  on public.eco_journeys for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update their own eco journeys"
  on public.eco_journeys for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can delete their own eco journeys"
  on public.eco_journeys for delete to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can view steps for their own eco journeys"
  on public.eco_route_steps for select to authenticated
  using (
    exists (
      select 1
      from public.eco_journeys journeys
      where journeys.id = eco_route_steps.journey_id
        and journeys.user_id = (select auth.uid())
    )
  );

create policy "Users can create steps for their own eco journeys"
  on public.eco_route_steps for insert to authenticated
  with check (
    exists (
      select 1
      from public.eco_journeys journeys
      where journeys.id = eco_route_steps.journey_id
        and journeys.user_id = (select auth.uid())
    )
  );

create policy "Users can update steps for their own eco journeys"
  on public.eco_route_steps for update to authenticated
  using (
    exists (
      select 1
      from public.eco_journeys journeys
      where journeys.id = eco_route_steps.journey_id
        and journeys.user_id = (select auth.uid())
    )
  )
  with check (
    exists (
      select 1
      from public.eco_journeys journeys
      where journeys.id = eco_route_steps.journey_id
        and journeys.user_id = (select auth.uid())
    )
  );

create policy "Users can delete steps for their own eco journeys"
  on public.eco_route_steps for delete to authenticated
  using (
    exists (
      select 1
      from public.eco_journeys journeys
      where journeys.id = eco_route_steps.journey_id
        and journeys.user_id = (select auth.uid())
    )
  );
