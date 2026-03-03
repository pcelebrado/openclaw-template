# Book-First UI System

## Overview

The Book-first UI implements the **"Calm Research UI"** pattern—a design philosophy that prioritizes reading, retention, and recall over trading execution. The interface creates an editorial, distraction-free environment where structured content takes center stage.

### Design Philosophy

- **Editorial First** — Typography and rhythm carry the design
- **Calm Density** — Full but breathable; never cramped
- **Quiet Chrome** — Minimal borders, subtle surfaces
- **One Accent** — Restrained color for focus and links
- **No Empty Pages** — Every state has purpose and a next action
- **No Silent Failure** — Every async action shows status, timestamp, and retry

---

## The Three-Column Sacred Shell

The core layout is a **stable 3-column shell** that remains consistent across all book-related pages:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Top App Bar (sticky)                                                        │
├──────────────┬──────────────────────────────┬───────────────────────────────┤
│              │                              │                               │
│  Left Rail   │      Center Content          │      Right Rail               │
│  (280px)     │      (760px max)             │      (360px)                  │
│              │                              │                               │
│  TOC Tree    │      Reader / Library        │      Agent Panel              │
│  ├─ Part 1   │      / Notes / Playbooks     │      / Page Tools             │
│  │  ├─ Ch 1  │                              │                               │
│  │  │  ├─ Sec│                              │                               │
│  │  │  └─ Sec│                              │                               │
│  │  └─ Ch 2  │                              │                               │
│  └─ Part 2   │                              │                               │
│              │                              │                               │
│  Bookmarks   │                              │                               │
│  Continue →  │                              │                               │
│              │                              │                               │
└──────────────┴──────────────────────────────┴───────────────────────────────┘
```

### Column Responsibilities

| Column | Width | Purpose |
|--------|-------|---------|
| **Left Rail** | 280px | TOC Tree (Parts → Chapters → Sections) with progress indicators |
| **Center** | 760px max | Reader content, Library lists, Notes, Playbooks |
| **Right Rail** | 360px | Agent panel with AI learning tools |

---

## Responsive Adaptation

The layout adapts gracefully across screen sizes:

| Breakpoint | Layout |
|------------|--------|
| `≥1536px` (2xl) | Full 3-column layout |
| `≥1280px` (xl) | 2-column + Agent drawer (slide-out) |
| `≥1024px` (lg) | 1-column + TOC drawer + Agent drawer |
| `<1024px` | Mobile: full-width sheets |

### Mobile Behavior
- TOC becomes a slide-out drawer
- Agent panel becomes a bottom sheet
- Content reflows to single column
- Touch-optimized interactions

---

## Required Page Set

### 1. Library (`/book`)
**Purpose:** Book index with progress overview

**Features:**
- Continue reading card (resumes from last position)
- Part list with chapter summaries
- Recently viewed sections
- Progress indicators

**Empty State:**
- "Start here" card linking to Part I / Chapter 1 / Section 1
- Invitation to begin the curriculum

---

### 2. Reader (`/book/[...slug]`)
**Purpose:** Section view with structured content blocks

**Features:**
- Breadcrumbs (Part / Chapter / Section)
- Structured content blocks (see below)
- Markdown prose body
- Previous/Next navigation
- Text selection → highlight/note

**Structured Blocks:**
Every section displays (when present):

| Block | Content | Limit |
|-------|---------|-------|
| **TL;DR** | Bullet summary | ≤3 bullets |
| **Checklist** | Actionable items | ≤5 items |
| **Common Mistakes** | Pitfalls to avoid | ≤3 items |
| **Drill** | Exercise | 1 exercise |

---

### 3. Notes (`/notes`)
**Purpose:** Filterable note collection

**Features:**
- Search/filter by text
- Tag chips for filtering
- Section filter
- Note cards with backlinks
- Detail drawer for editing

**Right Rail:**
- Recent highlights
- Top tags
- Backlinks

---

### 4. Playbooks (`/playbooks`)
**Purpose:** Draft → Published lifecycle

**Features:**
- Tabs: Draft / Published
- Playbook cards with trigger summaries
- Linked sections count
- Status badges

**Detail View:**
- Triggers
- Checklist
- Scenario tree
- Linked sections
- Publish/Archive actions (admin)

---

### 5. Admin (`/admin`)
**Purpose:** Status, reindex, audit log

**Features:**
- System status cards (Book, Search, Agent)
- Reindex Book action
- Last errors display
- Recent audit log

**No Silent Failure:**
- Every job shows current state
- Last run time visible
- Error details displayed
- Retry button available

---

### 6. Login (`/login`)
**Purpose:** Secure authentication

**Features:**
- Brand mark + description
- Email/password form
- Rate limit messaging
- Generic errors (no account enumeration)

---

## Agent Panel Skills

The right rail exposes **buttonable skills** for the current section:

### 1. Explain/Rephrase
**Modes:**
- **Simple** — Plain language explanation
- **Technical** — Precise terminology
- **Analogy** — Relatable comparisons

### 2. Socratic Tutor
Generates 3-5 questions to test understanding

### 3. Flashcards/Quiz
Creates 5-10 Q&A pairs for spaced repetition

### 4. Checklist Builder
Generates pre/during/post trade checklists

### 5. Scenario Tree Builder
Creates If/Then decision trees → Save as playbook draft

### 6. Notes Assistant
Create, tag, and link notes with AI suggestions

---

## Interaction Patterns

### Highlighting + Note Attachment

**Flow:**
1. User selects text in Reader
2. Floating toolbar appears:
   - Highlight
   - Add Note
   - Copy
3. Highlight creates `highlights` document
4. Add Note creates `notes` document and links highlight via `noteId`

**States:**
- Saving… (disable buttons)
- Saved → Toast "Saved"
- Error → Toast "Failed. Retry" + keep selection text

### Agent Output Saving

Every agent output includes:
- **Copy** — To clipboard
- **Save as Note** — Add to notes collection
- **Save as Playbook Draft** — When output is checklist/tree

---

## Typography & Styling

### Reader Typography
```css
/* Body text */
prose prose-invert
text-base leading-[1.65]

