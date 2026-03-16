# 1. Clone & Enter
git clone <repo-url>
cd mesmer_coaching_enterprise_monitoring

# 2. Database Creation (PostgreSQL)

**Linux / macOS:**
```bash
sudo -i -u postgres psql
CREATE DATABASE mesmer_db;
CREATE USER mesmer_user WITH PASSWORD 'your_pass';
GRANT ALL PRIVILEGES ON DATABASE mesmer_db TO mesmer_user;
```

**Windows (via psql or pgAdmin):**
Open `psql` shell (or pgAdmin) and run:
```sql
CREATE DATABASE mesmer_db;
CREATE USER mesmer_user WITH PASSWORD 'your_pass';
GRANT ALL PRIVILEGES ON DATABASE mesmer_db TO mesmer_user;
```

# 3. Schema Initialization
```bash
psql -h localhost -U mesmer_user -d mesmer_db -f docs/setup.sql
```
*(Windows users may need to specify the full path to `psql.exe` if not in PATH)*

# 4. Flutter Setup
```bash
flutter pub get
```

**Linux / macOS:**
```bash
cp .env.example .env
```

**Windows (PowerShell):**
```powershell
Copy-Item .env.example .env
```

*Edit `.env`: set API_BASE_URL and DB credentials*

# 5. Run the Application
```bash
flutter run --dart-define-from-file=.env
```

> [!NOTE]
> See `docs/setup.sql` for the full schema blueprint. This file is essential for team-wide database consistency.

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

## 🗺️ Development Roadmap (8-Phases)

*For progress reporting to mentors and stakeholders:*

| Phase | Goal | Status |
|---|---|---|
| **1. Foundation** | Architecture, Core Infra, & 74-File Skeleton | ✅ COMPLETE |
| **2. Auth & Security** | JWT flows, Roles & Protected Guards | ✅ COMPLETE |
| **3. Onboarding** | Multi-stepped Enterprise Registration | ✅ COMPLETE|
| **4. Diagnosis** | Assessment Tool, Scoring & Result Summary | ✅ COMPLETE |
| **5. Coaching** | Session Tracking, Tasks & R2 Evidence Upload | In progress |
| **6. Progress** | Data Visualization (Baseline vs Current Improvement) | 🔲 TODO |
| **7. Oversight** | Supervisor Reports & Program Analytics | 🔲 TODO |
| **8. Final Polish** | Brand consistency, Animations & Demo Prep | 🔲 TODO |

Refer to [development_roadmap.md](file:///home/yared/.gemini/antigravity/brain/40be37db-b718-4908-b7ed-627ea5d23870/development_roadmap.md) for full phase details.

---

## Docs

- [`docs/database_schema.md`](docs/database_schema.md) — DB tables & columns
- [`docs/api_endpoints.md`](docs/api_endpoints.md) — REST API reference
- [`docs/user_flows.md`](docs/user_flows.md) — Per-role user flows

---