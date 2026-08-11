# Testing Strategy

This document outlines the testing approach for the NUVI KIDZ application.

*Note: Do not create tests yet. This is the strategy definition.*

## Test Categories

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

## Flutter Testing

Flutter testing should focus on the following areas to ensure a robust mobile experience:

### Providers
* Test Riverpod state management logic independently.
* Ensure state transitions correctly based on different inputs and mock API responses.

### Repositories
* Unit test data fetching logic.
* Mock external dependencies (HTTP clients) to ensure the repository correctly parses responses and handles errors.

### Business Logic
* Thoroughly unit test all domain-level business rules separate from the UI.

### Critical Widgets
* Write Widget Tests for reusable UI components (e.g., custom buttons, product cards).
* Ensure they render correctly in various states (loading, empty, error, success).

### Navigation
* Test deep linking and internal app routing.

### Error States
* Verify the UI correctly displays error messages when API calls fail or data is invalid.

### Loading States
* Verify that loading indicators (shimmer effects, spinners) appear during asynchronous operations.

## Backend and Integration Testing

*(To be expanded in future phases)*
* **API Tests:** Ensure Spring Boot endpoints return expected payloads and status codes.
* **Database Tests:** Verify complex SQL queries and RLS policies in Supabase.
* **Integration Tests:** End-to-end tests validating the flow from the Flutter app to the Spring Boot API and back.
