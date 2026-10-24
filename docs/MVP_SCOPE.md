# NuroVed Patient App — MVP Scope & Feature Status

This document defines the scope of features in the **NuroVed MVP**, detailing which features are active, which are intentionally disabled or marked unavailable, the clinical/safety rationale for each decision, and the technical prerequisites for production enablement.

---

## 1. Feature Status Matrix

| Feature Area | MVP Status | Rationale | Enabling Requirements |
| :--- | :--- | :--- | :--- |
| **Authentication & Sessions** | **ACTIVE** | Supabase Auth with PKCE tokens, real session persistence, route guards, and biometric/password flows. | Fully configured with real or fake repository backends. |
| **Active Patient Profile & Family Switching** | **ACTIVE** | Multi-subject UUID isolation with single source of truth (`activeSubjectId`). Zero stale data bleeding. | Production migrations in `supabase/migrations/`. |
| **Emergency Medical Card** | **ACTIVE** | Displays only verified/patient-entered fields. Prominent "patient-entered, unverified" clinical disclaimer. Zero hard-coded mock data. | Complete. |
| **Medical Records & File Storage** | **ACTIVE** | Private storage bucket, mime/signature validation, progress indicators, short-lived signed URLs, RLS enforcement. | Supabase Private Storage Bucket configured. |
| **Visits & Health Timeline** | **ACTIVE** | Timezone-safe visit logging, record reference linking (no duplicates), doctor visit detail view. | Complete. |
| **Medication Routines & Progress** | **ACTIVE** | Per-subject routines, exact dosage preservation, "Self-Entered" vs "Verified Prescription" tagging, notification permission checks. | Complete. |
| **Caregiver Delegation Grants** | **ACTIVE** | Owner-granted access to trusted family/caregiver (`care_access_grants`) enforced via Row Level Security (RLS). | Complete. |
| **Food Scanner** | **DISABLED** | Clinical safety: Simulated or unverified nutritional estimates pose hypoglycaemia/hyperglycaemia risks for diabetic patients. | Accredited nutritional database integration (ICMR-NIN / USDA FoodData) and barcode lookup API. |
| **AI Meal Plan Generator** | **DISABLED** | Patient safety: Unvalidated AI meal recommendations without certified clinical algorithms can generate hazardous diets. | Certified clinical endocrinology rules engine, healthcare provider validation, and dynamic glucose telemetry. |
| **Direct Clinician / Hospital Access Portal** | **DISABLED** | Security & Privacy: Clinician identity cannot be proven by a typed email. Institutional clinical sharing requires authenticated provider portals. | ABDM / NDHM Healthcare Professional Registry integration, institutional clinician portal, and server-side identity verification. |
| **In-App Purchases (Store Checkout)** | **DISABLED** | Financial integrity: Simulated purchase flows and client-side entitlement are prohibited. All features free in preview. | Google Play Billing Library + Apple StoreKit 2, server-side receipt validation via Supabase Edge Functions. |
| **Report a Problem (Cloud Sync)** | **LOCAL-ONLY** | Diagnostics are stored locally on device. Support cloud gateway is not yet deployed. | Deployment of customer support ticketing webhook service. |

---

## 2. Detailed Rationale for Disabled Features

### 2.1 Food Scanner & AI Diet Planner
- **Clinical Risk**: Patients with Type 1 or Type 2 diabetes rely on accurate carbohydrate counting to calculate insulin or oral hypoglycaemic dosages. Providing mock, hallucinated, or unverified carbohydrate counts creates severe risks of insulin overdosing (fatal hypoglycaemia) or underdosing (ketoacidosis/hyperglycaemic crisis).
- **MVP Behavior**: The Food Scanner and AI Diet Planner screens render explicit "Unavailable in MVP" cards explaining that simulated data has been eliminated for clinical safety. Diet tracking history and manual meal routines remain available.

### 2.2 Hospital / Clinician Direct Sharing
- **Privacy & Regulatory Risk**: Health data regulations (HIPAA, GDPR, DISHA) prohibit granting external parties access to Protected Health Information (PHI) based solely on client-entered names or unverified email addresses.
- **MVP Behavior**: Direct hospital access requests in the "Access Request" tab display a clear notice indicating that direct clinician sharing requires a verified institutional provider portal. Caregiver delegation remains fully functional under "Manage Access" via Supabase RLS.

### 2.3 In-App Purchases & Subscriptions
- **Commercial & Security Risk**: Mock checkout buttons ("Pay", "Demo: Failed", "Demo: Renew") create a false impression of purchase processing and cannot reliably manage subscription entitlements across device restarts or store refunds.
- **MVP Behavior**: The Purchase Screen displays an honest "In-App Purchases Unavailable in MVP" card explaining that store billing is unconfigured. All core continuity-of-care tools remain accessible in free preview mode.

---

## 3. Production Roadmap

1. **Phase 7 (Release Preparation)**:
   - Configure live Supabase instance with migrations and RLS policies.
   - Integrate Google Play Billing and Apple StoreKit with backend receipt validation.
   - Integrate authenticated clinician identity verification through national registry or hospital federations.
   - Onboard verified nutritional datasets for barcode food scanning.
