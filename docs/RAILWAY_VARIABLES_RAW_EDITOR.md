# Railway Variables (Copy/Paste for Non-Programmers)

> **Preferred method**: Use the [Deploy on Railway](https://railway.com/new/template) button — all variables are pre-configured in the template. This guide is only needed if you're importing the repo manually (not using the template).

## If Using the Template (Recommended)

The Railway template pre-configures **all** environment variables, volumes, and networking.
You only need to set **one value** at deploy time:

| Variable | Where | What |
|----------|-------|------|
| `SETUP_PASSWORD` | Deploy screen | A password to protect the OpenClaw setup wizard |

Everything else is auto-generated (secrets, tokens, connection strings).

---

## If Importing Manually (Advanced)

If you imported the GitHub repo directly instead of using the template, you need to configure variables manually.

### 1) Create two services

- `openclaw-web` from `services/web`
- `openclaw-core` from `services/core`

### 2) Attach volume to core

Go to `openclaw-core` → Settings → Volumes → Add volume → mount path: `/data`

### 3) Import variables via Raw Editor

#### Web service

Open `services/web/.env.railway`, copy all lines, then paste into:

- Railway → `openclaw-web` → Variables → Raw Editor

#### Core service

Open `services/core/.env.railway`, copy all lines, then paste into:

- Railway → `openclaw-core` → Variables → Raw Editor

### 4) Networking

| Service | Setting |
|---------|---------|
| `openclaw-web` | Generate public domain |
| `openclaw-core` | **No** public domain (internal only) |
| `openclaw-core` | Enable TCP Proxy on port `2022` (for SFTP) |

### 5) Deploy

1. Deploy `core` first — starts MongoDB and SFTPGo
2. Deploy `web` — verify `/api/health` returns 200
3. Visit your public domain to access the app

---

## Variable Reference

See `docs/RAILWAY_TEMPLATE_SPEC.md` for the complete variable specification with descriptions and Railway template syntax.
