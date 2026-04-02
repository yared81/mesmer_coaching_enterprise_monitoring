# MESMER Demo Setup — 5 Steps

This guide gets the app running locally in under 10 minutes using the bundled SQLite database. No PostgreSQL installation required.

---

## Prerequisites

- [Node.js 18+](https://nodejs.org)
- [Flutter SDK 3.11+](https://flutter.dev/docs/get-started/install)
- Git

---

## Step 1 — Clone & Install

```bash
git clone <repository-url>
cd mesmer_coaching_enterprise_monitoring
flutter pub get
cd server && npm install && cd ..
```

---

## Step 2 — Configure the Server for Offline/Demo Mode

Open `server/.env` and add these two lines at the bottom:

```env
DB_DIALECT=sqlite
DB_STORAGE=./data/mesmer.sqlite
```

The `mesmer.sqlite` file is already bundled with seeded demo data (13 users, 3 enterprises, 18 coaching sessions, 90 audit logs).

---

## Step 3 — Start the Backend

```bash
cd server
node server.js
```

You should see:
```
✅ SQLite Connected via Sequelize
🚀 MESMER Server running on http://0.0.0.0:3000
```

---

## Step 4 — Configure the Flutter App

Open `.env` in the project root and set:

```env
API_BASE_URL=http://10.0.2.2:3000/api/v1
```

> Use `http://10.0.2.2:3000/api/v1` for Android emulator.
> Use `http://localhost:3000/api/v1` for web or desktop.
> Use your machine's local IP (e.g. `http://192.168.1.x:3000/api/v1`) for a physical device.

---

## Step 5 — Run the App

```bash
flutter run --dart-define-from-file=.env
```

---

## Demo Accounts

| Role | Email | Password |
|---|---|---|
| Super Admin | admin@mesmer.app | admin123 |
| Program Manager | pm@mesmer.app | admin123 |
| Regional Coordinator | rc@mesmer.app | admin123 |
| Coach | coach@mesmer.app | admin123 |
| Enterprise User | enterprise@mesmer.app | admin123 |
| M&E Officer | me@mesmer.app | admin123 |
| Enumerator | enumerator@mesmer.app | admin123 |

---

## What the Demo Shows

- Role-based dashboards — each login shows a different interface
- Enterprise management — 3 seeded enterprises with coaching history
- Coaching sessions — 18 sessions with diagnosis reports
- IAP task tracking — action plans with evidence upload
- Certificate generation — PDF with QR verification code
- QC workflow — audit history with 90 logged entries
- Offline mode — disconnect the server and the app falls back to local SQLite cache

---

## Switching Back to PostgreSQL (Production Mode)

Remove or comment out the two lines added in Step 2, then configure your PostgreSQL credentials in `server/.env` as documented in `docs/DEPLOYMENT_GUIDE.md`.

---

## Troubleshooting

**App shows "No internet connection"**
→ Check that the server is running and `API_BASE_URL` matches your setup.

**Server fails to start**
→ Run `npm install` inside the `server/` folder.

**Flutter build errors**
→ Run `flutter clean && flutter pub get` then retry.
