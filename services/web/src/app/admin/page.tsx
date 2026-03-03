/**
 * Admin minimal page — reindex + status.
 * UI Foundation §5.1 item 5.
 *
 * Scaffold only. Surfaces async process status per §2.4:
 * "status (idle/running/succeeded/failed), last run time, error visibility."
 */
export default function AdminPage() {
  return (
    <div className="px-4 py-12">
      <h1 className="text-2xl font-semibold tracking-tight">Admin</h1>
      <p className="mt-2 text-sm text-neutral-500 dark:text-neutral-400">
        System status and book management. Requires admin role.
      </p>

      <div className="mt-8 grid gap-6 sm:grid-cols-2">
        {/* Reindex card */}
        <div className="rounded-lg border border-neutral-200 p-6 dark:border-neutral-800">
          <h2 className="text-sm font-semibold">Book Reindex</h2>
          <dl className="mt-3 space-y-1 text-xs text-neutral-500">
            <div className="flex justify-between">
              <dt>Status</dt>
              <dd className="font-mono">idle</dd>
            </div>
            <div className="flex justify-between">
              <dt>Last run</dt>
              <dd className="font-mono">&mdash;</dd>
            </div>
            <div className="flex justify-between">
              <dt>Last error</dt>
              <dd className="font-mono">none</dd>
            </div>
          </dl>
          <button
            type="button"
            disabled
            className="mt-4 rounded bg-neutral-900 px-3 py-1.5 text-xs font-medium text-white opacity-50 dark:bg-neutral-100 dark:text-neutral-900"
          >
            Trigger Reindex
          </button>
        </div>

        {/* Service status card */}
        <div className="rounded-lg border border-neutral-200 p-6 dark:border-neutral-800">
          <h2 className="text-sm font-semibold">Service Health</h2>
          <dl className="mt-3 space-y-1 text-xs text-neutral-500">
            <div className="flex justify-between">
              <dt>Web</dt>
              <dd className="font-mono text-green-600">ok</dd>
            </div>
            <div className="flex justify-between">
              <dt>Core</dt>
              <dd className="font-mono text-neutral-400">not checked</dd>
            </div>
            <div className="flex justify-between">
              <dt>MongoDB</dt>
              <dd className="font-mono text-neutral-400">not checked</dd>
            </div>
            <div className="flex justify-between">
              <dt>Book import</dt>
              <dd className="font-mono text-neutral-400">disabled</dd>
            </div>
          </dl>
        </div>
      </div>
    </div>
  );
}
