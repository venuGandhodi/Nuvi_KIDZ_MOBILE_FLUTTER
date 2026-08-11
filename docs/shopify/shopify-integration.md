# Shopify Integration Strategy

## Shopify Responsibilities

Shopify is the authoritative source of truth for all commerce operations. It manages products, inventory, pricing, customers, orders, discounts, and fulfillment.

## Shopify Admin GraphQL API

All new development must use the Shopify Admin GraphQL API. Do not use the legacy REST Admin API for new functionality.

## Security

> **IMPORTANT: Shopify Admin API credentials must remain server-side and must never be embedded in the Flutter application.**

## Integration Details

### Authentication Approach
* Server-to-server authentication using Custom App access tokens.
* Tokens are securely stored in the Spring Boot backend environment variables.

### Required Access Scopes
* [Placeholder for specific scopes, e.g., `read_products`, `write_customers`]

### Product Synchronization Strategy
* [Placeholder: How products are fetched and cached]

### Inventory Strategy
* [Placeholder: How real-time inventory is handled]

### Order Strategy
* [Placeholder: Order creation and status tracking]

### Customer Strategy
* [Placeholder: Customer creation and mapping to Supabase profiles]

### Webhook Strategy
* [Placeholder: Handling Shopify webhooks for real-time updates]

### Error Handling
* [Placeholder: Handling API errors gracefully]

### Rate-Limit Handling
* [Placeholder: Strategies for respecting Shopify API limits]

### Caching Strategy
* [Placeholder: Caching commerce data to improve performance]
