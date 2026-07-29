# AGENTS.md

This file defines the working rules for developers and coding agents contributing
to CitiesWalk. Read this file and `README.md` before making changes.

## 1. Project Context

CitiesWalk is a Flutter mobile application for sustainable city travel. It
recommends walking and public-transport routes, records completed journeys,
estimates fitness and carbon outcomes, awards points, and supports destination
reviews.

The application is developed collaboratively by five team members. Changes must
be modular, reviewable, and safe to merge.

## 2. Current Priorities

Build a stable minimum viable product in this order:

1. Application foundation, theme, navigation, and environment configuration.
2. Authentication and user profile.
3. Map display and location permission.
4. Destination search and route preview.
5. Journey start, completion, and persistence.
6. Fitness and carbon estimates.
7. Rewards and leaderboard.
8. Community ratings and reviews.

Do not implement advanced background tracking, complex live navigation, or
real-time leaderboard behaviour until the related MVP flow works.

## 3. Architecture

Use a feature-first structure unless the existing repository clearly uses a
different established architecture:

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

Within a feature, separate UI, state, models, and data access when the feature
is large enough to justify it. Do not create unnecessary abstraction for a
single small widget or function.

Shared code belongs in `core/` only when at least two features use it.
Feature-specific code must stay inside its owning feature.

## 4. Module Ownership

| Module | Primary Owner |
|---|---|
| Eco-Route Navigation | Chua Thiam Poh |
| User Authentication and Profile | To be confirmed |
| Fitness and Carbon Analytics | To be confirmed |
| Rewards and Leaderboard | To be confirmed |
| Community Reviews | To be confirmed |

The primary owner reviews changes affecting their module. Cross-module changes
must be discussed with every affected owner before merging.

## 5. Eco-Route Navigation Contract

The Eco-Route Navigation module is responsible for:

- Requesting and handling location permission.
- Reading and displaying the user's current location.
- Searching for places and selecting a destination.
- Requesting walking and public-transport routes.
- Displaying route segments, distance, duration, and transit information.
- Producing step-by-step journey instructions.
- Starting, updating, and completing journeys.
- Supplying journey data to analytics, rewards, and reviews.

Use one shared journey model. It should support:

```text
journeyId
userId
originName
originLatitude
originLongitude
destinationName
destinationLatitude
destinationLongitude
startTime
endTime
totalDistanceKm
walkingDistanceKm
transitDistanceKm
durationMinutes
estimatedCalories
estimatedCarbonSavedKg
status
```

Use consistent units: kilometres for stored route distances, minutes for
duration, kilocalories for calories, and kilograms of CO2 equivalent for carbon
savings. Conversion for display belongs in the UI layer.

Journey statuses must use a shared enum or constants rather than unrelated
strings. Confirm the final status list with the team before database migration.

## 6. Coding Standards

- Follow Dart and Flutter recommended style.
- Run `dart format .` before committing.
- Use descriptive English names for files, classes, variables, and functions.
- Keep widgets small and focused; extract reusable widgets when it improves
  readability.
- Prefer immutable models and `const` widgets where practical.
- Avoid business logic inside widget `build` methods.
- Keep network and database operations in services or repositories.
- Handle loading, empty, success, permission-denied, offline, and error states.
- Do not silently catch exceptions. Provide a useful user message and retain
  diagnostic information suitable for development.
- Do not add packages when the Flutter or Dart SDK already provides a clear
  solution.
- Do not perform broad refactors while implementing an unrelated feature.

Follow the repository's existing state-management pattern after one is
established. Do not introduce a second state-management library without team
approval.

## 7. UI and Accessibility
### Design System

Before implementing any UI:

1. Read `DESIGN.md`.
2. Follow its color palette, typography, spacing, and component guidelines.
3. Reuse AppTheme and AppColors instead of hardcoding values.
4. Use Material 3 widgets.
5. Maintain a consistent eco-friendly visual identity across all screens.

- Use shared theme colours, typography, spacing, and components.
- Do not hard-code colours or text styles repeatedly inside feature screens.
- Support common Android screen sizes without overflow.
- Use meaningful labels and tooltips for interactive controls.
- Maintain sufficient colour contrast.
- Do not rely only on colour to communicate route state or errors.
- Display clear explanations before requesting sensitive permissions.
- Keep user-facing strings ready for future localisation where practical.

