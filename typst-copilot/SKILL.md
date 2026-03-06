---
name: typst-copilot
description: Typst (.typ) document assistant for creation, layout debugging, compilation, and format conversion. Use this skill whenever (1) user mentions "Typst", ".typ files", or Typst syntax patterns (#figure, #table, #set, #show), (2) creating any document type in Typst - papers, reports, resumes, CVs, presentations, slides, (3) struggling with layout - figures floating to wrong places, page breaks cutting off content, columns not working, elements mispositioned, (4) document structure issues - TOC page numbers wrong, headers not updating, show rules misbehaving, (5) compiling Typst to PDF or hitting build errors ("unknown variable", syntax errors), (6) converting or migrating from LaTeX/Markdown to Typst. This skill is the go-to for anything Typst-related. If the problem involves .typ files or Typst-specific concepts, use this skill.
---

# Typst Copilot

Typst v0.14.2 document assistant.

## Resources

### Scripts
- `scripts/compile_typst.py <input.typ> [output.pdf]` - Compile to PDF

### References (read as needed)
- `references/syntax.md` - Markup, math, code modes; function parameters
- `references/styling.md` - Set rules, show rules, typography
- `references/layout.md` - Page setup, grids, tables, figures
- `references/scripting.md` - Variables, functions, control flow, imports
- `references/conversion.md` - Markdown/LaTeX to Typst mappings
- `references/debugging.md` - Page flow fixes, layout troubleshooting

### Templates
- `assets/templates/report.typ` - Report with title page, TOC
- `assets/templates/paper.typ` - Academic two-column paper
- `assets/templates/presentation.typ` - Slide deck

## Workflow

### Document Creation

1. Determine type: report, paper, presentation, or custom
2. Use template or build from scratch:

```typ
#set document(title: "Title", author: "Author")
#set page(paper: "a4", margin: 2.5cm, numbering: "1")
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true)
#set heading(numbering: "1.1")

= Introduction
Content...
```

### Markdown/LaTeX Conversion

Read `references/conversion.md` for complete mappings.

Key differences:
| Markdown/LaTeX | Typst |
|----------------|-------|
| `**bold**` | `*bold*` |
| `*italic*` | `_italic_` |
| `## Heading` | `== Heading` |
| `\frac{a}{b}` | `a/b` |
| `\int` | `integral` |

### Compilation

```bash
python scripts/compile_typst.py input.typ
```

### Visual Debugging

When PDF has layout issues, read `references/debugging.md`.

Quick fixes:
```typ
// Prevent heading orphans
#show heading: it => block(breakable: false, it)

// Force page break before chapters
#show heading.where(level: 1): it => { pagebreak(weak: true); it }

// Keep table together
#show table: set block(breakable: false)
```

## Best Practices

- Use set rules for defaults, show rules for transformations
- Kebab-case for identifiers: `my-variable`
- Labels for cross-references: `<fig:chart>`, `@fig:chart`
- Output files use `.typ` extension
