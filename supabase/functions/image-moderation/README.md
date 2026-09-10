# Shared Image Moderation

This Edge Function checks selected review and profile images with Google Cloud
Vision SafeSearch before the mobile app uploads them to Supabase Storage.

It rejects images that Vision rates `LIKELY` or `VERY_LIKELY` for adult, racy,
or violent content. It requires an authenticated CitiesWalk user and uses the
existing server-side `GOOGLE_CLOUD_VISION_API_KEY` secret.
