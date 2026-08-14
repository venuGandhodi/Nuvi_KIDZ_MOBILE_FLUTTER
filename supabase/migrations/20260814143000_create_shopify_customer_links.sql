-- Migration: Create shopify_customer_links table with strict security controls
-- Authoritative server-side identity bridge between Supabase Auth and Shopify Customer records

CREATE TABLE IF NOT EXISTS public.shopify_customer_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supabase_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    shopify_customer_id TEXT NOT NULL,
    shopify_customer_email TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_shopify_customer_links_supabase_user UNIQUE (supabase_user_id),
    CONSTRAINT uq_shopify_customer_links_shopify_customer UNIQUE (shopify_customer_id)
);

-- Indices for rapid lookup
CREATE INDEX IF NOT EXISTS idx_shopify_customer_links_user_id ON public.shopify_customer_links (supabase_user_id);
CREATE INDEX IF NOT EXISTS idx_shopify_customer_links_shopify_id ON public.shopify_customer_links (shopify_customer_id);
CREATE INDEX IF NOT EXISTS idx_shopify_customer_links_email ON public.shopify_customer_links (shopify_customer_email);

-- Enable Row Level Security
ALTER TABLE public.shopify_customer_links ENABLE ROW LEVEL SECURITY;

-- Read-only policy for authenticated users to view their own link
CREATE POLICY "Users can only view their own Shopify link"
    ON public.shopify_customer_links
    FOR SELECT
    TO authenticated
    USING (auth.uid() = supabase_user_id);

-- IMPORTANT SECURITY RULE:
-- NO INSERT, UPDATE, OR DELETE policies for authenticated or anon roles.
-- Only the server-side Edge Function using the Supabase Service Role key can insert/update rows.
