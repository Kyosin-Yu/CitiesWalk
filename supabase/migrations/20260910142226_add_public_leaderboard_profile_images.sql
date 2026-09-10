-- Public leaderboard avatars are opt-in through profiles.public_profile.
-- The RPC exposes only the Storage path, never another participant's user ID.

drop function if exists public.get_current_weekly_leaderboard();

create function public.get_current_weekly_leaderboard()
returns table (
  user_id uuid,
  display_name text,
  initials text,
  profile_image_path text,
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
    case
      when profiles.public_profile is true then profiles.profile_image
      else null
    end,
    entries.total_points,
    entries.rank,
    entries.week_start,
    entries.generated_at
  from public.leaderboard_snapshot_entries entries
  join public.profiles profiles on profiles.id = entries.user_id
  where (select auth.uid()) is not null
    and entries.week_start = private.week_start_in_malaysia(now())
  order by entries.rank;
$$;

revoke all on function public.get_current_weekly_leaderboard() from public;
revoke all on function public.get_current_weekly_leaderboard() from anon;
grant execute on function public.get_current_weekly_leaderboard()
  to authenticated;

drop policy if exists "Authenticated users can read public profile images"
  on storage.objects;

create policy "Authenticated users can read public profile images"
on storage.objects for select to authenticated
using (
  bucket_id = 'profile-images'
  and exists (
    select 1
    from public.profiles profiles
    where profiles.id::text = (storage.foldername(name))[1]
      and profiles.public_profile is true
  )
);
