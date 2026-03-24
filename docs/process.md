# AI-Assisted Development Process

This document captures the prompts, decisions, and implementation flow used to build the Health Copilot application using Claude Code (Claude Opus 4.6) as an AI pair programmer.

---

## Table of Contents

1. [Session Overview](#session-overview)
2. [Phase 1: Project Setup and Backend](#phase-1-project-setup-and-backend)
3. [Phase 2: Flutter App](#phase-2-flutter-app)
4. [Phase 3: Clean Architecture Refactor](#phase-3-clean-architecture-refactor)
5. [Phase 4: Design System](#phase-4-design-system)
6. [Phase 5: Observability Architecture](#phase-5-observability-architecture)
7. [Phase 6: Patient Authentication](#phase-6-patient-authentication)
8. [Phase 7: My Appointments](#phase-7-my-appointments)
9. [Key Architectural Decisions](#key-architectural-decisions)
10. [Review Process](#review-process)

---

## Session Overview

The entire application was built in a single extended session. The development process followed an iterative approach: each feature started with a prompt describing the requirement, followed by planning, implementation, review, and refinement.

**Model**: Claude Opus 4.6 (1M context) via Claude Code CLI

**Total commits**: 6 (including this documentation commit)

**Approach**: The user provided high-level requirements and architectural preferences. Claude Code generated the implementation plan, wrote the code, ran analysis/tests, and committed. The user reviewed, provided feedback (including simulated "staff engineer reviews"), and Claude iterated.

---

## Phase 1: Project Setup and Backend

### Prompt

> "I will need create an app using flutter and backend using Python with Django. My challenge is build a co pilot app that will guide the patient to schedule a visit."

### Decisions Made

- **Monorepo structure**: Backend and Flutter app in the same repository
- **Hybrid AI approach**: Mock AI service for development (keyword-based symptom matching), real Claude API integration for production
- **SQLite for dev**: Simple setup, no external database dependency
- **Seed data**: 7 medical specialties, 14 doctors, 588 time slots generated via management command

### What Was Built

**Django Backend** (`backend/`):
- `copilot` app: Conversation management, AI symptom assessment service, appointment booking
- `scheduling` app: Specialty, Doctor, TimeSlot models with read-only REST APIs
- Mock AI service that detects symptoms by keywords, asks 3 follow-up questions, then returns a specialty + urgency recommendation
- Claude AI service (swappable via `AI_SERVICE_BACKEND` setting)
- Seed data management command

**Key Implementation Detail**: The AI service uses a Strategy pattern with `BaseCopilotService` as the interface and `MockCopilotService`/`ClaudeCopilotService` as implementations, controlled by a Django setting.

### Verification

All endpoints tested with `curl`:
- Conversation creation returns greeting
- Message exchange produces follow-up questions
- After 3+ messages, returns structured recommendation with specialty and urgency
- Doctor and slot endpoints return seeded data

---

## Phase 2: Flutter App

### Prompt

> "We will create with Very Good CLI" (user preference for project scaffolding)

### Decisions Made

- **Very Good CLI**: Generates project with flavors (dev/staging/prod), very_good_analysis linting, and bloc boilerplate
- **Cubit for state management**: Simpler than full BLoC for this use case
- **Dio for HTTP**: Platform-aware base URL (Android emulator vs iOS)
- **Repository pattern**: `CopilotRepository` and `SchedulingRepository` abstract API calls

### What Was Built

- Chat UI with message bubbles, typing indicator, and recommendation card
- Doctor list page filtered by AI-recommended specialty
- Time slot picker grouped by date
- Appointment confirmation page with all booking details
- Full navigation flow: Chat -> Recommendation -> Doctors -> Slots -> Confirmation

### Challenge Encountered

Very Good CLI had compatibility issues with the current Dart SDK (3.10.4 vs required 3.11+). Resolved by trying multiple CLI versions until finding one compatible with the SDK, then fixing an `intl` version conflict in pubspec.yaml.

---

## Phase 3: Clean Architecture Refactor

### Prompt

> "Refactor the app to adopt Clean Architecture by feature, ensuring a clear separation of responsibilities across layers."

The user specified the exact target structure:
```
features/<feature>/
├── domain/    (entities, repositories, usecases)
├── data/      (datasource, models, mappers, repositories)
└── presentation/ (view, cubit)
```

### Decisions Made

- **GetIt for DI**: User explicitly requested GetIt instead of the initial MultiRepositoryProvider approach (saved to memory for future sessions)
- **Entities vs Models**: Domain entities are pure Equatable (no fromJson). Data models handle JSON. Mappers are extensions on models.
- **Use cases**: Each wraps a single repository method. Cubits depend on use cases, not repositories directly.
- **Cross-feature deps**: One-way only, entity-level only (scheduling imports chat's Recommendation)

### What Was Built

36 new files created, 10 old files deleted:
- 7 domain entities, 3 abstract repository interfaces, 8 use cases
- 7 data models, 7 mappers, 3 data sources, 3 repository implementations
- All presentation files moved into `presentation/` subdirectories
- GetIt injection container with feature-grouped registration
- `MultiRepositoryProvider` removed from app.dart

### Key Refactoring Principle

The migration was done additively: new files were created alongside old ones, then cubits were rewired, then old files were deleted. At no point was the app broken — `flutter analyze` passed after each step.

---

## Phase 4: Design System

### Prompt

> "Create a Flutter Design System based on Atomic Design principles to standardize and scale the application UI."

### Decisions Made

- **Atomic Design layers**: tokens, atoms, molecules, organisms, templates
- **Tokens as `abstract final class`**: Static const members, not BuildContext extensions
- **Single barrel export**: `design_system.dart` — the design system is small enough that sub-barrels add complexity without benefit
- **Keep `app_theme.dart`**: Refactored to reference tokens instead of hardcoded values
- **Feature-specific widgets stay in features**: MessageBubble (chat-specific) was not extracted

### What Was Built

16 new files in `core/design_system/`:
- **Tokens**: AppColors (brand, urgency, success), AppSpacing (2-32dp scale + border radii), AppTypography (non-standard sizes only), AppIcons (all `_rounded` variant)
- **Atoms**: AppButton (primary/secondary/text), AppTextField, AppBadge, AppAvatar, AppLoader
- **Molecules**: InfoRow, DetailRow, InputWithAction
- **Organisms**: InfoCard (card with DetailRows + dividers), ListTileCard (avatar + title/subtitle + chevron)
- **Templates**: AsyncContent (loading/error/empty/content state wrapper)

All 9 existing feature widgets migrated to use design system components — eliminating hardcoded colors, spacing values, and duplicated patterns.

---

## Phase 5: Observability Architecture

### Prompt

> "Create an observability and analytics architecture using the Ports and Adapters pattern so the app remains provider-agnostic."

### Review Process

This feature went through **6 rounds of review** with simulated staff engineer feedback. Key changes from reviews:

1. **Merged ErrorTracker + CrashReporter** into single `ErrorReporter` (the fatal/non-fatal distinction is a severity level, not a different concern)
2. **Cut composite adapters** (YAGNI — no vendors exist yet)
3. **Removed EventTracker from BlocObserver** (analytics events belong at business call sites, not lifecycle hooks)
4. **Added tag parameter to AppLogger** for log filtering
5. **Made captureException return void** (fire-and-forget; adapters manage async internally)
6. **Added PlatformDispatcher.instance.onError** for uncaught async errors
7. **Renamed addBreadcrumb to addContext** (vendor-neutral naming)
8. **Removed email from AppUser** (privacy risk in health app context)
9. **Added _sanitizePath()** to interceptor (strip query params before logging)
10. **Made AppLogger a Template Method** — adapters override only `log()`, convenience methods are concrete defaults

### What Was Built

10 new files in `core/observability/`:
- 3 ports: AppLogger (with tag), ErrorReporter (fatal + non-fatal + flush), EventTracker
- 3 adapters: ConsoleLogger (dart:developer), NoopErrorReporter, NoopEventTracker
- ObservabilityInterceptor (Dio HTTP logging with URL sanitization)
- ObservabilityBlocObserver (structured state/error logging)
- Two-phase bootstrap: raw fallback pre-DI, full observability post-DI

4 test files with 18 tests covering observer, interceptor, adapters, and DI wiring.

---

## Phase 6: Patient Authentication

### Prompt

> "Before scheduling an appointment, the system should request the patient's information: name, work email, cellphone number, date of birth. An OTP verification should be sent to the work email."

### Decisions Made

- **Passwordless auth**: OTP to work email, no passwords
- **DRF TokenAuthentication**: Simple token stored in SharedPreferences
- **Insert point**: Between slot selection and appointment creation
- **OTP Strategy Pattern**: Three backends controlled by `OTP_BACKEND` env var:
  - `console` (dev): prints to stdout + returns in API response
  - `email` (production): uses Django send_mail, never in response
  - `fixed` (CI/test): always `111111`, in response
- **Rate limiting**: Max 5 OTPs per email per hour

### Staff Engineer Review on OTP

The OTP strategy was refined based on review feedback:
- Extracted from inline functions into dedicated `OtpService` class
- Added rate limiting
- Used `secrets.choice()` for production-grade randomness
- Added `cleanup_expired_otps` management command

### What Was Built

**Backend**: Patient model, OtpCode model, 4 auth endpoints (register, send-otp, verify-otp, me), OtpService with 3 backends

**Flutter**: Full `auth` feature with Clean Architecture layers:
- AuthCubit with states: unknown -> unauthenticated -> registering -> otpSent -> verifying -> authenticated
- PatientInfoPage (form with validation), OtpVerificationPage (6-digit input), LoginPage (returning patients)
- AuthInterceptor attaches token to all API requests
- Booking flow gates on authentication

### Bug Fix

App was freezing on splash screen after adding SharedPreferences. Root cause: `WidgetsFlutterBinding.ensureInitialized()` was missing from `bootstrap.dart` — required before any plugin can access platform channels.

---

## Phase 7: My Appointments

### Prompt

> "Implement a 'My Appointments' flow that allows patients to securely view all of their appointments. Authentication should be passwordless."

### What Was Built

Minimal changes leveraging existing infrastructure:

- **Backend**: Added `IsAuthenticated` permission + patient email filtering to `AppointmentViewSet.get_queryset()`
- **Flutter**: AppointmentsCubit, AppointmentsPage (with AsyncContent), AppointmentCard (doctor, specialty, date, time, urgency badge)
- **Navigation**: Calendar icon in ChatPage app bar with auth gate — routes through login if unauthenticated

This was the fastest feature to implement because the domain layer (entity, use case, repository, data source) already existed from the initial build. Only presentation and a small backend change were needed.

---

## Key Architectural Decisions

### 1. Clean Architecture by Feature

Each feature owns its full stack (domain/data/presentation). Cross-feature imports are one-way only and entity-level only. This keeps features self-contained and independently testable.

### 2. GetIt over MultiRepositoryProvider

The user explicitly requested GetIt for dependency injection. Cubits resolve use cases via `sl()` instead of `context.read()`. This decouples cubit creation from the widget tree.

### 3. Ports and Adapters for Observability

The app depends only on abstract interfaces (AppLogger, ErrorReporter, EventTracker). Vendor SDKs are adapter implementations registered via DI. This was designed as Phase 1 scaffold — vendor integration is Phase 2.

### 4. Mock AI Service

The mock service uses keyword matching to detect specialties (e.g., "headache" -> Neurology) and urgency levels (e.g., "severe" -> high). It simulates the real AI behavior with predictable, testable outputs.

### 5. OTP Strategy Pattern

Three OTP backends (console/email/fixed) controlled by environment variable. The `OtpService` class encapsulates generation, storage, delivery, and rate limiting. This separation makes the auth flow testable without email infrastructure.

### 6. Atomic Design System

UI components organized as tokens -> atoms -> molecules -> organisms -> templates. Feature-specific widgets (like MessageBubble) stay in their features. Shared building blocks (like AppButton, AsyncContent) live in the design system.

---

## Review Process

Several features went through simulated staff engineer review cycles. The most extensive was the observability architecture (6 rounds). Key themes from reviews:

- **YAGNI**: Don't build composite adapters for vendors that don't exist yet
- **Single Responsibility**: ErrorTracker and CrashReporter were correctly merged (the distinction was artificial)
- **Separation of Concerns**: Analytics events belong at business call sites, not in BlocObserver lifecycle hooks
- **Privacy by Design**: Remove email from shared telemetry types in a health app
- **Data Governance**: Sanitize URLs before logging, never log request/response bodies
- **Bootstrap Safety**: Two-phase error handling (raw fallback pre-DI, full observability post-DI)
- **Testability**: Every abstraction should have corresponding tests — adapters, observers, interceptors

These reviews improved the codebase significantly and demonstrated the value of architectural feedback loops in AI-assisted development.

---

## Phase 8: Backend Test Suite

### Prompt

> "Create backend tests for the copilot and scheduling modules. The tests should validate core business logic, API behavior, success and failure scenarios, important edge cases, and regression-prone flows."

### What Was Built

**54 tests** across two test files, all passing:

**scheduling/tests.py** (13 tests):
- Model tests: str representations, unique name constraint, cascade delete, unique_together (doctor + time), ordering
- API tests: list/retrieve specialties, list/filter/retrieve doctors, slots action (only available slots returned)

**copilot/tests.py** (41 tests):
- Model tests: UUID auto-generation, message ordering, unique email, default verified=False
- MockCopilotService (8 tests): greeting, follow-up questions before recommendation, specialty detection (Neurology from "headache", Cardiology from "chest", Dermatology from "skin", General Practice fallback), urgency levels (high from "severe", low from "mild")
- OtpService (7 tests): fixed/console/email backends, should_include_in_response behavior, 6-digit code format, DB storage with expiry, rate limiting
- Conversation API (4 tests): create with greeting, retrieve, send message with AI response, full conversation producing recommendation
- Patient Auth API (11 tests): register new + update existing, send OTP success + 404, verify OTP success + wrong code + expired + already used, patient me with/without auth, rate limit 429
- Appointment API (4 tests): create marks slot unavailable, list requires auth, filters by patient only, duplicate time slot fails (OneToOne constraint)

### Key Testing Decisions

- Used `@override_settings(OTP_SETTINGS=OTP_FIXED)` to control OTP backend per test class
- Used `unittest.mock.patch('builtins.print')` to suppress console output in console backend tests
- Created helper data (patients, users, tokens) in `setUp()` for auth-dependent tests
- Tested both success and failure paths for every endpoint

---

## Tools and Workflow

- **Claude Code CLI** (Claude Opus 4.6, 1M context) — AI pair programmer
- **Plan Mode** — Used for all non-trivial features. Claude explored the codebase, designed the approach, wrote a plan file, then implemented after approval.
- **Task Tracking** — Built-in task system for tracking implementation progress
- **Memory System** — Saved user preferences (Very Good CLI, Clean Architecture, GetIt) for consistency across the session
- **Background Commands** — Django server and Flutter app ran in background while implementation continued

---

*This document was generated as part of the Health Copilot project to demonstrate the AI-assisted development process for technical evaluation.*
