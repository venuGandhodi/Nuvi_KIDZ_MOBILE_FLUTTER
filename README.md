# NUVI KIDZ

NUVI KIDZ is a premium kids fashion e-commerce mobile application.

## Technology Stack

* **Mobile:** Flutter (Dart)
* **State Management:** Riverpod
* **Backend:** Spring Boot (Java)
* **Commerce Platform:** Shopify (Shopify Admin GraphQL API)
* **Application Backend/Data:** Supabase (PostgreSQL, Auth, Storage)
* **Design:** Stitch, Figma (NUVI KIDZ Design System)

## Repository Structure

```
nuvi-kidz/
├── .agents/          # AI Agent configurations and instructions
├── docs/             # Project documentation (architecture, design, database, etc.)
├── mobile/           # Flutter mobile application source code
├── backend/          # Spring Boot backend API source code
├── supabase/         # Supabase migrations, functions, and seed data
└── assets/           # Brand assets, icons, images, and fonts
```

## Development Prerequisites

* Flutter SDK
* Dart SDK
* Xcode (for iOS development)
* CocoaPods
* Android Studio (for Android development later)
* Java JDK (for Spring Boot)
* Supabase CLI

## Current Platform Target

* iOS (Primary development device: iPhone 17 Pro Simulator)
* Android support will be added later.

## Development Workflow

1. Use `.env.example` to create local `.env` files for necessary configurations.
2. Ensure you are working in the correct development environment (never use production credentials locally).
3. Follow the rules defined in `AGENTS.md` for AI-assisted development.
4. Review documentation in `docs/` before implementing new features.
5. Run `dart format` and `flutter analyze` before committing code.

## Security Principles

* Never commit API keys, access tokens, passwords, private keys, or production secrets to Git.
* Do not expose Shopify Admin credentials or Supabase service-role credentials in the Flutter application.
* Use environment variables or secure secret management.
* Never connect AI tools to production systems during initial development.

## Current Development Phase

Phase 1: Project foundation and architecture
Phase 2: Design system
Phase 3: Supabase foundation
Phase 4: Flutter application
Phase 5: Spring Boot backend
Phase 6: Shopify integration
Phase 7: Testing and performance
Phase 8: Android support

## Documentation Links

* [Architecture Overview](docs/architecture/architecture.md)
* [Design System](docs/design/design-system.md)
* [Database Schema](docs/database/database-schema.md)
* [Shopify Integration](docs/shopify/shopify-integration.md)
* [API Contracts](docs/api/api-contracts.md)
* [Security](docs/security/security.md)
* [Performance](docs/performance/performance.md)
* [Testing Strategy](docs/testing/testing-strategy.md)
