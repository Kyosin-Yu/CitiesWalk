-- Storage policies run with the viewer's role. The original policy queried
-- profiles directly, but profile RLS permits a viewer to read only their own
-- row, causing public peer avatars to be denied. This narrow helper bypasses
-- that lookup restriction while exposing only a boolean for an object path.
create or replace function public.can_read_public_profile_image(object_name text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles profiles
    where profiles.id::text = (storage.foldername(object_name))[1]
      and profiles.public_profile is true
  );
$$;

revoke all on function public.can_read_public_profile_image(text) from public;
revoke all on function public.can_read_public_profile_image(text) from anon;
grant execute on function public.can_read_public_profile_image(text)
  to authenticated;

drop policy if exists "Authenticated users can read public profile images"
  on storage.objects;

create policy "Authenticated users can read public profile images"
on storage.objects for select to authenticated
using (
  bucket_id = 'profile-images'
  and public.can_read_public_profile_image(name)
);
