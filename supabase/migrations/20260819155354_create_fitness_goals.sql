create table public.fitness_goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  metric text not null
    check (metric in ('walking_distance', 'calories', 'carbon_saved')),
  period text not null
    check (period in ('daily', 'weekly', 'monthly')),
  target_value numeric(10, 2) not null check (target_value > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, metric, period)
);

create index fitness_goals_user_id_idx
  on public.fitness_goals (user_id);

revoke all on table public.fitness_goals from anon;

grant select, insert, update, delete
  on table public.fitness_goals
  to authenticated;

alter table public.fitness_goals enable row level security;

create policy "Users can view their own fitness goals"
  on public.fitness_goals for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can create their own fitness goals"
  on public.fitness_goals for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update their own fitness goals"
  on public.fitness_goals for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can delete their own fitness goals"
  on public.fitness_goals for delete to authenticated
  using ((select auth.uid()) = user_id);

