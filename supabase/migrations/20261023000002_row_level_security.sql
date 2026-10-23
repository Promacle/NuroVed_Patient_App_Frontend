-- =============================================================================
-- Migration: 20261023000002_row_level_security.sql
-- Description: Row Level Security (RLS) policies for NuroVed Patient App
-- Enables RLS on all tables with explicit operations for owners & active grantees.
-- =============================================================================

-- 1. Helper Function: Check whether grantee holds an active, unrevoked, unexpired grant
CREATE OR REPLACE FUNCTION public.has_active_grant(
  p_patient_id uuid,
  p_grantee_id uuid,
  p_scope text,
  p_require_edit boolean DEFAULT false
)
RETURNS boolean AS $$
BEGIN
  IF p_patient_id IS NULL OR p_grantee_id IS NULL THEN
    RETURN false;
  END IF;

  RETURN EXISTS (
    SELECT 1 FROM public.care_access_grants g
    WHERE g.patient_id = p_patient_id
      AND g.grantee_id = p_grantee_id
      AND g.status = 'active'
      AND g.expires_at > clock_timestamp()
      AND g.revoked_at IS NULL
      AND (p_scope = ANY(g.scopes) OR 'full_profile' = ANY(g.scopes))
      AND (NOT p_require_edit OR g.access_type = 'view_and_edit')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE SET search_path = public, auth, pg_temp;

-- =============================================================================
-- 2. RLS on public.profiles
-- =============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select_owner_or_grantee" ON public.profiles;
CREATE POLICY "profiles_select_owner_or_grantee" ON public.profiles
FOR SELECT USING (
  auth.uid() = id OR
  public.has_active_grant(id, auth.uid(), 'full_profile')
);

DROP POLICY IF EXISTS "profiles_insert_owner" ON public.profiles;
CREATE POLICY "profiles_insert_owner" ON public.profiles
FOR INSERT WITH CHECK (
  auth.uid() = id
);

DROP POLICY IF EXISTS "profiles_update_owner" ON public.profiles;
CREATE POLICY "profiles_update_owner" ON public.profiles
FOR UPDATE USING (
  auth.uid() = id
) WITH CHECK (
  auth.uid() = id
);

DROP POLICY IF EXISTS "profiles_delete_owner" ON public.profiles;
CREATE POLICY "profiles_delete_owner" ON public.profiles
FOR DELETE USING (
  auth.uid() = id
);

-- =============================================================================
-- 3. RLS on public.family_members
-- =============================================================================
ALTER TABLE public.family_members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "family_members_select" ON public.family_members;
CREATE POLICY "family_members_select" ON public.family_members
FOR SELECT USING (
  auth.uid() = user_id OR
  public.has_active_grant(user_id, auth.uid(), 'full_profile') OR
  public.has_active_grant(user_id, auth.uid(), 'medical_records')
);

DROP POLICY IF EXISTS "family_members_insert" ON public.family_members;
CREATE POLICY "family_members_insert" ON public.family_members
FOR INSERT WITH CHECK (
  auth.uid() = user_id
);

DROP POLICY IF EXISTS "family_members_update" ON public.family_members;
CREATE POLICY "family_members_update" ON public.family_members
FOR UPDATE USING (
  auth.uid() = user_id
) WITH CHECK (
  auth.uid() = user_id
);

DROP POLICY IF EXISTS "family_members_delete" ON public.family_members;
CREATE POLICY "family_members_delete" ON public.family_members
FOR DELETE USING (
  auth.uid() = user_id
);

-- =============================================================================
-- 4. RLS on public.care_access_grants
-- =============================================================================
ALTER TABLE public.care_access_grants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "grants_select_parties" ON public.care_access_grants;
CREATE POLICY "grants_select_parties" ON public.care_access_grants
FOR SELECT USING (
  auth.uid() = patient_id OR
  auth.uid() = grantee_id
);

DROP POLICY IF EXISTS "grants_insert_patient" ON public.care_access_grants;
CREATE POLICY "grants_insert_patient" ON public.care_access_grants
FOR INSERT WITH CHECK (
  auth.uid() = patient_id
);

DROP POLICY IF EXISTS "grants_update_patient_or_grantee" ON public.care_access_grants;
CREATE POLICY "grants_update_patient_or_grantee" ON public.care_access_grants
FOR UPDATE USING (
  auth.uid() = patient_id OR
  auth.uid() = grantee_id
) WITH CHECK (
  -- Patient can edit or revoke grant; Grantee can only set status = 'revoked'
  auth.uid() = patient_id OR
  (auth.uid() = grantee_id AND status = 'revoked')
);

DROP POLICY IF EXISTS "grants_delete_patient" ON public.care_access_grants;
CREATE POLICY "grants_delete_patient" ON public.care_access_grants
FOR DELETE USING (
  auth.uid() = patient_id
);

-- =============================================================================
-- 5. RLS on public.medical_records
-- =============================================================================
ALTER TABLE public.medical_records ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "records_select_owner_or_grantee" ON public.medical_records;
CREATE POLICY "records_select_owner_or_grantee" ON public.medical_records
FOR SELECT USING (
  (auth.uid() = user_id AND deleted_at IS NULL) OR
  public.has_active_grant(user_id, auth.uid(), 'medical_records')
);

DROP POLICY IF EXISTS "records_insert_owner_or_clinician" ON public.medical_records;
CREATE POLICY "records_insert_owner_or_clinician" ON public.medical_records
FOR INSERT WITH CHECK (
  auth.uid() = user_id OR
  public.has_active_grant(user_id, auth.uid(), 'medical_records', true)
);

DROP POLICY IF EXISTS "records_update_owner_or_clinician" ON public.medical_records;
CREATE POLICY "records_update_owner_or_clinician" ON public.medical_records
FOR UPDATE USING (
  auth.uid() = user_id OR
  public.has_active_grant(user_id, auth.uid(), 'medical_records', true)
) WITH CHECK (
  auth.uid() = user_id OR
  public.has_active_grant(user_id, auth.uid(), 'medical_records', true)
);

DROP POLICY IF EXISTS "records_delete_owner" ON public.medical_records;
CREATE POLICY "records_delete_owner" ON public.medical_records
FOR DELETE USING (
  auth.uid() = user_id
);

-- =============================================================================
-- 6. RLS on public.visits
-- =============================================================================
ALTER TABLE public.visits ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "visits_select_owner_or_grantee" ON public.visits;
CREATE POLICY "visits_select_owner_or_grantee" ON public.visits
FOR SELECT USING (
  (auth.uid() = user_id AND deleted_at IS NULL) OR
  public.has_active_grant(user_id, auth.uid(), 'health_timeline')
);

DROP POLICY IF EXISTS "visits_insert_owner_or_clinician" ON public.visits;
CREATE POLICY "visits_insert_owner_or_clinician" ON public.visits
FOR INSERT WITH CHECK (
  auth.uid() = user_id OR
  public.has_active_grant(user_id, auth.uid(), 'health_timeline', true)
);

DROP POLICY IF EXISTS "visits_update_owner_or_clinician" ON public.visits;
CREATE POLICY "visits_update_owner_or_clinician" ON public.visits
FOR UPDATE USING (
  auth.uid() = user_id OR
  public.has_active_grant(user_id, auth.uid(), 'health_timeline', true)
) WITH CHECK (
  auth.uid() = user_id OR
  public.has_active_grant(user_id, auth.uid(), 'health_timeline', true)
);

DROP POLICY IF EXISTS "visits_delete_owner" ON public.visits;
CREATE POLICY "visits_delete_owner" ON public.visits
FOR DELETE USING (
  auth.uid() = user_id
);

-- =============================================================================
-- 7. RLS on public.visit_record_links
-- =============================================================================
ALTER TABLE public.visit_record_links ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "vrl_select" ON public.visit_record_links;
CREATE POLICY "vrl_select" ON public.visit_record_links
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.visits v
    WHERE v.id = visit_id
      AND ((v.user_id = auth.uid() AND v.deleted_at IS NULL) OR public.has_active_grant(v.user_id, auth.uid(), 'health_timeline'))
  )
);

