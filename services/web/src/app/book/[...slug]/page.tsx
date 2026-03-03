/**
 * Reader page — Section view with 3-column shell target.
 * UI Foundation §5.1 item 2.
 *
 * Route: /book/:partSlug/:chapterSlug/:sectionSlug (catch-all)
 * Maps to: GET /api/book/section?slug=<joined-slug>
 *
 * Scaffold only. The 3-column shell (left TOC, center content, right agent
 * panel) is the target layout per §2.1. This shell provides the structural
 * skeleton; content rendering and agent panel will be implemented separately.
 */
export default function ReaderPage({
  params,
}: {
  params: { slug: string[] };
}) {
  const sectionSlug = params.slug?.join('/') ?? '';

  return (
    <div className="flex min-h-[calc(100vh-57px)]">
      {/* Left rail — Book TOC / navigation (target: 260-300px) */}
      <aside className="hidden w-[280px] shrink-0 border-r border-neutral-200 p-4 lg:block dark:border-neutral-800">
        <h2 className="text-xs font-semibold uppercase tracking-wide text-neutral-400">
          Table of Contents
        </h2>
        <div className="mt-4 rounded border border-dashed border-neutral-300 p-4 text-center text-xs text-neutral-400 dark:border-neutral-700">
          TOC tree loads here
        </div>
      </aside>

      {/* Center — Reader content (target: 680-760px) */}
      <article className="min-w-0 flex-1 px-6 py-8 lg:px-10">
        <div className="mx-auto max-w-prose">
          {sectionSlug ? (
            <>
              <p className="mb-2 text-xs text-neutral-400">{sectionSlug}</p>
              <h1 className="text-2xl font-semibold tracking-tight">
                Section Title
              </h1>

              {/* Required section template blocks per §5.2 */}
              <div className="mt-8 space-y-6">
                <SectionBlock label="TL;DR" hint="3 bullets max" />
                <SectionBlock label="Checklist" hint="5 bullets max" />
                <SectionBlock label="Common Mistakes" hint="3 items max" />
                <SectionBlock label="Drill" hint="1 exercise" />
              </div>
            </>
          ) : (
            <div className="rounded-lg border border-dashed border-neutral-300 p-8 text-center dark:border-neutral-700">
              <p className="text-sm text-neutral-500">
                Select a section from the Table of Contents to begin reading.
              </p>
            </div>
          )}
        </div>
      </article>

      {/* Right rail — Agent panel (target: 320-380px) */}
      <aside className="hidden w-[340px] shrink-0 border-l border-neutral-200 p-4 xl:block dark:border-neutral-800">
        <h2 className="text-xs font-semibold uppercase tracking-wide text-neutral-400">
          Agent Panel
        </h2>
        <div className="mt-4 space-y-2">
          {[
            'Explain / Rephrase',
            'Socratic Tutor',
            'Flashcards / Quiz',
            'Checklist Builder',
            'Scenario Tree',
            'Notes Assistant',
          ].map((skill) => (
            <button
              key={skill}
              type="button"
              disabled
              className="w-full rounded border border-neutral-200 px-3 py-2 text-left text-sm text-neutral-400 dark:border-neutral-700"
            >
              {skill}
            </button>
          ))}
        </div>
      </aside>
    </div>
  );
}

/** Placeholder for required Reader section template blocks (§5.2). */
function SectionBlock({ label, hint }: { label: string; hint: string }) {
  return (
    <div className="rounded border border-dashed border-neutral-200 p-4 dark:border-neutral-800">
      <h3 className="text-xs font-semibold uppercase tracking-wide text-neutral-400">
        {label}
      </h3>
      <p className="mt-1 text-xs text-neutral-300 dark:text-neutral-600">
        Coming soon &mdash; {hint}
      </p>
    </div>
  );
}
