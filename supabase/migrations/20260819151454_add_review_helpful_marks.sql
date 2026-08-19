-- One Helpful mark per user per review, with a protected denormalised count.

alter table public.destination_reviews
  add column helpful_count integer not null default 0
  check (helpful_count >= 0);

revoke update on public.destination_reviews from authenticated;
grant update (
  author_name,
  rating,
  comment,
  is_anonymous,
  destination_name,
  destination_category
) on public.destination_reviews to authenticated;

create table public.review_helpful_marks (
  review_id uuid not null references public.destination_reviews(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (review_id, user_id)
);

create index review_helpful_marks_user_idx
  on public.review_helpful_marks (user_id);

create function public.sync_destination_review_helpful_count()
returns trigger
language plpgsql
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

create trigger sync_destination_review_helpful_count
after insert or delete on public.review_helpful_marks
for each row execute function public.sync_destination_review_helpful_count();

alter table public.review_helpful_marks enable row level security;
grant select, insert, delete on public.review_helpful_marks to authenticated;

create policy "users can view their own helpful marks"
on public.review_helpful_marks for select to authenticated
using (user_id = (select auth.uid()));

create policy "users can mark another user's published review helpful"
on public.review_helpful_marks for insert to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1 from public.destination_reviews review
    where review.id = review_helpful_marks.review_id
      and review.moderation_status = 'published'
      and review.user_id <> (select auth.uid())
  )
);

create policy "users can remove their own helpful marks"
on public.review_helpful_marks for delete to authenticated
using (user_id = (select auth.uid()));
