-- =============================================================================
-- Migration: 20261023000003_storage_security.sql
-- Description: Private Storage Bucket & Policies for Medical Documents
-- Bucket: medical-records (public = false)
-- Path convention: {owner_uid}/{subject_id}/{record_id}/{filename}
-- =============================================================================

-- 1. Create Private Storage Bucket for Medical Records (if not exists)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'medical-records',
  'medical-records',
  false, -- STRICTLY PRIVATE: No public access
  10485760, -- 10MB limit per file
  ARRAY['application/pdf', 'image/jpeg', 'image/png']::text[]
)
ON CONFLICT (id) DO UPDATE SET
  public = false,
  file_size_limit = 10485760,
  allowed_mime_types = ARRAY['application/pdf', 'image/jpeg', 'image/png']::text[];

-- =============================================================================
-- 2. Storage Object RLS Policies
-- Path convention: {owner_uid}/{subject_id}/{record_id}/{filename}
-- (storage.foldername(name))[1] parses {owner_uid}
-- =============================================================================

-- SELECT: Accessible by patient owner or active delegated grantee with medical_records scope
DROP POLICY IF EXISTS "storage_select_medical_records" ON storage.objects;
CREATE POLICY "storage_select_medical_records" ON storage.objects
FOR SELECT USING (
  bucket_id = 'medical-records' AND (
    auth.uid()::text = (storage.foldername(name))[1] OR
    public.has_active_grant(
      ((storage.foldername(name))[1])::uuid,
      auth.uid(),
      'medical_records'
    )
  )
);

-- INSERT: Uploadable by patient owner or active clinician with view_and_edit access
DROP POLICY IF EXISTS "storage_insert_medical_records" ON storage.objects;
CREATE POLICY "storage_insert_medical_records" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'medical-records' AND (
    auth.uid()::text = (storage.foldername(name))[1] OR
    public.has_active_grant(
      ((storage.foldername(name))[1])::uuid,
      auth.uid(),
      'medical_records',
      true
    )
  ) AND
  -- Verify path depth matches convention: {owner_uid}/{subject_id}/{record_id}/{filename}
  array_length(storage.foldername(name), 1) >= 3
);

-- UPDATE: Modifiable only by patient owner
DROP POLICY IF EXISTS "storage_update_medical_records" ON storage.objects;
CREATE POLICY "storage_update_medical_records" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'medical-records' AND
  auth.uid()::text = (storage.foldername(name))[1]
) WITH CHECK (
  bucket_id = 'medical-records' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- DELETE: Deletable only by patient owner
DROP POLICY IF EXISTS "storage_delete_medical_records" ON storage.objects;
CREATE POLICY "storage_delete_medical_records" ON storage.objects
FOR DELETE USING (
  bucket_id = 'medical-records' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- =============================================================================
-- 3. Authorization-Checked Signed URL Verification Helper
-- Validates authorization prior to client invoking Supabase signed URL generation.
-- =============================================================================
CREATE OR REPLACE FUNCTION public.authorize_medical_file_access(
  p_record_id uuid
)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
  v_caller_id uuid;
  v_storage_path text;
  v_owner_id uuid;
  v_is_authorized boolean := false;
BEGIN
  v_caller_id := auth.uid();

  IF v_caller_id IS NULL THEN
    RAISE EXCEPTION 'Unauthenticated access denied';
  END IF;

  -- Lookup record metadata
  SELECT user_id, storage_path INTO v_owner_id, v_storage_path
  FROM public.medical_records
  WHERE id = p_record_id AND deleted_at IS NULL;

  IF v_owner_id IS NULL THEN
    RAISE EXCEPTION 'Medical record not found or has been deleted';
  END IF;

  -- Check owner or active grant authorization
  IF v_owner_id = v_caller_id THEN
    v_is_authorized := true;
  ELSE
    v_is_authorized := public.has_active_grant(v_owner_id, v_caller_id, 'medical_records');
  END IF;

  IF NOT v_is_authorized THEN
    RAISE EXCEPTION 'Access forbidden: no active grant for medical records';
  END IF;

  -- Log access event in audit trail
  PERFORM public.log_audit_event(
    v_owner_id,
    'record_read',
    'medical_records',
    p_record_id,
    jsonb_build_object('accessed_by', v_caller_id, 'storage_path', v_storage_path)
  );

  RETURN v_storage_path;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.authorize_medical_file_access(uuid) FROM public, anon;
GRANT EXECUTE ON FUNCTION public.authorize_medical_file_access(uuid) TO authenticated;
