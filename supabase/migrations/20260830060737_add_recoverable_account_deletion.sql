create table public.account_deletion_requests (
  user_id uuid primary key references auth.users (id) on delete cascade,
  requested_at timestamptz not null default now(),
  permanently_delete_at timestamptz not null,
  constraint account_deletion_recovery_window_check check (
    permanently_delete_at = requested_at + interval '30 days'
  )
);

alter table public.account_deletion_requests enable row level security;

revoke all on table public.account_deletion_requests from anon, authenticated;
grant select on table public.account_deletion_requests to authenticated;

create policy "Users can view their own account deletion request"
  on public.account_deletion_requests for select to authenticated
  using ((select auth.uid()) = user_id);

create or replace function public.request_account_deletion()
returns table (requested_at timestamptz, permanently_delete_at timestamptz)
language plpgsql
security definer
set search_path = ''
as $$
declare
  requesting_user_id uuid := auth.uid();
begin
  if requesting_user_id is null then
    raise exception 'Authentication is required.';
  end if;

  update public.profiles
  set public_profile = false, updated_at = now()
  where id = requesting_user_id;

  return query
  insert into public.account_deletion_requests (
    user_id,
    requested_at,
    permanently_delete_at
  )
  values (
    requesting_user_id,
    now(),
    now() + interval '30 days'
  )
  on conflict (user_id) do update
  set
    requested_at = public.account_deletion_requests.requested_at,
    permanently_delete_at = public.account_deletion_requests.permanently_delete_at
  returning
    public.account_deletion_requests.requested_at,
    public.account_deletion_requests.permanently_delete_at;
end;
$$;

revoke all on function public.request_account_deletion() from public, anon;
grant execute on function public.request_account_deletion() to authenticated;

create or replace function public.cancel_account_deletion()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  requesting_user_id uuid := auth.uid();
  deletion_deadline timestamptz;
begin
  if requesting_user_id is null then
    raise exception 'Authentication is required.';
  end if;

  select requests.permanently_delete_at
  into deletion_deadline
  from public.account_deletion_requests requests
  where requests.user_id = requesting_user_id;

  if deletion_deadline is null then
    return;
  end if;

  if deletion_deadline <= now() then
    raise exception 'The account recovery period has expired.';
  end if;

  delete from public.account_deletion_requests
  where user_id = requesting_user_id;
end;
$$;

revoke all on function public.cancel_account_deletion() from public, anon;
grant execute on function public.cancel_account_deletion() to authenticated;

comment on table public.account_deletion_requests is
  'Recoverable CitiesWalk account deletion requests. Auth deletion is finalized server-side after the 30-day deadline.';
