# Railway Template Composer Specification

> **Purpose**: Exact specification for creating/updating the OpenClaw template in Railway's Template Composer dashboard.
> **Date**: 2026-03-03
> **Status**: MVP Template Definition

Railway templates are configured through the **Template Composer** (dashboard), not through files in the repo. This document defines every service, variable, volume, and networking setting needed.

---

## Template Metadata

| Field | Value |
|-------|-------|
| **Name** | OpenClaw Book Template |
| **Description** | AI-powered learning platform. Upload a book, let OpenClaw study it, then learn interactively with an AI teaching assistant. |
| **Repository** | `pcelebrado/Book-of-Openclaw` |
| **Branch** | `mvp` |

---

## Services Overview

| Service | Source | Root Directory | Public | Volume |
|---------|--------|----------------|--------|--------|
| `openclaw-web` | GitHub repo | `services/web` | Yes (HTTP) | No |
| `openclaw-core` | GitHub repo | `services/core` | No (internal only) | Yes: `/data` |

### Network Connections

The template composer shows dashed lines between connected services:

- `openclaw-web` → `openclaw-core` (via `${{openclaw-core.RAILWAY_PRIVATE_DOMAIN}}`)

### Networking Configuration

| Service | Setting | Value |
|---------|---------|-------|
| `openclaw-web` | Public HTTP domain | Generate domain |
| `openclaw-core` | Public HTTP domain | **NONE** (internal only) |
| `openclaw-core` | TCP Proxy | Port `2022` (for SFTP access) |

---

## Shared Variables

Create these as **Shared Variables** in the template composer (available to all services):

| Variable | Value | Description |
|----------|-------|-------------|
| `INTERNAL_SERVICE_TOKEN` | `${{secret(64, "abcdef0123456789")}}` | Shared secret for web↔core authentication. |

---

## Service: `openclaw-core`

### Settings Tab

| Setting | Value |
|---------|-------|
| **Root Directory** | `services/core` |
| **Builder** | `DOCKERFILE` |
| **Healthcheck Path** | `/setup/healthz` |
| **Healthcheck Timeout** | `300` |
| **Restart Policy** | `ON_FAILURE` (max 10 retries) |

### Volume

| Mount Path | Name |
|------------|------|
| `/data` | `openclaw-data` |

Right-click on the service → Attach Volume → mount path `/data`.

### Variables Tab

#### Required (user must provide or confirm)

These show the red **Required** badge on the deploy screen.

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `SETUP_PASSWORD` | *(empty — user must set)* | Setup password that protects the OpenClaw setup UI from the rest of the world. |

#### Pre-configured (auto-generated or computed)

These show under **"N pre-configured environment variables"** on the deploy screen.

| Variable | Value | Description |
|----------|-------|-------------|
| `OPENCLAW_GATEWAY_TOKEN` | `${{secret(64, "abcdef0123456789")}}` | Token that protects the OpenClaw gateway. |
| `INTERNAL_SERVICE_TOKEN` | `${{shared.INTERNAL_SERVICE_TOKEN}}` | Shared web↔core auth token. |
| `OPENCLAW_STATE_DIR` | `/data/.openclaw` | Where OpenClaw data lives — configs, auth, sessions. |
| `OPENCLAW_WORKSPACE_DIR` | `/data/workspace` | Where all the files you create via OpenClaw will reside. |
| `RAILWAY_RUN_UID` | `0` | Run as root for volume access. |
| `MONGO_PORT` | `27017` | MongoDB port (embedded). |
| `MONGO_BIND_IP` | `::,0.0.0.0` | MongoDB listen address (IPv6+IPv4 for Railway networking). |
| `MONGODB_URI` | `mongodb://127.0.0.1:27017/openclaw` | Local MongoDB connection string (core connects to itself). |
| `SFTPGO_ENABLED` | `true` | Enable embedded SFTPGo for SFTP file uploads. |
| `SFTPGO_DATA_ROOT` | `/data/sftpgo` | SFTPGo persistent data directory. |
| `SFTPGO_SFTPD__BINDINGS__0__PORT` | `2022` | SFTPGo SFTP listen port. |
| `SFTPGO_HTTPD__BINDINGS__0__PORT` | `2080` | SFTPGo admin web UI port (internal only). |
| `SFTPGO_DATA_PROVIDER__CREATE_DEFAULT_ADMIN` | `true` | Auto-create SFTPGo admin on first boot. |
| `SFTPGO_DEFAULT_ADMIN_USERNAME` | `admin` | SFTPGo admin username. |
| `SFTPGO_DEFAULT_ADMIN_PASSWORD` | `${{secret(24, "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789")}}` | SFTPGo admin password (auto-generated). |
| `BOOK_SOURCE_MODE` | `external` | How book content arrives (external/sftp/git/volume). |
| `BOOK_SOURCE_DIR` | `/data/book-source` | Where raw book files are staged before import. |
| `BOOK_IMPORT_MANIFEST` | `/data/book-source/manifest.json` | Manifest describing available book content. |
| `BOOK_CANONICAL_COLLECTION` | `book_sections` | MongoDB collection for canonical book data. |
| `BOOK_TOC_COLLECTION` | `book_toc` | MongoDB collection for table of contents. |
| `BOOK_IMPORT_ENABLED` | `false` | Enable automatic book import on startup. |
| `BOOK_IMPORT_DRY_RUN` | `true` | Dry run mode for book import (safe default). |

