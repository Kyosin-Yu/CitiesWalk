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
- **Map Display:** OpenStreetMap with `flutter_map`
- **Location Services:** Device GPS with `geolocator`
- **Place Search:** Nominatim
- **Walking and Public-Transport Routing:** OpenTripPlanner
- **Transit Schedule Data:** Malaysia GTFS Static
- **Live Transit Data:** Malaysia GTFS Realtime, where available
- **State Management:** Provider with `ChangeNotifier`
- **Version Control:** Git and GitHub
- **Project Management:** Trello

> OpenTripPlanner combines OpenStreetMap walking-network data with Malaysia
> GTFS transit schedules to generate walking and public-transport routes.
> External map, search, routing, and Supabase operations must be placed behind
> replaceable services or repositories so providers can be changed without
> rewriting the application UI.
>
> During early development, sample routing data may be used until the
> OpenTripPlanner server and required Malaysian GTFS feeds are configured.
> API availability, data coverage, usage policies, quotas, hosting requirements,
> and costs must be reviewed before production deployment.

## Suggested Project Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── models/
│   ├── services/
│   ├── theme/
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

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android emulator or physical Android device
- Git
- Access to the project's Supabase instance
- API credentials for the selected mapping and routing services

### Installation

```bash
git clone <repository-url>
cd CitiesWalk
flutter pub get
```

Create the required local environment configuration using the template provided
by the team. Do not commit API keys, passwords, service-role keys, or other
secrets to GitHub.

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
- Transit route quality and availability depend on the selected external API.

## Documentation

- Project proposal: maintained by the team
- Development rules for contributors and coding agents: `AGENTS.md`
- API and database documentation: to be added as the implementation develops

## License

This is an academic project. Add a licence only after the team and course
supervisor confirm the intended usage and distribution terms.
