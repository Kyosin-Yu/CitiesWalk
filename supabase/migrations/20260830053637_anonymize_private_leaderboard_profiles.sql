-- Private profiles remain ranked, but their identity is masked at the server
-- boundary. Direct snapshot access stays unavailable; clients use the RPC.

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
      profiles.public_profile,
      sum(transactions.points)::integer as total_points
    from public.reward_point_transactions transactions
    join public.profiles profiles on profiles.id = transactions.user_id
    where transactions.journey_completed_at >= (
        leaderboard_week_start::timestamp at time zone 'Asia/Kuala_Lumpur'
      )
      and transactions.journey_completed_at < (
        (leaderboard_week_start + 7)::timestamp at time zone 'Asia/Kuala_Lumpur'
      )
    group by
      transactions.user_id,
      profiles.full_name,
      profiles.public_profile
  )
  select
    leaderboard_week_start,
    user_id,
    case when public_profile then full_name else 'Anonymous' end,
    case
      when public_profile then coalesce(
        nullif(
          upper(
            left(split_part(trim(full_name), ' ', 1), 1)
            || left(split_part(trim(full_name), ' ', 2), 1)
          ),
          ''
        ),
        'CW'
      )
      else 'A'
    end,
    total_points,
    row_number() over (order by total_points desc, user_id)::smallint
  from weekly_totals;
end;
$$;

revoke all on function private.refresh_weekly_leaderboard(date) from public;

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
security definer
set search_path = ''
as $$
  select
    case
      when entries.user_id = (select auth.uid()) then entries.user_id
      else null
    end,
    entries.display_name,
    entries.initials,
    entries.total_points,
    entries.rank,
    entries.week_start,
    entries.generated_at
  from public.leaderboard_snapshot_entries entries
  where (select auth.uid()) is not null
    and entries.week_start = private.week_start_in_malaysia(now())
  order by entries.rank;
$$;

revoke all on function public.get_current_weekly_leaderboard() from public;
revoke all on function public.get_current_weekly_leaderboard() from anon;
grant execute on function public.get_current_weekly_leaderboard()
  to authenticated;

revoke select on table public.leaderboard_snapshot_entries
  from anon, authenticated;

drop policy if exists
  "Users can view their own or public weekly leaderboard entries"
  on public.leaderboard_snapshot_entries;

create or replace function private.refresh_leaderboard_after_profile_update()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if old.full_name is distinct from new.full_name
    or old.public_profile is distinct from new.public_profile then
    perform private.refresh_weekly_leaderboard(
      private.week_start_in_malaysia(now())
    );
  end if;
  return new;
end;
$$;

revoke all on function private.refresh_leaderboard_after_profile_update()
  from public;

drop trigger if exists profiles_refresh_weekly_leaderboard
  on public.profiles;

create trigger profiles_refresh_weekly_leaderboard
after update of full_name, public_profile on public.profiles
for each row execute function private.refresh_leaderboard_after_profile_update();

select private.refresh_weekly_leaderboard(
  private.week_start_in_malaysia(now())
);

comment on table public.leaderboard_snapshot_entries is
  'Weekly Malaysia-time leaderboard snapshot. Private profiles are retained with anonymous identity fields.';