---

## Service: `openclaw-web`

### Settings Tab

| Setting | Value |
|---------|-------|
| **Root Directory** | `services/web` |
| **Builder** | `DOCKERFILE` |
| **Healthcheck Path** | `/api/health` |
| **Healthcheck Timeout** | `300` |
| **Restart Policy** | `ON_FAILURE` (max 10 retries) |
| **Public Networking** | Enable HTTP (generate domain) |

### Variables Tab

#### Pre-configured (all auto-generated or computed — no user input needed)

| Variable | Value | Description |
|----------|-------|-------------|
| `MONGODB_URI` | `mongodb://${{openclaw-core.RAILWAY_PRIVATE_DOMAIN}}:27017/openclaw` | Connects to MongoDB in core via Railway private networking. |
| `INTERNAL_CORE_BASE_URL` | `http://${{openclaw-core.RAILWAY_PRIVATE_DOMAIN}}:${{openclaw-core.PORT}}` | Internal URL to reach core service API. |
| `INTERNAL_SERVICE_TOKEN` | `${{shared.INTERNAL_SERVICE_TOKEN}}` | Shared web↔core auth token. |
| `AUTH_SECRET` | `${{secret(43, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/")}}=` | NextAuth.js session encryption (openssl rand -base64 32 equivalent). |
| `AUTH_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL for NextAuth.js callbacks. |
| `NEXT_PUBLIC_APP_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL for server-rendered links. |
| `NEXT_TELEMETRY_DISABLED` | `1` | Disable Next.js telemetry. |
| `HOSTNAME` | `::` | IPv4/IPv6 dual-stack for Railway networking. |
| `BOOK_SOURCE_MODE` | `external` | How book content arrives. |
| `BOOK_SOURCE_DIR` | `/data/book-source` | Book staging directory. |
| `BOOK_IMPORT_MANIFEST` | `/data/book-source/manifest.json` | Book content manifest. |
| `BOOK_CANONICAL_COLLECTION` | `book_sections` | MongoDB collection for book data. |
| `BOOK_TOC_COLLECTION` | `book_toc` | MongoDB collection for TOC. |
| `BOOK_IMPORT_ENABLED` | `false` | Auto-import on startup. |
| `BOOK_IMPORT_DRY_RUN` | `true` | Dry run mode (safe default). |

---

## Deploy Screen Preview

When users click "Deploy Template", they should see:

