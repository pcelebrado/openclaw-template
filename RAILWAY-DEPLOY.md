# OpenClaw Railway Deployment Guide

## Quick Deploy (Option C - Railway CLI)

### Prerequisites
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Link to your project
railway link
```

### Deploy Commands

```bash
# Deploy both services
./railway-deploy.sh all

# Deploy only web
./railway-deploy.sh web

# Deploy only core
./railway-deploy.sh core

# Or use Railway CLI directly
railway up --service web
railway up --service core
```

## Local Testing with Railpack (Option A)

### Prerequisites
```bash
# Install Railpack
curl -sSL https://railpack.com/install.sh | sh

# Start BuildKit
docker run --rm --privileged -d --name buildkit moby/buildkit
export BUILDKIT_HOST='docker-container://buildkit'
```

### Build Locally

```bash
# Build web service with Railpack
cd services/web
railpack build . --name openclaw-web

# Build core service with Railpack
cd services/core
railpack build . --name openclaw-core
```

### Test Locally

```bash
# Run the built image
docker run -p 3000:3000 openclaw-web

# Or use the npm scripts from root
npm run railpack:web
npm run railpack:core
```

## Build Configuration Priority

Railway uses this priority:
1. `railway.toml` settings (if present)
2. `railpack.json` (if present and builder = RAILPACK)
3. Auto-detection (Railpack guesses your stack)
4. Dockerfile (if builder = DOCKERFILE)

## Current Setup

### Web Service
- **Build**: Uses Dockerfile (railway.toml has `builder = "DOCKERFILE"`)
- **Railpack config**: `services/web/railpack.json` (for local testing)
- **To switch**: Change railway.toml to `builder = "RAILPACK"`

### Core Service
- **Build**: Uses Dockerfile (railway.toml has `builder = "DOCKERFILE"`)
- **Railpack config**: `services/core/railpack.json` (for local testing)
- **To switch**: Change railway.toml to `builder = "RAILPACK"`

## Switching to Railpack (Option A)

Edit each service's `railway.toml`:

```toml
[build]
builder = "RAILPACK"  # Change from DOCKERFILE
```

Then deploy:
```bash
railway up
```

## Troubleshooting

### "No start command was found"
- Root package.json now has scripts (fixed)
- Or service package.json needs a "start" script

### "Cannot connect to core service"
- Check private networking is enabled in Railway dashboard
- Verify service names match in environment variables

### "Port already in use"
- Use `${PORT:-3000}` pattern in start commands
- Railway injects PORT variable

## Environment Variables

Set in Railway dashboard:
- `SETUP_PASSWORD` (required for Core)
- `INTERNAL_SERVICE_TOKEN` (must match between services)
- `AUTH_SECRET` (for Web NextAuth)

## Support

See `RAILPACK-EXAMPLES-REFERENCE.md` for detailed configuration options.
