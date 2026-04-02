# Running the MESMER App

---

## Option A — Use the Live Deployment (Recommended)

The backend is already deployed on Railway. Just install the APK and log in.

**Backend URL:** `https://mesmercoachingenterprisemonitoring-production.up.railway.app`

### Get the APK

Build it with the live URL already baked in:

```bash
# .env already set to the Railway URL
flutter build apk --release --dart-define-from-file=.env
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

Transfer to your phone and install. Enable "Install from unknown sources" in Android settings if prompted.

### Log In

All passwords: `123456`

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

Works on any network — WiFi or cellular.

---

## Option B — Run Locally (Development Only)

For local development when you don't have access to the deployed Railway backend. Requires PostgreSQL installed on your machine.

### Prerequisites
- Node.js 18+
- Flutter SDK 3.11+
- PostgreSQL 14+

### Step 1 — Install dependencies

```bash
flutter pub get
cd server && npm install && cd ..
```

### Step 2 — Create a local PostgreSQL database

```bash
psql -U postgres
CREATE DATABASE mesmer_coaching;
CREATE USER mesmer_user WITH PASSWORD 'password123';
GRANT ALL PRIVILEGES ON DATABASE mesmer_coaching TO mesmer_user;
\q
```

### Step 3 — Configure the server

Open `server/.env` and set your local Postgres credentials:

```env
NODE_ENV=development
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mesmer_coaching
DB_USER=mesmer_user
DB_PASSWORD=password123
JWT_ACCESS_SECRET=local_dev_secret
JWT_REFRESH_SECRET=local_dev_refresh_secret
JWT_ACCESS_EXPIRE=8h
JWT_REFRESH_EXPIRE=7d
BCRYPT_ROUNDS=10
ALLOWED_ORIGINS=*
```

### Step 4 — Start the server

```bash
cd server
node server.js
```

Expected output:
```
✅ PostgreSQL Connected via Sequelize
🔄 Database Schema Synchronized (Alter Mode)
🚀 MESMER Server running on http://0.0.0.0:3000
```

### Step 5 — Seed demo data

```bash
node scripts/seed.js
```

### Step 6 — Configure the Flutter app

Open `.env` at the project root:

```env
# Android emulator
API_BASE_URL=http://10.0.2.2:3000/api/v1

# Web or desktop
API_BASE_URL=http://localhost:3000/api/v1

# Physical phone on same WiFi — use your machine's local IP
API_BASE_URL=http://192.168.x.x:3000/api/v1
```

### Step 7 — Run

```bash
flutter run --dart-define-from-file=.env
```

> **Note:** If you don't want to install PostgreSQL locally, you can use the SQLite fallback by adding `DB_DIALECT=sqlite` and `DB_STORAGE=./data/mesmer.sqlite` to `server/.env`. The bundled `mesmer.sqlite` has pre-seeded demo data. This is only for quick local testing — the production system uses PostgreSQL.

---

## Offline Behavior

After the first successful login, the app caches data locally. When internet is unavailable:
- Previously loaded enterprises, sessions, and data remain visible
- Forms, sessions, and IAP updates are saved locally and queued
- When connectivity returns, queued actions sync to the server automatically

---

## Troubleshooting

**"Invalid credentials"**
→ Use the exact emails above. Autocorrect on phones sometimes changes `mesmer.com`.

**"No internet connection" with internet on**
→ The app briefly lost connection during startup. Pull to refresh on any list screen to reconnect.

**Server fails to start locally**
→ Run `npm install` inside the `server/` folder first.

**Flutter build errors**
→ Run `flutter clean && flutter pub get` then retry.

**Physical phone can't connect to local server**
→ Phone and laptop must be on the same WiFi. Use the machine's local IP, not `localhost`.
