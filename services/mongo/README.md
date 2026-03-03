# OpenClaw Mongo — Railway Template

A **MongoDB replica set** with keyfile authentication for the OpenClaw Railway deployment.
Based on the official MongoDB Community Edition image with keyfile auth enabled.

## What you get

- MongoDB replica set with keyfile authentication
- Init service that bootstraps the replica set and self-deletes
- Internal-only networking — no public port exposure
- Example connection apps (Node.js, Python)

## Architecture

This is **Service C** in the OpenClaw 3-service Railway deployment:

```
Browser → [web] (public) → [core] (internal) → OpenClaw Gateway
                         → [mongo] (internal, this service)
```

- This service is **internal only** — no public database port.
- Accessible only from the `web` and `core` services via Railway internal networking.
- Connection string pattern: `mongodb://mongo.railway.internal:27017/openclaw`

## Deploy on Railway

1. Create a new Railway project from this repo (or add as a service to an existing project)
2. **Disable Public Networking** — this service must not be publicly accessible
3. The init service will bootstrap the replica set automatically
4. Use the internal connection string from your `web` and `core` services

## Security

- No public port exposure
- No direct browser access
- Keyfile authentication between replica set members
- Connection credentials managed via Railway environment variables

## Example apps

Included example apps demonstrate how to connect from a client:
- [Node.js app](/exampleApps/node/)
- [Python app](/exampleApps/python/)

## Related services

- [`openclaw-web`](https://github.com/pcelebrado/openclaw-web) — Next.js frontend (public)
- [`openclaw-core`](https://github.com/pcelebrado/openclaw-core) — OpenClaw Gateway wrapper (internal)

## License

MIT License — see [LICENSE](LICENSE).
