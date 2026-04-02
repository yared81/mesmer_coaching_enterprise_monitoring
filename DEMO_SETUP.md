# MESMER — Running the App

There are two ways to run this app. Choose based on your situation.

---

## Option A — Live Deployment (Recommended)

The app is deployed on Railway with a real PostgreSQL database. Works on any phone, any network.

See **[DEPLOYMENT.md](./DEPLOYMENT.md)** for the full Railway setup guide.

Once deployed, build the APK with the Railway URL:

```bash
# Set API_BASE_URL in .env to your Railway URL first
flutter build apk --release --dart-define-from-file=.env
```

Install the APK on any Android phone. Done.

---

## Option B — Local Demo (No Internet Required)

Run everything on your machine using the bundled SQLite database. Useful for offline demos or development.

### Prerequisites
- Node.js 18+
- Flutter SDK 3.11+

### Step 1 — Install dependencies

```bash
flutter pub get
cd server && npm install && cd ..
```

### Step 2 — Configure server for SQLite mode

Open `server/.env` and add:

```env
DB_DIALECT=sqlite
DB_STORAGE=./data/mesmer.sqlite
```

The `mesmer.sqlite` file is pre-seeded with demo data (13 users, 3 enterprises, 18 sessions).

### Step 3 — Start the server

```bash
cd server
node server.js
```

You should see:
```
✅ SQLite Connected via Sequelize
🚀 MESMER Server running on http://0.0.0.0:3000
```

### Step 4 — Configure the Flutter app

Open `.env` at the project root:

```env
# Android emulator
API_BASE_URL=http://10.0.2.2:3000/api/v1

# Web or desktop
API_BASE_URL=http://localhost:3000/api/v1

# Physical phone on same WiFi (use your machine's local IP)
API_BASE_URL=http://192.168.x.x:3000/api/v1
```

### Step 5 — Run the app

```bash
flutter run --dart-define-from-file=.env
```

---

## Demo Accounts

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

## Troubleshooting

**App shows "No internet connection"**
→ Check the server is running and `API_BASE_URL` matches your setup.

**Server fails to start**
→ Run `npm install` inside the `server/` folder.

**Flutter build errors**
→ Run `flutter clean && flutter pub get` then retry.

**Physical phone can't connect**
→ Make sure phone and laptop are on the same WiFi. Use your machine's local IP, not `localhost`.
