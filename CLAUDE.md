# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Health Copilot — a monorepo with a Django REST backend and Flutter mobile app. The app guides patients through AI-powered symptom assessment and schedules doctor visits.

## Commands

### Backend (Django)

```bash
cd backend
source venv/bin/activate

python manage.py runserver 0.0.0.0:8000    # Start dev server
python manage.py makemigrations             # Generate migrations after model changes
python manage.py migrate                    # Apply migrations
python manage.py seed_data                  # Populate specialties, doctors, time slots
python manage.py test                       # Run all tests
python manage.py test copilot.tests.TestClassName  # Run a single test class
```

Install dependencies: `pip install -r requirements.txt`

### Flutter App

```bash
cd health_copilot

# Run on simulator (requires --flavor for VGC template)
flutter run --flavor development --target lib/main_development.dart

# Analysis (uses very_good_analysis rules)
flutter analyze

# Tests
flutter test --coverage --test-randomize-ordering-seed random
flutter test test/path/to/specific_test.dart   # Single test file
```

## Architecture

### Backend

Two Django apps under `backend/`:

- **copilot** — Conversation management and AI-powered symptom assessment. The `services.py` file contains a `BaseCopilotService` with two implementations: `MockCopilotService` (keyword-based, no external deps) and `ClaudeCopilotService` (real Claude API). Controlled by `AI_SERVICE_BACKEND` setting (`'mock'` or `'claude'`).
- **scheduling** — Specialty, Doctor, TimeSlot models. Read-only APIs with a custom `slots` action on DoctorViewSet.

Appointments live in the copilot app but reference scheduling models. Booking an appointment marks the TimeSlot as unavailable.

API prefix: `/api/scheduling/` and `/api/copilot/`

### Flutter App

Created with Very Good CLI — uses **flavors** (development, staging, production) with separate entry points (`main_development.dart`, etc.). Must pass `--flavor` and `--target` when running.

**Clean Architecture by feature**: Each feature is self-contained with three layers:

```
features/<feature>/
├── domain/          # Entities (pure Equatable), abstract repositories, use cases
├── data/            # Models (fromJson), mappers (Model→Entity), datasources, repo impls
└── presentation/    # Cubits, views, widgets
```

**Dependency rule**: `presentation → domain ← data`. Domain has no dependencies on data or presentation. Data implements domain interfaces. Presentation depends on domain use cases.

**Entities vs Models**: Domain entities are pure Dart (no serialization). Data models handle `fromJson`/`toJson`. Mappers (extensions on models) convert between them.

**Use cases**: Each use case wraps a single repository method. Cubits depend on use cases, not repositories directly.

**Dependency injection**: GetIt service locator (`core/di/injection_container.dart`). Dependencies registered in `initDependencies()` called from `bootstrap.dart`. Cubits resolve use cases via `sl()`.

**Cross-feature imports**: One-way only, entity-level only. Scheduling imports chat's `Recommendation` entity and appointments' `Appointment` entity + `CreateAppointment` use case.

**Data flow**: Chat → AI recommendation (specialty + urgency) → Doctor list → Slot picker → Confirmation. Navigation is imperative (`Navigator.push`), passing domain entities between screens via constructor params.

**API client**: `core/api/api_client.dart` uses Dio with platform-aware base URL (Android emulator: `10.0.2.2:8000`, iOS/macOS: `localhost:8000`).

**Design System**: Atomic Design in `core/design_system/`, imported via single barrel `design_system.dart`:

```
core/design_system/
├── tokens/    # AppColors, AppSpacing, AppTypography, AppIcons
├── atoms/     # AppButton, AppTextField, AppBadge, AppAvatar, AppLoader
├── molecules/ # InfoRow, DetailRow, InputWithAction
├── organisms/ # InfoCard, ListTileCard
└── templates/ # AsyncContent (loading/error/empty/content wrapper)
```

Tokens are `abstract final class` with static const members. Use `AppSpacing` for all spacing/radii, `AppColors` for semantic colors (urgency, success, shadow), `AppIcons` for the icon set (all `_rounded` variant). Standard text styles use `Theme.of(context).textTheme`; only non-standard sizes live in `AppTypography`.

**Observability**: Ports and Adapters in `core/observability/`, imported via `observability.dart`:

```
core/observability/
├── ports/        # AppLogger, ErrorReporter, EventTracker, AppUser
├── adapters/     # ConsoleLogger, NoopErrorReporter, NoopEventTracker
├── interceptors/ # ObservabilityInterceptor (Dio HTTP logging)
└── observers/    # ObservabilityBlocObserver (Bloc state/error logging)
```

`AppLogger` uses Template Method pattern — adapters override only `log()`. All methods accept `tag` for filtering (e.g., `'HTTP'`, `'Bloc'`). `ErrorReporter` covers both fatal and non-fatal errors. `EventTracker` is for analytics events tracked at business call sites (cubits), NOT in BlocObserver. All ports registered in `_initObservability()` in `injection_container.dart` before other registrations. Vendor adapters (Sentry, Crashlytics, Mixpanel) are swapped via DI without changing app code.

**Linting**: `very_good_analysis` — strict rules including 80-char line length.

**Localization**: ARB-based (en, es) with pre-generated files in `lib/l10n/arb/`. Imported from `package:health_copilot/l10n/arb/app_localizations.dart` (not flutter_gen).
