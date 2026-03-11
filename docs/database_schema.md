# Database Schema — MESMER

Backend: **Node.js + PostgreSQL**

---

## Users

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| email | VARCHAR(255) UNIQUE | |
| password_hash | TEXT | Argon2 or bcrypt |
| name | VARCHAR(255) | |
| role | ENUM | admin, institution_admin, supervisor, coach |
| institution_id | UUID FK → Institutions | |
| is_active | BOOLEAN | default true |
| token_version | INT | for JWT refresh rotation |
| created_at | TIMESTAMP | |
| updated_at | TIMESTAMP | |

## Institutions

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| name | VARCHAR(255) | e.g. Tigray Labor Bureau |
| region | VARCHAR(100) | |
| contact_email | VARCHAR(255) | |
| created_at | TIMESTAMP | |

## Enterprises

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| business_name | VARCHAR(255) | |
| owner_name | VARCHAR(255) | |
| sector | ENUM | agriculture, manufacturing, trade, services, construction, other |
| employee_count | INT | |
| location | VARCHAR(255) | |
| phone | VARCHAR(20) | |
| email | VARCHAR(255) | nullable |
| coach_id | UUID FK → Users | |
| institution_id | UUID FK → Institutions | |
| registered_at | TIMESTAMP | |

## Assessments

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| enterprise_id | UUID FK → Enterprises | |
| coach_id | UUID FK → Users | |
| status | ENUM | draft, completed |
| total_score | DECIMAL(5,2) | calculated on submission |
| priority_areas | TEXT[] | auto-identified challenges |
| conducted_at | TIMESTAMP | |

## AssessmentResponses

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| assessment_id | UUID FK → Assessments | |
| question_id | UUID FK → AssessmentQuestions | |
| score | SMALLINT | 0–3 |

## AssessmentQuestions

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| category | ENUM | finance, marketing, operations, human_resources, governance |
| question_text | TEXT | |
| order_index | INT | display order within category |
| is_active | BOOLEAN | |

## CoachingSessions

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| enterprise_id | UUID FK → Enterprises | |
| coach_id | UUID FK → Users | |
| scheduled_date | TIMESTAMP | |
| status | ENUM | scheduled, completed, cancelled |
| problems_identified | TEXT | nullable |
| recommendations | TEXT | nullable |
| notes | TEXT | nullable |
| created_at | TIMESTAMP | |

## SessionTasks

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| session_id | UUID FK → CoachingSessions | |
| enterprise_id | UUID FK → Enterprises | |
| title | VARCHAR(255) | |
| description | TEXT | |
| due_date | DATE | |
| is_completed | BOOLEAN | default false |

## UploadedEvidence

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| session_id | UUID FK → CoachingSessions | |
| file_type | ENUM | photo, document, video |
| file_url | TEXT | Local server path (e.g. `/uploads/session_123_img.jpg`) |
| file_name | VARCHAR(255) | Original filename |
| file_size | INT | Bytes |
| uploaded_at | TIMESTAMP | |

---

## Indexes (recommended)

```sql
CREATE INDEX idx_enterprises_coach ON enterprises(coach_id);
CREATE INDEX idx_sessions_enterprise ON coaching_sessions(enterprise_id);
CREATE INDEX idx_assessments_enterprise ON assessments(enterprise_id);
CREATE INDEX idx_users_institution ON users(institution_id);
```
