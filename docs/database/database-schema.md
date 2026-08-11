# Database Schema Design

> **Shopify remains the source of truth for commerce data.**

This document outlines the entities for application-specific data managed by Supabase.

## Shopify Identifier Strategy

Shopify Product and Variant IDs are stored as `TEXT`. The application uses the Shopify Admin GraphQL API, so the IDs are stored in their Global ID format (e.g., `gid://shopify/Product/123456789`).

## Application-Specific Entities

### `profiles`
* **Purpose**: Extended user information linked to the Supabase authentication system. Automatically created by a secure database trigger (`handle_new_user()`) when a user signs up.
* **Fields**:
  * `id` (UUID, Primary Key, Foreign Key to `auth.users`)
  * `display_name`, `first_name`, `last_name`, `phone`, `avatar_url`, `status`
  * `created_at`, `updated_at` (managed by trigger)
* **RLS & Security**:
  * **SELECT**: Users can only view their own profile.
  * **UPDATE**: Users can only update their own profile. A database trigger (`restrict_profile_updates`) blocks authenticated users from modifying `id`, `status`, or `created_at`.
  * **INSERT / DELETE**: Not allowed.

### `user_preferences`
* **Purpose**: App settings, notification preferences, etc. Automatically created upon user signup.
* **Fields**:
  * `user_id` (UUID, Primary Key, Foreign Key to `profiles.id`)
  * `language`, `currency`
  * `notification_preferences`, `marketing_preferences` (JSONB)
  * `created_at`, `updated_at` (managed by trigger)
* **RLS & Security**:
  * **SELECT**: Users can only view their own preferences.
  * **UPDATE**: Users can only update their own preferences.
  * **INSERT / DELETE**: Not allowed.

### `wishlist`
* **Purpose**: User-specific wishlists.
* **Fields**:
  * `id` (UUID, Primary Key)
  * `user_id` (UUID, Foreign Key to `profiles.id`)
  * `shopify_product_id` (TEXT)
  * `shopify_variant_id` (TEXT, Nullable)
  * `created_at`
* **Constraints**: 
  * Unique Partial Index: `(user_id, shopify_product_id) WHERE shopify_variant_id IS NULL`
  * Unique Partial Index: `(user_id, shopify_product_id, shopify_variant_id) WHERE shopify_variant_id IS NOT NULL`
* **RLS & Security**:
  * **SELECT / INSERT / DELETE**: Users can only manage their own wishlist items.
  * **UPDATE**: Not allowed.

### `recently_viewed`
* **Purpose**: History of products viewed by the user.
* **Fields**:
  * `id` (UUID, Primary Key)
  * `user_id` (UUID, Foreign Key to `profiles.id`)
  * `shopify_product_id` (TEXT)
  * `viewed_at` (TIMESTAMPTZ)
* **Constraints**: Unique constraint on `(user_id, shopify_product_id)` (facilitates UPSERT updates on timestamp).
* **Indexes**: Optimized lookup on `(user_id, viewed_at DESC)`.
* **RLS & Security**:
  * **SELECT / INSERT / UPDATE / DELETE**: Users can fully manage their own viewing history.

### `notifications`
* **Purpose**: In-app notifications and alerts.
* **Fields**:
  * `id` (UUID, Primary Key)
  * `user_id` (UUID, Foreign Key to `profiles.id`)
  * `type`, `title`, `message`
  * `metadata` (JSONB)
  * `read_at`, `expires_at`
  * `created_at`
* **Indexes**: 
  * `(user_id, created_at DESC)`
  * `(user_id) WHERE read_at IS NULL`
* **RLS & Security**:
  * **SELECT**: Users can only view their own notifications.
  * **UPDATE**: Users can update their own notifications, but a trigger (`check_notification_update`) restricts updates to the `read_at` field only for authenticated users.
  * **INSERT / DELETE**: Not allowed.

### `loyalty`
* **Purpose**: User loyalty points and rewards status.
* **Fields**:
  * `user_id` (UUID, Primary Key, Foreign Key to `profiles.id`)
  * `status_tier` (TEXT)
  * `points_balance`, `lifetime_points` (INTEGER)
  * `created_at`, `updated_at` (managed by trigger)
* **Constraints**:
  * `CHECK (points_balance >= 0)`
  * `CHECK (lifetime_points >= 0)`
  * `CHECK (lifetime_points >= points_balance)`
* **RLS & Security**:
  * **SELECT**: Users can only view their own loyalty status.
  * **INSERT / UPDATE / DELETE**: Not allowed.

### `app_configuration`
* **Purpose**: Dynamic app configuration (feature flags, minimum supported app version, etc.). Secrets and private credentials are NOT stored here.
* **Fields**:
  * `id` (TEXT, Primary Key)
  * `maintenance_mode` (BOOLEAN)
  * `min_supported_app_version` (TEXT)
  * `feature_flags` (JSONB)
  * `created_at`, `updated_at` (managed by trigger)
* **RLS & Security**:
  * **SELECT**: Publicly readable (all users).
  * **INSERT / UPDATE / DELETE**: Not allowed. Only modifiable by backend/service roles.

---
*Note: The `addresses` table has been intentionally omitted from Supabase as Shopify acts as the source of truth for customer addresses during the checkout flow.*
