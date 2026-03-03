# Contributing

Thanks for helping improve the OpenClaw Core Railway template.

## Reporting bugs

Please include:

1) **Railway logs** around the failure
2) The output of:
   - `GET /healthz`
   - `GET /setup/api/debug` (after authenticating to `/setup`)
3) Your Railway settings relevant to networking:
   - Public Networking disabled?
   - Volume mounted at `/data`?

## Pull requests

- Keep PRs small and focused (one fix per PR)
- Test locally with Docker build before submitting
- If you're making Dockerfile changes, explain why they're needed and how you tested
