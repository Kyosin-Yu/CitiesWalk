# Eco-Route Navigation

This feature owns device-location access, destination discovery, train-and-walk
route previews, and local journey-start state.

## Current MVP behaviour

- Uses `geolocator` to request foreground location permission and read the
  device location.
- Falls back to a clearly labelled KL Sentral sample origin if permission or
  location services are unavailable.
- Provides local sample destinations and train-and-walk route data.
- Displays time, platform, walking distance, calories, estimated CO₂ savings,
  and step-by-step instructions.
- Receives `userId` from `AppShell` after authentication.

## Pending team configuration

The sample repository is intentionally replaceable. Before production routing,
the team must confirm the Nominatim usage configuration, OpenTripPlanner
endpoint, Malaysian GTFS feed, shared journey table, RLS policies, and final
journey status values. No Supabase journey data is written by this feature yet.
