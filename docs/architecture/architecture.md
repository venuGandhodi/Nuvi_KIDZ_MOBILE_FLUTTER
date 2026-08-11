# System Architecture

## Overall System Architecture

The NUVI KIDZ system follows a modern, decoupled architecture designed for scale, performance, and clear separation of concerns.

```text
Flutter
   |
   v
Spring Boot API
   |
   +------------------+
   |                  |
   v                  v
Supabase          Shopify
PostgreSQL        Admin GraphQL
```

## Component Responsibilities

### Flutter (Mobile Application)
* **Responsibility:** Presentation and user interaction.
* **Details:** The mobile app is responsible for rendering the UI, managing application state via Riverpod, and communicating with the backend API. It does not communicate directly with Shopify.

### Spring Boot (Backend API)
* **Responsibility:** Orchestration, business logic, and secure integration.
* **Details:** Acts as the secure middle tier. It orchestrates calls between the mobile app, Supabase, and Shopify. It handles complex business logic and secures sensitive operations.

### Supabase (Application Backend/Data)
* **Responsibility:** Source of truth for application-specific data.
* **Details:** Manages data specific to the app experience that doesn't belong in Shopify.
  * User preferences
  * Wishlist
  * Recently viewed products
  * Notifications
  * Loyalty data
  * App-specific configuration
* **Note:** Uses PostgreSQL and leverages Row Level Security (RLS) for data protection.

### Shopify (Commerce Platform)
* **Responsibility:** Source of truth for commerce data.
* **Details:** Manages all core e-commerce functionality.
  * Products and Product variants
  * Prices and Inventory
  * Collections
  * Orders and Order items
  * Customers
  * Discounts
  * Fulfillment and Shipping
* **Note:** Accessed exclusively via the Shopify Admin GraphQL API from the Spring Boot backend.
* Explain why: Shopify is the commerce source of truth because it handles complex transactional, inventory, and fulfillment logic natively. Supabase is the application-data source of truth because it allows for flexible, fast, and scalable storage of app-specific user experiences without bloating the commerce engine.

## Boundaries

### Authentication Boundary
* Supabase Auth manages user identities.
* The Spring Boot API verifies authentication tokens before processing requests.
* Shopify authentication is handled strictly server-to-server.

### API Boundary
* The Flutter app communicates only with the Spring Boot API and (safely configured) Supabase endpoints.
* Shopify Admin API is completely isolated from the mobile client.

### Security Boundary
* The mobile application is considered an untrusted environment. No sensitive secrets (Shopify credentials, Supabase service-role keys) are present on the client.

## Future Android Support
* The architecture is platform-agnostic at the backend level. The Flutter codebase is designed to be cross-platform, allowing Android support to be added with minimal architectural changes, primarily focusing on platform-specific UI/UX adjustments and native integrations.
