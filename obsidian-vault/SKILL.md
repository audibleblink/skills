---
name: obsidian-vault
description: Write and edit Obsidian vault notes using Obsidian-flavored Markdown. Use when (1) creating new .md notes for an Obsidian vault, (2) editing existing Obsidian notes, (3) adding properties/frontmatter, wikilinks, callouts, embeds, tags, or other Obsidian-specific syntax, (4) converting standard Markdown to Obsidian format, (5) creating presentation slides for Obsidian Slides Extended (reveal.js), or (6) any task involving Obsidian Markdown formatting.
---

# Obsidian Vault Note Formatting

Write notes and presentation slides using Obsidian-flavored Markdown: CommonMark + GFM + Obsidian extensions.

## Reference Files

Detailed syntax for each topic in `references/`:

### Note Writing
- **[properties.md](references/properties.md)** — YAML frontmatter, property types, default properties
- **[links.md](references/links.md)** — Wikilinks, heading/block links, display text, markdown-style links
- **[embeds.md](references/embeds.md)** — Embedding notes, images, audio, PDFs, lists
- **[tags.md](references/tags.md)** — Inline tags, nested tags, tag format rules
- **[callouts.md](references/callouts.md)** — Callout types, foldable/nested callouts
- **[formatting.md](references/formatting.md)** — Bold, italic, highlights, headings, lists, task lists
- **[tables.md](references/tables.md)** — Table alignment, escaping pipes for wikilinks
- **[diagrams.md](references/diagrams.md)** — Mermaid flowcharts, sequence diagrams, internal-link class
- **[math.md](references/math.md)** — MathJax/LaTeX block and inline math
- **[footnotes.md](references/footnotes.md)** — Reference-style and inline footnotes
- **[comments.md](references/comments.md)** — Inline and block comments (`%%`)
- **[code-blocks.md](references/code-blocks.md)** — Inline code, fenced blocks, nested blocks

### Presentation Slides (Obsidian Slides Extended)
- **[slides-syntax.md](references/slides-syntax.md)** — Slide separators, frontmatter, fragments, speaker notes, layouts
- **[slides-patterns.md](references/slides-patterns.md)** — Common slide patterns, examples, templates

Load only the reference file relevant to the current task.

## Key Differences from Standard Markdown

Obsidian extends standard Markdown with these features — always use them when writing for an Obsidian vault:

- **Wikilinks**: `[[Note Name]]` instead of `[text](file.md)` (preferred default)
- **Embeds**: `![[Note Name]]` to inline another note's content
- **Highlights**: `==highlighted text==`
- **Callouts**: `> [!type] Title` blockquote admonitions
- **Block references**: `[[Note#^block-id]]` to link to specific paragraphs
- **Comments**: `%%hidden text%%` visible only in edit mode
- **Properties**: YAML frontmatter with typed fields (`tags`, `aliases`, `cssclasses`)
- **Tags**: `#tag` inline or in frontmatter, with `/` nesting (`#project/active`)

## Creating Presentation Slides

When the user wants to create presentation slides for Obsidian Slides Extended (reveal.js plugin):

### When to Create Slides

Use slide format when user:
- Explicitly requests slides, presentations, or slide decks
- Asks to convert content to presentation format
- Requests reveal.js or Obsidian Slides Extended output

### Slide Creation Workflow

1. **Understand requirements:**
   - From outline/bullets → convert hierarchy to slide structure
   - From topic description → ask about duration, audience, key messages
   - From existing markdown → reformat with slide syntax
   - Interactive planning → collaborate on structure

2. **Apply standard structure:**
   - Title slide
   - Agenda slide with vertical sub-slides for each section
   - Main sections (horizontal slides)
   - Detail slides (vertical slides under main sections)
   - Takeaways slide
   - Questions/Resources slide

3. **Use slide-specific syntax:**
   - Frontmatter with `theme: blood`, `verticalSeparator: xxx`, `hash: true`
   - `---` for horizontal slides (main sections)
   - `xxx` for vertical slides (sub-topics)
   - `-` for visible list items, `+` for progressive reveals
   - `notes:` or `note:` for speaker notes
   - Navigation indicators: `<i class="fa-solid fa-arrow-right"></i>` and `<i class="fa-solid fa-arrow-down"></i>`

4. **Follow content guidelines:**
   - One main idea per slide
   - Use vertical slides for details/examples
   - Add speaker notes for context
   - Use progressive disclosure with `+` fragments

**See [slides-syntax.md](references/slides-syntax.md)** for complete syntax reference and **[slides-patterns.md](references/slides-patterns.md)** for common patterns and examples.

**Template:** Use [assets/slide-template.md](assets/slide-template.md) as a starting point.

---

## Writing Notes

### Frontmatter

Always include YAML frontmatter when creating notes. At minimum, include relevant tags:

```yaml
---
tags:
  - topic
aliases:
  - alternate-name
---
```

Use `aliases` to make the note discoverable under different names when linking. Use `cssclasses` only when specific styling is needed.

Internal links in properties must be quoted: `link: "[[Target Note]]"`.

### Linking

Prefer wikilinks: `[[Note Name]]`. Use display text for clarity: `[[Note Name|readable text]]`.

Link to headings: `[[Note#Heading]]`. Link to blocks: `[[Note#^block-id]]`.

### Callouts

Use callouts for tips, warnings, and structured asides:

```md
> [!tip] Key Insight
> Content here with **formatting** and [[links]].
```

Make foldable with `+` (expanded) or `-` (collapsed) after the type: `> [!note]-`.

Common types: `note`, `tip`, `warning`, `info`, `example`, `question`, `quote`, `todo`, `abstract`, `success`, `failure`, `danger`, `bug`.

### Embeds

Embed notes, headings, blocks, images, audio, and PDFs:

```md
![[Other Note]]
![[image.png|300]]
![[doc.pdf#page=2]]
```

### Tags

Use inline `#tags` in note body or `tags` property in frontmatter. Nest with `/`: `#area/project`.

Tags must contain at least one non-numeric character. Case-insensitive.

### Tables

Escape `|` with `\|` inside cells when using wikilinks or image sizing:

```md
| Note | Image |
| ---- | ----- |
| [[Page\|Alias]] | ![[photo.jpg\|200]] |
```

## Important Rules

1. **No Markdown in properties** — property values are plain text (except internal links in quotes)
2. **Wikilinks over Markdown links** — use `[[target]]` not `[text](target.md)` unless interoperability is required
3. **Block IDs** — use only Latin letters, numbers, and dashes (e.g., `^my-block-id`)
4. **Tag format** — no spaces; use camelCase, kebab-case, or snake_case
5. **Comments** — use `%%text%%` for content hidden from reading view
6. **Inline footnotes** — `^[text]` only render in Reading view, not Live Preview
7. **Mermaid diagrams** — use `internal-link` class on nodes to link to vault notes
8. **Nested code blocks** — outer fence must use more backtick/tilde characters than inner
