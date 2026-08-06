# AGENTS.md

This file defines the working rules for developers and coding agents
contributing to CitiesWalk. Read this file, `README.md`, and `DESIGN.md` before
making changes.

## 1. Project Context

CitiesWalk is a Flutter mobile application for sustainable city travel. It
recommends walking and public-transport routes, records completed journeys,
estimates fitness and carbon outcomes, awards points, and supports destination
reviews.

The application is developed collaboratively by five team members. Changes must
be modular, reviewable, and safe to merge.

## 2. Current Priorities

The project aims to deliver the complete CitiesWalk system across all five
modules. Build a stable minimum viable product in this order:

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

For whole-system development, complete the project incrementally. Each milestone
must compile, be reviewable, and preserve the existing integrated flow.

When requirements are not confirmed:

- Keep feature UI, state, repositories, and external services separated.
- Define clear contracts between modules.
- Hide Supabase and external API details behind repositories or services.
- Use clearly labelled sample or in-memory implementations when required.
- Do not invent final business rules, database schemas, API configurations, or
  calculation formulas.
- Document unresolved decisions and keep their implementations replaceable.
- Update documentation and tests when a confirmed requirement changes.

## 3. Architecture

Use the established feature-first **three-layer architecture**. The project is
feature-first at the top level, while each sufficiently large feature uses the
same Presentation, Business Logic, and Data layers.

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
│   │   ├── presentation/
│   │   │   ├── controllers/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   ├── business/
│   │   │   ├── models/
│   │   │   └── services/
│   │   └── data/
│   │       ├── repositories/
│   │       └── datasources/
│   ├── analytics/
│   ├── rewards/
│   └── reviews/
└── main.dart
```

Directory responsibilities:

- `app/` contains the root application widget, application navigation, and
  shared theme.
- `core/` contains code used by at least two features.
- `features/` contains the functional modules.
- `main.dart` is limited to application startup and global initialization.

Within a sufficiently large feature, use these layers consistently:

- `presentation/` is the **Presentation Layer**. It contains pages, widgets,
  and Provider `ChangeNotifier` controllers. It must not call APIs, Supabase,
  or device plugins directly.
- `business/` is the **Business Logic Layer**. It contains feature-specific
  models, calculation or decision services, and business rules. It does not
  depend on Flutter UI widgets or provider-specific response models.
- `data/` is the **Data Layer**. It contains repository implementations,
  data sources, API clients, Supabase access, and provider-specific mapping.
  It supplies data to the Business Logic Layer through repository contracts.

For small features, do not create an empty folder only to satisfy this tree.
Create a layer folder when it has a real responsibility or file.

Existing modules do not need to be moved just to match this structure. New
features and files should follow it, and existing modules should be migrated
only as part of a separately agreed refactoring task.

Do not create unnecessary abstractions or empty directories for a single small
widget or function.

Do not move the established theme from `app/theme/` to `core/theme/`.

Shared code belongs in `core/` only when at least two features use it. Shared
models and services belong in `core/models/` and `core/services/`; otherwise,
feature-specific models and services remain inside that feature's `business/`
layer.

Features must communicate through models, services, and repository contracts.
A feature must not import another feature's screens or internal state.

## 4. Module Ownership

| Module | Primary Owner |
|---|---|
| Eco-Route Navigation | Chua Thiam Poh |
| User Authentication and Profile | Koh Huai Yu |
| Fitness and Carbon Analytics | Eng Zhen Xin |
| Rewards and Leaderboard | Lai Yu Wai |
| Community Reviews | Tan Yan Zun |

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
- Supplying completed journey data to analytics, rewards, and reviews.

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

Use consistent units:

- Kilometres for stored route distances.
- Minutes for journey duration.
- Kilocalories for estimated calories.
- Kilograms of CO2 equivalent for estimated carbon savings.
- UTC for stored timestamps.

Unit and time conversion for display belongs in the UI layer.

Journey statuses must use a shared enum or constants instead of unrelated
strings. The final status list must be confirmed before creating a database
migration.

## 6. Whole-System Module Contracts

All five modules form part of the MVP. Modules must integrate through explicit
models, services, and repositories.

### 6.1 Authentication and Profile

The Authentication and Profile module must:

- Handle registration, login, logout, and session state.
- Support user profile viewing and editing.
- Supply the authenticated user identifier to user-owned features.
- Keep authentication and Supabase operations outside UI widgets.
- Handle authentication loading, validation, and failure states.

### 6.2 Fitness and Carbon Analytics

The Analytics module must:

- Consume completed journey data.
- Display journey history.
- Calculate aggregate walking distance.
- Estimate calories burned.
- Estimate carbon emissions saved.
- Keep calculations in testable utilities or services.
- Clearly label calories and carbon outcomes as estimates.
- Document the source, version, units, and assumptions of each formula.

### 6.3 Rewards and Leaderboard

The Rewards module must:

- Consume eligible completed journeys or analytics outcomes.
- Award points through one documented and testable policy.
- Prevent duplicate rewards for the same journey.
- Display user points, achievements, and leaderboard information.
- Use an MVP snapshot leaderboard; real-time behaviour is not required.
- Keep the points and achievement rules replaceable until confirmed.

### 6.4 Community Reviews

The Reviews module must:

- Associate ratings and reviews with a user and destination.
- Validate rating and written-review input.
- Allow only permitted owner operations for user-owned data.
- Use the selected or completed journey destination where appropriate.
- Support text reviews for the MVP without requiring photo upload.
- Handle empty, loading, submission, and error states.

### 6.5 Integration Rules

- Authentication supplies `userId` to journeys, rewards, and reviews.
- Eco-Route creates, updates, and completes the shared journey record.
- Analytics reads completed journeys and produces fitness and carbon estimates.
- Rewards processes each eligible journey only once.
- Reviews use the destination from a selected or completed journey.
- Cross-feature models belong in `core/models/`.
- Feature-only models remain in the owning feature.
- Features must not directly modify another feature's internal state.

## 7. Coding Standards

- Use Flutter 3.44.2 with its bundled Dart 3.12.2.
- Use Provider with `ChangeNotifier` for application state management.
- Do not introduce another state-management library without team approval.
- Follow recommended Dart and Flutter style.
- Run `dart format .` before committing.
- Use descriptive English names for files, classes, variables, and functions.
- Keep widgets small and focused.
- Prefer immutable models and `const` widgets where practical.
- Avoid business logic inside widget `build` methods.
- Keep network and database operations in services or repositories.
- Do not silently catch exceptions.
- Show useful user-facing error messages while preserving diagnostic information
  for development.
- Handle loading, empty, success, offline, permission-denied, and error states
  where relevant.
- Do not add packages when the Flutter or Dart SDK already provides a clear
  solution.
- Do not perform broad refactoring while implementing an unrelated feature.
- Add or update tests whenever behaviour changes.

## 8. UI and Accessibility

Read `DESIGN.md` before implementing or changing UI.

- Use Material 3 widgets.
- Reuse `AppTheme`, `AppColors`, and other established design tokens.
- Maintain the shared eco-friendly visual identity.
- Do not repeatedly hard-code equivalent colours, spacing, or text styles.
- Keep screens responsive on common Android screen sizes.
- Prevent text and layout overflow.
- Use meaningful labels and tooltips for interactive controls.
- Maintain sufficient colour contrast.
- Do not rely only on colour to communicate status or errors.
- Explain why a sensitive permission is needed before requesting it.
- Keep user-facing strings ready for future localisation where practical.
- Display calories and carbon savings clearly as estimates.
- Do not describe a route as safe unless verified safety data supports that
  statement.

## 9. Supabase and Database Rules

- Use the shared Supabase client configuration.
- Keep Supabase access behind repositories or services.
- Never commit project secrets, passwords, private keys, or service-role keys.
- Never expose a Supabase service-role key in the Flutter application.
- Store secrets using the team's approved local environment configuration.
- Enable and test Row Level Security for user-owned data.
- A user must not access another user's private records unless the feature
  explicitly requires public data.
- Database changes require a reviewed migration or documented SQL script.
- Do not rename or remove shared tables or columns without team agreement.
- Store timestamps consistently in UTC and convert them for display.
- Do not invent the final database schema or security policies before team
  confirmation.

## 10. External API Rules

Use the following confirmed technologies:

- OpenStreetMap with `flutter_map` for map display.
- `geolocator` for device location.
- Nominatim for place search.
- OpenTripPlanner for walking and public-transport routing.
- Malaysian GTFS Static data for transit schedules.
- GTFS Realtime only where suitable data is available.

External API requirements:

- Keep map, location, place-search, and routing access behind services.
- Do not call external APIs directly from UI widgets.
- Keep provider-specific response models separate from domain models.
- Handle unavailable routes, quota errors, timeouts, offline conditions, and
  missing transit data.
- Follow provider usage policies and attribution requirements.
- Cache only data permitted by the provider's terms.
- Do not scrape websites unless the team confirms that their terms permit it.
- Do not claim that a route is safe without verified supporting data.
- Record the source and version of carbon-emission factors.
- Treat calories and carbon savings as estimates.
- Use sample data when the OpenTripPlanner server or GTFS feeds are unavailable,
  and clearly label it as sample data.

## 11. Testing and Quality Checks

Every completed task should include the most relevant tests:

- Unit tests for calculations, validation, mapping, and model conversion.
- Widget tests for important UI states and interactions.
- Integration tests for critical flows when feasible.
- Manual tests for GPS, location permission, maps, transit routes, and
  device-specific behaviour.

Before requesting review, run:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Do not claim that a task is complete if relevant checks fail.

If a check cannot run, or an unrelated existing failure blocks validation,
record the exact failure in the pull request.

## 12. Git Workflow

Use a branch-and-pull-request workflow. Do not develop or push directly to the
protected `main` branch.

### 12.1 Starting a Task

Update `main` before creating a task branch:

```bash
git switch main
git pull origin main
git switch -c <branch-name>
```

Use one focused branch per task.

Allowed branch prefixes:

| Change | Prefix | Example |
|---|---|---|
| New feature | `feature/` | `feature/eco-route-search` |
| Bug fix | `fix/` | `fix/location-permission` |
| Refactoring | `refactor/` | `refactor/journey-repository` |
| Testing | `test/` | `test/carbon-calculation` |
| Documentation | `docs/` | `docs/update-readme` |
| Configuration | `chore/` | `chore/update-dependencies` |

Branch names must be lowercase, use hyphens between words, and describe one
specific task.

### 12.2 Before Committing

Review and validate the changes:

```bash
git status
git diff
dart format .
flutter analyze
flutter test
```

Stage only files related to the task:

```bash
git add <file-path>
git diff --staged
```

Create a meaningful commit:

```bash
git commit -m "feat(eco-route): add destination search"
```

Use this commit-message format:

```text
<type>(<scope>): <short description>
```

Recommended types are `feat`, `fix`, `refactor`, `test`, `docs`, and `chore`.

Examples:

```text
feat(eco-route): add destination search
fix(location): handle permanently denied permission
test(analytics): cover carbon saving calculation
docs: update project setup instructions
```

Avoid unclear messages such as `changes`, `final`, `done`, or `update code`.

### 12.3 Push and Pull Request

Push the task branch:

```bash
git push -u origin <branch-name>
```

Open a pull request into `main`, or into the team's confirmed development
branch.

The pull request must describe:

- The implemented changes.
- The modules and important files affected.
- Testing performed and its results.
- Configuration, dependency, database, or API changes.
- Known limitations or unfinished work.
- The affected module owners who must review it.

Include screenshots or recordings when the change affects visible UI.

Request review from the primary owner of every affected module. Do not merge
until the acceptance criteria are met, required checks pass, conflicts are
resolved, and the required reviewers approve the change.

### 12.4 After Merging

Update the local `main` branch:

```bash
git switch main
git pull origin main
git branch -d <branch-name>
```

Delete the local branch only after confirming that the pull request was merged.
Then update the related Trello task or GitHub issue.

### 12.5 Git Safety Rules

- Do not commit secrets, generated builds, or unrelated changes.
- Do not force-push a shared branch without explicit team approval.
- Do not discard another member's work while resolving conflicts.
- Review every conflict instead of automatically accepting one side.
- Do not combine unrelated tasks in one branch or pull request.
- Do not merge while required checks are failing.
- Do not delete or rewrite shared Git history without team approval.

## 13. Rules for Coding Agents

Before editing:

1. Read `README.md`, this file, `DESIGN.md`, and any closer `AGENTS.md`.
2. Inspect `pubspec.yaml`, the relevant feature, and existing patterns.
3. Check the Git working tree and preserve unrelated changes.
4. State assumptions when requirements are incomplete.

While editing:

- Make the smallest coherent change that satisfies the task.
- For a whole-system request, work milestone by milestone in the priority order
  defined in Section 2.
- Keep every milestone compilable and reviewable.
- Reuse the existing architecture and dependencies.
- Do not overwrite unrelated work.
- Do not change database schemas, authentication policies, API providers, or
  architecture without explicit approval.
- Do not insert real credentials or fabricate production configuration.
- Add or update tests when behaviour changes.
- Do not stop after implementing only Eco-Route when the user requests the
  complete system.

After editing:

1. Format the changed Dart files.
2. Run static analysis and relevant tests.
3. Summarise the changed files and behaviour.
4. Report checks that passed, failed, or could not run.
5. Identify configuration the team must provide locally.

Coding agents may prepare code and commits only within the user's requested
scope. They must not push, merge, deploy, delete remote resources, or change
production data unless the user explicitly requests that action.

## 14. Definition of Done

A task is complete when:

- Its acceptance criteria are satisfied.
- Loading, empty, permission, offline, and error behaviour has been considered
  where relevant.
- Code follows the established architecture and coding standards.
- Relevant tests have been added or updated.
- Formatting, analysis, and tests have been run.
- No secrets or generated files are included.
- Documentation is updated when setup, contracts, or behaviour changes.
- A teammate can review and understand the pull request.

## 15. Items the Team Must Confirm

The team must confirm the following decisions before their final
implementation:

- Environment-file convention, such as `.env` or `--dart-define`.
- Database tables, Row Level Security policies, and migration process.
- Journey status values.
- Fitness, carbon-saving, and reward formulas.
- Main development branch and pull-request approval rules.
- OpenTripPlanner hosting and deployment configuration.

After confirming a decision, document it in the relevant section and remove it
from this list.

Until then, follow existing repository patterns and ask the team before making a
decision that could affect multiple modules.
