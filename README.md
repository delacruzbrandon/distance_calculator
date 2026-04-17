# Distance Calculator

A Flutter mobile app that tracks your real-time GPS distance to a fixed target location. Start tracking, and the app polls your device's GPS every 5 seconds — computing how far you are from the target, showing it live on screen, and saving every reading to local storage.

---

## What It Does

- **Live distance tracking** — polls GPS every 5 seconds and calculates distance using the Haversine formula
- **Human-readable distance** — displays meters when under 1 km, switches to kilometers above that
- **Reading history** — shows the last 5, 10, 15, or 20 readings in a filterable list
- **Local persistence** — every reading is saved to a local Hive database, surviving app restarts
- **Lifecycle-aware** — automatically pauses and resumes tracking when the app is backgrounded or foregrounded
- **Remote target** — fetches the target coordinates from an API on session start

---

## Tech Stack

| Concern | Library |
|---|---|
| State management | `flutter_bloc` (Cubit) |
| Dependency injection | `get_it` |
| HTTP client | `dio` |
| Local storage | `hive` + `hive_flutter` |
| Location services | `geolocator` |
| Reactive streams | `rxdart` |
| Value equality | `equatable` |
| Code generation | `build_runner` + `hive_generator` |

---

## Architecture

Clean Architecture with BLoC state management and GetIt for dependency injection.

```
lib/
├── main.dart                         # Entry point: init Hive, GetIt, MultiBlocProvider
├── core/
│   ├── di/
│   │   ├── dependencies.dart         # GetIt registrations (singletons, factories)
│   │   └── provider.dart             # BlocProvider list
│   └── widgets/
│       └── filter_dropdown.dart      # Reusable history filter UI
└── src/
    ├── domain/                        # Pure business logic — no Flutter imports
    │   ├── entities/
    │   │   ├── target_location.dart  # Haversine distance calculation lives here
    │   │   └── location_reading.dart # Hive @HiveType model for a GPS reading
    │   └── repositories/
    │       └── location_repository.dart  # Abstract interface
    ├── data/
    │   ├── repositories/
    │   │   └── location_repository_impl.dart  # Dio (API) + Hive (storage) impl
    │   └── constants/
    │       └── app_constants.dart    # API base URL and endpoints
    └── presentation/
        ├── home_cubit.dart           # Core logic: tracking lifecycle, GPS polling
        ├── home_state.dart           # Sealed states: Idle, Loading, TrackingStart, TrackingEnd, Error
        ├── home_screen.dart          # Root screen
        ├── home_content.dart         # Main UI with BlocBuilder
        └── filter_cubit.dart         # Simple state for the history filter dropdown
```

### Data Flow

1. User taps **Start** → `HomeCubit` requests location permission via `geolocator`
2. `HomeCubit` calls `LocationRepository.getTargetLocation()` → fetches target lat/lng from the API
3. A `Timer.periodic` fires every 5 seconds → gets current device position
4. `TargetLocation.distanceTo()` computes the Haversine distance
5. The `LocationReading` is written to the Hive box
6. `TrackingStart` state is emitted → UI rebuilds with updated distance and history
7. User taps **Stop** → `TrackingEnd` state emitted with the full session history

### Dependency Injection (GetIt)

| Lifetime | Dependency |
|---|---|
| Singleton | `Dio`, Hive `Box<LocationReading>` |
| Lazy Singleton | `LocationRepository` |
| Factory | `HomeCubit`, `FilterCubit` |

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.10.8 or newer
- A connected device or emulator with **location services enabled**
- Location permissions granted to the app at runtime

### Install & Run

```bash
# Install dependencies
flutter pub get

# Run on a connected device or emulator
`flutter run` OR `flutter run lib/main.dart`
```

### Regenerate Hive Adapters

Run this any time you modify a class annotated with `@HiveType` or `@HiveField`:

```bash
flutter pub run build_runner build
```

### Other Useful Commands

```bash
flutter test        # Run the test suite
flutter analyze     # Static analysis / lint
flutter build apk   # Build Android APK
flutter build ios   # Build iOS
flutter build web   # Build web
```

---

## Configuration

No `.env` file or secrets are needed. The only configuration is in:

**`lib/src/data/constants/app_constants.dart`**
Endpoint is hosted from my own personal Website Domain.
```
Base URL:  https://www.kasundo.app/api/
Endpoint:  /target-location-test
```

The API is expected to return JSON in the form:
```json
{ "id": 1, "target_lat": 14.5995, "target_lng": 120.9842 }
```

---

## Platform Notes

| Platform | Notes |
|---|---|
| Android | Uses `forceLocationManager`; shows a foreground notification while tracking |
| iOS | Background location updates are **disabled** — tracking pauses when the app is not in the foreground |
| Web | Falls back to standard browser geolocation settings |

---

## Testing

```bash
flutter test
```

| Test file | What it covers |
|---|---|
| `test/widget_test.dart` | Smoke test — verifies the app initializes correctly |
| `test/home_cubit_test.dart` | Unit tests for `HomeCubit` using `bloc_test` + `mocktail` |

**`HomeCubit` test cases:**

- Initial state is `HomeIdle`
- `toggleTracking(true)` emits `[HomeLoading, TrackingStart]` and calls `clearReadings` + `getTargetLocation`
- `toggleTracking(true)` emits `[HomeLoading, HomeError]` when location permissions are denied
- `onChangeLifecycleState(resumed)` restarts GPS polling when the current state is `TrackingStart`

---

## Assumptions

- **Foreground-only tracking** — the app pauses the GPS timer when backgrounded and resumes it when brought back to the foreground. No background location updates are requested.
- **Target is fetched once per session** — the target coordinates are retrieved from the API when tracking starts and held in memory for the duration of that session. They are not polled or refreshed mid-session.
- **Each session starts fresh** — starting a new tracking session clears all readings from the previous session (both in-memory and in the Hive box). History is not cumulative across sessions.
- **Backend endpoint is live** — `https://www.kasundo.app/api/target-location-test` is a hosted mock endpoint. No local server setup is required to run the app.
- **Distance stored as a formatted string** — distance is computed as a raw `double` via the Haversine formula, then immediately formatted to a human-readable string (e.g. `"542m"`, `"1.23km"`) before being stored in Hive and displayed in the UI.
- **Filter applies to the most recent N readings** — the dropdown filters the list to the newest N entries. Readings are ordered newest-first.