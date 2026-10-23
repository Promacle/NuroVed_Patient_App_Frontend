-- =============================================================================
-- Migration: 20261023000001_core_schema.sql
-- Description: Core MVP Schema for NuroVed Patient App (Diabetes Care Timeline)
-- Non-destructive, idempotent, strongly-typed with UUIDs, constraints & triggers.
-- =============================================================================

-- 1. Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. Utility Trigger Function: Automatic updated_at Timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = clock_timestamp();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- 3. Table: public.profiles (Patient Profiles)
-- One record per authenticated auth.users entry.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL CHECK (char_length(trim(name)) > 0),
  email text NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  phone text CHECK (phone IS NULL OR char_length(trim(phone)) >= 7),
  date_of_birth date CHECK (date_of_birth IS NULL OR (date_of_birth <= CURRENT_DATE AND date_of_birth >= '1900-01-01'::date)),
  gender text CHECK (gender IS NULL OR gender IN ('Male', 'Female', 'Other', 'Prefer not to say')),
  height numeric(5,2) CHECK (height IS NULL OR (height >= 30.0 AND height <= 300.0)),
  weight numeric(5,2) CHECK (weight IS NULL OR (weight >= 1.0 AND weight <= 500.0)),
  blood_group text CHECK (blood_group IS NULL OR blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
  allergies text[] DEFAULT '{}'::text[] NOT NULL,
  chronic_conditions text[] DEFAULT '{Diabetes}'::text[] NOT NULL,
  photo_url text,
  created_at timestamptz DEFAULT clock_timestamp() NOT NULL,
  updated_at timestamptz DEFAULT clock_timestamp() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
CREATE TRIGGER trg_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Automatic trigger to populate public.profiles when an auth.users record is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    name,
    email,
    phone,
    date_of_birth,
    gender
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Patient'),
    NEW.email,
    NEW.raw_user_meta_data->>'phone',
    CASE
      WHEN NEW.raw_user_meta_data->>'date_of_birth' IS NOT NULL
      THEN (NEW.raw_user_meta_data->>'date_of_birth')::date
      ELSE NULL
    END,
    COALESCE(NEW.raw_user_meta_data->>'gender', 'Prefer not to say')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, auth, pg_temp;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =============================================================================
-- 4. Table: public.family_members
-- Managed dependents and care circles under an account owner.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.family_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name text NOT NULL CHECK (char_length(trim(name)) > 0),
  relation text NOT NULL CHECK (relation IN ('Self', 'Spouse', 'Father', 'Mother', 'Son', 'Daughter', 'Brother', 'Sister', 'Grandparent', 'Other')),
  is_main boolean DEFAULT false NOT NULL,
  is_emergency_contact boolean DEFAULT false NOT NULL,
  phone text CHECK (phone IS NULL OR char_length(trim(phone)) >= 7),
  blood_group text CHECK (blood_group IS NULL OR blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
  photo_url text,
  created_at timestamptz DEFAULT clock_timestamp() NOT NULL,
  updated_at timestamptz DEFAULT clock_timestamp() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_family_members_user ON public.family_members(user_id);
-- Ensure at most one primary dependent profile per user
CREATE UNIQUE INDEX IF NOT EXISTS idx_family_members_single_main ON public.family_members(user_id) WHERE is_main = true;

DROP TRIGGER IF EXISTS trg_family_members_updated_at ON public.family_members;
CREATE TRIGGER trg_family_members_updated_at
BEFORE UPDATE ON public.family_members
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =============================================================================
-- 5. Table: public.care_access_grants
-- Delegated clinician or caregiver access with temporal and resource scoping.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.care_access_grants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  grantee_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  grantee_email text NOT NULL CHECK (grantee_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  grantee_name text NOT NULL CHECK (char_length(trim(grantee_name)) > 0),
  access_type text NOT NULL CHECK (access_type IN ('view_only', 'view_and_edit')),
  scopes text[] NOT NULL CHECK (scopes <@ ARRAY['full_profile', 'medical_records', 'health_timeline', 'medications']),
  purpose text NOT NULL CHECK (char_length(trim(purpose)) > 0),
  status text DEFAULT 'active' NOT NULL CHECK (status IN ('active', 'revoked', 'expired', 'pending')),
  created_at timestamptz DEFAULT clock_timestamp() NOT NULL,
  expires_at timestamptz NOT NULL CHECK (expires_at > created_at),
  revoked_at timestamptz,
  CONSTRAINT check_revocation_consistency CHECK (
    (status = 'revoked' AND revoked_at IS NOT NULL) OR
    (status != 'revoked' AND revoked_at IS NULL)
  )
);

CREATE INDEX IF NOT EXISTS idx_grants_patient ON public.care_access_grants(patient_id, status);
CREATE INDEX IF NOT EXISTS idx_grants_grantee ON public.care_access_grants(grantee_id, status, expires_at);

-- =============================================================================
-- 6. Table: public.medical_records
-- Diagnostic metadata, prescriptions, lab results, and file pointers.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.medical_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  family_member_id uuid REFERENCES public.family_members(id) ON DELETE SET NULL,
  title text NOT NULL CHECK (char_length(trim(title)) > 0),
  record_type text NOT NULL CHECK (record_type IN ('Prescription', 'Lab Report', 'Discharge Summary', 'Imaging/X-Ray', 'Vaccination', 'Insurance', 'Other')),
  record_date date NOT NULL CHECK (record_date <= CURRENT_DATE + interval '1 day'),
  doctor_name text,
  hospital_name text,
  description text,
  storage_path text CHECK (
    storage_path IS NULL OR
    storage_path ~* '^[0-9a-fA-F-]{36}/[0-9a-fA-F-]{36}/[0-9a-fA-F-]{36}/[^/]+$'
  ),
  file_name text,
  mime_type text CHECK (mime_type IS NULL OR mime_type IN ('application/pdf', 'image/jpeg', 'image/png')),
  file_size bigint CHECK (file_size IS NULL OR (file_size > 0 AND file_size <= 10485760)), -- Max 10MB
  created_at timestamptz DEFAULT clock_timestamp() NOT NULL,
  updated_at timestamptz DEFAULT clock_timestamp() NOT NULL,
  deleted_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_medical_records_user_date ON public.medical_records(user_id, record_date DESC);
CREATE INDEX IF NOT EXISTS idx_medical_records_family ON public.medical_records(family_member_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_active ON public.medical_records(user_id) WHERE deleted_at IS NULL;

DROP TRIGGER IF EXISTS trg_medical_records_updated_at ON public.medical_records;
CREATE TRIGGER trg_medical_records_updated_at
BEFORE UPDATE ON public.medical_records
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =============================================================================
-- 7. Table: public.visits
-- Clinical consultations and hospital checkups.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.visits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  family_member_id uuid REFERENCES public.family_members(id) ON DELETE SET NULL,
  visit_date date NOT NULL,
  title text NOT NULL CHECK (char_length(trim(title)) > 0),
  subtitle text,
  doctor_name text,
  specialty text,
  hospital_name text,
  notes text,
  created_at timestamptz DEFAULT clock_timestamp() NOT NULL,
  updated_at timestamptz DEFAULT clock_timestamp() NOT NULL,
  deleted_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_visits_user_date ON public.visits(user_id, visit_date DESC);
CREATE INDEX IF NOT EXISTS idx_visits_family ON public.visits(family_member_id);

DROP TRIGGER IF EXISTS trg_visits_updated_at ON public.visits;
CREATE TRIGGER trg_visits_updated_at
BEFORE UPDATE ON public.visits
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =============================================================================
-- 8. Table: public.visit_record_links
-- Canonical many-to-many relationship linking visits to diagnostic records.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.visit_record_links (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  visit_id uuid NOT NULL REFERENCES public.visits(id) ON DELETE CASCADE,
  record_id uuid NOT NULL REFERENCES public.medical_records(id) ON DELETE CASCADE,
  linked_at timestamptz DEFAULT clock_timestamp() NOT NULL,
  CONSTRAINT uq_visit_record UNIQUE(visit_id, record_id)
);

CREATE INDEX IF NOT EXISTS idx_vrl_visit ON public.visit_record_links(visit_id);
CREATE INDEX IF NOT EXISTS idx_vrl_record ON public.visit_record_links(record_id);

-- =============================================================================
-- 9. Table: public.medication_routines
-- Ongoing prescribed medications and scheduling for diabetes care.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.medication_routines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  family_member_id uuid REFERENCES public.family_members(id) ON DELETE SET NULL,
  medicine_name text NOT NULL CHECK (char_length(trim(medicine_name)) > 0),
  instruction text NOT NULL CHECK (instruction IN ('Before Food', 'After Food', 'With Food', 'Empty Stomach', 'As Needed')),
  dosage text CHECK (dosage IS NULL OR char_length(dosage) <= 50),
  scheduled_time time NOT NULL,
  start_date date DEFAULT CURRENT_DATE NOT NULL,
  end_date date CHECK (end_date IS NULL OR end_date >= start_date),
  is_active boolean DEFAULT true NOT NULL,
  created_at timestamptz DEFAULT clock_timestamp() NOT NULL,
  updated_at timestamptz DEFAULT clock_timestamp() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_med_routines_user ON public.medication_routines(user_id, is_active);

DROP TRIGGER IF EXISTS trg_med_routines_updated_at ON public.medication_routines;
CREATE TRIGGER trg_med_routines_updated_at
BEFORE UPDATE ON public.medication_routines
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =============================================================================
-- 10. Table: public.medication_completions
-- Daily patient intake log for compliance and timeline analysis.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.medication_completions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  routine_id uuid NOT NULL REFERENCES public.medication_routines(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  completed_date date DEFAULT CURRENT_DATE NOT NULL,
  completed_at timestamptz DEFAULT clock_timestamp() NOT NULL,
  status text DEFAULT 'completed' NOT NULL CHECK (status IN ('completed', 'skipped', 'delayed')),
  notes text,
  CONSTRAINT uq_routine_daily UNIQUE(routine_id, completed_date)
);

CREATE INDEX IF NOT EXISTS idx_med_completions_user_date ON public.medication_completions(user_id, completed_date DESC);

-- =============================================================================
-- 11. View: public.patient_timeline
-- Unified chronological projection of medical records and visits.
-- =============================================================================
CREATE OR REPLACE VIEW public.patient_timeline WITH (security_invoker = true) AS
SELECT
  r.id AS item_id,
  r.user_id,
  r.family_member_id,
  'medical_record'::text AS item_type,
  r.title,
  COALESCE(r.record_type, 'Medical Record') AS subtitle,
  r.record_date AS event_date,
  r.doctor_name,
  r.hospital_name,
  r.storage_path,
  r.file_name,
  r.created_at
FROM public.medical_records r
WHERE r.deleted_at IS NULL

UNION ALL

SELECT
  v.id AS item_id,
  v.user_id,
  v.family_member_id,
  'visit'::text AS item_type,
  v.title,
  COALESCE(v.specialty, v.subtitle, 'Doctor Visit') AS subtitle,
  v.visit_date AS event_date,
  v.doctor_name,
  v.hospital_name,
  NULL::text AS storage_path,
  NULL::text AS file_name,
  v.created_at
FROM public.visits v
WHERE v.deleted_at IS NULL;

-- =============================================================================
-- 12. Table: public.audit_events (Append-Only)
-- Immutable clinical and security audit trail for patient data operations.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.audit_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  event_type text NOT NULL CHECK (event_type IN (
    'auth_login', 'auth_logout',
    'record_read', 'record_created', 'record_updated', 'record_deleted',
    'access_granted', 'access_revoked',
    'export_requested', 'account_deleted'
  )),
  resource_table text NOT NULL,
  resource_id uuid,
  actor_ip text,
  actor_user_agent text,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT clock_timestamp() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_audit_events_user ON public.audit_events(user_id, created_at DESC);

-- Guard function preventing ANY update or delete on audit_events
CREATE OR REPLACE FUNCTION public.prevent_audit_tampering()
RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'Audit events are immutable and cannot be updated or deleted.';
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_events_immutable ON public.audit_events;
CREATE TRIGGER trg_audit_events_immutable
BEFORE UPDATE OR DELETE ON public.audit_events
FOR EACH ROW EXECUTE FUNCTION public.prevent_audit_tampering();

-- Helper function to write audit events from server-side triggers
CREATE OR REPLACE FUNCTION public.log_audit_event(
  p_user_id uuid,
  p_event_type text,
  p_resource_table text,
  p_resource_id uuid,
  p_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
  v_audit_id uuid;
BEGIN
  INSERT INTO public.audit_events (
    user_id,
    event_type,
    resource_table,
    resource_id,
    metadata
  )
  VALUES (
    p_user_id,
    p_event_type,
    p_resource_table,
    p_resource_id,
    p_metadata
  )
  RETURNING id INTO v_audit_id;

  RETURN v_audit_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, auth, pg_temp;

-- Automatic audit triggers for medical records and access grants
CREATE OR REPLACE FUNCTION public.audit_medical_record_changes()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM public.log_audit_event(
      NEW.user_id,
      'record_created',
      'medical_records',
      NEW.id,
      jsonb_build_object('title', NEW.title, 'type', NEW.record_type)
    );
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
      PERFORM public.log_audit_event(
        NEW.user_id,
        'record_deleted',
        'medical_records',
        NEW.id,
        jsonb_build_object('title', NEW.title, 'deleted_at', NEW.deleted_at)
      );
    ELSE
      PERFORM public.log_audit_event(
        NEW.user_id,
        'record_updated',
        'medical_records',
        NEW.id,
        jsonb_build_object('title', NEW.title)
      );
    END IF;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    PERFORM public.log_audit_event(
      OLD.user_id,
      'record_deleted',
      'medical_records',
      OLD.id,
      jsonb_build_object('title', OLD.title)
    );
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, auth, pg_temp;

DROP TRIGGER IF EXISTS trg_audit_medical_records ON public.medical_records;
CREATE TRIGGER trg_audit_medical_records
AFTER INSERT OR UPDATE OR DELETE ON public.medical_records
FOR EACH ROW EXECUTE FUNCTION public.audit_medical_record_changes();

-- =============================================================================
-- 13. Server-Backed Account Deletion RPC
-- =============================================================================
CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
  v_user_id uuid;
BEGIN
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthenticated request: cannot delete account without active session';
  END IF;

  -- 1. Log account deletion event prior to cascade
  PERFORM public.log_audit_event(
    v_user_id,
    'account_deleted',
    'profiles',
    v_user_id,
    jsonb_build_object('deleted_by', 'patient_self_request')
  );

  -- 2. Delete patient clinical data and cascades
  DELETE FROM public.medical_records WHERE user_id = v_user_id;
  DELETE FROM public.visits WHERE user_id = v_user_id;
  DELETE FROM public.family_members WHERE user_id = v_user_id;
  DELETE FROM public.care_access_grants WHERE patient_id = v_user_id OR grantee_id = v_user_id;
  DELETE FROM public.medication_routines WHERE user_id = v_user_id;
  DELETE FROM public.profiles WHERE id = v_user_id;

  -- 3. Delete from auth.users (cascades sessions, MFA, tokens)
  DELETE FROM auth.users WHERE id = v_user_id;

  RETURN json_build_object(
    'success', true,
    'message', 'Account and all associated clinical data permanently erased'
  );
END;
$$;

REVOKE EXECUTE ON FUNCTION public.delete_user_account() FROM public, anon;
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated;
