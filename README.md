# CitiesWalk

CitiesWalk is a Flutter mobile application that encourages tourists and local
travellers to explore cities using walking and public transport. The application
combines eco-route navigation, fitness tracking, carbon-savings estimates,
rewards, and community reviews in one platform.

This project is developed for **BMSE3004 Collaborative Development** at
Tunku Abdul Rahman University of Management and Technology (TAR UMT).

## Project Objectives

- Recommend routes that prioritise walking and public transport.
- Help users discover landmarks, attractions, and food destinations.
- Estimate walking distance, calories burned, and carbon emissions saved.
- Motivate sustainable travel through rewards and leaderboards.
- Allow users to share ratings and reviews of visited places.

## Main Modules

| Module | Main Responsibilities |
|---|---|
| User Authentication and Profile | Registration, login, profile management, preferences, and account security |
| Eco-Route Navigation | Current location, destination search, walking and transit routes, route estimates, and journey guidance |
| Fitness and Carbon Analytics | Steps, distance, calories, journey history, and estimated carbon savings |
| Rewards and Leaderboard | Points, badges, achievements, challenges, and leaderboard rankings |
| Community Reviews | Place ratings, written reviews, photos, and destination feedback |

## Core User Flow

1. The user registers or signs in.
2. The user searches for a destination.
3. CitiesWalk recommends a walking and public-transport route.
4. The user reviews the distance, duration, transit details, estimated calories,
   and estimated carbon savings.
5. The user starts and completes the journey.
6. The completed journey updates the user's analytics and rewards.
7. The user may rate and review the destination.

## Technology Stack

- **Frontend:** Flutter and Dart
- **Backend:** Supabase
- **Database:** PostgreSQL through Supabase
- **Authentication:** Supabase Auth
- **Map Display:** Google Maps Platform with `google_maps_flutter`
- **Location Services:** Device GPS with `geolocator`
- **Place Search:** Google Places API (New), accessed through a Supabase Edge Function
- **Walking and Public-Transport Routing:** Google Routes API, accessed through a Supabase Edge Function
- **State Management:** Provider with `ChangeNotifier`
- **Version Control:** Git and GitHub
- **Project Management:** Trello

> Google Maps Platform provides the interactive map, place discovery, and route
> geometry. The Google Places and Routes calls are made only by the Supabase
> Edge Function, so the Google server key is not distributed in the app.
> External map, search, routing, and Supabase operations must be placed behind
> replaceable services or repositories so providers can be changed without
> rewriting the application UI.
>
> The Eco-Route module requests train-and-walk routes only. When a qualifying
> rail itinerary is unavailable, it may present a walking-only route rather than
> suggesting a car, taxi, or e-hailing trip. API availability, coverage, quotas,
> and costs must be reviewed before production deployment.

## Project Architecture

```text
lib/
├── app/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_theme.dart
│   │   └── app_theme.dart
│   └── app.dart
├── core/
│   ├── constants/
│   ├── models/
│   ├── services/
│   └── utils/
├── features/
│   ├── authentication/
│   ├── eco_route/
│   ├── analytics/
│   ├── rewards/
│   └── reviews/
└── main.dart
```

Each feature should contain its own presentation, model, service, and state
management files where applicable. The exact structure may be adjusted after
the team agrees on the application architecture.

## Getting Started

### Prerequisites

- Flutter SDK 3.44.2, which includes Dart SDK 3.12.2
- Android Studio or Visual Studio Code
- Android emulator or physical Android device
- Git
- Access to the project's Supabase instance
- API credentials for the selected mapping and routing services

### Installation

```bash
git clone https://github.com/Kyosin-Yu/CitiesWalk.git
cd CitiesWalk
flutter pub get
```

Create the required local environment configuration using the template provided
by the team. Do not commit API keys, passwords, service-role keys, or other
secrets to GitHub.

### Authentication deep-link setup

Google login uses Supabase Auth and the mobile redirect URL
`com.citieswalk.citieswalk://login-callback/`. Before testing it:

1. Create a Web OAuth client in Google Auth Platform.
2. Add the Supabase callback URL shown in **Authentication > Providers >
   Google** to the Google client's authorised redirect URIs.
3. Enable Google in the Supabase Auth providers page and enter the Web client ID
   and client secret there. Never add the client secret to this repository.
