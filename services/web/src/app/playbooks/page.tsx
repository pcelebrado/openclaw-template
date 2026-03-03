/**
 * Playbooks page — list + detail, draft and published.
 * UI Foundation §5.1 item 3.
 *
 * Scaffold only. Intentional empty state per §2.3.
 */
export default function PlaybooksPage() {
  return (
    <div className="px-4 py-12">
      <h1 className="text-2xl font-semibold tracking-tight">Playbooks</h1>
      <p className="mt-2 text-sm text-neutral-500 dark:text-neutral-400">
        Trading playbooks built from the Book. Includes triggers, checklists,
        and scenario trees for defined-risk SPY spreads.
      </p>

      {/* Empty state */}
      <div className="mt-8 rounded-lg border border-dashed border-neutral-300 p-8 text-center dark:border-neutral-700">
        <p className="text-sm text-neutral-500 dark:text-neutral-400">
          No playbooks yet.
        </p>
        <p className="mt-2 text-xs text-neutral-400 dark:text-neutral-500">
          Use the Scenario Tree builder in the{' '}
          <a href="/book" className="underline">
            Reader
          </a>{' '}
          to create your first playbook draft.
        </p>
      </div>
    </div>
  );
}
