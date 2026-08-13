
-- RLS restricts every record to its owning authenticated user. These grants
-- expose only the required tables to the Supabase Data API for that role.
grant select, insert, update, delete on table public.eco_journeys to authenticated;
grant select, insert, update, delete on table public.eco_route_steps to authenticated;
