-- Review destinations come from Eco-Route and must not be editable by a review owner.
revoke update (destination_name, destination_category)
on public.destination_reviews from authenticated;
