# User Flows — MESMER

---

## Flow 1: Coach — Register an Enterprise

```
Login → Coach Dashboard
  → Tap "Register Enterprise"
  → EnterpriseFormScreen (multi-step)
      Step 1: Business info (name, sector, employees)
      Step 2: Owner info (name, phone, email, location)
      Step 3: Baseline info (financial, operational notes)
  → Submit → POST /enterprises
  → Success → EnterpriseDetailScreen
```

---

## Flow 2: Coach — Conduct Business Diagnosis

```
EnterpriseDetailScreen
  → Tap "Start Assessment"
  → AssessmentScreen
      Answer all questions per category (Finance, Marketing, Ops, HR, Governance)
      Score each: 0 (None) → 3 (Strong)
  → Submit → POST /assessments
  → DiagnosisResultScreen
      Overall score, category breakdown chart
      Priority areas highlighted
  → CTA: "Plan Coaching Session"
```

---

## Flow 3: Coach — Record Coaching Session

```
EnterpriseDetailScreen OR SessionListScreen
  → Tap "New Session"
  → SessionFormScreen
      Date picker, problems identified, recommendations, notes
      Add tasks: title, description, due date
  → Save → POST /coaching-sessions
  → EvidenceUploadScreen (optional)
      Pick photo/doc from camera or gallery
      Upload → POST /sessions/:id/evidence
  → Return to SessionListScreen
```

---

## Flow 4: Coach — View Enterprise Progress

```
EnterpriseDetailScreen
  → Tap "View Progress"
  → ProgressDashboardScreen
      Gauge: baseline score vs current score
      Line chart: score trend over time
  → Tap indicator → IndicatorChartScreen
      Bar chart: category-by-category comparison
```

---

## Flow 5: Supervisor — View Analytics

```
Login → Supervisor Dashboard
  → Overview stats: enterprises, coaches, sessions, avg improvement
  → Tap "Reports"
  → SupervisorReportsScreen
      Charts: enterprises by sector, sessions by month
      Table: top/bottom performing enterprises
```

---

## Role → Landing Screen Matrix

| Role | After Login | Default Screen |
|---|---|---|
| admin | `AdminDashboardScreen` | Institution stats, user mgmt |
| institution_admin | `AdminDashboardScreen` | Institution-scoped stats |
| supervisor | `SupervisorDashboardScreen` | Coaching oversight |
| coach | `CoachDashboardScreen` | My enterprises + sessions |
