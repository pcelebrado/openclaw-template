/**
 * Reader landing — shown when no section slug is provided.
 * Redirects attention to the Library to pick a section.
 */
export default function ReaderLandingPage() {
  return (
    <div className="flex min-h-[calc(100vh-57px)] items-center justify-center px-4">
      <div className="text-center">
        <h1 className="text-2xl font-semibold tracking-tight">Reader</h1>
        <p className="mt-2 text-sm text-neutral-500 dark:text-neutral-400">
          Select a section from the{' '}
          <a href="/" className="underline">
            Library
          </a>{' '}
          to start reading.
        </p>
      </div>
    </div>
  );
}
