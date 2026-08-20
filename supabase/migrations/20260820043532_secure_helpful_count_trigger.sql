-- Helpful marks are inserted/deleted by authenticated users, but the
-- denormalised counter must only be changed by this trigger.  Running the
-- trigger function as its owner avoids granting clients direct UPDATE access
-- to destination_reviews.helpful_count.
create or replace function public.sync_destination_review_helpful_count()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    update public.destination_reviews
    set helpful_count = helpful_count + 1
    where id = new.review_id;
    return new;
  end if;

  update public.destination_reviews
  set helpful_count = greatest(helpful_count - 1, 0)
  where id = old.review_id;
  return old;
end;
$$;

-- This is a trigger-only function; clients cannot call it through the Data API.
revoke all on function public.sync_destination_review_helpful_count() from public;
