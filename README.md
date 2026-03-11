# MESMER Coaching Enterprise Monitoring

Mobile app for the MESMER program — digitizing business coaching for Micro and Small Enterprises (MSEs).


## Quick Start

```bash
# 1. Clone and enter project
git clone <repo-url>
cd mesmer_coaching_enterprise_monitoring

# 2. Install dependencies
flutter pub get

# 3. Copy env config
cp .env.example .env
# Edit .env with your local backend URL

# 4. Run the app
flutter run --dart-define-from-file=.env
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.x (Dart) |
| State | Riverpod 2.x |
| Navigation | GoRouter |
| HTTP | Dio |
| Auth | JWT (access + refresh) |
| Backend | Node.js REST API |
| Database | PostgreSQL |
| File Storage | Cloudflare R2 (via backend) |
| Email | Brevo (transactional, via backend) |

---

## Project Structure

```
lib/
├── core/           # Shared infrastructure (network, storage, router, utils)
├── shared/         # Reusable UI widgets and theme
└── features/       # One folder per feature — see ARCHITECTURE.md
    ├── auth/
    ├── dashboard/
    ├── enterprise/
    ├── diagnosis/
    ├── coaching/
    ├── progress/
    └── reports/
```

Each feature follows **Clean Architecture**:
```
feature/
  data/         ← datasources, models, repository impl
  domain/       ← entities, repository interfaces, use cases
  presentation/ ← screens, widgets, Riverpod providers
```

---

## Team Module Assignments

| Module | Owner | Status |
|---|---|---|
| Auth & Navigation | — | 🔲 TODO |
| Dashboard (role-based) | — | 🔲 TODO |
| Enterprise Management | — | 🔲 TODO |
| Business Diagnosis Tool | — | 🔲 TODO |
| Coaching Sessions | — | 🔲 TODO |
| Progress Tracking | — | 🔲 TODO |
| Reports & Analytics | — | 🔲 TODO |

> Assign names and update this table when work begins.

---

## Docs

- [`docs/database_schema.md`](docs/database_schema.md) — DB tables & columns
- [`docs/api_endpoints.md`](docs/api_endpoints.md) — REST API reference
- [`docs/user_flows.md`](docs/user_flows.md) — Per-role user flows

---