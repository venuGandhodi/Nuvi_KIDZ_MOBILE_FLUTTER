# NUVI KIDZ - AI Development Instructions

## Project Identity

NUVI KIDZ is a premium kids fashion e-commerce mobile application.

Brand:
NUVI KIDZ

Tagline:
Tiny styles, big smiles.

The elephant integrated into the NUVI logo is the official brand mascot.
Do not redesign or recreate the official logo unless explicitly requested.

---

## Development Principles

* Follow clean, maintainable, production-quality architecture.
* Prefer simple and understandable solutions.
* Use feature-first architecture for Flutter.
* Separate presentation, domain and data responsibilities.
* Keep business logic outside widgets.
* Use repositories for external data access.
* Use Riverpod for application state management.
* Reuse existing components.
* Avoid duplicate functionality.
* Do not introduce dependencies without justification.
* Do not modify unrelated files.
* Do not make architectural changes without approval.
* Prefer small, reviewable changes.
* Write tests for business-critical functionality.

---

## Flutter Rules

* Use null safety.
* Prefer const widgets.
* Avoid unnecessary widget rebuilds.
* Use lazy lists for large collections.
* Use pagination for large datasets.
* Optimize images.
* Avoid loading unnecessarily large images.
* Handle loading, empty and error states.
* Handle network failures gracefully.
* Follow centralized theme configuration.
* Keep reusable widgets independent and composable.
* Run `dart format`.
* Run `flutter analyze`.
* Run tests before completing significant features.

Initial target platform:
iOS.

Primary development device:
iPhone 17 Pro Simulator.

Android will be added later.

---

## Supabase Rules

Supabase is responsible for application-specific data.

Examples:
* User preferences
* Wishlist
* Recently viewed products
* Notifications
* Loyalty data
* App-specific configuration

Rules:
* Use Row Level Security.
* Never expose the Supabase service-role key in Flutter.
* Never disable RLS to solve application problems.
* Use migrations for database schema changes.
* Development and production environments must remain separate.
* AI tools must initially connect only to the development Supabase project.
* Production database changes require explicit human approval.

---

## Shopify Rules

Shopify is the source of truth for commerce data.

Shopify owns:
* Products
* Product variants
* Prices
* Inventory
* Collections
* Orders
* Order items
* Customers
* Discounts
* Fulfillment
* Shipping

Rules:
* Never call Shopify Admin API directly from Flutter.
* Never expose Shopify Admin API credentials in Flutter.
* Never store Shopify Admin access tokens in the mobile application.
* Shopify Admin API must be accessed server-side.
* Use Shopify Admin GraphQL API for new development.
* Do not use the legacy REST Admin API for new functionality.
* Request only required Shopify scopes.
* Do not duplicate Shopify commerce data into Supabase without documented justification.

---

## Security Rules

Never commit:
* API keys
* Access tokens
* Passwords
* Private keys
* Shopify Admin credentials
* Supabase service-role credentials
* Production secrets

Never put secrets in Flutter source code.
Use environment variables or secure secret management.
Never connect AI tools to production systems during initial development.

---

## AI Agent Rules

Before making significant changes:
1. Inspect the existing project.
2. Understand the relevant architecture.
3. Identify files that will change.
4. Explain the proposed implementation.
5. Make the smallest reasonable change.
6. Validate the change.
7. Report what changed.

For destructive, architectural or security-sensitive changes, request approval before execution.
Never modify unrelated files.
Never generate the entire application in one step.