/* Headings */
Clear hierarchy with anchor links on hover

/* Lists */
Slightly increased spacing

/* Links */
Accent color, underline on hover
```

### shadcn/ui Components
- `NavigationMenu` — Top navigation
- `ScrollArea` — Independent column scrolling
- `CommandDialog` — Global search (⌘K)
- `Card` — Content blocks
- `Accordion` — TOC tree
- `Button` — Actions
- `Badge` — Status indicators
- `Tooltip` — Help text
- `Sheet` — Mobile drawers
- `Separator` — Minimal dividers
- `Toast` — Notifications

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘K` / `Ctrl+K` | Command palette |
| `n` | New note (in Reader) |
| `b` | Toggle bookmark (in Reader) |
| `?` | Shortcut help |

---

## Configuration

### Book Content Source
```bash
# Environment Variables
BOOK_SOURCE_MODE=manifest          # or 'directory'
BOOK_SOURCE_DIR=/data/content
BOOK_IMPORT_MANIFEST=/data/content/manifest.json
BOOK_CANONICAL_COLLECTION=book_sections
BOOK_TOC_COLLECTION=book_toc
BOOK_IMPORT_ENABLED=true
BOOK_IMPORT_DRY_RUN=false
```

### Responsive Breakpoints
```typescript
// Default breakpoints
const breakpoints = {
  '2xl': 1536,  // Full 3-column
  'xl': 1280,   // 2-column + drawer
  'lg': 1024,   // 1-column + drawers
  'default': 0  // Mobile sheets
}
```

### Agent Skills
```typescript
// Available skills
const skills = [
  'explain',        // Explain/Rephrase
  'socratic',       // Socratic Tutor
  'flashcards',     // Flashcards/Quiz
  'checklist',      // Checklist Builder
  'scenario_tree',  // Scenario Tree Builder
  'notes_assist'    // Notes Assistant
]
```

---

## Empty States

Every empty state includes:
1. Short explanation
2. A single, clear CTA

**Examples:**
- No progress: "Start here →" (links to first section)
- No notes: "Add a note while reading"
- No drafts: "Generate from Scenario Tree"
- No bookmarks: "Bookmark sections as you read"

---

## States & Loading

### Page States
- **Loading:** Skeleton screens matching content shape
- **Error:** Clear message + Retry + Back navigation
- **Empty:** Explanation + CTA
- **Success:** Content with subtle transition

### Async Actions
- **Pending:** Spinner or disabled state
- **Success:** Toast confirmation
- **Error:** Inline error with retry
- **Timeout:** "Taking longer than expected..." with cancel

---

## Accessibility

- Semantic HTML structure
- ARIA labels on interactive elements
- Keyboard navigation support
- Focus indicators
- Reduced motion support
- Screen reader optimized

---

## Performance

- Independent column scrolling
- Virtualized long lists
- Lazy-loaded images
- Debounced search input
- Optimistic UI updates

---

*For implementation details, see the [Service Architecture](./service-architecture.md) and [Agent Skills](./agent-skills.md) documentation.*
