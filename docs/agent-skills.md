# Agent Skills & AI Integration

## Overview

The Agent Skills system provides AI-assisted study tools through the right rail Agent Panel. Six core skills help users understand, retain, and apply book content: Explain/Rephrase, Socratic Tutor, Flashcards/Quiz, Checklist Builder, Scenario Tree Builder, and Notes Assistant.

Each skill is context-aware, receiving the current section content, selected text, and user preferences to generate relevant outputs. The system is designed with graceful degradation—when the core service is unavailable, the UI shows clear status messages while allowing users to continue reading.

---

## The Six Agent Skills

### 1. Explain/Rephrase

**Purpose:** Help users understand complex concepts in different ways

**Modes:**
- **Simple** — Plain language explanation without jargon
- **Technical** — Precise terminology and detailed mechanics
- **Analogy** — Relatable comparisons to everyday concepts

**Example Interaction:**
```
User selects: "Gamma measures the rate of change in delta..."

Simple: "Gamma tells you how much your position's sensitivity 
         to price changes will change as the price moves."

Technical: "Gamma (Γ) is the second derivative of option price 
           with respect to underlying price, measuring convexity."

Analogy: "Think of gamma like acceleration in a car. Delta is 
         your speed, but gamma tells you how quickly you're 
         pressing the gas pedal."
```

**Save Options:** Copy, Save as Note

---

### 2. Socratic Tutor

**Purpose:** Test understanding through guided questioning

**Output:** 3-5 questions that probe comprehension

**Example:**
```
1. What does it mean when gamma is high? What happens to your 
   delta as the underlying moves?

2. Why might gamma be higher for at-the-money options compared 
   to deep in-the-money options?

3. How would high gamma affect your hedging strategy if you're 
   short options?
```

**Save Options:** Copy, Save as Note

---

### 3. Flashcards/Quiz

**Purpose:** Generate study materials for spaced repetition

**Output:** 5-10 Q&A pairs

**Example:**
```
Q: What is gamma?
A: The rate of change of delta with respect to the underlying price

Q: When is gamma highest?
A: At-the-money, near expiration

Q: What is gamma risk?
A: The risk of large delta changes causing unexpected losses
```

**Save Options:** Copy, Save as Note, Export to Anki (optional)

---

### 4. Checklist Builder

**Purpose:** Generate actionable checklists from section content

**Output:** Pre/During/Post trade checklists

**Example:**
```
Pre-Trade:
☐ Check IV rank is above 50%
☐ Verify gamma exposure is under 5% of account
☐ Calculate max loss scenario

During Trade:
☐ Monitor delta every 15 minutes
☐ Watch for gamma squeeze signals

Post-Trade:
☐ Log actual vs predicted outcomes
☐ Review gamma impact on P&L
```

**Save Options:** Copy, Save as Note, Save as Playbook Draft

---

### 5. Scenario Tree Builder

**Purpose:** Create If/Then decision trees for complex situations

**Output:** Structured decision tree with conditions and actions

**Example:**
```
IF: IV Rank > 80%
  THEN: Consider selling premium
  
  IF: Gamma > 0.10
    THEN: Reduce position size by 50%
    ELSE: Trade normal size
    
ELSE IF: IV Rank < 20%
  THEN: Consider buying premium
  
  IF: Time to expiration < 7 days
    THEN: Avoid due to gamma risk
    ELSE: Evaluate debit spreads
```

**Save Options:** Copy, Save as Note, Save as Playbook Draft

---

### 6. Notes Assistant

**Purpose:** Help create, organize, and link notes

**Capabilities:**
- Suggest note titles based on content
- Recommend tags from existing note taxonomy
- Link related sections
- Summarize selected text

**Example:**
```
Selected: "Gamma scalping involves frequent delta hedging..."

Suggested Title: "Gamma Scalping Strategy Overview"
Suggested Tags: ["gamma", "scalping", "delta-hedging", "volatility"]
Related Sections: ["part-2/ch-3/02-delta-hedging"]
Summary: "Gamma scalping profits from volatility through 
          continuous delta-neutral adjustments."
```

**Save Options:** Create Note (with suggestions)

---

## API Contract

### Request

```http
POST /api/agent/skill
Content-Type: application/json

{
  "skill": "explain|socratic|flashcards|checklist|scenario_tree|notes_assist",
  "context": {
    "sectionSlug": "part-1/ch-1/01-gamma-basics",
    "anchorId": "definition",
    "selectedText": "Gamma measures the rate of change...",
    "userNoteIds": ["note-1", "note-2"],
    "mode": "simple|technical|analogy"
  }
}
```

### Response

```json
{
  "output": {
    "type": "text|qa|cards|checklist|tree",
    "title": "Gamma Explained Simply",
    "content": "Gamma tells you how much...",
    "items": [
      // For cards, checklist, tree types
    ]
  },
  "saveSuggestions": {
    "note": true,
    "playbookDraft": false
  }
}
```

---

## Internal Flow

```
1. User invokes skill from Agent Panel
2. Web service validates session
3. Web service constructs context (section, selection, mode)
4. Web service generates JWT for Core authentication
5. Web service POST /internal/agent/run
6. Core executes skill with OpenClaw
7. Core returns structured output
8. Web service returns response to browser
9. UI displays output with save options
```

