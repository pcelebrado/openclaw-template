/**
 * Notes page — filters, tags, backlinks.
 * UI Foundation §5.1 item 4.
 *
 * Scaffold only. Intentional empty state per §2.3.
 */
export default function NotesPage() {
  return (
    <div className="px-4 py-12">
      <h1 className="text-2xl font-semibold tracking-tight">Notes</h1>
      <p className="mt-2 text-sm text-neutral-500 dark:text-neutral-400">
        Your notes, highlights, and bookmarks from across the Book. Filter by
        section, tag, or date.
      </p>

      {/* Empty state */}
      <div className="mt-8 rounded-lg border border-dashed border-neutral-300 p-8 text-center dark:border-neutral-700">
        <p className="text-sm text-neutral-500 dark:text-neutral-400">
          No notes yet.
        </p>
        <p className="mt-2 text-xs text-neutral-400 dark:text-neutral-500">
          Highlight text or use the Notes Assistant in the{' '}
          <a href="/book" className="underline">
            Reader
          </a>{' '}
          to create your first note.
        </p>
      </div>
    </div>
  );
}
