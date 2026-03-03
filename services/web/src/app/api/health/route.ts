/**
 * Health endpoint for Railway probes and service monitoring.
 * Foundation infrastructure health probe.
 *
 * Returns service readiness without exposing secrets.
 */
import { NextResponse } from 'next/server';

export async function GET() {
  const checks: Record<string, string> = {
    status: 'ok',
    service: 'web',
    timestamp: new Date().toISOString(),
  };

  // Check MongoDB connectivity (non-blocking, best-effort)
  const mongoUri = process.env.MONGODB_URI;
  checks.mongo = mongoUri ? 'configured' : 'not_configured';

  // Check internal core reachability config (non-blocking)
  const coreUrl = process.env.INTERNAL_CORE_BASE_URL;
  checks.core = coreUrl ? 'configured' : 'not_configured';

  // Check service auth config
  const serviceToken = process.env.INTERNAL_SERVICE_TOKEN;
  const jwtKey = process.env.INTERNAL_JWT_SIGNING_KEY;
  checks.service_auth = serviceToken || jwtKey ? 'configured' : 'not_configured';

  return NextResponse.json(checks);
}
