# Health Copilot

A patient scheduling copilot that guides users through AI-powered symptom assessment and helps them book doctor visits. Built as a monorepo with a **Django REST** backend and **Flutter** mobile app.

## Features

- **AI Symptom Assessment** — Conversational chat that asks about symptoms, follow-up questions, and recommends a medical specialty with urgency level
- **Doctor Scheduling** — Browse doctors by specialty, view available time slots, and book appointments
- **Patient Authentication** — Passwordless OTP verification via work email. First-time patients register with name, email, phone, and DOB; returning patients log in with email + OTP only
- **My Appointments** — Auth-gated view of all booked appointments with doctor, date, time, and urgency details
- **Mock + Real AI** — Swappable AI service: mock (keyword-based) for development, Claude API for production

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Python 3.12, Django 6, Django REST Framework, SQLite |
| AI | Anthropic Claude API (with mock fallback) |
| Frontend | Flutter, Dart 3.10, Cubit (BLoC) |
| DI | GetIt service locator |
| Auth | DRF TokenAuthentication, OTP via email |
| Linting | very_good_analysis (strict, 80-char lines) |
| Architecture | Clean Architecture by feature, Atomic Design System, Ports & Adapters (observability) |

## Quick Start

### Prerequisites

- Python 3.12+
- Flutter SDK 3.4+
- iOS Simulator or Android Emulator

### Backend

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

python manage.py migrate
python manage.py seed_data    # 7 specialties, 14 doctors, 588 time slots
python manage.py runserver 0.0.0.0:8000
```

### Flutter App

```bash
cd health_copilot
flutter pub get
flutter run --flavor development --target lib/main_development.dart
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `AI_SERVICE_BACKEND` | `mock` | AI service: `mock` or `claude` |
| `ANTHROPIC_API_KEY` | (empty) | Required when `AI_SERVICE_BACKEND=claude` |
| `OTP_BACKEND` | `console` | OTP delivery: `console` (dev), `email` (prod), `fixed` (CI) |

For testing, use `OTP_BACKEND=fixed` — all OTPs will be `111111`:

```bash
OTP_BACKEND=fixed python manage.py runserver 0.0.0.0:8000
```

## Architecture

### Backend

Two Django apps under `backend/`:

- **copilot** — Conversations, messages, appointments, patient auth, AI symptom assessment
- **scheduling** — Specialties, doctors, time slots (read-only APIs)

API prefix: `/api/copilot/` and `/api/scheduling/`

### Flutter App — Clean Architecture by Feature

```
features/<feature>/
├── domain/          # Entities, abstract repositories, use cases
├── data/            # Models (JSON), mappers, datasources, repo implementations
└── presentation/    # Cubits, views, widgets
```

Four features: `chat`, `scheduling`, `appointments`, `auth`

**Dependency rule**: `presentation -> domain <- data`

### Design System — Atomic Design

```
core/design_system/
├── tokens/     # AppColors, AppSpacing, AppTypography, AppIcons
├── atoms/      # AppButton, AppTextField, AppBadge, AppAvatar, AppLoader
├── molecules/  # InfoRow, DetailRow, InputWithAction
├── organisms/  # InfoCard, ListTileCard
└── templates/  # AsyncContent (loading/error/empty/content)
```

### Observability — Ports and Adapters

```
core/observability/
├── ports/        # AppLogger, ErrorReporter, EventTracker
├── adapters/     # ConsoleLogger, NoopErrorReporter, NoopEventTracker
├── interceptors/ # ObservabilityInterceptor (HTTP logging)
└── observers/    # ObservabilityBlocObserver
```

Vendor SDKs (Sentry, Crashlytics, Mixpanel) can be swapped in via DI without modifying app code.

## Patient Flow

```
1. Chat        — "I have terrible headaches for a week"
2. AI Follow-up — "How long?", "Severity 1-10?", "Any medication?"
3. Recommendation — Neurology specialist, medium urgency
4. Doctor List  — Browse neurology doctors
5. Slot Picker  — Select date and time
6. Patient Auth — Name, email, phone, DOB + OTP verification
7. Confirmation — Appointment booked with full details
```

Returning patients skip step 6 (authenticated via stored token).

## API Endpoints

### Scheduling
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/scheduling/specialties/` | No | List specialties |
| GET | `/api/scheduling/doctors/` | No | List doctors (filter by `?specialty=id`) |
| GET | `/api/scheduling/doctors/{id}/slots/` | No | Available time slots |

### Copilot
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/copilot/conversations/` | No | Start conversation |
| POST | `/api/copilot/conversations/{id}/messages/` | No | Send message, get AI response |
| GET | `/api/copilot/appointments/` | Token | List patient's appointments |
| POST | `/api/copilot/appointments/` | No | Book appointment |

### Patient Auth
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/copilot/patients/register/` | No | Register + send OTP |
| POST | `/api/copilot/patients/send-otp/` | No | Send OTP (login) |
| POST | `/api/copilot/patients/verify-otp/` | No | Verify OTP, get token |
| GET | `/api/copilot/patients/me/` | Token | Current patient profile |

## Development

### Running Tests

```bash
# Backend (54 tests)
cd backend && source venv/bin/activate
python manage.py test                              # All tests
python manage.py test copilot                      # Copilot tests (41)
python manage.py test scheduling                   # Scheduling tests (13)
python manage.py test copilot.tests.TestPatientAuthAPI  # Single class

# Flutter
cd health_copilot
flutter analyze
flutter test --coverage --test-randomize-ordering-seed random
```

Backend test coverage includes: model constraints, AI service behavior, OTP service backends, all API endpoints (success + failure), auth flows, rate limiting, and appointment booking rules.

### Project Structure

```
vitable/
├── backend/                  # Django REST API
│   ├── config/               # Settings, URLs
│   ├── copilot/              # Chat, appointments, auth, AI service
│   └── scheduling/           # Doctors, specialties, time slots
├── health_copilot/           # Flutter mobile app
│   └── lib/
│       ├── core/             # API client, DI, design system, observability, theme
│       └── features/         # chat, scheduling, appointments, auth
├── docs/                     # Process documentation
├── CLAUDE.md                 # AI coding assistant guidance
└── README.md
```

## Commit History

| Commit | Description |
|--------|-------------|
| `4dd7d8a` | Initial monorepo: Django backend + Flutter app with full booking flow |
| `51ae98d` | Atomic Design System with tokens, atoms, molecules, organisms, templates |
| `c687382` | Observability with Ports & Adapters (logger, error reporter, event tracker) |
| `67c057c` | Patient authentication with OTP verification (passwordless) |
| `fdc162b` | My Appointments flow with auth-gated access |
| `2a8f0ad` | README and AI-assisted development process documentation |

## Built With AI

This project was built using [Claude Code](https://claude.ai/code) (Claude Opus 4.6) as an AI pair programmer. The full development process, including prompts, architectural decisions, and implementation details, is documented in [`docs/process.md`](docs/process.md).
