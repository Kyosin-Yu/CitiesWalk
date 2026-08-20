-- An early end keeps the measured progress for the owner's history but must
-- remain distinct from a completed journey used by Fitness and Rewards.
alter table public.eco_journeys
  drop constraint if exists eco_journeys_status_check;

alter table public.eco_journeys
  add constraint eco_journeys_status_check
  check (
    status in (
      'preview',
      'in_progress',
      'paused',
      'completed',
      'cancelled',
      'ended_early'
    )
  );
