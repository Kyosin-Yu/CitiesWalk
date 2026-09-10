# Review Image Moderation

This Edge Function checks a locally selected review photo with Google Cloud
Vision SafeSearch before the app allows it to be attached to a review.

Before deploying, enable the Vision API for the team's Google Cloud project and
set its server-side key as a Supabase secret. Do not put this key in Flutter or
commit it to the repository.

```text
supabase secrets set GOOGLE_CLOUD_VISION_API_KEY=<server-side-key>
supabase functions deploy review-image-moderation
```

The function rejects photos when Vision reports `LIKELY` or `VERY_LIKELY` for
adult, racy, or violent content. If the function or provider is unavailable,
the app fails closed and does not attach the photo.
