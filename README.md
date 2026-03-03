# OpenClaw Railway Template

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/github?repo=https://github.com/pcelebrado/openclaw-template)

OpenClaw is a monorepo Railway template with three services:

- `web` - Next.js public application
- `core` - internal OpenClaw wrapper service
- `mongo` - internal MongoDB replica set service

## Repository Layout

```text
openclaw-template/
├── services/
│   ├── web/
│   ├── core/
│   └── mongo/
├── railway.json
├── README.md
├── LICENSE
└── .github/
```

## Architecture

```text
Public Internet
      |
      v
[web (public)]
   |        \
   v         v
[core]    [mongo]
(internal) (internal)
```

## Railway Service Setup

Create three services in one Railway project using this repository:

1. `web`
   - Root directory: `services/web`
   - Public networking: enabled
2. `core`
   - Root directory: `services/core`
   - Public networking: disabled
   - Volume mount path: `/data`
3. `mongo`
   - Root directory: `services/mongo/nodes`
   - Public networking: disabled

## Required Environment Variables

Set environment variables per service from each service's `.env.example` file.

At minimum, keep these contracts aligned across services:

- `web` and `core` must share the same `INTERNAL_SERVICE_TOKEN`
- `web` must use internal hostnames for `INTERNAL_CORE_BASE_URL` and `MONGODB_URI`

## Notes

- Only `web` is intended to be publicly reachable.
- `core` and `mongo` must remain internal-only.
- This template provides code scaffolding and configuration only.
