# NuroVed Patient App — Architectural Decisions & Open Questions

> **Document Status**: ACTIVE  
> **Date**: October 23, 2026

This document records key architectural decisions, rationale, and recommended resolutions for open questions in accordance with NuroVed Engineering Rules.

---

## 1. Architectural Decisions

### DEC-001: Model Layer & Immutability
- **Context**: The existing application passes untyped `Map<String, dynamic>` between screens and controllers. Entity IDs are non-existent, and records are identified/deleted using display names.
- **Decision**: Adopt strongly typed, immutable domain models (`@immutable` classes with `final` fields and `copyWith` methods) located in `lib/core/models/`. Every model (`UserProfile`, `FamilyMember`, `MedicalRecord`, `Visit`, `RoutineMedicine`) must have an immutable `final String id` (UUID).
- **Rationale**: Eliminates runtime type casting exceptions, prevents name collisions from deleting wrong medical records, and aligns with strict NuroVed Code Standards.

### DEC-002: Provider Architecture & Elimination of Hidden Singletons
- **Context**: 7 controllers utilize `static final ... _instance = ..._internal()` hidden singletons, preventing proper disposal, resetting, and dependency injection during tests.
- **Decision**: Eradicate all hidden singletons. Register controllers at the top level via `MultiProvider` in `lib/app/app_binding.dart`. Presentation widgets will obtain controllers using `context.read<T>()` or `context.watch<T>()`.
- **Rationale**: Preserves testability, allows providing fake repositories in tests, and ensures proper controller lifecycles.

### DEC-003: Platform-Safe File & Image Abstraction
- **Context**: 10 files directly import `dart:io` and invoke `FileImage(imageFile as File)`, which compiles on web but crashes fatally at runtime.
- **Decision**: Introduce a platform-safe file wrapper `PlatformFileAttachment` containing file metadata, mime type, and bytes (`Uint8List`). For mobile, use cached file paths; for web, use in-memory bytes. Replace `FileImage` with a unified widget that uses `MemoryImage` on web and `FileImage` on mobile via conditional helpers.
- **Rationale**: Guarantees zero crashes on Flutter Web without duplicating widget trees.

### DEC-004: Repository Layer & Backend Isolation
- **Context**: Existing controllers directly manipulate in-memory data arrays without an abstract interface or boundary.
- **Decision**: Introduce an abstract repository layer (`AuthRepository`, `RecordsRepository`, `VisitsRepository`, `RoutineRepository`). Provide two implementations:
  1. `Supabase*Repository`: Connects to real backend via Supabase client with RLS.
  2. `Fake*Repository`: In-memory implementation used for widget tests, unit tests, and offline mock mode.
- **Rationale**: Decouples UI development and testing from live backend availability.

---

## 2. Open Questions & Recommendations

### Question 1: Unification of Doctor Share and Hospital Access
- **Question**: `lib/features/doctor_share/` contains 4 empty (0-byte) files, while `lib/features/access/` contains a partially developed UI for managing hospital access. Should these be unified into a single "Access Management" feature?
- **Recommendation**: **(Recommended) Yes, unify into Access Management.** Patients should have one single, unambiguous place to review, grant, and revoke access for both individual doctors and healthcare institutions. Delete the empty files in `lib/features/doctor_share/` to prevent confusion.

### Question 2: Barcode Food Scanner Approach for MVP
- **Question**: The current food scanner displays hardcoded nutrition facts for Lay's chips for every scanned barcode. What should be done for MVP?
- **Recommendation**: **(Recommended) Integrate the free Open Food Facts API with a safe fallback.**
  - If barcode is found: display real verified nutrition data.
  - If barcode is not found: display a clear "Barcode not found in database — enter details manually" message. Never show simulated or fabricated nutrition advice to a diabetic patient.

### Question 3: Premium / In-App Purchases Scope
- **Question**: The purchase flow is simulated with "Demo: Failed" and "Demo: Renew" buttons and has no active payment gateway.
- **Recommendation**: **(Recommended) Temporarily disable subscription checkout and mark as "Coming Soon" in MVP.**
  - Rationale: Building secure, compliant Apple In-App Purchases and Google Play Billing requires store credentials, merchant agreements, and webhook servers. Simulating payment in a medical app is misleading and unacceptable. Document in `docs/MVP_SCOPE.md`.

### Question 4: Local Storage Engine for Offline Adherence
- **Question**: When the patient is offline (e.g., in a clinic basement or traveling), medication routines and visits need local persistence.
- **Recommendation**: **(Recommended) Use Hive / SharedPreferences for local caching alongside Supabase.**
  - Keep `SharedPreferences` for simple settings and use a lightweight local cache for recent timeline events.
