-- Migration: Create delhivery_serviceability_cache table
-- Short-lived server-side cache for Delhivery Pincode Serviceability + Expected TAT
-- results, keyed on destination pincode + origin pincode + mode of transport.
-- Only ever read/written by the delhivery-serviceability Edge Function via the
-- service role key — never exposed to anon or authenticated clients.

CREATE TABLE IF NOT EXISTS public.delhivery_serviceability_cache (
    cache_key TEXT PRIMARY KEY,
    response JSONB NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_delhivery_cache_expires_at
    ON public.delhivery_serviceability_cache (expires_at);

ALTER TABLE public.delhivery_serviceability_cache ENABLE ROW LEVEL SECURITY;

-- IMPORTANT SECURITY RULE:
-- No policies for anon or authenticated roles. Only the service-role key
-- (used exclusively inside the delhivery-serviceability Edge Function) can
-- read/write rows in this table.