DROP POLICY IF EXISTS "vrl_insert" ON public.visit_record_links;
CREATE POLICY "vrl_insert" ON public.visit_record_links
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.visits v
    WHERE v.id = visit_id
      AND (v.user_id = auth.uid() OR public.has_active_grant(v.user_id, auth.uid(), 'health_timeline', true))
  )
);

DROP POLICY IF EXISTS "vrl_delete" ON public.visit_record_links;
CREATE POLICY "vrl_delete" ON public.visit_record_links
FOR DELETE USING (
  EXISTS (
    SELECT 1 FROM public.visits v
    WHERE v.id = visit_id AND v.user_id = auth.uid()
  )
);

-- =============================================================================
-- 8. RLS on public.medication_routines
-- =============================================================================
ALTER TABLE public.medication_routines ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "med_routines_select" ON public.medication_routines;
CREATE POLICY "med_routines_select" ON public.medication_routines
FOR SELECT USING (
  auth.uid() = user_id OR
  public.has_active_grant(user_id, auth.uid(), 'medications')
);

DROP POLICY IF EXISTS "med_routines_insert" ON public.medication_routines;
CREATE POLICY "med_routines_insert" ON public.medication_routines
FOR INSERT WITH CHECK (
  auth.uid() = user_id
);

DROP POLICY IF EXISTS "med_routines_update" ON public.medication_routines;
CREATE POLICY "med_routines_update" ON public.medication_routines
FOR UPDATE USING (
  auth.uid() = user_id
) WITH CHECK (
  auth.uid() = user_id
);

