---
name: typst-copilot
description: Comprehensive Typst copilot for document creation, semantic improvements, markdown conversion, compilation with visual debugging, and expert consultation. Use when working with Typst documents for (1) creating new Typst documents with proper syntax, (2) improving or refactoring Typst code, (3) converting Markdown to Typst, (4) compiling .typ files to PDF and debugging visual issues, (5) answering questions about Typst syntax, functions, or best practices, (6) troubleshooting Typst errors or layout problems.
refs:
  - references/*.md
---

# Typst Copilot

Expert assistant for Typst document creation, editing, conversion, compilation, and consultation.

> **Version**: Based on Typst v0.14.2

## Core Capabilities

1. **Document Creation**: Generate Typst source code for documents, reports, papers, and presentations
2. **Semantic Improvements**: Review and refactor Typst code for better structure and idiomaticity
3. **Markdown Conversion**: Convert Markdown (Extended level) to Typst syntax
4. **Compilation & Visual Debugging**: Compile .typ files and analyze PDFs for page flow and layout issues
5. **Expert Consultation**: Answer questions and provide guidance on Typst best practices

## Typst Modes Overview

Typst has three syntactical modes that you can switch between at any point:

| Mode | Entry Syntax | Purpose |
|------|--------------|---------|
| Markup | Default | Text, headings, lists, emphasis |
| Math | `$...$` | Mathematical formulas |
| Code | `#` prefix | Variables, functions, logic |

## Key Differences from LaTeX

| Feature | LaTeX | Typst |
|---------|-------|-------|
| Bold | `\textbf{text}` | `*text*` |
| Italic | `\textit{text}` | `_text_` |
| Heading | `\section{Title}` | `= Title` |
| Fraction | `\frac{a}{b}` | `a/b` or `frac(a, b)` |
| Function call | `\func{arg}` | `#func(arg)` |
| Set property | preamble commands | `#set func(prop: value)` |

## Available Resources

### Scripts

- `scripts/compile_typst.py`: Compile .typ files to PDF with error handling. Output all PDFs to `./drafts`

### References

- `references/syntax.md`: Markup, math, and code mode syntax with function parameters
- `references/styling.md`: Set rules and show rules for styling
- `references/scripting.md`: Variables, functions, control flow
- `references/math.md`: Mathematical notation and symbols
- `references/layout.md`: Page setup, grids, alignment
- `references/markdown-conversion.md`: Markdown to Typst conversion mappings
- `references/visual-debugging.md`: Page flow and layout issue identification and fixes

### Templates

- `assets/templates/report.typ`: Professional report template with title page, TOC
- `assets/templates/paper.typ`: Academic paper template with two-column layout
- `assets/templates/presentation.typ`: Presentation template with slide structure

## Workflow Guidance

### 1. Document Creation

When user asks for help creating a document:

**Determine document type**:
- Report -> Use `assets/templates/report.typ`
- Academic paper -> Use `assets/templates/paper.typ`
- Presentation -> Use `assets/templates/presentation.typ`
- Custom -> Build from scratch using best practices

**Provide template usage example**:
```typ
#import "templates/report.typ": *

#show: report.with(
  title: "My Report",
  authors: ("Author Name",),
  date: datetime.today().display(),
)

= Introduction
Content here...
```

**Basic document setup pattern**:
```typ
#set document(title: "Document Title", author: "Author Name")
#set page(paper: "a4", margin: 2.5cm, numbering: "1")
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")

= Introduction
Content here...
```

### 2. Semantic Code Improvements

When user provides Typst code for improvement:

**Analyze the code**:
- Identify structure and intent
- Note any non-idiomatic patterns
- Check for opportunities to use built-in functions

**Apply best practices**:
- Use set rules instead of repeated function calls
- Apply show rules for consistent styling
- Utilize proper semantic elements (headings, lists, figures)
- Simplify complex expressions
- Add appropriate spacing and layout functions

**Example pattern to improve**:
```typ
// Before: Repetitive function calls
#text(size: 14pt, weight: "bold")[Heading]
#text(size: 14pt, weight: "bold")[Another Heading]

// After: Use show rule
#show heading: set text(size: 14pt, weight: "bold")
= Heading
= Another Heading
```

### 3. Markdown to Typst Conversion

When user provides Markdown for conversion:

**Consult conversion reference**: Read `references/markdown-conversion.md` for detailed mappings

**Key conversion patterns**:
| Markdown | Typst |
|----------|-------|
| `## Title` | `== Title` |
| `**text**` | `*text*` |
| `*text*` | `_text_` |
| `1. item` | `+ item` |
| `[link](url)` | `#link("url")[link]` |
| `![alt](img)` | `#image("img", alt: "alt")` |
| `> quote` | `#quote[quote]` |
| `$math$` | `$math$` |

**Math symbol differences**:
| LaTeX | Typst |
|-------|-------|
| `\int` | `integral` |
| `\infty` | `infinity` |
| `\frac{a}{b}` | `a/b` |
| `\sqrt{x}` | `sqrt(x)` |

### 4. Compilation Workflow

When user needs to compile Typst documents:

**Compile using script**:
```bash
python scripts/compile_typst.py input.typ [output.pdf]
```

**Common compilation errors and fixes**:
- Unknown function: Check spelling, imports
- Type mismatch: Verify parameter types
- Missing file: Check file paths
- Syntax error: Review syntax in documentation

### 5. Visual Debugging (Page Flow & Layout)

When user reports visual issues or after compilation:

**Consult debugging reference**: Read `references/visual-debugging.md` for comprehensive patterns

**Common fixes**:

Page Break Issues:
```typ
// Prevent heading orphans
#show heading: it => block(breakable: false, it)

// Force page break before chapter
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  it
}
```

Spacing Issues:
```typ
// Consistent heading spacing
#show heading: set block(above: 2em, below: 1em)
```

Layout Issues:
```typ
// Optimize line breaks
#set par(linebreaks: optimized)

// Prevent table breaks
#show table: set block(breakable: false)
```

### 6. Expert Consultation

When user asks questions about Typst:

**Consult comprehensive documentation**: Read relevant reference files

**Common consultation topics**:
- Syntax: How to write specific elements
- Styling: Set rules, show rules, themes
- Layout: Page setup, grids, columns, positioning
- Functions: Parameters, return values, usage
- Math: Notation, symbols, alignment
- Patterns: Templates, custom functions, automation

## Best Practices

### Code Quality
- Use set rules for defaults
- Apply show rules for consistency
- Use semantic elements
- Modular code with functions
- Clear variable names (kebab-case)

### Document Structure
- Logical heading hierarchy
- Consistent spacing
- Cross-references with labels
- Table of contents for longer documents
- Appropriate page numbering

### Typography
- Font pairing for hierarchy
- Appropriate line spacing
- Justification with hyphenation
- Semantic markup
- Clear visual hierarchy

### Layout
- Adequate margins
- Grid systems for complex layouts
- Control page breaks
- Auto placement for figures
- Column gutters for readability

## Common Patterns

### Custom Function
```typ
#let alert(body, color: red) = block(
  fill: color.lighten(80%),
  inset: 1em,
  radius: 0.3em,
  stroke: 2pt + color,
)[#body]
```

### Template Function
```typ
#let article(title: none, authors: (), body) = {
  set document(title: title, author: authors)
  set page(paper: "a4", margin: 2cm, numbering: "1")
  set text(font: "Linux Libertine", size: 11pt)
  set par(justify: true)
  set heading(numbering: "1.1")
  
  align(center)[#text(size: 17pt, weight: "bold", title)]
  if authors.len() > 0 { align(center)[#authors.join(", ")] }
  
  body
}

// Usage
#show: article.with(title: [My Paper], authors: ("Alice", "Bob"))
```

### Conditional Styling
```typ
#show heading.where(level: 1): set text(size: 18pt)
#show heading.where(level: 2): set text(size: 14pt)
```

## Error Handling

Common errors:
1. Function not found: Check imports and spelling
2. Type error: Verify parameter types
3. File not found: Check file paths
4. Syntax error: Review documentation
5. Compilation timeout: Simplify operations

Debugging approach:
1. Read error message carefully
2. Identify line number and context
3. Check documentation for correct usage
4. Simplify code to isolate issue
5. Test incrementally

## Constraints

- **File Extension**: Output files use `.typ` extension
- **Unicode Support**: Typst natively supports Unicode symbols
- **No Packages Required**: Most features are built-in (unlike LaTeX)
- Assume Typst CLI is installed
- Use Python compilation script for reliability

## Notes

- Focus on page flow and layout for visual debugging
- Consult bundled documentation first
- Provide clear, actionable advice with code examples
