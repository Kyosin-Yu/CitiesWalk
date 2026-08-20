-- Community Reviews: data, private image storage, reporting, and Row Level Security.
-- Applied remotely as migration 20260819145403_create_destination_reviews.

create table public.destination_reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  destination_id text not null,
  destination_name text not null,
  destination_category text,
  author_name text not null,
  rating smallint not null check (rating between 1 and 5),
  comment text not null check (char_length(btrim(comment)) between 1 and 500),
  is_anonymous boolean not null default false,
  moderation_status text not null default 'published'
    check (moderation_status in ('published', 'hidden', 'removed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint destination_reviews_one_per_user_destination
    unique (user_id, destination_id)
);

create index destination_reviews_published_destination_created_idx
  on public.destination_reviews (destination_id, created_at desc)
  where moderation_status = 'published';

create table public.review_photos (
  id uuid primary key default gen_random_uuid(),
  review_id uuid not null references public.destination_reviews(id) on delete cascade,
  storage_path text not null unique,
  position smallint not null check (position between 0 and 4),
  created_at timestamptz not null default now(),
  constraint review_photos_one_position_per_review unique (review_id, position)
);

create table public.review_reports (
  id uuid primary key default gen_random_uuid(),
  review_id uuid not null references public.destination_reviews(id) on delete cascade,
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  reason text not null check (reason in ('spam', 'offensive', 'misleading', 'other')),
  details text check (details is null or char_length(btrim(details)) <= 500),
  status text not null default 'open'
    check (status in ('open', 'resolved', 'dismissed')),
  created_at timestamptz not null default now(),
  constraint review_reports_one_per_user unique (review_id, reporter_id)
);

create index review_reports_open_created_idx
  on public.review_reports (status, created_at asc)
  where status = 'open';

create function public.set_destination_review_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_destination_review_updated_at
before update on public.destination_reviews
for each row execute function public.set_destination_review_updated_at();

alter table public.destination_reviews enable row level security;
alter table public.review_photos enable row level security;
alter table public.review_reports enable row level security;

grant select, insert, update, delete on public.destination_reviews to authenticated;
grant select, insert, update, delete on public.review_photos to authenticated;
grant select, insert on public.review_reports to authenticated;

create policy "published reviews are visible and owners can see their own"
on public.destination_reviews for select to authenticated
using (moderation_status = 'published' or user_id = (select auth.uid()));

create policy "users can create one published review for themselves"
on public.destination_reviews for insert to authenticated
with check (
  user_id = (select auth.uid())
  and moderation_status = 'published'
  and author_name <> ''
);

create policy "users can edit their published reviews"
on public.destination_reviews for update to authenticated
using (user_id = (select auth.uid()) and moderation_status = 'published')
with check (user_id = (select auth.uid()) and moderation_status = 'published');

create policy "users can delete their own reviews"
on public.destination_reviews for delete to authenticated
using (user_id = (select auth.uid()));

create policy "published review photos are visible and owners can see their own"
on public.review_photos for select to authenticated
using (
  exists (
    select 1 from public.destination_reviews review
    where review.id = review_photos.review_id
      and (review.moderation_status = 'published'
        or review.user_id = (select auth.uid()))
  )
);

create policy "owners can add photos to their published reviews"
on public.review_photos for insert to authenticated
with check (
  exists (
    select 1 from public.destination_reviews review
    where review.id = review_photos.review_id
      and review.user_id = (select auth.uid())
      and review.moderation_status = 'published'
  )
);

create policy "owners can update photos on their published reviews"
on public.review_photos for update to authenticated
using (
  exists (
    select 1 from public.destination_reviews review
    where review.id = review_photos.review_id
      and review.user_id = (select auth.uid())
      and review.moderation_status = 'published'
  )
)
with check (
  exists (
    select 1 from public.destination_reviews review
    where review.id = review_photos.review_id
      and review.user_id = (select auth.uid())
      and review.moderation_status = 'published'
  )
);

create policy "owners can delete photos from their reviews"
on public.review_photos for delete to authenticated
using (
  exists (
    select 1 from public.destination_reviews review
    where review.id = review_photos.review_id
      and review.user_id = (select auth.uid())
  )
);

create policy "users can view their own reports"
on public.review_reports for select to authenticated
using (reporter_id = (select auth.uid()));

create policy "users can report another user's published review once"
on public.review_reports for insert to authenticated
with check (
  reporter_id = (select auth.uid())
  and exists (
    select 1 from public.destination_reviews review
    where review.id = review_reports.review_id
      and review.moderation_status = 'published'
      and review.user_id <> (select auth.uid())
  )
);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'review-photos',
  'review-photos',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
);

create policy "review photos can be read when their review is visible"
on storage.objects for select to authenticated
using (
  bucket_id = 'review-photos'
  and exists (
    select 1 from public.review_photos photo
    join public.destination_reviews review on review.id = photo.review_id
    where photo.storage_path = name
      and (review.moderation_status = 'published'
        or review.user_id = (select auth.uid()))
  )
);

create policy "review owners can upload photo objects"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'review-photos'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
  and exists (
    select 1 from public.destination_reviews review
    where review.id::text = (storage.foldername(name))[2]
      and review.user_id = (select auth.uid())
      and review.moderation_status = 'published'
  )
);

create policy "review owners can update photo objects"
on storage.objects for update to authenticated
using (
  bucket_id = 'review-photos'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
  and exists (
    select 1 from public.review_photos photo
    join public.destination_reviews review on review.id = photo.review_id
    where photo.storage_path = name
      and review.user_id = (select auth.uid())
      and review.moderation_status = 'published'
  )
)
with check (
  bucket_id = 'review-photos'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
  and exists (
    select 1 from public.destination_reviews review
    where review.id::text = (storage.foldername(name))[2]
      and review.user_id = (select auth.uid())
      and review.moderation_status = 'published'
  )
);

create policy "review owners can delete photo objects"
on storage.objects for delete to authenticated
using (
  bucket_id = 'review-photos'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
  and exists (
    select 1 from public.review_photos photo
    join public.destination_reviews review on review.id = photo.review_id
    where photo.storage_path = name
      and review.user_id = (select auth.uid())
  )
);