---

## Context Assembly

### Available Context

| Field | Description | Example |
|-------|-------------|---------|
| `sectionSlug` | Current section identifier | `"part-1/ch-1/01-gamma-basics"` |
| `anchorId` | Heading within section | `"definition"` |
| `selectedText` | User's text selection | `"Gamma measures..."` |
| `userNoteIds` | IDs of user's notes on this section | `["note-1", "note-2"]` |
| `mode` | Explanation mode | `"simple"` |

### Context Building

```typescript
async function buildContext(sectionSlug: string, userId: string) {
  const section = await db.book_sections.findOne({ slug: sectionSlug });
  const notes = await db.notes.find({ userId, sectionSlug });
  
  return {
    sectionSlug,
    sectionTitle: section.section.title,
    sectionBody: section.bodyMarkdown,
    frontmatter: section.frontmatter,
    userNoteIds: notes.map(n => n._id.toString()),
    // selectedText added from UI
  };
}
```

---

## Rate Limiting

### Limits

| Skill Type | Limit |
|------------|-------|
| All skills | 10 per minute per user |
| All skills | 100 per hour per user |

### Rate Limit Response

```json
{
  "error": {
    "code": "rate_limited",
    "message": "You've hit the assistant limit. Try again soon.",
    "details": {
      "retryAfterSeconds": 60
    }
  }
}
```

---

## Error Handling

### Core Unavailable

**UI State:** "Waking assistant..."
```
Title: "Waking assistant..."
Body: "This can take a few seconds after inactivity."
CTA: [Retry] [Continue reading]
```

**After Timeout:** "Assistant temporarily unavailable"
```
Title: "Assistant temporarily unavailable"
Body: "Try again in a moment."
CTA: [Retry]
Status: "Last success: 5 minutes ago"
```

### Skill Execution Error

```json
{
  "error": {
    "code": "skill_failed",
    "message": "The assistant encountered an error. Please try again.",
    "details": {
      "skill": "explain",
      "requestId": "req-abc-123"
    }
  }
}
```

---

## Saving Outputs

### Save as Note

```http
POST /api/notes
{
  "sectionSlug": "part-1/ch-1/01-gamma-basics",
  "title": "Gamma Explained (AI)",
  "body": "Gamma tells you how much...",
  "tags": ["gamma", "ai-generated"]
}
```

### Save as Playbook Draft

```http
POST /api/playbooks/draft
{
  "title": "Gamma Scalping Checklist",
  "triggers": ["High gamma environment"],
  "checklist": ["Check IV rank", "Calculate position size"],
  "linkedSections": ["part-1/ch-1/01-gamma-basics"]
}
```

---

## Audit Logging

All agent runs are logged to `agent_runs` collection:

```javascript
{
  _id: ObjectId,
  userId: ObjectId("..."),
  skill: "explain",
  context: {
    sectionSlug: "part-1/ch-1/01-gamma-basics",
    selectedText: "Gamma measures...",
    mode: "simple"
  },
  output: {
    type: "text",
    title: "Gamma Explained",
    content: "Gamma tells you..."
  },
  savedTo: {
    noteId: ObjectId("..."),
    playbookId: null
  },
  createdAt: ISODate()
}
```

---

## Configuration

### Available Skills

```bash
# Comma-separated list of enabled skills
AGENT_SKILLS=explain,socratic,flashcards,checklist,scenario_tree,notes_assist
```

### Default Modes

```bash
# Default explanation mode
AGENT_DEFAULT_MODE=simple  # simple | technical | analogy
```

### Core Service URL

```bash
INTERNAL_CORE_BASE_URL=http://core.railway.internal:7200
```

---

## UI Integration

### Agent Panel Layout

```
┌─────────────────────────┐
│  Assistant              │
├─────────────────────────┤
│  [Explain ▼] [Socratic] │
│  [Flashcards] [Check]   │
│  [Scenario] [Notes]     │
├─────────────────────────┤
│  Mode: [Simple ▼]       │
├─────────────────────────┤
│  ┌─────────────────────┐│
│  │ Output area         ││
│  │                     ││
│  │                     ││
│  └─────────────────────┘│
├─────────────────────────┤
│  [Copy] [Save Note]     │
└─────────────────────────┘
```

### Skill Buttons

Each skill is a button with:
- Icon representing the skill
- Label
- Tooltip with description
- Disabled state when unavailable

### Output Display

Different output types render differently:
- **Text:** Markdown formatted
- **QA:** Question/Answer pairs with reveal
- **Cards:** Flip cards for flashcards
- **Checklist:** Interactive checkboxes
- **Tree:** Collapsible tree view

---

## Best Practices

1. **Always provide context** — The more context (section, selection, notes), the better the output
2. **Handle timeouts gracefully** — Show waking state, never hang indefinitely
3. **Log all interactions** — Audit trail helps debugging and improvement
4. **Rate limit aggressively** — Protect API costs and prevent abuse
5. **Make saving easy** — One-click save to notes or playbooks
6. **Show save suggestions** — Guide users on what to do with outputs

---

*For more details, see the [Book-First UI](./book-first-ui.md) and [Internal Service Auth](./internal-service-auth.md) documentation.*
