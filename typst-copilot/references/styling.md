# Typst Styling Reference

Typst uses set rules and show rules for styling documents.

## Set Rules

Set rules apply default property values to all instances of an element within a scope.

### Syntax

```typst
#set element(property: value)
```

### Common Set Rules

```typst
// Text styling
#set text(font: "New Computer Modern", size: 11pt)
#set text(lang: "en", hyphenate: true)

// Paragraph styling
#set par(justify: true, leading: 0.65em, first-line-indent: 1em)

// Page setup
#set page(paper: "a4", margin: 2cm)
#set page(numbering: "1")

// Heading numbering
#set heading(numbering: "1.1")

// List styling
#set list(marker: [*])
#set enum(numbering: "1.a)")
```

### Scoped Set Rules

```typst
// Apply only within block
#[
  #set text(fill: blue)
  This text is blue.
]
This text is default color.
```

## Show Rules

Show rules transform how elements are displayed. Unlike set rules which configure properties, show rules can completely redefine an element's appearance.

### Basic Show Rule

```typst
// Transform all headings
#show heading: it => {
  set text(fill: blue)
  it
}

// Transform specific text
#show "typst": [*Typst*]
```

### Show-Set Rule

A shorthand that combines show rules with set rules:

```typst
#show heading: set text(fill: navy)
#show raw: set text(font: "Fira Code")
```

### Show with Function

```typst
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  set text(size: 18pt)
  block(it.body)
}
```

### Selector Types

| Selector | Example |
|----------|---------|
| Element | `#show heading: ...` |
| Text | `#show "word": ...` |
| Regex | `#show regex("\d+"): ...` |
| Label | `#show <label>: ...` |
| Where | `#show heading.where(level: 1): ...` |

### Element Fields

- `it.body`: Main content
- `it.numbering`: Numbering pattern
- `it.level`: Heading level
- `it.caption`: Figure caption
- Function-specific fields match parameters

## Function Parameters

### `text` Function

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `font` | str \| array | `"libertinus serif"` | Font family or priority list |
| `size` | length | `11pt` | Font size |
| `fill` | color | `black` | Text color |
| `weight` | int \| str | `"regular"` | `"thin"`, `"light"`, `"regular"`, `"medium"`, `"bold"`, or 100-900 |
| `style` | str | `"normal"` | `"normal"`, `"italic"`, `"oblique"` |
| `lang` | str | `"en"` | Language code |
| `region` | str \| none | `none` | Region code |
| `hyphenate` | auto \| bool | `auto` | Enable hyphenation |
| `tracking` | length | `0pt` | Letter spacing |
| `spacing` | relative | `100%` | Word spacing |
| `baseline` | length | `0pt` | Baseline shift |

### `par` Function

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `leading` | length | `0.65em` | Line spacing |
| `spacing` | length | `1.2em` | Paragraph spacing |
| `justify` | bool | `false` | Justify text |
| `linebreaks` | auto \| str | `auto` | `"simple"`, `"optimized"` |
| `first-line-indent` | length | `0pt` | First line indentation |
| `hanging-indent` | length | `0pt` | Hanging indent |

### `block` Function

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | auto \| relative | `auto` | Block width |
| `height` | auto \| relative | `auto` | Block height |
| `fill` | none \| color | `none` | Background color |
| `stroke` | none \| stroke | `none` | Border stroke |
| `radius` | relative \| dict | `(:)` | Corner radius |
| `inset` | relative \| dict | `(:)` | Inner padding |
| `spacing` | relative | `1.2em` | Spacing around block |
| `above` | auto \| relative | `auto` | Spacing above |
| `below` | auto \| relative | `auto` | Spacing below |
| `breakable` | bool | `true` | Allow page breaks |
| `clip` | bool | `false` | Clip overflow content |

## Document Setup Pattern

```typst
#set document(
  title: "Document Title",
  author: "Author Name",
)

#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 3cm),
  header: [
    #set text(8pt)
    Document Title
    #h(1fr)
    #context counter(page).display()
  ],
)

#set text(
  font: "Noto Sans",
  size: 10pt,
  lang: "en",
)

#set par(
  justify: true,
  leading: 0.8em,
)

#set heading(numbering: "1.1")
#show heading.where(level: 1): set text(size: 16pt)
#show heading.where(level: 2): set text(size: 14pt)
```

## LaTeX-like Styling

```typst
#set page(margin: 1.75in)
#set par(
  leading: 0.55em,
  spacing: 0.55em,
  first-line-indent: 1.8em,
  justify: true,
)
#set text(font: "New Computer Modern")
#show raw: set text(font: "New Computer Modern Mono")
#show heading: set block(above: 1.4em, below: 1em)
```

## Typography Best Practices

### Font Pairing

**Academic:**
```typst
#set text(font: ("Linux Libertine", "Georgia"))
#show heading: set text(font: ("Linux Biolinum", "Arial"))
```

**Modern:**
```typst
#set text(font: ("Inter", "Helvetica"))
```

**Classic:**
```typst
#set text(font: ("New Computer Modern", "Times"))
```

### Line Spacing

```typst
// Single spacing
#set par(leading: 0.65em)

// 1.5 spacing
#set par(leading: 1em)

// Double spacing
#set par(leading: 1.3em)
```

### Hierarchy

```typst
#show heading.where(level: 1): set text(size: 18pt)
#show heading.where(level: 2): set text(size: 14pt)
#show heading.where(level: 3): set text(size: 12pt, style: "italic")
```

## Common Issues & Solutions

### Overfull Lines

```typst
#set text(hyphenate: true)
#set text(tracking: -0.01em)
#set text(overhang: true)
```

### Inconsistent Spacing

```typst
#show heading: set block(above: 2em, below: 1em)
#set par(spacing: 1.2em)
```
