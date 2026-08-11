-- Reusable trigger function for updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = '';

-- 1. profiles
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    avatar_url TEXT,
    status TEXT DEFAULT 'active'::TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Profiles are viewable by owner" ON public.profiles FOR SELECT TO authenticated USING ((select auth.uid()) = id);
CREATE POLICY "Profiles can be updated by owner" ON public.profiles FOR UPDATE TO authenticated USING ((select auth.uid()) = id) WITH CHECK ((select auth.uid()) = id);

CREATE OR REPLACE FUNCTION public.restrict_profile_updates()
RETURNS TRIGGER AS $$
BEGIN
    IF current_setting('request.jwt.claims', true)::jsonb->>'role' = 'authenticated' THEN
        IF NEW.id IS DISTINCT FROM OLD.id OR
           NEW.status IS DISTINCT FROM OLD.status OR
           NEW.created_at IS DISTINCT FROM OLD.created_at THEN
            RAISE EXCEPTION 'Only display_name, first_name, last_name, phone, and avatar_url can be updated by authenticated users.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = '';

CREATE TRIGGER enforce_profile_update_restrictions
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.restrict_profile_updates();

CREATE TRIGGER handle_updated_at_profiles
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, first_name, last_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'display_name',
    NEW.raw_user_meta_data->>'first_name',
    NEW.raw_user_meta_data->>'last_name',
    NEW.raw_user_meta_data->>'avatar_url'
  );
  
  -- Create default user preferences
  INSERT INTO public.user_preferences (user_id) VALUES (NEW.id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 2. user_preferences
CREATE TABLE public.user_preferences (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    language TEXT,
    currency TEXT,
    notification_preferences JSONB DEFAULT '{}'::jsonb,
    marketing_preferences JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Preferences are viewable by owner" ON public.user_preferences FOR SELECT TO authenticated USING ((select auth.uid()) = user_id);
CREATE POLICY "Preferences can be updated by owner" ON public.user_preferences FOR UPDATE TO authenticated USING ((select auth.uid()) = user_id) WITH CHECK ((select auth.uid()) = user_id);

CREATE TRIGGER handle_updated_at_user_preferences
    BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 3. wishlist
CREATE TABLE public.wishlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    shopify_product_id TEXT NOT NULL,
    shopify_variant_id TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX wishlist_unique_product_idx ON public.wishlist (user_id, shopify_product_id) WHERE shopify_variant_id IS NULL;
CREATE UNIQUE INDEX wishlist_unique_variant_idx ON public.wishlist (user_id, shopify_product_id, shopify_variant_id) WHERE shopify_variant_id IS NOT NULL;

ALTER TABLE public.wishlist ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Wishlist viewable by owner" ON public.wishlist FOR SELECT TO authenticated USING ((select auth.uid()) = user_id);
CREATE POLICY "Wishlist insertable by owner" ON public.wishlist FOR INSERT TO authenticated WITH CHECK ((select auth.uid()) = user_id);
CREATE POLICY "Wishlist deletable by owner" ON public.wishlist FOR DELETE TO authenticated USING ((select auth.uid()) = user_id);

-- 4. recently_viewed
CREATE TABLE public.recently_viewed (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    shopify_product_id TEXT NOT NULL,
    viewed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, shopify_product_id)
);
CREATE INDEX recently_viewed_user_viewed_idx ON public.recently_viewed(user_id, viewed_at DESC);

ALTER TABLE public.recently_viewed ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Recently viewed viewable by owner" ON public.recently_viewed FOR SELECT TO authenticated USING ((select auth.uid()) = user_id);
CREATE POLICY "Recently viewed insertable by owner" ON public.recently_viewed FOR INSERT TO authenticated WITH CHECK ((select auth.uid()) = user_id);
CREATE POLICY "Recently viewed updatable by owner" ON public.recently_viewed FOR UPDATE TO authenticated USING ((select auth.uid()) = user_id) WITH CHECK ((select auth.uid()) = user_id);
CREATE POLICY "Recently viewed deletable by owner" ON public.recently_viewed FOR DELETE TO authenticated USING ((select auth.uid()) = user_id);

-- 5. notifications
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    read_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX notifications_user_created_idx ON public.notifications(user_id, created_at DESC);
CREATE INDEX notifications_user_unread_idx ON public.notifications(user_id) WHERE read_at IS NULL;

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Notifications viewable by owner" ON public.notifications FOR SELECT TO authenticated USING ((select auth.uid()) = user_id);
CREATE POLICY "Notifications updatable by owner" ON public.notifications FOR UPDATE TO authenticated USING ((select auth.uid()) = user_id) WITH CHECK ((select auth.uid()) = user_id);

CREATE OR REPLACE FUNCTION public.check_notification_update()
RETURNS TRIGGER AS $$
BEGIN
  IF current_setting('request.jwt.claims', true)::jsonb->>'role' = 'authenticated' THEN
      IF NEW.type IS DISTINCT FROM OLD.type OR
         NEW.title IS DISTINCT FROM OLD.title OR
         NEW.message IS DISTINCT FROM OLD.message OR
         NEW.metadata IS DISTINCT FROM OLD.metadata OR
         NEW.expires_at IS DISTINCT FROM OLD.expires_at OR
         NEW.created_at IS DISTINCT FROM OLD.created_at OR
         NEW.user_id IS DISTINCT FROM OLD.user_id THEN
          RAISE EXCEPTION 'Only read_at can be updated by authenticated users.';
      END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = '';

CREATE TRIGGER check_notification_update_trigger
  BEFORE UPDATE ON public.notifications
  FOR EACH ROW EXECUTE FUNCTION public.check_notification_update();

-- 6. loyalty
CREATE TABLE public.loyalty (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    status_tier TEXT NOT NULL DEFAULT 'standard'::TEXT,
    points_balance INTEGER NOT NULL DEFAULT 0 CHECK (points_balance >= 0),
    lifetime_points INTEGER NOT NULL DEFAULT 0 CHECK (lifetime_points >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT valid_loyalty_points CHECK (lifetime_points >= points_balance)
);
ALTER TABLE public.loyalty ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Loyalty viewable by owner" ON public.loyalty FOR SELECT TO authenticated USING ((select auth.uid()) = user_id);

CREATE TRIGGER handle_updated_at_loyalty
    BEFORE UPDATE ON public.loyalty
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 7. app_configuration
CREATE TABLE public.app_configuration (
    id TEXT PRIMARY KEY,
    maintenance_mode BOOLEAN NOT NULL DEFAULT false,
    min_supported_app_version TEXT,
    feature_flags JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.app_configuration ENABLE ROW LEVEL SECURITY;
CREATE POLICY "App configuration is publicly readable" ON public.app_configuration FOR SELECT TO authenticated USING (true);
CREATE POLICY "App configuration is publicly readable anon" ON public.app_configuration FOR SELECT TO anon USING (true);

CREATE TRIGGER handle_updated_at_app_configuration
    BEFORE UPDATE ON public.app_configuration
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
