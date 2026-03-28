# AI-Assisted Development Session — Prompts & Responses

This document captures every prompt given to Claude Code and a summary of its response throughout the development of the Health Copilot application.

---

## Table of Contents

1. [Prompt 1 — Project Kickoff](#prompt-1--project-kickoff)
2. [Prompt 2 — Clarifying Requirements](#prompt-2--clarifying-requirements)
3. [Prompt 3 — Run Backend and App](#prompt-3--run-backend-and-app)
4. [Prompt 4 — Initialize CLAUDE.md](#prompt-4--initialize-claudemd)
5. [Prompt 5 — Clean Architecture Refactor](#prompt-5--clean-architecture-refactor)
6. [Prompt 6 — Run Mobile App](#prompt-6--run-mobile-app)
7. [Prompt 7 — First Commit](#prompt-7--first-commit)
8. [Prompt 8 — Push to GitHub](#prompt-8--push-to-github)
9. [Prompt 9 — Atomic Design System](#prompt-9--atomic-design-system)
10. [Prompt 10 — Run App (Post Design System)](#prompt-10--run-app-post-design-system)
11. [Prompt 11 — Commit and Push (Design System)](#prompt-11--commit-and-push-design-system)
12. [Prompt 12 — Observability Architecture](#prompt-12--observability-architecture)
13. [Prompt 13 — Commit and Push (Observability)](#prompt-13--commit-and-push-observability)
14. [Prompt 14 — Patient Authentication with OTP](#prompt-14--patient-authentication-with-otp)
15. [Prompt 15 — Run the App (Auth)](#prompt-15--run-the-app-auth)
16. [Prompt 16 — Debug Splash Screen Freeze](#prompt-16--debug-splash-screen-freeze)
17. [Prompt 17 — OTP Strategy for Testing](#prompt-17--otp-strategy-for-testing)
18. [Prompt 18 — Setup Fixed OTP and Run](#prompt-18--setup-fixed-otp-and-run)
19. [Prompt 19 — Commit and Push (Auth + OTP)](#prompt-19--commit-and-push-auth--otp)
20. [Prompt 20 — My Appointments Flow](#prompt-20--my-appointments-flow)
21. [Prompt 21 — Run the App (Appointments)](#prompt-21--run-the-app-appointments)
22. [Prompt 22 — Commit and Push (Appointments)](#prompt-22--commit-and-push-appointments)
23. [Prompt 23 — README and Documentation](#prompt-23--readme-and-documentation)
24. [Prompt 24 — Commit and Push (Docs)](#prompt-24--commit-and-push-docs)
25. [Prompt 25 — Backend Tests](#prompt-25--backend-tests)
26. [Prompt 26 — Commit and Push (Backend Tests)](#prompt-26--commit-and-push-backend-tests)
27. [Prompt 27 — Flutter Tests](#prompt-27--flutter-tests)
28. [Prompt 28 — OWASP Security Audit](#prompt-28--owasp-security-audit)
29. [Prompt 29 — Address Security Items 1-7](#prompt-29--address-security-items-1-7)
30. [Prompt 30 — Commit, Push, Update Docs](#prompt-30--commit-push-update-docs)

---

## Prompt 1 — Project Kickoff

### Prompt

> Resuming previous session on the right path I'm on challenging for new job. I will need create an app using flutter and backend using Python with Django. As part of the process I will need create it using AI, I'm also should share the prompts and share all the process. My challenge is build a co pilot app that will guide the patient to schedule a visit. App will start asking what they are feeling and it should guide the patient. First of all I'm not so familiar with Django and Python, I will need learn a little about it. I have until tuesday to delivery it. How can you help me?

### Claude's Response

Claude outlined 4 areas of help: Django crash course, full implementation guidance, architecture design, and prompt documentation. It proposed a high-level plan:

**Backend (Django + DRF):**
- Patient symptom intake API
- Guided flow/decision tree logic
- Appointment scheduling endpoints

**Flutter App:**
- Conversational UI (chat-like or step-by-step wizard)
- Symptom selection → follow-up questions → scheduling

**Recommended Timeline (~3 days):**

| Day | Focus |
|-----|-------|
| Saturday | Django basics + project setup + data models + API |
| Sunday | Flutter app UI + API integration |
| Monday | Polish, testing, edge cases, documentation |
| Tuesday | Final review + delivery |

Claude then asked 4 clarifying questions: how sophisticated should the guidance be, is there a specific design/spec, should it be a monorepo or separate project, and any requirements around auth/database/deployment.

---

## Prompt 2 — Clarifying Requirements

### Prompt

> 1- We can explore more both approaches
> 2- open-ended
> 3- we will create a monorepo
> 4- No requirements

### Claude's Response

Claude presented two approaches for the AI guidance:

- **Option A: Decision Tree** — Predefined symptom categories, deterministic, easy to test
- **Option B: LLM-Powered Copilot** — Natural language, Claude API, more impressive

**Recommendation: Hybrid** — LLM for conversational intake (impressive, flexible), structured data for specialties/doctors/slots (reliable).

Claude then proposed the full architecture:

```
vitable/
├── backend/              # Django + DRF
│   ├── copilot/          # Symptom conversation + LLM integration
│   └── scheduling/       # Doctors, specialties, time slots
├── app/                  # Flutter mobile app
└── docs/                 # Prompts + process documentation
```

**Data models:** Specialty, Doctor, TimeSlot, Conversation, Message, Appointment

**Patient flow:** Open app → Chat → Describe symptoms → Follow-up questions → Specialty + urgency recommendation → Available doctors → Pick doctor + time → Appointment confirmed

**Tech stack:** Django 5 + DRF, Claude API (Anthropic SDK), SQLite, Flutter with Cubit, Dio

After approval, Claude built the entire backend and Flutter app in one session:
- Created Django project with `copilot` and `scheduling` apps
- Built models, serializers, views, URL routing
- Implemented mock AI service (keyword-based symptom detection)
- Created seed data (7 specialties, 14 doctors, 588 time slots)
- Set up Flutter project with Very Good CLI
- Built chat UI, scheduling flow, confirmation page
- Verified all APIs and `flutter analyze` passed with no issues

---

## Prompt 3 — Run Backend and App

### Prompt

> run backend and app

### Claude's Response

Claude started the Django server on `0.0.0.0:8000`, verified the API was responding, booted the iPhone 16e simulator, and launched the Flutter app with `--flavor development --target lib/main_development.dart`. Both services started successfully.

---

## Prompt 4 — Initialize CLAUDE.md

### Prompt

> /init

### Claude's Response

Claude explored the codebase and created `CLAUDE.md` at the repo root with essential commands, architecture patterns, and non-obvious details (VGC flavors, AI service switching, platform-aware URLs, localization import path).

---

## Prompt 5 — Clean Architecture Refactor

### Prompt

> Refactor the app to adopt Clean Architecture by feature, ensuring a clear separation of responsibilities across layers.
>
> Each feature must follow this structure:
> - domain (entities, repositories, usecases)
> - presentation (view, cubit)
> - data (datasource, models, mappers, repositories)
>
> Organize the codebase by feature so that each feature is self-contained and includes its own domain, data, and presentation layers.
>
> The refactor should: improve maintainability and scalability, enforce separation of concerns, keep the codebase easier to test and evolve, preserve existing app behavior as much as possible.

### Claude's Response

Claude explored the current structure, designed a detailed refactoring plan, and after approval implemented:

**36 new files** across domain, data, and presentation layers for all 3 features (chat, scheduling, appointments).

**Target structure per feature:**
```
features/<feature>/
├── domain/          # Entities (pure Equatable), abstract repositories, use cases
├── data/            # Models (fromJson), mappers (Model→Entity), datasources, repo impls
└── presentation/    # Cubits, views, widgets
```

**Key changes:**
- Domain entities are pure Dart (no serialization)
- Data models handle `fromJson`/`toJson`, mappers bridge to entities
- Use cases wrap single repository methods; cubits depend on use cases, not repositories
- GetIt service locator for DI (`core/di/injection_container.dart`)
- 10 old files deleted (`lib/models/`, old repositories)
- `MultiRepositoryProvider` removed from `app.dart`
- CLAUDE.md updated to reflect the new architecture
- `flutter analyze` passed with no issues

---

## Prompt 6 — Run Mobile App

### Prompt

> run mobile app

### Claude's Response

Claude verified the backend was down, restarted it, booted the simulator, and launched the Flutter app with the development flavor. App ran successfully on iPhone 16e simulator.

---

## Prompt 7 — First Commit

### Prompt

> commit

### Claude's Response

Initial commit created: `4dd7d8a` — 383 files changed, 11,706 insertions. Includes the complete Django backend and Flutter app with Clean Architecture.

---

## Prompt 8 — Push to GitHub

### Prompt

> git branch -M main
> git remote add origin git@github.com:fernandocruz/vitable-challenge.git
> git push -u origin main

### Claude's Response

Claude guided Fernando to run the git commands directly (since they involve SSH credentials). Fernando executed them successfully, pushing to `origin/main`.

---

## Prompt 9 — Atomic Design System

### Prompt

> Create a Flutter Design System based on Atomic Design principles to standardize and scale the application UI.
>
> The design system should be organized into reusable layers, such as: atoms, molecules, organisms, templates, pages (when needed).
>
> It should define and standardize the core UI foundations and reusable components, including: color palette, typography, spacing system, icons, buttons, text fields, cards, loaders, empty states, error states, layout patterns.
>
> Requirements: ensure visual consistency across the app, improve component reusability, support scalability and maintainability, align with the app's new architecture and feature-based organization, make it easier to build new screens using shared UI building blocks.

### Claude's Response

Claude explored the current UI patterns, designed the system, and after approval created **16 new files**:

```
core/design_system/
├── design_system.dart              # Single barrel export
├── tokens/
│   ├── app_colors.dart             # Brand, urgency, success, shadow
│   ├── app_spacing.dart            # Spacing scale + border radii
│   ├── app_typography.dart         # Non-standard font sizes/weights
│   └── app_icons.dart              # Semantic icon set (_rounded variant)
├── atoms/
│   ├── app_button.dart             # Primary/secondary/text button
│   ├── app_text_field.dart         # Pill-shaped text input
│   ├── app_badge.dart              # Colored status/urgency badge
│   ├── app_avatar.dart             # Circle avatar with icon
│   └── app_loader.dart             # Centered CircularProgressIndicator
├── molecules/
│   ├── info_row.dart               # Icon + "Label: " + bold value
│   ├── detail_row.dart             # Icon + stacked label/value
│   └── input_with_action.dart      # Text field + action button row
├── organisms/
│   ├── info_card.dart              # Card with list of DetailRows
│   └── list_tile_card.dart         # Avatar + title/subtitle + trailing card
└── templates/
    └── async_content.dart          # Loading/error/empty/content wrapper
```

Then migrated all 9 feature widget files to use the design system tokens and components. Updated `app_theme.dart` to reference tokens. `flutter analyze` passed.

---

## Prompt 10 — Run App (Post Design System)

### Prompt

> run app

### Claude's Response

Backend was still up. Claude launched the Flutter app on the iPhone 16e simulator. App ran successfully with the new Design System.

---

## Prompt 11 — Commit and Push (Design System)

### Prompt

> commit and push

### Claude's Response

Committed `51ae98d` — 26 files changed, 932 insertions, 425 deletions. Pushed to `origin/main`.

---

## Prompt 12 — Observability Architecture

### Prompt

> Create an observability and analytics architecture using the Ports and Adapters pattern so the app remains provider-agnostic.
>
> The application must not depend directly on any specific vendor such as Sentry, Crashlytics, Mixpanel, or Amplitude. These providers should be treated as infrastructure implementations behind well-defined abstractions.
>
> Define the architecture so that: the app depends only on abstract interfaces (ports), providers are adapter implementations, observability and analytics can be swapped or extended without impacting the app's core logic, the solution supports error tracking, crash reporting, event tracking, and user analytics, the app remains decoupled from vendor-specific SDK details.

### Claude's Response

Claude designed and implemented a Ports and Adapters observability architecture:

```
core/observability/
├── observability.dart          # Barrel export
├── ports/
│   ├── app_logger.dart         # Template Method: abstract log(), concrete info/warning/error
│   ├── error_reporter.dart     # reportFatal + reportNonFatal
│   ├── event_tracker.dart      # trackEvent with properties
│   └── app_user.dart           # User identity model
├── adapters/
│   ├── console_logger.dart     # Dev adapter (developer.log)
│   ├── noop_error_reporter.dart
│   └── noop_event_tracker.dart
├── interceptors/
│   └── observability_interceptor.dart  # Dio HTTP logging
└── observers/
    └── observability_bloc_observer.dart # Bloc state/error logging
```

After multiple review rounds addressing 7 items (breadcrumb scope, Template Method pattern, file counts, test consolidation, PlatformDispatcher error handling), the plan was implemented with 9 new files, DI wiring, and 4 test files.

---

## Prompt 13 — Commit and Push (Observability)

### Prompt

> commit and push

### Claude's Response

Committed `c687382` — 22 files changed, 900 insertions. Pushed to `origin/main`.

---

## Prompt 14 — Patient Authentication with OTP

### Prompt

> Before scheduling an appointment, the system should request the patient's information: name, work email, cellphone number, date of birth.
>
> An OTP verification should be sent to the work email to validate the patient's identity.
>
> Once the email is verified, the system should create a patient account in the app.
>
> For future appointments, the patient should not need to fill in all their information again. They should only log in using their work email and an OTP, and then proceed to schedule the appointment.

### Claude's Response

Claude explored the booking flow, designed the auth plan, and after approval implemented:

**Backend:**
- `Patient` model (name, email, phone, DOB, `is_verified`)
- `OtpCode` model (email, code, expiry, `is_used`)
- REST endpoints: `POST /register/`, `POST /send-otp/`, `POST /verify-otp/`, `GET /me/`
- Token-based auth (DRF TokenAuthentication)
- `AuthInterceptor` for Dio to attach token to requests

**Flutter:**
- New `auth` feature with full Clean Architecture (domain/data/presentation)
- Patient info form (name, email, phone, DOB)
- OTP verification screen
- Login flow for returning patients (email + OTP only)
- Secure token storage with SharedPreferences
- Auth gate before appointment booking

---

## Prompt 15 — Run the App (Auth)

### Prompt

> Run the app

### Claude's Response

Backend was up with `OTP_BACKEND=fixed`. Flutter app launched on simulator. Claude explained the test flow: chat → recommendation → doctor → slot → patient form → enter OTP → appointment confirmed.

---

## Prompt 16 — Debug Splash Screen Freeze

### Prompt

> check why app is freezing on splash screen
> *(attached screenshot of stuck splash screen)*

### Claude's Response

Claude diagnosed the issue immediately: `WidgetsFlutterBinding.ensureInitialized()` was missing before `SharedPreferences.getInstance()` was called in `initDependencies()`. Added the missing line to `bootstrap.dart`. Restarted the app — it loaded past the splash screen.

---

## Prompt 17 — OTP Strategy for Testing

### Prompt

> We need a better strategy for OTP handling that makes the authentication flow easier to test without compromising production security.
>
> Please propose a solution that: keeps the production OTP flow secure, makes OTP retrieval easier in development/staging/QA environments, improves the experience for developers and testers, clearly separates non-production testing mechanisms from production behavior, is scalable, maintainable, and safe against misuse.

### Claude's Response

Claude designed and implemented an environment-aware OTP service with 3 backends:

| Backend | `_generate_code()` | `_deliver()` | In API response? |
|---------|-------------------|-------------|-----------------|
| `console` (dev) | `random.choices(digits, k=length)` | `print()` to stdout | Yes |
| `email` (prod) | `secrets.choice(digits) × length` | `send_mail()` | No |
| `fixed` (CI/test) | Always `"111111"` | No-op | Yes |

**Config:** `OTP_BACKEND` env var controls backend. `OTP_SETTINGS` in `settings.py` for code length, expiry, rate limit.

**Rate limiting:** Max 5 OTPs per email per hour. Returns 429 if exceeded.

**Cleanup command:** `cleanup_expired_otps` deletes OTPs older than 24h.

---

## Prompt 18 — Setup Fixed OTP and Run

### Prompt

> setup fixed 111111 and run the app

### Claude's Response

Claude killed the old server, started the backend with `OTP_BACKEND=fixed`, and launched the Flutter app. Confirmed OTP code is always `111111` for testing.

---

## Prompt 19 — Commit and Push (Auth + OTP)

### Prompt

> commit and push

### Claude's Response

Committed `67c057c` — 51 files changed, 1,944 insertions. Full patient auth with OTP and environment-aware OTP service. Pushed to `origin/main`.

---

## Prompt 20 — My Appointments Flow

### Prompt

> Implement a "My Appointments" flow that allows patients to securely view all of their appointments.
>
> Authentication should be passwordless: the patient enters their email address, the system sends an OTP to that email, the patient verifies the OTP to access their account.
>
> After authentication, the app should display all appointments associated with that patient, including relevant appointment details.
>
> The experience should be simple, secure, and easy to use for returning patients.

### Claude's Response

Claude explored the current state and implemented:

- **Backend:** `GET /api/copilot/appointments/` filtered by authenticated patient
- **Flutter:** New `AppointmentsCubit` and `AppointmentsListPage` showing all patient appointments
- **Auth gate:** Calendar icon in chat screen top-right; if not logged in, redirects to email + OTP flow first
- **Login screen:** Email input → OTP verification → appointments list

6 files changed, 312 insertions.

---

## Prompt 21 — Run the App (Appointments)

### Prompt

> run the app

### Claude's Response

Backend was up. Flutter app launched on simulator. Claude explained the new calendar icon in the chat screen for accessing "My Appointments."

---

## Prompt 22 — Commit and Push (Appointments)

### Prompt

> commit and push

### Claude's Response

Committed `fdc162b` — 6 files changed, 312 insertions. Pushed to `origin/main`.

---

## Prompt 23 — README and Documentation

### Prompt

> Create a comprehensive README.md for the project.
>
> In addition, export the full content of this session into a Markdown file and save it inside a docs/ directory.
>
> The documentation should: clearly describe the project and its purpose, capture the prompts, decisions, and implementation guidance discussed in this session, be well-structured and easy to navigate, use clean Markdown formatting suitable for review in an interview or technical evaluation.

### Claude's Response

Claude created two files:

- **`README.md`** (198 lines) — Project overview, features, architecture diagrams, tech stack, setup instructions, API reference, patient flow, commit history, testing commands
- **`docs/process.md`** (305 lines) — Full development process documenting 7 phases with prompts, decisions, review cycles, bug fixes, and architectural rationale

---

## Prompt 24 — Commit and Push (Docs)

### Prompt

> commit and push

### Claude's Response

Already committed and pushed in previous step: `2a8f0ad` — 2 files changed, 503 insertions.

---

## Prompt 25 — Backend Tests

### Prompt

> Create backend tests for the copilot and scheduling modules.
>
> The tests should validate: core business logic, API or service behavior, success and failure scenarios, important edge cases, regression-prone flows.
>
> Aim for a test suite that improves reliability, documents expected behavior, and supports future refactoring safely.

### Claude's Response

Claude created **54 tests** across two test files:

**`scheduling/tests.py`** (13 tests):
- Model tests: str representations, unique name constraint, cascade delete, unique_together, ordering
- API tests: list/retrieve specialties, list/filter/retrieve doctors, slots action

**`copilot/tests.py`** (41 tests):
- Model tests: UUID auto-generation, message ordering, unique email, default verified=False
- MockCopilotService (8 tests): greeting, follow-up questions, specialty detection (Neurology, Cardiology, Dermatology, General Practice fallback), urgency levels
- OtpService (7 tests): fixed/console/email backends, `should_include_in_response`, rate limiting
- Conversation API (4 tests): create with greeting, retrieve, send message, full conversation → recommendation
- Patient Auth API (11 tests): register, send OTP, verify OTP (success + wrong code + expired + used), patient me, rate limit 429
- Appointment API (4 tests): create marks slot unavailable, list requires auth, filters by patient, duplicate slot fails

---

## Prompt 26 — Commit and Push (Backend Tests)

### Prompt

> commit and push. Update Docs

### Claude's Response

Updated `docs/process.md` with Phase 8 (backend test suite details). Updated `README.md` with test commands and coverage. Committed `56b47e6` — 4 files changed, 675 insertions. Pushed.

---

## Prompt 27 — Flutter Tests

### Prompt

> Create comprehensive Flutter app tests for the following features: appointments, auth, chat, scheduling.
>
> In addition, create integration tests to validate the main end-to-end flows involving these features.
>
> The tests should: cover the primary user journeys, validate expected UI and state behavior, include success, failure, and edge-case scenarios, verify interactions between screens, state management, and services, improve confidence in regressions and future refactors.

### Claude's Response

Claude created **27 Flutter cubit tests** across all 4 features using `bloc_test` and `mocktail`:

- **ChatCubit** (7 tests): startConversation success/error, sendMessage success/error/with recommendation, resetConversation, sendMessage ignored when no conversation
- **SchedulingCubit** (8 tests): loadDoctorsBySpecialty success/error, loadSlots success/error, bookAppointment success/error, bookAppointment needs selected doctor/slot
- **AuthCubit** (7 tests): register success/error, sendOtp success/error, verifyOtp success/error, logout clears state
- **AppointmentsCubit** (5 tests): loadAppointments success/error/empty, loadAppointments sets loaded status, initial state is correct

Total test coverage: **81 tests** (54 backend + 27 Flutter cubits).

---

## Prompt 28 — OWASP Security Audit

### Prompt

> Act as a Staff Security Engineer and perform a thorough security review of the codebase against the OWASP Top 10.
>
> Identify vulnerabilities, insecure coding patterns, weak architectural decisions, and missing protections that could expose the system to attack.
>
> Requirements: review the codebase with an attacker-minded perspective, map findings to relevant OWASP Top 10 categories, identify both direct vulnerabilities and risky patterns, explain the business and technical impact of each issue, propose concrete mitigation and remediation steps, prioritize findings by severity and likelihood.

### Claude's Response

Claude ran two parallel security audits (backend + Flutter) and produced a comprehensive assessment with **16 findings**:

| # | OWASP Category | Severity | Issue |
|---|---------------|----------|-------|
| 1 | A05 Misconfiguration | CRITICAL | Hardcoded SECRET_KEY in source |
| 2 | A01 Access Control | CRITICAL | Unauthenticated appointment creation |
| 3 | A02 Cryptographic | CRITICAL | HTTP transport (no TLS) |
| 4 | A02 Cryptographic | CRITICAL | Token in SharedPreferences (unencrypted) |
| 5 | A07 Auth Failures | HIGH | OTP brute-force (no attempt limiting) |
| 6 | A01 Access Control | HIGH | Conversations accessible without auth |
| 7 | A03 Injection | HIGH | Prompt injection via AI service |
| 8 | A05 Misconfiguration | HIGH | DEBUG=True, CORS_ALLOW_ALL |
| 9 | A07 Auth Failures | MEDIUM | Email enumeration |
| 10 | A04 Insecure Design | MEDIUM | No input length limits |
| 11 | A09 Logging Failures | MEDIUM | OTP printed to stdout |
| 12 | A01 Access Control | MEDIUM | Admin panel exposed |
| 13-16 | Various | LOW | Missing security headers, no token expiration, weak validation, no cert pinning |

---

## Prompt 29 — Address Security Items 1-7

### Prompt

> Address items 1 - 7

### Claude's Response

Claude implemented all 7 priority security fixes:

1. **SECRET_KEY from env var** — `os.environ.get('DJANGO_SECRET_KEY', fallback)` with dev-only fallback
2. **Appointment auth** — `IsAuthenticated` for all actions, patient set server-side from `request.user`
3. **OTP brute-force protection** — 5-attempt limit per OTP code, `hmac.compare_digest()` for constant-time comparison
4. **HTTPS documentation** — production must use HTTPS with certificate pinning
5. **flutter_secure_storage** — replaced SharedPreferences with encrypted Keychain/EncryptedSharedPreferences
6. **Conversation auth** — retrieve requires `IsAuthenticated`
7. **Input length limits** — `max_length=2000` on messages, `min_length=6, max_length=6` on OTP code

Backend tests updated to reflect new auth requirements. Test count increased from 54 to 56.

---

## Prompt 30 — Commit, Push, Update Docs

### Prompt

> commit, push and update docs

### Claude's Response

Updated `docs/process.md` with Phase 9 (security audit and remediation details). Updated `README.md` commit history table. Committed `e697075` — 18 files changed, 291 insertions. Pushed to `origin/main`.

---

## Commit History Summary

| Commit | Description |
|--------|-------------|
| `4dd7d8a` | Initial commit: Health Copilot monorepo (Django + Flutter) |
| `51ae98d` | Add Atomic Design System and migrate feature widgets |
| `c687382` | Add observability architecture with Ports and Adapters |
| `67c057c` | Add patient authentication with OTP verification |
| `fdc162b` | Add My Appointments flow with auth-gated access |
| `2a8f0ad` | Add README and AI-assisted development process documentation |
| `56b47e6` | Add backend test suite (54 tests) |
| `dc2db83` | Add Flutter cubit tests (27 tests) |
| `e697075` | Address OWASP Top 10 security findings (items 1-7) |

---

## Tools Used

- **Claude Code CLI** (Claude Opus 4.6, 1M context) — AI pair programmer
- **Very Good CLI** — Flutter project scaffolding
- **Django 5 + Django REST Framework** — Backend
- **Flutter + Cubit** — Mobile app
- **GetIt** — Dependency injection
- **bloc_test + mocktail** — Flutter testing
