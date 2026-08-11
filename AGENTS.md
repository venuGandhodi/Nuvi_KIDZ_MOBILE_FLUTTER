# NUVI KIDZ - AI Development Instructions

## 1. Project Identity

NUVI KIDZ is a premium kids fashion e-commerce mobile application.

**Brand:**
NUVI KIDZ

**Tagline:**
Tiny styles, big smiles.

The elephant integrated into the NUVI logo is the official brand mascot.

Do not redesign, recreate, modify, or replace the official NUVI KIDZ logo unless explicitly requested.

---

# 2. Technology Stack

## Mobile

* Flutter
* Dart
* iOS first
* Android later
* Riverpod for state management

## Backend

* Java
* Spring Boot
* REST APIs where appropriate
* Shopify Admin GraphQL API integration

## Commerce

* Shopify
* Shopify Admin GraphQL API

## Application Platform

* Supabase
* PostgreSQL
* Supabase Auth
* Supabase Storage
* Row Level Security

## Design

* Stitch
* Figma
* NUVI KIDZ Design System

## AI Development

* Google Antigravity
* Dart / Flutter MCP
* Supabase MCP
* GitHub MCP when required
* Figma MCP when required

---

# 3. Development Principles

* Follow clean, maintainable, production-quality architecture.
* Prefer simple and understandable solutions.
* Use feature-first architecture for Flutter.
* Separate presentation, domain, and data responsibilities.
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
* Prefer composition over unnecessary inheritance.
* Keep modules loosely coupled.
* Favor explicit contracts between application layers.

---

# 4. Flutter Rules

* Use Dart null safety.
* Prefer `const` widgets wherever applicable.
* Avoid unnecessary widget rebuilds.
* Use lazy lists for large collections.
* Use pagination for large datasets.
* Optimize images for mobile.
* Avoid loading unnecessarily large images.
* Handle loading, empty, success, and error states.
* Handle network failures gracefully.
* Follow centralized theme configuration.
* Keep reusable widgets independent and composable.
* Do not place business logic directly inside widgets.
* Do not access Supabase directly from presentation widgets.
* Use repositories and providers for data access.
* Avoid unnecessary global state.
* Avoid deeply nested widget trees where simpler composition is possible.
* Run `dart format`.
* Run `flutter analyze`.
* Run tests before completing significant features.

## Initial Platform

Primary platform:

**iOS**

Primary development device:

**iPhone 17 Pro Simulator**

Android support will be introduced later.

Do not add Android-specific dependencies or configuration unless required by an explicitly requested feature.

---

# 5. Flutter Architecture

Use feature-first architecture.

Preferred conceptual structure:

```text
lib/
├── core/
├── features/
│   ├── auth/
│   ├── home/
│   ├── products/
│   ├── categories/
│   ├── search/
│   ├── wishlist/
│   ├── cart/
│   ├── checkout/
│   ├── orders/
│   └── profile/
└── main.dart
```

Within a feature, separate responsibilities appropriately:

```text
feature/
├── data/
├── domain/
└── presentation/
```

Do not create layers that provide no practical value.

---

# 6. State Management

Use **Riverpod** consistently.

Preferred flow:

```text
UI
 ↓
Riverpod Provider
 ↓
Repository
 ↓
Data Source
 ↓
API / Supabase
```

Do not introduce multiple state-management frameworks.

Do not use global mutable state as a shortcut.

---

# 7. Backend Rules

The backend will use:

* Java
* Spring Boot

The backend is responsible for:

* Secure Shopify integration
* Business logic
* API aggregation
* Authentication/authorization integration
* Shopify webhook processing
* Data synchronization where required
* Caching where required
* Rate limiting
* Error handling
* Logging
* External service abstraction

The backend must not expose Shopify Admin credentials to the mobile application.

Use clear separation between:

```text
Controller
Service
Domain
Repository
Integration
Configuration
```

Do not place business logic inside controllers.

External integrations should be isolated behind appropriate service/client abstractions.

---

# 8. Supabase Rules

Supabase is responsible for application-specific data.

Examples:

* User preferences
* Wishlist
* Recently viewed products
* Notifications
* Loyalty data
* App-specific configuration
* Other data explicitly owned by the mobile application

Rules:

* Use Row Level Security.
* Never expose the Supabase service-role key in Flutter.
* Never disable RLS to solve application problems.
* Use migrations for database schema changes.
* Keep development, staging, and production environments separate.
* AI tools must initially connect only to the development Supabase project.
* Production database changes require explicit human approval.
* Prefer database migrations over manual schema changes.
* Do not create duplicate commerce data unless there is a documented architectural reason.

---

# 9. Shopify Rules

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
* Shopify remains the source of truth for actual commerce state.
* Implement webhook processing where asynchronous Shopify events are required.
* Webhook processing must be idempotent.
* Handle Shopify API rate limits appropriately.
* Do not assume Shopify data changes are synchronous.

Preferred architecture:

```text
Flutter
   ↓
Spring Boot
   ↓
Shopify Admin GraphQL API
```

---

# 10. Security Rules

Never commit:

* API keys
* Access tokens
* Passwords
* Private keys
* Shopify Admin credentials
* Supabase service-role credentials
* Production secrets
* Signing certificates
* Provisioning credentials

Never put secrets in Flutter source code.

Use environment variables, platform secure storage, CI/CD secrets, or appropriate secret-management systems.

Never connect AI tools to production systems during initial development.

Never paste production credentials into AI prompts.

Do not log:

* Access tokens
* Passwords
* Authentication secrets
* Payment credentials
* Sensitive customer information

---

# 11. Environment Strategy

Maintain separate environments:

```text
Development
    ↓
Staging
    ↓
Production
```

Development should use:

