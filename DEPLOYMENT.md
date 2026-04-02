# Deploying MESMER to Railway

This guide covers deploying the backend to Railway with a managed PostgreSQL database so the app works live on any phone over the internet.

---

## Prerequisites

- [Railway account](https://railway.app) (free tier is sufficient)
- Your repo pushed to GitHub
- Flutter SDK installed locally for building the APK

---

## Step 1 — Create a Railway Project

1. Go to [railway.app](https://railway.app) and sign in
2. Click **New Project → Deploy from GitHub repo**
3. Select your repository
4. When asked for the **Root Directory**, set it to `server`
5. Railway will detect Node.js automatically

---

## Step 2 — Add PostgreSQL

1. In your Railway project dashboard, click **+ New**
2. Select **Database → Add PostgreSQL**
3. Railway creates a managed Postgres instance and automatically injects `DATABASE_URL` into your service environment

---

## Step 3 — Set Environment Variables

In your Railway service → **Variables**, add:

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

Do **not** set `DB_DIALECT` or `DB_STORAGE` — the server auto-detects `DATABASE_URL` from the Postgres addon and uses PostgreSQL.

---

## Step 4 — Deploy

Railway deploys automatically on every push to your main branch. The first deploy:
- Runs `npm ci --only=production`
- Starts `node server.js`
- Sequelize runs `sync({ alter: true })` and creates all tables automatically

---

## Step 5 — Seed Demo Data

After the first successful deploy, open Railway's terminal for your service and run:

```bash
node scripts/seed.js
```

This creates the institution, all 11 demo user accounts, and sample enterprises.

**Demo credentials after seeding:**

| Role | Email | Password |
|---|---|---|
| Super Admin | superadmin@mesmer.com | 123456 |
| Program Manager | programmanager@mesmer.com | 123456 |
| Regional Coordinator | regionalcoordinator@mesmer.com | 123456 |
| Coach | coach@mesmer.com | 123456 |
| Enterprise User | enterprise@mesmer.com | 123456 |
| M&E Officer | meofficer@mesmer.com | 123456 |
| Enumerator | enumerator@mesmer.com | 123456 |

---

## Step 6 — Get Your Public URL

Railway assigns a URL like:
```
https://mesmer-backend-production.up.railway.app
```

Find it in your service → **Settings → Domains**.

---

## Step 7 — Build the Flutter APK

Update your `.env` file at the project root:

```env
API_BASE_URL=https://your-service.up.railway.app/api/v1
```

Then build:

```bash
flutter build apk --release --dart-define-from-file=.env
```

The APK is at `build/app/outputs/flutter-apk/app-release.apk`.

Install it on any Android phone. The app connects to your Railway server over the internet — WiFi or cellular, anywhere.

---

## Architecture on Railway

```
Railway Service (Node.js)
    ↓ reads DATABASE_URL
Railway PostgreSQL Addon
    ↓ persistent data, survives redeploys

Flutter APK on phone
    ↓ HTTPS requests to Railway public URL
    ↓ works on any network (WiFi, cellular)
    ↓ caches data locally for offline use
    ↓ syncs queued actions when back online
```

---

## Offline Behavior

The Flutter app caches enterprises, sessions, and other data locally after the first successful load. When offline:
- Previously loaded data is visible
- Forms can be filled and are queued locally
- When connectivity returns, the sync queue replays to the server automatically

A fresh install with no prior cache requires at least one online session to populate the local cache.

---

## Local Demo (No Deployment)

See `DEMO_SETUP.md` for running everything locally with SQLite — no PostgreSQL or internet required.

---

## Troubleshooting

**Deploy fails with "Cannot find module"**
→ Make sure Root Directory is set to `server` in Railway settings.

**App gets CORS error**
→ Confirm `ALLOWED_ORIGINS=*` is set in Railway variables.

**Login fails after deploy**
→ Run `node scripts/seed.js` from Railway's terminal to create user accounts.

**DATABASE_URL not found**
→ Make sure the PostgreSQL addon is linked to the same Railway project as your service.
