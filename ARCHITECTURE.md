# Architecture Guide — MESMER App

## Overview

This app uses **Clean Architecture + Feature-First** directory structure.

## Layer Responsibilities

```
Presentation  →  UI/Widgets, Riverpod Providers (AsyncNotifier / StateNotifier)
Domain        →  Entities, Repository interfaces, Use Cases (pure Dart, no Flutter)
Data          →  API calls (Dio), JSON Models (freezed), Repository implementations
```

**Rule:** Dependencies only flow **inward**.
- Presentation depends on Domain (via use cases)
- Data depends on Domain (implements repository interfaces)
- Domain depends on nothing except Dart core

## Feature Module Structure

```
features/auth/
  data/
    datasources/   ← raw API or DB calls
    models/        ← JSON-serializable classes (freezed + json_serializable)
    repositories/  ← implements domain repository interface
  domain/
    entities/      ← pure Dart classes, no JSON annotations
    repositories/  ← abstract interface classes
    usecases/      ← single-purpose business logic classes
  presentation/
    providers/     ← Riverpod providers (AsyncNotifier, etc.)
    screens/       ← full page widgets
    widgets/       ← small reusable widgets for that feature only
```

## Key Rules

1. **Never import across features directly** — if two features share data, go through the domain layer or core providers.
2. **Screens only call providers** — no raw API calls or repository calls in screen files.
3. **Use cases have ONE job** — each use case file does exactly one thing.
4. **Entities have no JSON** — JSON belongs in models (data layer), not entities (domain layer).
5. **Shared widgets go in `lib/shared/`** — not inside a feature folder.

## State Management (Riverpod 2.x)

- Use `AsyncNotifierProvider` for mutable state that involves async (lists, forms)
- Use `FutureProvider.family` for read-only data fetched by an ID
- Use `StateProvider` only for simple local UI state (toggles, tabs)

## Navigation (GoRouter)

- All route paths are constants in `core/router/app_routes.dart`
- Role-based redirects live in `core/router/app_router.dart`
- Never call `Navigator.push()` directly — always use `context.go()` or `context.push()`

## Naming Conventions

| Type | Convention | Example |
|---|---|---|
| Files | snake_case | `enterprise_card.dart` |
| Classes | PascalCase | `EnterpriseCard` |
| Providers | camelCase + `Provider` suffix | `enterpriseListProvider` |
| Use Cases | PascalCase + `UseCase` suffix | `RegisterEnterpriseUseCase` |
| Entities | PascalCase + `Entity` suffix | `EnterpriseEntity` |
| Models | PascalCase + `Model` suffix | `EnterpriseModel` |
