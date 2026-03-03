# OpenClaw Template Predeploy Next Steps

This file captures a full-scope predeploy audit and the deterministic next steps
to deploy without committing secrets.

## Scope audited

- Template repo: `services/web`, `services/core`, `services/mongo`, `services/sftpgo`, root Railway config.
- External specs assimilated:
  - `ExternalDocs/railway-mongodb`
  - `ExternalDocs/railway-openclaw`
  - `ExternalDocs/sftpgo`
  - `ExternalDocs/qmd`

## Audit snapshot

- `PASS` web/core/mongo boundary separation remains correct (`web` public, `core`/`mongo` internal).
- `PASS` no hardcoded production secrets found in tracked template files.
- `PASS` service env examples use `changeme-*` placeholders.
- `FIXED` missing env contract parity for Mongo init services.
- `FIXED` Mongo init scripts now accept standard Mongo root vars and legacy aliases.
- `FIXED` web env contract now includes `NEXT_PUBLIC_APP_URL` used by reader route rendering.
- `FIXED` optional SFTPGo service scaffold added for SSH/SFTP go-live readiness.

## Secrets wiring map (Railway Variables)

Set these values in Railway Variables (workspace-level or service-level), not in git.

### Shared secrets (recommended single source)

- `OC_INTERNAL_SERVICE_TOKEN`
- `OC_SETUP_PASSWORD`
- `OC_GATEWAY_TOKEN` (optional but recommended)
- `OC_MONGO_ROOT_USER`
- `OC_MONGO_ROOT_PASSWORD`
- `OC_MONGO_KEYFILE`
- `OC_AUTH_SECRET`

### web service variables

- `MONGODB_URI`
- `INTERNAL_CORE_BASE_URL`
- `INTERNAL_SERVICE_TOKEN` -> set from `OC_INTERNAL_SERVICE_TOKEN`
- `AUTH_SECRET` -> set from `OC_AUTH_SECRET`
- `AUTH_URL`
- `NEXT_PUBLIC_APP_URL`
- Optional key mode: `INTERNAL_JWT_SIGNING_KEYS` or `INTERNAL_JWT_SIGNING_KEY`
- Book ingest settings:
  - `BOOK_SOURCE_MODE`
  - `BOOK_SOURCE_DIR`
  - `BOOK_IMPORT_MANIFEST`
  - `BOOK_CANONICAL_COLLECTION`
  - `BOOK_TOC_COLLECTION`
  - `BOOK_IMPORT_ENABLED`
  - `BOOK_IMPORT_DRY_RUN`

### core service variables

- `INTERNAL_SERVICE_TOKEN` -> set from `OC_INTERNAL_SERVICE_TOKEN`
- `SETUP_PASSWORD` -> set from `OC_SETUP_PASSWORD`
- `OPENCLAW_GATEWAY_TOKEN` -> set from `OC_GATEWAY_TOKEN` (recommended)
- `OPENCLAW_STATE_DIR=/data/.openclaw`
- `OPENCLAW_WORKSPACE_DIR=/data/workspace`
- Optional:
  - `INTERNAL_GATEWAY_HOST`
  - `INTERNAL_GATEWAY_PORT`
  - `OPENCLAW_ENTRY`
  - `OPENCLAW_NODE`
  - `OPENCLAW_CONFIG_PATH`
- Book ingest settings (must stay aligned with web):
  - `BOOK_SOURCE_MODE`
  - `BOOK_SOURCE_DIR`
  - `BOOK_IMPORT_MANIFEST`
  - `BOOK_CANONICAL_COLLECTION`
  - `BOOK_TOC_COLLECTION`
  - `BOOK_IMPORT_ENABLED`
  - `BOOK_IMPORT_DRY_RUN`

### mongo node service variables

- `REPLICA_SET_NAME=rs0`
- `MONGO_INITDB_ROOT_USERNAME` -> set from `OC_MONGO_ROOT_USER`
- `MONGO_INITDB_ROOT_PASSWORD` -> set from `OC_MONGO_ROOT_PASSWORD`
- `KEYFILE` -> set from `OC_MONGO_KEYFILE`
- Optional host/port defaults:
  - `MONGO_PORT=27017`
  - `MONGO_PRIMARY_HOST=mongo.railway.internal`

### mongo init service variables (run once, then remove service)

- `REPLICA_SET_NAME`
- `MONGO_PORT`
- `MONGO_PRIMARY_HOST`
- Multi-node only: `MONGO_REPLICA_HOST`, `MONGO_REPLICA2_HOST`
- Credentials (either format):
  - Preferred: `MONGO_INITDB_ROOT_USERNAME`, `MONGO_INITDB_ROOT_PASSWORD`
  - Legacy fallback: `MONGOUSERNAME`, `MONGOPASSWORD`

### sftpgo service variables (optional, for SSH/SFTP ingress)

- `SFTPGO_DEFAULT_ADMIN_USERNAME`
- `SFTPGO_DEFAULT_ADMIN_PASSWORD`
- `SFTPGO_HTTPD__BINDINGS__0__PORT=8080`
- `SFTPGO_SFTPD__BINDINGS__0__PORT=2022`
- `SFTPGO_DATA_ROOT=/data/sftpgo`

## Deterministic next steps before deployment

1. Create/link three services in Railway (`web`, `core`, `mongo`) with correct root paths.
2. Disable Public Networking for `core` and `mongo`; keep Public Networking enabled only for `web`.
3. Attach `/data` volume to `core` and `mongo` before first deploy.
4. Populate Railway Variables using the map above (no plaintext secrets in repo files).
5. Deploy `mongo` first, then run one init service (`initServiceSingle` or `initService`), then delete init service.
6. Deploy `core`; verify `/setup/healthz` and auth gate behavior.
7. Deploy `web`; verify `/api/health` plus internal connectivity checks.
8. Confirm cross-service auth (`INTERNAL_SERVICE_TOKEN`) and gateway token consistency.
9. Set book ingest mode (`BOOK_SOURCE_MODE`) and verify chosen source path.
10. Run post-deploy smoke: `web /`, `web /api/health`, `core /healthz` (internal), book endpoints.
11. If using SFTP ingest, validate SSH/SFTP by connecting to SFTPGo on port `2022` and uploading a probe file.

## Optional integrations from assimilated specs

- SFTPGo service scaffold is included in `services/sftpgo/` and can back `BOOK_SOURCE_MODE=sftp`.
- QMD is consumed through OpenClaw core runtime behavior; keep core volume persistence and startup health checks in place.
