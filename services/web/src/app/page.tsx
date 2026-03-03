/**
 * Library page — Book index / landing.
 * UI Foundation §5.1 item 1.
 *
 * Scaffold only. Intentional empty state per §2.3:
 * "a short explanation of what belongs here + exactly one clear next action."
 */
export default function LibraryPage() {
  return (
    <div className="px-4 py-12">
      <h1 className="text-2xl font-semibold tracking-tight">Library</h1>
      <p className="mt-2 text-sm text-neutral-500 dark:text-neutral-400">
        The Book index will appear here. Parts, chapters, and sections are
        organized as a structured Table of Contents.
      </p>

      {/* Empty state — one clear next action */}
      <div className="mt-8 rounded-lg border border-dashed border-neutral-300 p-8 text-center dark:border-neutral-700">
        <p className="text-sm text-neutral-500 dark:text-neutral-400">
          No book content imported yet.
        </p>
        <p className="mt-2 text-xs text-neutral-400 dark:text-neutral-500">
          An admin can trigger a book import from the{' '}
          <a href="/admin" className="underline">
            Admin panel
          </a>
          .
        </p>
      </div>
    </div>
  );
}