4. Add `com.citieswalk.citieswalk://login-callback/` to **Authentication > URL
   Configuration > Redirect URLs** in Supabase.

The Flutter app stores only the Supabase publishable key. Google credentials
remain in Google Cloud and Supabase configuration.

Password recovery uses the same mobile callback. Keep
`com.citieswalk.citieswalk://login-callback/` as both the **Site URL** and an
entry under **Authentication > URL Configuration > Redirect URLs** so a
reset-email link can reopen CitiesWalk and show the new-password form. Test
recovery emails on a device or emulator where CitiesWalk is installed, request
only one email, and use the newest link.

### Android fitness data setup

CitiesWalk reads today's steps, walking/running distance, and active calories
through Google Health Connect. This authorization is separate from Google
login: users must connect Health Connect from the Fitness page and grant the
three read-only permissions.

- Use an Android 9 (API 28) or newer physical device with Google Play services.
- On Android 14 or newer, Health Connect is built into Android Settings.
- On Android 13 or older, install Health Connect from Google Play when prompted.
- Ensure Google Fit or another activity app is configured to write its data to
  Health Connect if that app is the desired data source.

Health Connect data replaces only today's dashboard steps, distance, and active
calories. Eco Route remains the source for CO2 savings, route history, rewards,
and verified journey completion. No health data is uploaded to Supabase by this
integration.

Run the application:

```bash
flutter run
```

## Development Commands

```bash
# Install dependencies
flutter pub get

# Format Dart files
dart format .

# Run static analysis
flutter analyze

# Run automated tests
flutter test

# Start the application
flutter run
```

## Shared Journey Data

Modules should exchange journey information through one agreed model containing
at least:

- Journey ID and user ID
- Origin and destination names and coordinates
- Start time and end time
- Total, walking, and transit distances
- Estimated duration
- Estimated calories burned
- Estimated carbon saved
- Journey status

Carbon savings and calories are estimates. Their formulas, units, assumptions,
and data sources must be documented before results are shown to users.

An in-progress Eco-Route journey is saved only while tracking. It becomes a
completed history record only after the latest GPS point reaches the selected
destination. Cancelling an unfinished journey deletes its record and GPS points.
Completed journeys store GPS-derived walking and transit distance separately;
the displayed step count is an estimate derived from walking distance, not a
hardware pedometer count.

Completing an eligible journey atomically inserts its immutable Rewards
transaction through a private database trigger. Reward policy `v1` rounds the
walking distance and carbon saving to three decimal places, then awards
`round(30 × walking km + 45 × carbon kg)` points. Very short journeys may
therefore earn zero points, but their zero-point transaction is still retained
and displayed in Points History. The unique journey constraint keeps repeated
completion attempts idempotent.

## Team Workflow

1. Create or select a GitHub issue or Trello task.
2. Pull the latest changes from the shared development branch.
3. Create a focused feature branch.
4. Implement and test only the assigned task.
5. Format and analyse the project before committing.
6. Push the branch and open a pull request.
7. Request review before merging.

Example branch names:

```text
feature/eco-route-search
feature/journey-history
fix/location-permission
docs/update-readme
```

## Team Members

| Member | Role | Assigned Module |
|---|---|---|
| CHUA THIAM POH | Project Manager / Developer | Eco-Route Navigation |
| KOH HUAI YU | Requirement Leader / Developer | User Authentication and Profile |
| ENG ZHEN XIN |  / Coding Developer | Fitness and Carbon Analytics |
| LAI YU WAI | Design Leader / Developer | Rewards and Leaderboard |
| TAN YAN ZUN | Testing Leader / Developer | Community Reviews |

## Scope and Limitations

- The first release focuses on route preview rather than full turn-by-turn live
  navigation.
- Routes should be described as recommended pedestrian and public-transport
  routes unless verified safety data is available.
- Background location tracking is an advanced feature and depends on Android and
  iOS restrictions.
- Carbon savings are estimates based on a documented comparison with car travel.
- Route and place availability depend on Google Maps Platform coverage,
  the user’s network connection, and the enabled Google APIs.

## Documentation

- Project proposal: maintained by the team
- Development rules for contributors and coding agents: `AGENTS.md`
- API and database documentation: to be added as the implementation develops

## License

This is an academic project. Add a licence only after the team and course
supervisor confirm the intended usage and distribution terms.
