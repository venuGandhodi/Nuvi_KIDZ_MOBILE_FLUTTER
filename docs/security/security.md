# Security Strategy

## Environment Model

```text
Development
Staging
Production
```

> **CRITICAL: Production credentials must never be committed to Git or exposed to AI development tools.**

## Security Pillars

### Authentication
* Handled by Supabase Auth for mobile users.
* JWT validation by Spring Boot API.

### Authorization
* Role-based access control (RBAC) managed where applicable.
* The API ensures users can only access their own resources (e.g., their own orders, wishlist).

### Supabase RLS (Row Level Security)
* RLS policies will be enforced on all Supabase tables to ensure users can only read/write their own data.
* Service-role keys must only be used by the secure backend, never the mobile app.

### Shopify Credential Security
* Shopify Admin API credentials exist only on the Spring Boot server environment.
* These credentials must never be passed to or stored on the mobile client.

### Environment Separation
* Strict isolation between Development, Staging, and Production environments.
* Separate Supabase projects and Shopify stores for each environment.

### Secret Management
* Use `.env` files for local development.
* Use secure secret managers (e.g., AWS Secrets Manager, GitHub Secrets) for deployed environments.

### API Security
* All endpoints must use HTTPS.
* Implement rate limiting on the Spring Boot API to prevent abuse.

### Input Validation
* The backend API must rigorously validate and sanitize all incoming data.

### Logging Security
* Avoid logging PII (Personally Identifiable Information), passwords, or access tokens.

### PII Protection
* Comply with privacy regulations (GDPR, CCPA) regarding user data.
* Securely manage user data both in Supabase and Shopify.

### Secure Storage (Mobile)
* Use `flutter_secure_storage` to store sensitive data locally on the device if required (e.g., refresh tokens).

### Dependency Security
* Regularly update Flutter, Spring Boot, and other dependencies to patch known vulnerabilities.
