# MESMER Backend — Deployment

## Current Status

The backend is **live on Railway**:

```
https://mesmercoachingenterprisemonitoring-production.up.railway.app
```

Health check: `GET /health` → `{"status":"UP","message":"MESMER API is reaching you!"}`

Database: SQLite (bundled, pre-seeded). To switch to persistent PostgreSQL, see the PostgreSQL section below.

---

## Deploying a New Instance on Railway

### Prerequisites
- Railway account at [railway.app](https://railway.app)
- Repo pushed to GitHub

### Step 1 — Create project

1. Railway dashboard → **New Project → Deploy from GitHub repo**
2. Select your repository
3. Set **Root Directory** to `server` — this is critical, Railway must look inside `server/` not the repo root

### Step 2 — Set environment variables

In your service → **Variables** tab (not Project Settings → Shared Variables):

| Variable | Value |
|---|---|
| `NODE_ENV` | `production` |
| `PORT` | `3000` |
| `ALLOWED_ORIGINS` | `*` |
| `JWT_ACCESS_SECRET` | any long random string |
| `JWT_REFRESH_SECRET` | a different long random string |
| `JWT_ACCESS_EXPIRE` | `8h` |
| `JWT_REFRESH_EXPIRE` | `7d` |
| `BCRYPT_ROUNDS` | `10` |
| `DB_DIALECT` | `sqlite` |
| `DB_STORAGE` | `./data/mesmer.sqlite` |

### Step 3 — Deploy

Railway deploys automatically. The server starts, connects to SQLite, syncs the schema, and is ready.

### Step 4 — Seed demo data (if needed)

The `mesmer.sqlite` file is committed to the repo and contains pre-seeded data. If you need to re-seed:

Open Railway's service terminal and run:
```bash
node scripts/seed.js
```

**Demo accounts — all passwords: `123456`**

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

## Switching to PostgreSQL (Persistent Data)

SQLite resets on redeploy. For persistent data across redeploys:

1. In Railway project → **+ New → Database → PostgreSQL**
2. Railway injects `DATABASE_URL` automatically into your service
3. In your service Variables, remove `DB_DIALECT` and `DB_STORAGE`
4. The server auto-detects `DATABASE_URL` and uses PostgreSQL
5. Redeploy — Sequelize creates all tables automatically on startup
6. Run `node scripts/seed.js` once to populate demo accounts

---

## Building the Flutter APK

After deployment, update `.env` at the project root:

```env
API_BASE_URL=https://your-service.up.railway.app/api/v1
```

Build:
```bash
flutter build apk --release --dart-define-from-file=.env
```

APK: `build/app/outputs/flutter-apk/app-release.apk`

The APK connects to your Railway server over HTTPS — works on any phone, any network.

---

## Architecture

```
Railway (Node.js + Express)
    ↓ SQLite (bundled) or PostgreSQL addon
    ↓ HTTPS public URL

Flutter APK on phone
    ↓ Calls Railway API when online
    ↓ Caches to local SQLite (sqflite) on device
    ↓ Offline → reads cache, queues writes
    ↓ Back online → syncs queue to server
```

---

## Troubleshooting

**Build fails — "Railpack could not determine how to build"**
→ Root Directory must be set to `server` in Railway service settings.

**Variables not loading (`injecting env (0)`)**
→ Variables must be in the service's own Variables tab, not Project Settings → Shared Variables.

**CORS error in app**
→ Set `ALLOWED_ORIGINS=*` in service Variables.

**Login fails**
→ Run `node scripts/seed.js` from Railway terminal to create accounts.

**`DATABASE_URL` not found**
→ PostgreSQL addon must be in the same Railway project as the Node.js service.
