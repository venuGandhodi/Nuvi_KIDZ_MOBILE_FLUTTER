# Database Schema Design

> **Shopify remains the source of truth for commerce data.**

This document outlines the conceptual entities for application-specific data managed by Supabase.

## Application-Specific Entities (Conceptual)

### `profiles`
* Extended user information linked to the authentication system.
* Fields: [Placeholder]

### `addresses`
* User address book for faster checkout (synchronized or mapped appropriately with Shopify).
* Fields: [Placeholder]

### `wishlist`
* User-specific wishlists.
* Fields: [Placeholder]

### `wishlist_items`
* Individual items within a wishlist (references Shopify Product/Variant IDs).
* Fields: [Placeholder]

### `recently_viewed`
* History of products viewed by the user.
* Fields: [Placeholder]

### `notifications`
* In-app notifications and alerts.
* Fields: [Placeholder]

### `loyalty`
* User loyalty points and rewards status.
* Fields: [Placeholder]

### `user_preferences`
* App settings, notification preferences, etc.
* Fields: [Placeholder]

### `app_configuration`
* Dynamic app configuration (feature flags, banners, etc.).
* Fields: [Placeholder]

---
*Note: Do not create SQL tables or execute migrations yet. This is a conceptual schema.*
