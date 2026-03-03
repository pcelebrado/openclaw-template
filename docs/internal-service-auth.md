# Internal Service Authentication

## Overview

Internal service authentication secures communication between the web service (Next.js) and the core service (OpenClaw/QMD/SFTPGo). Even though the core service is internal-only on Railway's network, it does not rely on network secrecy for security—every request must be authenticated.

---

## Authentication Methods

### Recommended: Short-Lived JWTs

The preferred approach uses **short-lived signed JWTs** for Web → Core requests:

- Web signs a JWT per request with a short expiry (5-15 minutes)
- Core validates the JWT on every request
- Core rejects requests without valid JWTs

### Fallback: Shared Secret

For MVP deployments, a rotating shared token can be used temporarily:

```
Authorization: Bearer <shared-secret>
```

**Note:** Migrate to JWT as soon as possible for better security.

---

## JWT Specification

### Required Claims

| Claim | Value | Description |
|-------|-------|-------------|
| `iss` | `"web"` | Issuer identity |
| `aud` | `"core"` | Audience (target service) |
| `sub` | `"web-service"` or user ID | Subject |
| `iat` | Unix timestamp | Issued at |
| `exp` | Unix timestamp | Expiration (5-15 min) |
| `jti` | UUID | Unique token ID |

### Optional Claims

| Claim | Description |
|-------|-------------|
| `uid` | End-user ID (for per-user rate limiting) |
| `role` | `"admin"` or `"user"` (for authorization) |
| `rid` | Request ID (for tracing) |

### Example JWT Payload
```json
{
  "iss": "web",
  "aud": "core",
  "sub": "web-service",
  "iat": 1700000000,
  "exp": 1700000600,
  "jti": "550e8400-e29b-41d4-a716-446655440000",
  "uid": "user-12345",
  "role": "user",
  "rid": "req-abc-123"
}
```

---

## Key Management

### Key Format

Use HMAC-SHA256 (HS256) for MVP:

```json
[
  {
    "kid": "k1",
    "secret": "your-cryptographically-random-secret-here",
    "active": true
  }
]
```

### Environment Variables

**Web Service:**
```bash
INTERNAL_JWT_SIGNING_KEYS=[{"kid":"k1","secret":"...","active":true}]
```

**Core Service:**
```bash
INTERNAL_JWT_VERIFY_KEYS=[{"kid":"k1","secret":"...","active":true}]
```

### Generating Keys

```bash
# Generate a secure random secret
openssl rand -base64 32

# Or using Node.js
crypto.randomBytes(32).toString('base64')
```

---

## Key Rotation

### Dual-Key Strategy

1. **Web signs** with the **active** key
2. **Core accepts** both active and previous keys during transition

### Rotation Procedure

```
Step 1: Add new key to both services
         Web: [{"kid":"k2",...,"active":false}, {"kid":"k1",...,"active":true}]
         Core: [{"kid":"k2",...,"active":false}, {"kid":"k1",...,"active":true}]

Step 2: Deploy Core service

Step 3: Deploy Web service (mark k2 active)
         Web: [{"kid":"k2",...,"active":true}, {"kid":"k1",...,"active":false}]

Step 4: Wait 24-72 hours for safety

Step 5: Remove old key from both
         Web: [{"kid":"k2",...,"active":true}]
         Core: [{"kid":"k2",...,"active":true}]
```

---

## Request Headers

### Required Headers

```http
Authorization: Bearer <jwt>
X-Request-Id: <uuid>
```

### Optional Headers

```http
X-User-Id: <user-id>
X-User-Role: <role>
```

**Note:** `X-User-*` headers are advisory. Core should prioritize JWT claims.

---

## Authorization Policy

### Core Endpoint Access

| Endpoint | Required Claims |
|----------|----------------|
| `/internal/health` | Valid JWT |
| `/internal/search` | Valid JWT |
| `/internal/agent/run` | Valid JWT |
| `/internal/index/rebuild` | Valid JWT + `role: "admin"` |
| `/internal/index/status` | Valid JWT |

### Validation Rules

1. Token must be present
2. Signature must be valid
3. Token must not be expired
4. `aud` must equal `"core"`
5. `iss` must equal `"web"`
6. Clock skew tolerance: ±60 seconds

---

## Implementation Example

### Web Service (Signing)