* Development Supabase project
* Development Shopify configuration/store where applicable
* Development API configuration

Production credentials must never be used during normal local development.

Environment-specific configuration must not be hardcoded.

Use `.env.example` for documentation of required variables.

Never commit actual `.env` files.

---

# 12. Design System Rules

NUVI KIDZ must follow a centralized design system.

Brand characteristics:

* Premium
* Elegant
* Warm
* Minimal
* Modern
* Playful
* Sophisticated
* Child-friendly without appearing childish

Brand colors:

```text
Cream       #FFF9F3
Sage        #9AA38C
Soft Peach  #F2B49A
Mustard     #EAB83D
```

Do not introduce arbitrary brand colors.

Do not create one-off button styles.

Do not create duplicate components.

Reuse centralized:

* Colors
* Typography
* Spacing
* Buttons
* Cards
* Product cards
* Inputs
* Navigation
* Icons
* Loading states
* Error states
* Empty states

Stitch and Figma designs must ultimately follow the NUVI KIDZ design system.

AI-generated designs must not replace the approved design system.

---

# 13. Performance Rules

Performance is a first-class requirement.

Prioritize:

* Fast startup
* Smooth scrolling
* Smooth animations
* Efficient image loading
* Image caching
* Pagination
* Efficient API calls
* Efficient database queries
* Minimal widget rebuilds
* Memory efficiency
* Appropriate caching

Do not load full-resolution product images when a smaller image is sufficient.

Use lazy loading for large collections.

Do not make repeated API calls when cached data is appropriate.

Performance issues must be measured and profiled rather than fixed based only on assumptions.

Initial engineering targets:

```text
Startup:
Approximately 2–3 seconds target

UI:
Smooth 60 FPS experience

Product listing:
Paginated

Images:
Optimized for device resolution

Network:
Avoid unnecessary requests
```

These are engineering targets and must be validated through measurement.

---

# 14. Testing Rules

Use appropriate testing levels:

```text
Unit Tests
Widget Tests
Integration Tests
API Tests
Database Tests
Security Tests
Performance Tests
Regression Tests
```

Flutter tests should cover:

* Providers
* Repositories
* Business logic
* Critical widgets
* Navigation
* Loading states
* Error states

Backend tests should cover:

* Services
* Controllers
* Integration clients
* Business rules
* Error handling

Do not skip tests for business-critical functionality.

---

# 15. MCP Rules

Use only MCP servers that have a defined purpose.

Initial MCPs:

```text
Dart / Flutter MCP
Supabase MCP
```

Future MCPs:

```text
GitHub MCP
Figma MCP
```

Rules:

* MCP access must follow least privilege.
* Development MCP connections should be used initially.
* Do not connect MCP tools to production systems without explicit approval.
* Do not expose secrets unnecessarily through MCP configuration.
* Do not install duplicate MCP servers providing the same capability.
* Review MCP permissions before enabling write operations.
* Prefer read-only access while exploring unfamiliar systems.
* Never expose Shopify Admin credentials through Flutter MCP or mobile application configuration.

---

# 16. AI Agent Rules

Before making significant changes:

1. Inspect the existing project.
2. Understand the relevant architecture.
3. Read applicable documentation under `docs/`.
4. Identify files that will change.
5. Explain the proposed implementation.
6. Make the smallest reasonable change.
7. Validate the change.
8. Report what changed.

For destructive, architectural, database, infrastructure, or security-sensitive changes:

**Request approval before execution.**

Never modify unrelated files.

Never generate the entire application in one step.

Never blindly replace existing implementations.

Prefer incremental implementation.

---

# 17. Git Rules

Use feature branches.

Preferred workflow:

```text
main
  ↓
feature/<feature-name>
  ↓
Implementation
  ↓
Tests
  ↓
Review
  ↓
Pull Request
  ↓
Merge
```

Do not commit directly to `main` unless explicitly requested.

Use meaningful commit messages.

Do not commit generated files, secrets, local configuration, or credentials.

Before completing a feature:

```text
git diff
dart format
flutter analyze
tests
```

For backend changes, run the applicable build and test commands.

---

# 18. Documentation Rules

Before implementing a significant architectural feature:

1. Check the relevant documentation.
2. Update documentation if the architecture changes.
3. Keep documentation consistent with the actual implementation.

Important documentation:

```text
docs/
├── architecture/
├── design/
├── database/
├── shopify/
├── api/
├── security/
├── performance/
└── testing/
```

Do not create unnecessary documentation files.

---

# 19. Change Management

Before changing architecture, database schema, authentication, security, Shopify integration, or major dependencies:

Explain:

1. Current implementation.
2. Problem.
3. Proposed solution.
4. Files affected.
5. Risks.
6. Testing approach.

Wait for approval when the change is destructive, security-sensitive, or architectural.

---

# 20. Current Development Phase

The project is currently in the foundation phase.

Current sequence:

```text
1. Repository foundation
2. Antigravity configuration
3. Dart / Flutter MCP
4. Supabase development environment
5. Supabase MCP
6. Flutter architecture
7. NUVI KIDZ design system
8. Stitch / Figma design
9. Flutter implementation
10. Spring Boot backend
11. Shopify integration
12. Testing
13. Performance optimization
14. iOS release
15. Android support
```

Do not skip foundational architecture and security work to accelerate UI development.

---

# 21. Definition of Done

A feature is not considered complete until:

* Implementation is complete.
* Architecture rules are followed.
* Design system is followed.
* Error states are handled.
* Loading states are handled.
* Security requirements are satisfied.
* Tests are added where appropriate.
* `dart format` passes.
* `flutter analyze` passes.
* Relevant tests pass.
* Documentation is updated when required.
* No unrelated files are modified.
* Changes are reviewable.
