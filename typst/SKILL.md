---
name: typst
description: Comprehensive Typst copilot for semantic improvements, markdown conversion, compilation with visual debugging, and expert consultation. Use when working with Typst documents for (1) improving or refactoring Typst code, (2) converting Markdown to Typst, (3) compiling .typ files to PDF and debugging visual issues, (4) answering questions about Typst syntax, functions, or best practices, (5) creating or styling Typst documents, (6) troubleshooting Typst errors or layout problems.
refs:
  - references/*.md
---

# Typst Copilot

Expert assistant for Typst document creation, editing, conversion, compilation, and consultation.

## Core Capabilities

1. **Semantic Improvements**: Review and refactor Typst code for better structure and idiomaticity
2. **Markdown Conversion**: Convert Markdown (Extended level) to Typst syntax
3. **Compilation & Visual Debugging**: Compile .typ files and analyze PDFs for page flow and layout issues
4. **Expert Consultation**: Answer questions and provide guidance on Typst best practices

## Available Resources

### Scripts

- `scripts/compile_typst.py`: Compile .typ files to PDF with error handling. Output all pdfs to `./drafts`

### References

- `references/typst-docs.md`: Comprehensive Typst syntax and function reference
- `references/markdown-conversion.md`: Markdown to Typst conversion mappings
- `references/visual-debugging.md`: Page flow and layout issue identification and fixes
- `references/threat-model-outline.md`: Section definitions for threat actor threat modeling

### Templates

- `assets/templates/report.typ`: Professional report template with title page, TOC
- `assets/templates/paper.typ`: Academic paper template with two-column layout
- `assets/templates/presentation.typ`: Presentation template with slide structure

## Workflow Guidance

### 1. Semantic Code Improvements

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

**Explain improvements**:
- Describe what was changed and why
- Reference Typst best practices
- Suggest additional enhancements if applicable

Example pattern to improve:
```typ
// Before: Repetitive function calls
#text(size: 14pt, weight: "bold")[Heading]
#text(size: 14pt, weight: "bold")[Another Heading]

// After: Use show rule
#show heading: set text(size: 14pt, weight: "bold")
= Heading
= Another Heading
```

### 2. Markdown to Typst Conversion

When user provides Markdown for conversion:

**Consult conversion reference**: Read `references/markdown-conversion.md` for detailed mappings

**Parse Markdown structure**:
- Identify headers, lists, code blocks, tables, etc.
- Note nesting and hierarchy

**Convert systematically**:
- Headers: `#` → `=`
- Lists: maintain `-` for unordered, convert `1.` to `+` for ordered
- Code blocks: preserve language identifiers
- Tables: convert to `#table()` function
- Images: convert to `#image()` or `#figure()`
- Math: convert LaTeX syntax to Typst math

**Key conversion patterns**:
- `## Title` → `== Title`
- `**text**` → `*text*`
- `*text*` → `_text_`
- `1. item` → `+ item`
- <code>\`\`\`lang</code> → <code>\`\`\`lang</code>

### 3. Compilation Workflow

When user needs to compile Typst documents:

**Compile using script**:
```bash
python scripts/compile_typst.py input.typ [output.pdf]
```

**Handle errors**:
- Analyze error message
- Provide specific fixes for common errors
- Suggest consulting documentation if needed

**Common compilation errors and fixes**:
- Unknown function: Check spelling, imports
- Type mismatch: Verify parameter types
- Missing file: Check file paths
- Syntax error: Review syntax in documentation

### 4. Visual Debugging (Page Flow & Layout)

When user reports visual issues or after compilation:

**Consult debugging reference**: Read `references/visual-debugging.md` for comprehensive patterns

**Identify issue category**:
- Page flow: Awkward breaks, widows/orphans, section breaks
- Layout: Margins, spacing, alignment, columns, overlap

**Apply targeted fixes**:

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

### 5. Expert Consultation

When user asks questions about Typst:

**Consult comprehensive documentation**: Read `references/typst-docs.md` for syntax, functions, and patterns

**Provide accurate answers**:
- Reference specific functions and parameters
- Show code examples
- Explain concepts clearly

**Common consultation topics**:
- Syntax: How to write specific elements
- Styling: Set rules, show rules, themes
- Layout: Page setup, grids, columns, positioning
- Functions: Parameters, return values, usage
- Patterns: Templates, custom functions, automation
- Troubleshooting: Error messages, unexpected behavior

### 6. Document Creation

When user asks for help creating a document:

**Determine document type**:
- Report → Use `assets/templates/report.typ`
- Academic paper → Use `assets/templates/paper.typ`
- Presentation → Use `assets/templates/presentation.typ`
- Custom → Build from scratch using best practices

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

Custom Functions:
```typ
#let alert(body, color: red) = block(
  fill: color.lighten(80%),
  inset: 1em,
  radius: 0.3em,
  stroke: 2pt + color,
)[#body]
```

Conditional Styling:
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

## Notes

- Assume Typst CLI is installed
- Use Python compilation script for reliability
- Focus on page flow and layout for visual debugging
- Consult bundled documentation first
- Provide clear, actionable advice with code examples
