# MESMER Digital Coaching

Enterprise transformation through digital coaching and quality assurance — a Flutter + Node.js platform that digitizes the MESMER Program end-to-end, from enterprise intake to graduation.

---

## Live Demo

The backend is deployed and running. Install the APK and log in immediately — no setup required.

**Backend:** `https://mesmercoachingenterprisemonitoring-production.up.railway.app`

**Demo Accounts — all passwords: `123456`**

| Role | Email |
|---|---|
| Super Admin | superadmin@mesmer.com |
| Program Manager | programmanager@mesmer.com |
| Regional Coordinator | regionalcoordinator@mesmer.com |
| M&E Officer | meofficer@mesmer.com |
| Data Verifier | dataverifier@mesmer.com |
| Trainer | trainer@mesmer.com |
| Coach | coach@mesmer.com |
| Enumerator | enumerator@mesmer.com |
| Comms Officer | commsofficer@mesmer.com |
| Enterprise User | beneficiary@mesmer.com |
| Stakeholder | stakeholder@mesmer.com |

---

## What It Does

- 11-role RBAC system — Super Admin down to Enterprise User
- Enterprise intake, consent capture, baseline assessment with photo evidence
- Individual Action Plans with task tracking and evidence upload
- Coaching session logging, phone follow-up logs, calendar scheduling
- Diagnosis/assessment tool with category scoring and result visualization
- QC workflow — random sampling, verification queue, audit history
- Training management — sessions, attendance, feedback
- Certificate generation — PDF with QR verification code, graduation checklist lock
- MERL dashboards — funnel analytics, progress charts, regional reports
- Offline-first — caches data locally, queues writes, syncs when back online
- Biometric auth + auto-lock timeout

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.x + Riverpod 2.x |
| Navigation | GoRouter |
| HTTP | Dio with JWT interceptor |
| Local Cache | SQLite (sqflite) |
| Backend | Node.js + Express |
| Database | PostgreSQL (Railway) |
| Auth | JWT access + refresh tokens |

---

## Running the App

See **[DEMO_SETUP.md](./DEMO_SETUP.md)** — covers both the live deployment and local development options.

For deploying your own instance, see **[DEPLOYMENT.md](./DEPLOYMENT.md)**.

---

## Architecture

```
lib/
├── core/           # Network, router, storage, theme, utils
├── shared/         # Reusable widgets
└── features/
    ├── auth/           # JWT auth, biometric, splash
    ├── dashboard/      # Role-based dashboards (8 roles)
    └── workflow/
        ├── enterprise/ # Registration, profile, progress, graduation
        ├── coaching/   # Sessions, IAP, evidence, phone logs
        ├── diagnosis/  # Assessment tool, scoring, results
        ├── intake/     # Enumerator queue, baseline, consent
        ├── training/   # Sessions, attendance, evaluation
        ├── qc/         # QC dashboard, audit history
        └── comms/      # Certificates, success stories
```

Clean Architecture + Feature-First. Presentation → Domain → Data. No cross-feature imports.

---

## Offline Behavior

The app works without internet after the first login:
- Data loaded from the server is cached to local SQLite automatically
- Forms, sessions, and IAP updates are queued when offline
- When connectivity returns, the sync queue replays to the server
- The interceptor detects connection state and switches modes automatically

---

## Development Roadmap

| Phase | Goal | Status |
|---|---|---|
| 1. Foundation | Architecture, Core Infra | ✅ Complete |
| 2. Auth & Security | JWT, Biometric, RBAC | ✅ Complete |
| 3. Onboarding | Enterprise Registration, Consent, CSV Import | ✅ Complete |
| 4. Diagnosis | Assessment Tool, Scoring, Results | ✅ Complete |
| 5. Coaching | Sessions, IAP, Evidence, Phone Logs | ✅ Complete |
| 6. Progress | Baseline vs. Current KPI Charts | ✅ Complete |
| 7. Oversight | Supervisor Reports, Regional Analytics |  ✅ Complete  |
| 8. Final Polish | Animations, Brand Consistency |  ✅ Complete  |

---

## Documentation

- [DEMO_SETUP.md](./DEMO_SETUP.md) — how to run the app
- [DEPLOYMENT.md](./DEPLOYMENT.md) — Railway deployment guide
- [ARCHITECTURE.md](./ARCHITECTURE.md) — system design
- [docs/API_DOCUMENTATION.md](./docs/API_DOCUMENTATION.md) — REST API reference
- [docs/USER_MANUAL.md](./docs/USER_MANUAL.md) — per-role user guides