```
Variable values missing for 1 service
                                                Remove Template
┌─────────────────────────────────────────────────────────────────┐
│  openclaw-core                              ⊘ 1 variable needed │
│  pcelebrado/Book-of-Openclaw                                    │
│                                                                 │
│  SETUP_PASSWORD                                                 │
│  ⊘ Setup password that protects the OpenClaw    [VALUE or $REF] │
│    setup UI from the rest of the world.                         │
│                                                                 │
│  ▸ 22 pre-configured environment variables                      │
│                                                                 │
│    OPENCLAW_STATE_DIR              /data/.openclaw            {} │
│    OPENCLAW_GATEWAY_TOKEN          ${{secret(64,             {} │
│                                    "abcdef0123456789")}}        │
│    OPENCLAW_WORKSPACE_DIR          /data/workspace            {} │
│    ...                                                          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  openclaw-web                              ✓ Ready to deploy    │
│  pcelebrado/Book-of-Openclaw                                    │
│                                                                 │
│  ▸ 15 pre-configured environment variables                      │
│                                                                 │
│    MONGODB_URI                     mongodb://${{openclaw-core.  │
│                                    RAILWAY_PRIVATE_DOMAIN}}     │
│                                    :27017/openclaw              │
│    AUTH_SECRET                     ${{secret(43, ...)}}=        │
│    ...                                                          │
└─────────────────────────────────────────────────────────────────┘
```

### Canvas View

After deployment, the Railway canvas should show:

```
┌──────────────────────────────────────────────────────────┐
│                      OpenClaw Book Template                │
│                                                          │
│  ┌──────────────────┐           ┌──────────────────────┐ │
│  │                  │           │                      │ │
│  │   openclaw-web   │- - - - ->│    openclaw-core      │ │
│  │                  │           │                      │ │
│  │   your-app.      │           │   (internal only)    │ │
│  │   railway.app    │           │                      │ │
│  │                  │           │   📦 openclaw-data   │ │
│  └──────────────────┘           └──────────────────────┘ │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Step-by-Step: Creating the Template in Railway Dashboard

### 1. Go to Template Composer

Navigate to [railway.com/workspace/templates](https://railway.com/workspace/templates) → **New Template**

### 2. Add `openclaw-core` service

1. Click **+ Add New** → GitHub repo → `pcelebrado/Book-of-Openclaw` (branch: `mvp`)
2. **Settings tab**:
   - Root Directory: `services/core`
   - No public networking (internal only)
   - TCP Proxy: enable on port `2022`
   - Healthcheck path: `/setup/healthz`
3. **Variables tab**: Add all variables from the `openclaw-core` table above
   - Mark `SETUP_PASSWORD` as **required** (leave default empty)
   - All others get their default values from the table
4. **Volume**: Right-click service → Attach Volume → mount path `/data`

### 3. Add `openclaw-web` service

1. Click **+ Add New** → GitHub repo → `pcelebrado/Book-of-Openclaw` (branch: `mvp`)
2. **Settings tab**:
   - Root Directory: `services/web`
   - Enable public networking (HTTP)
   - Healthcheck path: `/api/health`
3. **Variables tab**: Add all variables from the `openclaw-web` table above
   - No required variables — all are pre-configured

### 4. Add Shared Variable

1. In the template composer, create a **Shared Variable**:
   - Name: `INTERNAL_SERVICE_TOKEN`
   - Value: `${{secret(64, "abcdef0123456789")}}`
2. Both services reference this via `${{shared.INTERNAL_SERVICE_TOKEN}}`

### 5. Create Template

Click **Create Template** → copy the template URL.

---

## Post-Deploy User Guide

After a user deploys this template, they need to:

1. **Wait** for both services to build and deploy (core deploys first)
2. **Set SETUP_PASSWORD** if they didn't during deploy
3. **Visit** `https://your-app.railway.app` — this is the Next.js frontend
4. **Configure OpenClaw** by visiting the core service's `/setup` endpoint
   - The setup UI is behind the SETUP_PASSWORD
   - Users pick their AI provider (OpenAI, Anthropic, Google, etc.)
5. **Upload content** via SFTP (port 2022 via TCP proxy) or Git

---

## Validation Checklist

- [ ] Both services show in template composer
- [ ] `openclaw-core` has volume at `/data`
- [ ] `openclaw-core` has no public domain
- [ ] `openclaw-core` has TCP proxy on 2022
- [ ] `openclaw-web` has public domain
- [ ] Shared variable `INTERNAL_SERVICE_TOKEN` exists
- [ ] `SETUP_PASSWORD` shows as required on deploy screen
- [ ] All pre-configured vars show under expandable section
- [ ] Network connection line visible between web and core
- [ ] Deploy screen shows "1 variable needed" (SETUP_PASSWORD)