DROP POLICY IF EXISTS "med_routines_delete" ON public.medication_routines;
CREATE POLICY "med_routines_delete" ON public.medication_routines
FOR DELETE USING (
  auth.uid() = user_id
);

-- =============================================================================
-- 9. RLS on public.medication_completions
-- =============================================================================
ALTER TABLE public.medication_completions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "med_completions_select" ON public.medication_completions;
CREATE POLICY "med_completions_select" ON public.medication_completions
FOR SELECT USING (
  auth.uid() = user_id OR
  public.has_active_grant(user_id, auth.uid(), 'medications')
);

DROP POLICY IF EXISTS "med_completions_insert" ON public.medication_completions;
CREATE POLICY "med_completions_insert" ON public.medication_completions
FOR INSERT WITH CHECK (
  auth.uid() = user_id
);

DROP POLICY IF EXISTS "med_completions_update" ON public.medication_completions;
CREATE POLICY "med_completions_update" ON public.medication_completions
FOR UPDATE USING (
  auth.uid() = user_id
) WITH CHECK (
  auth.uid() = user_id
);

DROP POLICY IF EXISTS "med_completions_delete" ON public.medication_completions;
CREATE POLICY "med_completions_delete" ON public.medication_completions
FOR DELETE USING (
  auth.uid() = user_id
);

-- =============================================================================
-- 10. RLS on public.audit_events (Append-Only)
-- =============================================================================
ALTER TABLE public.audit_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "audit_events_select_owner" ON public.audit_events;
CREATE POLICY "audit_events_select_owner" ON public.audit_events
FOR SELECT USING (
  auth.uid() = user_id
);

DROP POLICY IF EXISTS "audit_events_insert_authenticated" ON public.audit_events;
CREATE POLICY "audit_events_insert_authenticated" ON public.audit_events
FOR INSERT WITH CHECK (
  auth.uid() = user_id
);

-- Explicitly NO UPDATE or DELETE policies exist for audit_events.
-- Combined with trg_audit_events_immutable, this guarantees append-only integrity.