```typescript
import { SignJWT } from 'jose';

async function signRequest(userId: string, role: string) {
  const keys = JSON.parse(process.env.INTERNAL_JWT_SIGNING_KEYS);
  const activeKey = keys.find(k => k.active);
  
  const secret = Buffer.from(activeKey.secret, 'base64');
  
  const jwt = await new SignJWT({
    uid: userId,
    role: role,
    rid: crypto.randomUUID()
  })
    .setProtectedHeader({ alg: 'HS256', kid: activeKey.kid })
    .setIssuer('web')
    .setAudience('core')
    .setSubject('web-service')
    .setIssuedAt()
    .setExpirationTime('10m')
    .setJti(crypto.randomUUID())
    .sign(secret);
  
  return jwt;
}
```

### Core Service (Verification)

```typescript
import { jwtVerify } from 'jose';

async function verifyRequest(authHeader: string) {
  const token = authHeader.replace('Bearer ', '');
  const keys = JSON.parse(process.env.INTERNAL_JWT_VERIFY_KEYS);
  
  // Try each key until one works
  for (const key of keys) {
    try {
      const secret = Buffer.from(key.secret, 'base64');
      const { payload } = await jwtVerify(token, secret, {
        issuer: 'web',
        audience: 'core',
        algorithms: ['HS256']
      });
      return payload; // Success
    } catch (err) {
      continue; // Try next key
    }
  }
  
  throw new Error('Invalid token');
}
```

---

## Logging and Audit

### Core Logs (Minimum)

For every request:
- Request ID
- Endpoint
- Token validation result (success/fail)
- Failure reason (expired, bad signature, wrong aud/iss)

### Audit Log (Web)

Log to `audit_log` collection:
- Admin actions
- Auth failures to Core (rate-limited)
- Token rotation events

### Example Log Entry

```javascript
{
  actorUserId: null, // system
  action: "login_fail",
  details: {
    reason: "invalid_token",
    endpoint: "/internal/agent/run",
    requestId: "req-abc-123"
  },
  createdAt: ISODate()
}
```

---

## Replay Resistance

### MVP Approach

For MVP:
- `jti` is logged and can be inspected
- Do not store every `jti` server-side unless needed

### Enhanced Protection

If replay attacks are observed:

```javascript
// Add jti tracking collection
{
  _id: "550e8400-e29b-41d4-a716-446655440000",
  usedAt: ISODate(),
  expiresAt: ISODate()  // TTL index
}

// TTL index: { expiresAt: 1 }, expireAfterSeconds: 900
```

Reject requests with reused `jti` values within the TTL window.

---

## Error Responses

### Invalid Token
```json
{
  "error": {
    "code": "unauthorized",
    "message": "Invalid or missing authentication token"
  }
}
```

### Expired Token
```json
{
  "error": {
    "code": "token_expired",
    "message": "Authentication token has expired"
  }
}
```

### Wrong Audience
```json
{
  "error": {
    "code": "invalid_token",
    "message": "Token audience mismatch"
  }
}
```

---

## Configuration Checklist

- [ ] JWT signing keys generated (cryptographically secure)
- [ ] Web service has `INTERNAL_JWT_SIGNING_KEYS`
- [ ] Core service has `INTERNAL_JWT_VERIFY_KEYS`
- [ ] Keys match between services
- [ ] Token TTL configured (5-15 minutes)
- [ ] Clock skew tolerance set (±60 seconds)
- [ ] Core rejects requests without Authorization header
- [ ] Core rejects tokens with wrong `aud` or `iss`
- [ ] Core rejects expired tokens
- [ ] Admin endpoints require `role: "admin"`
- [ ] Auth failures are logged with request IDs
- [ ] Key rotation procedure documented

---

## Troubleshooting

### "Invalid token" errors
- Check that keys match between Web and Core
- Verify token hasn't expired
- Ensure `aud` and `iss` claims are correct

### Clock skew issues
- Synchronize server clocks
- Increase clock skew tolerance temporarily
- Check for timezone misconfigurations

### Key rotation failures
- Ensure both keys are in Core's verify list during transition
- Verify Web is using the correct active key
- Check logs for which key is being used

---

*For more details, see the [Service Architecture](./service-architecture.md) and [Security & Rate Limiting](./security-rate-limiting.md) documentation.*