## 8. Supabase and Database Rules

- Use the shared Supabase client configuration.
- Never commit project secrets, passwords, private keys, or service-role keys.
- Never expose a Supabase service-role key in the Flutter application.
- Store secrets in the team's approved local environment configuration.
- Enable and test Row Level Security for user-owned data.
- A user must not be able to read or modify another user's private records
  unless the feature explicitly requires public data.
- Database schema changes require a reviewed migration or documented SQL script.
- Do not rename or remove shared tables or columns without team agreement.
- Store timestamps consistently in UTC and convert them for display.

## 9. External API Rules

- Keep map, place, and routing API access behind services.
- Do not call external APIs directly from UI widgets.
- Keep API-specific response models separate from domain models.
- Handle unavailable routes, quota errors, timeouts, and missing transit data.
- Cache only data allowed by the provider's terms.
- Do not claim that a route is safe unless verified safety data supports it.
- Record the source and version of carbon-emission factors.
- Treat calories and carbon savings as estimates and label them accordingly.

Do not scrape a website unless the team has confirmed that its terms permit the
planned use.

## 10. Testing and Quality Checks

Every completed task should include the most relevant tests:

- Unit tests for calculations, validation, mapping, and model conversion.
- Widget tests for important UI states and interactions.
- Integration tests for critical flows when feasible.
- Manual tests for GPS, permissions, maps, transit routes, and device-specific
  behaviour.

Before requesting review, run:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Do not say a task is complete if relevant checks fail. If an existing unrelated
failure blocks validation, report it clearly in the pull request.

## 11. Git Workflow

- Pull the latest team branch before starting.
- Use one focused branch per task.
- Recommended prefixes: `feature/`, `fix/`, `refactor/`, `test/`, and `docs/`.
- Do not commit generated build output, IDE settings, credentials, or local
  environment files.
- Keep commits small and meaningful.
- Do not push directly to the protected main branch.
- Open a pull request and request review from the affected module owner.
- Resolve merge conflicts carefully; do not discard another member's work.

Recommended commit examples:

```text
feat(eco-route): add destination search
fix(location): handle permanently denied permission
test(analytics): cover carbon saving calculation
docs: update project setup instructions
```

## 12. Rules for Coding Agents

Before editing:

1. Read `README.md`, this file, and any closer `AGENTS.md`.
2. Inspect `pubspec.yaml`, the relevant feature, and existing patterns.
3. Check the Git working tree and preserve unrelated user changes.
4. State assumptions when requirements are incomplete.

While editing:

- Make the smallest coherent change that satisfies the task.
- Reuse existing architecture and dependencies.
- Do not overwrite unrelated work.
- Do not change database schemas, authentication policies, API providers, or
  architecture without explicit approval.
- Do not insert real credentials or fabricate production configuration.
- Add or update tests when behaviour changes.

After editing:

1. Format changed Dart files.
2. Run static analysis and relevant tests.
3. Summarise changed files and behaviour.
4. Report checks that passed, failed, or could not run.
5. Identify any configuration the team must supply locally.

Coding agents may prepare code and commits only within the user's requested
scope. They must not push, merge, deploy, delete remote resources, or change
production data unless the user explicitly asks for that action.

## 13. Definition of Done

A task is done when:

- Its acceptance criteria are met.
- Loading, empty, permission, offline, and error behaviour is considered where
  relevant.
- Code follows the established architecture and style.
- Relevant tests are added or updated.
- Formatting, analysis, and tests have been run.
- No secrets or generated files are included.
- Documentation is updated when setup, data contracts, or behaviour changes.
- A teammate can review and understand the pull request.

## 14. Items the Team Must Confirm

Update this file after the team confirms:

- Final team member names and module ownership.
- State-management approach.
- Map, place-search, and routing providers.
- Environment-file convention.
- Database tables, policies, and migration process.
- Journey status values and shared formulas.
- Main development branch and pull-request approval rules.
- Minimum Flutter and Dart versions.

Until confirmed, follow existing repository patterns and ask before making a
decision that would affect multiple modules.
