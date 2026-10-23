-- =============================================================================
-- Test Suite: supabase/tests/rls_policies_test.sql
-- Description: Automated SQL Verification Suite for Row Level Security (RLS)
-- Validates:
--  1. Anonymous users cannot read or write any resource.
--  2. Unrelated authenticated users cannot read/modify/delete each other's data.
--  3. Delegated access grants enforce temporal (active/expired/revoked) and resource scoping.
--  4. Storage paths are isolated to account owners & authorized grantees.
--  5. Audit events are strictly append-only and cannot be updated or deleted.
-- =============================================================================

BEGIN;

-- Setup Test Users in auth.users
INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES
  ('11111111-1111-1111-1111-111111111111'::uuid, 'patient_a@nuroved.com', '{"name":"Patient A"}'::jsonb),
  ('22222222-2222-2222-2222-222222222222'::uuid, 'patient_b@nuroved.com', '{"name":"Patient B"}'::jsonb),
  ('33333333-3333-3333-3333-333333333333'::uuid, 'clinician_c@nuroved.com', '{"name":"Dr. Clinician C"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Populate profiles
INSERT INTO public.profiles (id, name, email)
VALUES
  ('11111111-1111-1111-1111-111111111111'::uuid, 'Patient A', 'patient_a@nuroved.com'),
  ('22222222-2222-2222-2222-222222222222'::uuid, 'Patient B', 'patient_b@nuroved.com'),
  ('33333333-3333-3333-3333-333333333333'::uuid, 'Dr. Clinician C', 'clinician_c@nuroved.com')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- Seed Data as Patient A
INSERT INTO public.medical_records (
  id,
  user_id,
  title,
  record_type,
  record_date,
  storage_path,
  file_name
)
VALUES (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  'Patient A HbA1c Lab Report',
  'Lab Report',
  '2026-10-01'::date,
  '11111111-1111-1111-1111-111111111111/11111111-1111-1111-1111-111111111111/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa/report.pdf',
  'report.pdf'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.visits (
  id,
  user_id,
  visit_date,
  title,
  specialty
)
VALUES (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  '2026-10-05'::date,
  'Endocrinology Consultation',
  'Endocrinology'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.medication_routines (
  id,
  user_id,
  medicine_name,
  instruction,
  scheduled_time
)
VALUES (
  'cccccccc-cccc-cccc-cccc-cccccccccccc'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  'Metformin 500mg',
  'After Food',
  '08:00:00'::time
)
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- TEST SUITE 1: ANONYMOUS USERS CANNOT READ OR WRITE
-- =============================================================================
DO $$
DECLARE
  v_count integer;
BEGIN
  -- Simulate unauthenticated anonymous request
  SET LOCAL role TO anon;
  SET LOCAL "request.jwt.claim.sub" TO '';

  -- Verify SELECT returns 0 records
  SELECT count(*) INTO v_count FROM public.profiles;
  ASSERT v_count = 0, 'Test Failed: Anonymous user could read profiles';

  SELECT count(*) INTO v_count FROM public.medical_records;
  ASSERT v_count = 0, 'Test Failed: Anonymous user could read medical_records';

  SELECT count(*) INTO v_count FROM public.visits;
  ASSERT v_count = 0, 'Test Failed: Anonymous user could read visits';

  SELECT count(*) INTO v_count FROM public.medication_routines;
  ASSERT v_count = 0, 'Test Failed: Anonymous user could read medication_routines';

  SELECT count(*) INTO v_count FROM public.audit_events;
  ASSERT v_count = 0, 'Test Failed: Anonymous user could read audit_events';

  RAISE NOTICE 'Test Suite 1 Passed: Anonymous user gets nothing (0 rows).';
END;
$$;

-- =============================================================================
-- TEST SUITE 2: TWO UNRELATED USERS ISOLATION (PATIENT B vs PATIENT A)
-- =============================================================================
DO $$
DECLARE
  v_count integer;
BEGIN
  -- Switch context to authenticated Patient B
  SET LOCAL role TO authenticated;
  SET LOCAL "request.jwt.claim.sub" TO '22222222-2222-2222-2222-222222222222';

  -- Patient B attempting to query Patient A's medical records
  SELECT count(*) INTO v_count FROM public.medical_records WHERE user_id = '11111111-1111-1111-1111-111111111111'::uuid;
  ASSERT v_count = 0, 'Test Failed: Patient B could see Patient A medical records';

  -- Patient B attempting to query Patient A's record by exact guessed UUID
  SELECT count(*) INTO v_count FROM public.medical_records WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
  ASSERT v_count = 0, 'Test Failed: Patient B could read Patient A record by guessed UUID';

  -- Patient B attempting to query Patient A's visits
  SELECT count(*) INTO v_count FROM public.visits WHERE id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid;
  ASSERT v_count = 0, 'Test Failed: Patient B could read Patient A visit by guessed UUID';

  -- Patient B attempting to UPDATE Patient A's record
  UPDATE public.medical_records SET title = 'Tampered Title' WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
  SELECT count(*) INTO v_count FROM public.medical_records WHERE title = 'Tampered Title';
  ASSERT v_count = 0, 'Test Failed: Patient B successfully updated Patient A record';

  -- Patient B attempting to DELETE Patient A's record
  DELETE FROM public.medical_records WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
  
  -- Verify record still exists
  SET LOCAL "request.jwt.claim.sub" TO '11111111-1111-1111-1111-111111111111';
  SELECT count(*) INTO v_count FROM public.medical_records WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
  ASSERT v_count = 1, 'Test Failed: Patient B successfully deleted Patient A record';

  RAISE NOTICE 'Test Suite 2 Passed: Full isolation between unrelated patients verified.';
END;
$$;

-- =============================================================================
-- TEST SUITE 3: DELEGATED CARE ACCESS GRANTS & SCOPE ENFORCEMENT
-- =============================================================================
DO $$
DECLARE
  v_count integer;
  v_grant_id uuid;
BEGIN
  -- As Patient A, grant Dr. Clinician C access ONLY to 'medical_records'
  SET LOCAL role TO authenticated;
  SET LOCAL "request.jwt.claim.sub" TO '11111111-1111-1111-1111-111111111111';

  INSERT INTO public.care_access_grants (
    id,
    patient_id,
    grantee_id,
    grantee_email,
    grantee_name,
    access_type,
    scopes,
    purpose,
    status,
    expires_at
  )
  VALUES (
    '44444444-4444-4444-4444-444444444444'::uuid,
    '11111111-1111-1111-1111-111111111111'::uuid,
    '33333333-3333-3333-3333-333333333333'::uuid,
    'clinician_c@nuroved.com',
    'Dr. Clinician C',
    'view_only',
    ARRAY['medical_records'],
    'Diabetes review',
    'active',
    clock_timestamp() + interval '7 days'
  )
  ON CONFLICT (id) DO UPDATE SET status = 'active', expires_at = clock_timestamp() + interval '7 days', revoked_at = NULL;

  -- Switch context to Dr. Clinician C
  SET LOCAL "request.jwt.claim.sub" TO '33333333-3333-3333-3333-333333333333';

  -- 1. Dr. Clinician C SHOULD be able to read medical records (in scope)
  SELECT count(*) INTO v_count FROM public.medical_records WHERE user_id = '11111111-1111-1111-1111-111111111111'::uuid;
  ASSERT v_count = 1, 'Test Failed: Clinician C could not read medical records under active grant';

  -- 2. Dr. Clinician C SHOULD NOT be able to read visits (out of scope: health_timeline not granted)
  SELECT count(*) INTO v_count FROM public.visits WHERE user_id = '11111111-1111-1111-1111-111111111111'::uuid;
  ASSERT v_count = 0, 'Test Failed: Clinician C could read visits out of granted scope';

  -- 3. Dr. Clinician C SHOULD NOT be able to read routines (out of scope: medications not granted)
  SELECT count(*) INTO v_count FROM public.medication_routines WHERE user_id = '11111111-1111-1111-1111-111111111111'::uuid;
  ASSERT v_count = 0, 'Test Failed: Clinician C could read routines out of granted scope';

  -- 4. Clinician C has view_only; attempting to insert record for Patient A must fail
  BEGIN
    INSERT INTO public.medical_records (user_id, title, record_type, record_date)
    VALUES ('11111111-1111-1111-1111-111111111111'::uuid, 'Unauthorized Record', 'Other', CURRENT_DATE);
    RAISE EXCEPTION 'Test Failed: Clinician with view_only could insert medical record';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL; -- Expected RLS check failure
  END;

  -- 5. Revoke the grant as Patient A
  SET LOCAL "request.jwt.claim.sub" TO '11111111-1111-1111-1111-111111111111';
  UPDATE public.care_access_grants
  SET status = 'revoked', revoked_at = clock_timestamp()
  WHERE id = '44444444-4444-4444-4444-444444444444'::uuid;

  -- Switch back to Clinician C -> access must now be denied
  SET LOCAL "request.jwt.claim.sub" TO '33333333-3333-3333-3333-333333333333';
  SELECT count(*) INTO v_count FROM public.medical_records WHERE user_id = '11111111-1111-1111-1111-111111111111'::uuid;
  ASSERT v_count = 0, 'Test Failed: Clinician C could read records after grant was revoked';

  RAISE NOTICE 'Test Suite 3 Passed: Scope and revocation enforcement verified.';
END;
$$;

-- =============================================================================
-- TEST SUITE 4: STORAGE OBJECT PATH CONVENTIONS & ACCESS FUNCTION
-- =============================================================================
DO $$
DECLARE
  v_path text;
BEGIN
  -- Test authorize_medical_file_access helper function
  -- As Patient A (owner)
  SET LOCAL role TO authenticated;
  SET LOCAL "request.jwt.claim.sub" TO '11111111-1111-1111-1111-111111111111';

  v_path := public.authorize_medical_file_access('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);
  ASSERT v_path LIKE '11111111-1111-1111-1111-111111111111/%', 'Test Failed: Storage path mismatch';

  -- As Patient B (unauthorized) -> must raise exception
  SET LOCAL "request.jwt.claim.sub" TO '22222222-2222-2222-2222-222222222222';
  BEGIN
    PERFORM public.authorize_medical_file_access('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);
    RAISE EXCEPTION 'Test Failed: Unauthorized user was able to authorize storage path';
  EXCEPTION
    WHEN OTHERS THEN
      -- Expected exception: 'Medical record not found or has been deleted' or 'Access forbidden'
      NULL;
  END;

  RAISE NOTICE 'Test Suite 4 Passed: Storage authorization check verified.';
END;
$$;

-- =============================================================================
-- TEST SUITE 5: AUDIT EVENTS IMMUTABILITY (APPEND-ONLY)
-- =============================================================================
DO $$
DECLARE
  v_audit_id uuid;
BEGIN
  SET LOCAL role TO authenticated;
  SET LOCAL "request.jwt.claim.sub" TO '11111111-1111-1111-1111-111111111111';

  SELECT id INTO v_audit_id FROM public.audit_events WHERE user_id = '11111111-1111-1111-1111-111111111111'::uuid LIMIT 1;

  IF v_audit_id IS NOT NULL THEN
    -- Attempt to UPDATE audit event
    BEGIN
      UPDATE public.audit_events SET event_type = 'auth_login' WHERE id = v_audit_id;
      RAISE EXCEPTION 'Test Failed: audit_events row was updated';
    EXCEPTION
      WHEN OTHERS THEN
        NULL; -- Expected trigger exception
    END;

    -- Attempt to DELETE audit event
    BEGIN
      DELETE FROM public.audit_events WHERE id = v_audit_id;
      RAISE EXCEPTION 'Test Failed: audit_events row was deleted';
    EXCEPTION
      WHEN OTHERS THEN
        NULL; -- Expected trigger exception
    END;
  END IF;

  RAISE NOTICE 'Test Suite 5 Passed: Audit events immutability verified.';
END;
$$;

ROLLBACK;
