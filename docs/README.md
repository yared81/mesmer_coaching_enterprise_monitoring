# MESMER Documentation

---

## Quick Links

| Document | Purpose |
|---|---|
| [../DEMO_SETUP.md](../DEMO_SETUP.md) | How to run the app — live deployment or local |
| [../DEPLOYMENT.md](../DEPLOYMENT.md) | Railway deployment guide |
| [../README.md](../README.md) | Project overview, tech stack, demo accounts |
| [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) | REST API reference — 40+ endpoints |
| [USER_MANUAL.md](./USER_MANUAL.md) | Per-role user guides for all 11 roles |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | System design and patterns |
| [setup.sql](./setup.sql) | PostgreSQL schema (for self-hosted setup) |

---

## Current Deployment

Backend is live at:
```
https://mesmercoachingenterprisemonitoring-production.up.railway.app
```

Database: SQLite (pre-seeded). Switchable to Railway PostgreSQL addon for persistent data.

---

## For Developers

1. Read [ARCHITECTURE.md](./ARCHITECTURE.md) for system design
2. Read [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) for endpoint reference
3. Follow [../DEPLOYMENT.md](../DEPLOYMENT.md) to deploy your own instance

## For Users / Judges

1. See [../DEMO_SETUP.md](../DEMO_SETUP.md) — install the APK and log in
2. Read [USER_MANUAL.md](./USER_MANUAL.md) for your role's workflow

## For Administrators

1. Follow [../DEPLOYMENT.md](../DEPLOYMENT.md) for Railway setup
2. Use [setup.sql](./setup.sql) if setting up a self-hosted PostgreSQL instance
