# API Endpoints Reference — MESMER

Base URL: `POST /api/v1`
Auth: `Authorization: Bearer <access_token>` on all protected routes

---

## Auth

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/auth/login` | ❌ | Login with email + password, returns access + refresh tokens |
| POST | `/auth/logout` | ✅ | Logout, revoke refresh token |
| POST | `/auth/refresh` | ❌ | Exchange refresh token for new access token |
| GET | `/auth/me` | ✅ | Get current user profile |
| POST | `/auth/forgot-password` | ❌ | Send password reset email via Brevo |

---

## Users

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/users` | admin, institution_admin | List users (filtered by institution) |
| POST | `/users` | admin, institution_admin | Create a new user (coach / supervisor) |
| GET | `/users/:id` | ✅ | Get user by ID |
| PATCH | `/users/:id` | admin | Update user |
| DELETE | `/users/:id` | admin | Deactivate user |

---

## Enterprises

| Method | Endpoint | Auth | Roles | Description |
|---|---|---|---|---|
| GET | `/enterprises` | ✅ | all | List enterprises (coach sees own, supervisor sees institution's) |
| POST | `/enterprises` | ✅ | coach | Register new enterprise |
| GET | `/enterprises/:id` | ✅ | all | Get enterprise detail |
| PATCH | `/enterprises/:id` | ✅ | coach | Update enterprise info |

---

## Assessments (Diagnosis)

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/assessment-questions` | ✅ | Get all active questions (grouped by category) |
| POST | `/assessments` | coach | Submit a completed assessment |
| GET | `/assessments/:id` | ✅ | Get assessment detail |
| GET | `/assessments/:id/result` | ✅ | Get diagnosis result with scores and priority areas |
| GET | `/enterprises/:id/assessments` | ✅ | List all assessments for an enterprise |

---

## Coaching Sessions

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/coaching-sessions` | ✅ | List sessions (scoped by role) |
| POST | `/coaching-sessions` | coach | Create a new session |
| GET | `/coaching-sessions/:id` | ✅ | Get session detail |
| PATCH | `/coaching-sessions/:id` | coach | Update session (add notes, mark completed) |
| GET | `/enterprises/:id/sessions` | ✅ | List sessions for an enterprise |
| POST | `/coaching-sessions/:id/tasks` | coach | Add task to session |
| PATCH | `/tasks/:id/complete` | coach | Mark task as completed |

---

## Evidence Upload

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/sessions/:id/evidence` | coach | Upload file (photo/doc/video) → stored in Cloudflare R2, returns URL |
| GET | `/sessions/:id/evidence` | ✅ | List uploaded evidence for a session |
| DELETE | `/evidence/:id` | coach | Remove uploaded evidence |

---

## Progress

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/progress/:enterpriseId` | ✅ | Get progress data (baseline vs latest assessment scores) |
| GET | `/progress` | supervisor, admin | Get all enterprises' progress (aggregated) |

---

## Reports & Stats

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/stats` | supervisor, admin | Aggregated program stats |
| GET | `/reports` | supervisor, admin | List generated reports |
| POST | `/reports` | supervisor | Generate a period report |

---

## Response Format

All endpoints return:
```json
{
  "success": true,
  "data": { ... },
  "message": "optional message"
}
```

Errors:
```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE"
}
```
