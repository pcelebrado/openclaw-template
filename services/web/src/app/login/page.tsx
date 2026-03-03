/**
 * Login + onboarding page.
 * UI Foundation §5.1 item 6.
 *
 * Scaffold only. MVP-hardened login pattern will be implemented with Auth.js.
 * This shell provides the route and intentional empty state.
 */
export default function LoginPage() {
  return (
    <div className="flex min-h-[calc(100vh-57px)] items-center justify-center px-4">
      <div className="w-full max-w-sm">
        <h1 className="text-center text-2xl font-semibold tracking-tight">
          Sign in
        </h1>
        <p className="mt-2 text-center text-sm text-neutral-500 dark:text-neutral-400">
          Authentication will be configured during deployment.
        </p>

        {/* Placeholder form — no auth wiring yet */}
        <div className="mt-8 space-y-4">
          <div>
            <label
              htmlFor="email"
              className="block text-xs font-medium text-neutral-600 dark:text-neutral-400"
            >
              Email
            </label>
            <input
              id="email"
              type="email"
              disabled
              placeholder="you@example.com"
              className="mt-1 w-full rounded border border-neutral-300 bg-neutral-50 px-3 py-2 text-sm placeholder:text-neutral-300 dark:border-neutral-700 dark:bg-neutral-900 dark:placeholder:text-neutral-600"
            />
          </div>
          <button
            type="button"
            disabled
            className="w-full rounded bg-neutral-900 px-3 py-2 text-sm font-medium text-white opacity-50 dark:bg-neutral-100 dark:text-neutral-900"
          >
            Continue
          </button>
        </div>

        <p className="mt-6 text-center text-xs text-neutral-400">
          Auth provider will be selected at deploy time via AUTH_SECRET and
          AUTH_URL.
        </p>
      </div>
    </div>
  );
}
