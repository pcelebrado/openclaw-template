# MongoDB Service - INTERNAL ONLY

**Boundary Rule**

This MongoDB service MUST NOT be publicly accessible.

## Railway Configuration

- **Networking > Public Networking**: DISABLED
- **Access**: Only from `web` and `core` services via Railway internal networking
- **Connection string pattern**: `mongodb://mongo.railway.internal:27017/openclaw`

## Security Posture

- No public port exposure
- No direct browser access
- Connection credentials managed via Railway environment variables
- Backups: scheduled logical dump/export (implementation detail for Phase 2+)

## Connection String Contract

The `web` service owns the primary MongoDB connection via `MONGODB_URI`.
The `core` service MAY access MongoDB if explicitly needed, but the preferred
pattern is web-owned DB access per the OpenClaw architecture.
