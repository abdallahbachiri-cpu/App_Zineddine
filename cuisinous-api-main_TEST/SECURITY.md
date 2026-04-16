# API Security Best Practices

This document outlines the security measures implemented in the Cuisinous API to protect against common threats and vulnerabilities.

## Table of Contents
1. [Rate Limiting](#rate-limiting)
2. [Security Headers](#security-headers)
3. [Request Validation](#request-validation)
4. [Input Sanitization](#input-sanitization)
5. [Authentication & Authorization](#authentication--authorization)
6. [CORS Configuration](#cors-configuration)
7. [Database Security](#database-security)
8. [Production Deployment](#production-deployment)

---

## Rate Limiting

Rate limiting prevents abuse and protects against Denial of Service (DoS) attacks, brute force attempts, and resource exhaustion.

### Implementation
- **Framework**: Symfony Rate Limiter with sliding window algorithm
- **Storage**: Redis/Cache-based rate limit tracking
- **Key Factory**: IP-based for public endpoints, User-ID based for authenticated endpoints

### Rate Limit Policies

| Endpoint | Limit | Window | Purpose |
|----------|-------|--------|---------|
| `/api/auth/login` | 5 requests | 15 minutes | Prevent brute force attacks |
| `/api/auth/register` | 5 requests | 15 minutes | Prevent spam registrations |
| `/api/user/password-reset` | 3 requests | 1 hour | Prevent password reset abuse |
| `/api/user/email-confirmation` | 10 requests | 1 hour | Prevent email confirmation spam |
| `/api/admin/*` | 2000 requests | 5 minutes | Administrative operations |
| `/api/seller/*` | 300 requests | 5 minutes | Seller operations |
| `/api/buyer/*` | 500 requests | 5 minutes | Buyer operations |
| `Search endpoints` | 30 requests | 1 minute | Prevent search exhaustion |
| `General API` | 1000 requests | 5 minutes | Authenticated user limits |
| `/api/webhook/stripe` | 1000 requests | 1 minute | External webhook requests |

### Response Headers
Rate limit information is included in response headers:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
```

When rate limit is exceeded, the API returns:
```http
HTTP 429 Too Many Requests
{
  "error": "Too many requests. Please try again later.",
  "retry_after": 1234567890
}
```

---

## Security Headers

All API responses include security-related HTTP headers to prevent common attacks:

### Header Reference

| Header | Value | Purpose |
|--------|-------|---------|
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains; preload` | Force HTTPS connections |
| `X-Content-Type-Options` | `nosniff` | Prevent MIME type sniffing |
| `X-Frame-Options` | `DENY` | Prevent clickjacking attacks |
| `X-XSS-Protection` | `1; mode=block` | Enable XSS protection |
| `Content-Security-Policy` | `default-src 'self'` | Strict content policies |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Control referrer information |
| `Permissions-Policy` | `geolocation=(), microphone=(), camera=()` | Disable browser features |
| `Cache-Control` | `no-store, no-cache, must-revalidate` | Sensitive data caching prevention |

### Example Response Headers
```http
HTTP/1.1 200 OK
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

---

## Request Validation

All incoming requests are validated before processing to prevent malicious payloads and attacks:

### Validation Rules

#### URL Path Validation
- Maximum path length: 2048 characters
- Prevents directory traversal (`..` sequences)
- Blocks null bytes (`\0`)
- Only allows safe URL characters (alphanumeric, `-`, `/`, `.`, `:`, `%`, `?`, `=`, `&`)

#### HTTP Method Validation
- Only standard HTTP methods allowed: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`, `HEAD`
- Invalid methods return `405 Method Not Allowed`

#### Content-Type Validation
- `POST`, `PUT`, `PATCH` requests must have `Content-Type: application/json`
- Returns `415 Unsupported Media Type` if invalid
- Accepts `application/json; charset=utf-8` variants

#### Payload Size Validation
- Maximum content length: 10 MB
- Exceeding limit returns `413 Payload Too Large`
- Configurable via `Content-Length` header

#### JSON Validation
- All JSON payloads are validated for correct JSON syntax
- Malformed JSON returns `400 Bad Request`
- Empty payloads are treated as valid

#### Query String Validation
- Prevents directory traversal in query parameters
- Blocks null bytes in query strings
- Validates proper URL encoding

### Error Responses

**Invalid Path:**
```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{"error": "Invalid request path."}
```

**Payload Too Large:**
```http
HTTP/1.1 413 Payload Too Large
Content-Type: application/json

{"error": "Payload too large. Maximum size is 10MB."}
```

**Invalid JSON:**
```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{"error": "Invalid JSON in request body."}
```

---

## Input Sanitization

The `SecurityHelper` class provides methods for safe input handling:

### Email Sanitization
```php
$email = SecurityHelper::sanitizeEmail($userInput);
// Returns lowercase, trimmed email or throws InvalidArgumentException
```

### URL Sanitization
```php
$url = SecurityHelper::sanitizeUrl($userInput, ['trusted-domain.com']);
// Validates against allowed hosts, throws on mismatch
```

### String Sanitization
```php
$text = SecurityHelper::sanitizeString($userInput, 1000);
// Removes null bytes, enforces max length
```

### Integer Sanitization
```php
$limit = SecurityHelper::sanitizeInteger($page, 1, 100);
// Validates range, throws on invalid values
```

### Output Encoding
```php
$safe = SecurityHelper::escapeHtml($userText);
// Prevents XSS through output encoding
```

---

## Authentication & Authorization

### JWT Authentication
- Uses Lexik JWT Authentication Bundle
- Access tokens have short TTL (configurable, typically 1 hour)
- Refresh tokens with longer expiry (7 days or 30 days with "remember me")
- All refresh tokens for a user are revoked on login

### Password Security
- Minimum 8 characters
- Must contain: uppercase, lowercase, number, special character
- Uses bcrypt hashing with automatic cost calculation
- Passwords never logged or exposed in responses

### Authorization
- Role-based access control (RBAC): `ROLE_ADMIN`, `ROLE_SELLER`, `ROLE_BUYER`
- Routes protected by firewall and access control rules
- Inactive/deleted users cannot authenticate
- Tokens validated on every request

### Brute Force Protection
- Strict rate limiting on authentication endpoints (5 requests/15 minutes)
- Account lockout after failed attempts (via rate limiting)
- No user enumeration (generic error messages)

---

## CORS Configuration

### Allowed Origins
Configured via `CORS_ALLOW_ORIGIN` environment variable:
```env
CORS_ALLOW_ORIGIN=^https://yourdomain\.com$
```

### Allowed Methods
- `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`

### Allowed Headers
- `Content-Type`
- `Authorization`

### Exposed Headers
- `Link`
- `X-RateLimit-Limit`
- `X-RateLimit-Remaining`

### Credentials
- `allow_credentials: false` - Does not expose credentials to browser

### Configuration File
See: `config/packages/nelmio_cors.yaml`

---

## Database Security

### SQL Injection Prevention
- Uses Doctrine ORM with parameterized queries
- Never constructs raw SQL with user input
- Entity validation on persist/update

### Query Timeouts
- Long-running queries are subject to database timeouts
- Pagination enforced on all list endpoints
- Maximum limit: 1000 items per page

### Entity Soft Deletes
- Deleted entities maintain referential integrity
- Queries filter soft-deleted records by default

### Password Storage
- Bcrypt hashing with automatic cost calculation
- Never store plain text passwords
- Passwords are salted and verified securely

---

## Production Deployment

### Environment Configuration

#### Required Environment Variables
```env
APP_ENV=prod
APP_DEBUG=false
APP_SECRET=your-secret-key-here

# Database
DATABASE_URL=mysql://user:password@host:3306/dbname

# JWT
LEXIK_JWT_AUTHENTICATION_SECRET_KEY=path/to/private.pem
LEXIK_JWT_AUTHENTICATION_PUBLIC_KEY=path/to/public.pem
LEXIK_JWT_AUTHENTICATION_TOKEN_TTL=3600  # 1 hour

# CORS
CORS_ALLOW_ORIGIN=^https://yourdomain\.com$

# Google OAuth (if enabled)
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-secret
GOOGLE_REDIRECT_URI=https://yourdomain.com/api/auth/google/callback

# Email
MAILER_DSN=smtp://user:password@host:port
```

### HTTPS/TLS
- **MUST** use HTTPS in production (enforce via HSTS header)
- Certificate from trusted CA
- TLS 1.2 or higher
- Redirect HTTP → HTTPS

### Web Server Configuration

#### Nginx
```nginx
# Limit request body size
client_max_body_size 32M;

# Enable gzip compression
gzip on;
gzip_types application/json text/plain;

# Security headers (added by Symfony, but ensure)
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
```

#### PHP-FPM
```ini
[www]
; Limit execution time
php_admin_value[max_execution_time] = 30

; Memory limit
php_admin_value[memory_limit] = 256M

; File upload limits
php_admin_value[upload_max_filesize] = 30M
php_admin_value[post_max_size] = 32M
```

### Logging & Monitoring

#### Log Locations
- Application logs: `var/log/prod.log`
- Security events: `var/log/security.log`
- Database queries: `var/log/doctrine.log` (production: disabled)

#### What to Monitor
- Failed authentication attempts
- Rate limit violations
- Unusual API patterns
- 4xx and 5xx error rates
- Database connection issues
- Memory and CPU usage

### Database Backups
- Daily automated backups
- Test restore procedures
- Encrypt backups
- Store off-site

### API Key Management
- Use strong random keys for external integrations
- Rotate keys regularly (quarterly minimum)
- Store in secure vaults (never in git)
- Monitor key usage

### Incident Response
1. Immediately revoke compromised credentials
2. Review access logs for unauthorized access
3. Reset affected user passwords
4. Notify users if personal data exposed
5. Document incident and remediation

---

## Security Checklist for Developers

- [ ] No hardcoded secrets in code
- [ ] Input validation on every endpoint
- [ ] Output encoding for dynamic content
- [ ] Proper error handling (no stack traces in responses)
- [ ] SQL queries use parameterized statements
- [ ] Authentication required for sensitive endpoints
- [ ] Authorization checked for resources
- [ ] Passwords hashed with bcrypt
- [ ] CORS properly configured
- [ ] HTTPS enabled in production
- [ ] Security headers present
- [ ] Rate limiting applied
- [ ] Logging configured for security events
- [ ] Dependency vulnerabilities checked (`composer audit`)

---

## Additional Resources

- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [Symfony Security Documentation](https://symfony.com/doc/current/security.html)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [NIST Application Security](https://csrc.nist.gov/projects/application-security-group)

---

## Contact & Support

For security vulnerabilities, please report to: [security contact information]

Do NOT create public issues for security vulnerabilities.
