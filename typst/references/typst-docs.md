# Typst Comprehensive Reference

Complete reference for Typst syntax, functions, styling, and best practices.

## Syntax Overview

### Modes

Typst has three syntactical modes:

| Mode | Syntax | Example |
|------|--------|---------|
| Code | Prefix with `#` | `#(1 + 2)` |
| Math | `$...$` | `$x^2$` |
| Markup | `[..]` | `[*bold*]` |

### Markup Elements

| Element | Syntax | Function |
|---------|--------|----------|
| Paragraph break | Blank line | `parbreak` |
| Strong | `*text*` | `strong` |
| Emphasis | `_text_` | `emph` |
| Raw/code | `` `code` `` | `raw` |
| Link | `https://url` | `link` |
| Label | `<name>` | `label` |
| Reference | `@name` | `ref` |
| Heading | `= Title` | `heading` |
| List | `- item` | `list` |
| Enum | `+ item` | `enum` |
| Terms | `/ Term: desc` | `terms` |
| Math | `$x^2$` | — |
| Linebreak | `\` | `linebreak` |
| Smart quotes | `'text'` or `"text"` | `smartquote` |
| Non-breaking space | `~` | — |
| Em dash | `---` | — |
| Comment | `//` or `/* */` | — |

### Math Mode

| Element | Syntax | Function |
|---------|--------|----------|
| Inline | `$x^2$` | — |
| Block | `$ x^2 $` | — |
| Subscript | `x_1` | `attach` |
| Superscript | `x^2` | `attach` |
| Fraction | `(a+b)/5` | `frac` |
| Linebreak | `\` | `linebreak` |
| Alignment | `&=` | — |
| Code | `#x` | — |
| Symbol | `pi`, `arrow.r.long` | — |
| Spacing | `x y` | — |
| Text | `"is natural"` | — |

### Code Mode

| Element | Syntax | Type |
|---------|--------|------|
| None | `none` | `none` |
| Auto | `auto` | `auto` |
| Boolean | `true`, `false` | `bool` |
| Integer | `10`, `0xff` | `int` |
| Float | `3.14`, `1e5` | `float` |
| Length | `2pt`, `3mm`, `1em` | `length` |
| Angle | `90deg`, `1rad` | `angle` |
| Fraction | `2fr` | `fraction` |
| Ratio | `50%` | `ratio` |
| String | `"text"` | `str` |
| Label | `<name>` | `label` |
| Content block | `[*text*]` | `content` |
| Code block | `{ code }` | — |
| Parentheses | `(expr)` | — |
| Array | `(1, 2, 3)` | `array` |
| Dictionary | `(a: 1, b: 2)` | `dictionary` |
| Function call | `func(x, y)` | — |
| Method call | `x.method()` | — |
| Field access | `x.field` | — |

### Identifiers

- Can contain letters, numbers, hyphens (`-`), underscores (`_`)
- Must start with letter or underscore
- Kebab-case recommended: `my-variable`
- Examples: `my-func`, `_internal`, `π`

### Escape Sequences

- Escape character: `\#`, `\$`, `\\`
- Unicode: `\u{1f600}` → 😀
- Works in markup and strings

### Paths

**Relative path** (from current file):
```typ
#image("images/logo.png")
```

**Absolute path** (from project root):
```typ
#image("/assets/logo.png")
```

**Notes:**
- Cannot read files outside project root
- Package paths relative to package root

## Styling System

### Set Rules

Configure default properties for elements:

```typ
#set text(font: "New Computer Modern", size: 12pt)
#set heading(numbering: "1.")
#set par(justify: true, leading: 0.65em)
#set page(margin: 2.5cm, numbering: "1")
```

**Key functions for set rules:**
- `text`: Font, size, color, weight, style
- `page`: Size, margins, columns, numbering, header, footer
- `par`: Justification, leading, spacing, first-line-indent
- `heading`: Numbering, outlined
- `document`: Title, author, keywords (PDF metadata)
- `block`: Spacing, breakable
- `list`, `enum`, `terms`: Indent, marker, numbering

**Scope:** Set rules apply until end of current block or file.

### Show Rules

Transform element appearance completely:

**Show-set rule** (configure appearance):
```typ
#show heading: set text(blue)
#show heading.where(level: 1): set align(center)
```

**Transformational show rule** (complete customization):
```typ
#show heading: it => {
  set text(font: "Inria Serif")
  block[
    #counter(heading).display(it.numbering)
    #h(0.5em)
    #emph(it.body)
  ]
}
```

**Show rule selectors:**
- Everything: `show: rest => ..`
- Text: `show "word": ..`
- Regex: `show regex("\w+"): ..`
- Function: `show heading: ..`
- With fields: `show heading.where(level: 1): ..`

**Element fields:**
- `it.body`: Main content
- `it.numbering`: Numbering pattern
- `it.level`: Heading level
- `it.caption`: Figure caption
- Function-specific fields match parameters

## Layout Functions

### Page

```typ
#set page(
  width: 21cm,
  height: 29.7cm,
  margin: (x: 2.5cm, y: 2cm),
  columns: 2,
  numbering: "1 / 1",
  number-align: center + bottom,
  header: align(right, [My Document]),
  footer: context counter(page).display("i"),
)
```

### Grid

```typ
#grid(
  columns: (1fr, auto, 2fr),
  rows: (auto, 1fr),
  gutter: 1em,
  column-gutter: 2em,
  row-gutter: 0.5em,
  align: horizon,
  fill: (x, y) => if calc.odd(x + y) { gray },
  stroke: 1pt,
  [A], [B], [C],
  [D], [E], [F],
)
```

**Track sizing:**
- `auto`: Fit content
- `1fr`: Fractional
- `50%`: Percentage
- `10cm`: Fixed length
- Array: Per-column/row sizes

### Table

```typ
#table(
  columns: (auto, 1fr, 1fr),
  inset: 10pt,
  align: horizon,
  stroke: (x, y) => if y == 0 { (bottom: 2pt) },
  table.header(
    [], [*Column 1*], [*Column 2*],
  ),
  [Row 1], [Data], [Data],
  [Row 2], [Data], [Data],
)
```

**Differences from grid:**
- Default stroke and inset
- Semantic (for data)
- Accessibility metadata
- `table.header()` and `table.footer()` for repeating rows

### Figure

```typ
#figure(
  image("photo.jpg", width: 80%),
  caption: [Caption text],
  placement: auto,
  kind: image,
  supplement: [Figure],
) <fig:label>

// Reference
See @fig:label for details.
```

### Align

```typ
#align(center, [Centered])
#align(right, [Right-aligned])
#align(center + horizon, [Centered vertically & horizontally])
```

### Block

```typ
#block(
  width: 100%,
  height: 5cm,
  fill: silver,
  inset: 1em,
  radius: 0.5em,
  stroke: 1pt,
  spacing: 1em,  // Space before/after
  above: 2em,    // Space above only
  below: 1em,    // Space below only
  breakable: true,
)[Content]
```

### Box

```typ
#box(
  width: 2cm,
  height: 1cm,
  fill: blue,
  inset: 5pt,
  radius: 3pt,
  stroke: 1pt + black,
)[Inline box]
```

### Columns

```typ
#columns(2, [
  Multi-column content flows automatically.
  #lorem(50)
])

// Or via page:
#set page(columns: 2)
```

### Place

```typ
// Absolute positioning
#place(
  top + right,
  dx: -1cm,
  dy: 1cm,
  rect(fill: red, width: 2cm, height: 1cm),
)

// Floating
#place(
  top + center,
  float: true,
  figure(image("chart.png"), caption: [Chart]),
)
```

### Layout

Access container dimensions:

```typ
#layout(size => {
  let width = size.width
  let height = size.height
  [Width: #width, Height: #height]
})
```

## Text & Typography

### Text Function

```typ
#set text(
  font: ("Linux Libertine", "Noto Sans"),
  size: 11pt,
  weight: "regular",  // or "bold", "semibold", etc.
  style: "normal",    // or "italic", "oblique"
  fill: black,
  stroke: none,
  tracking: 0pt,
  spacing: 100%,
  baseline: 0pt,
  overhang: true,
  top-edge: "cap-height",
  bottom-edge: "baseline",
  lang: "en",
  region: "US",
  hyphenate: true,
  kerning: true,
  ligatures: true,
)
```

### Paragraph

```typ
#set par(
  justify: false,
  leading: 0.65em,
  spacing: 1.2em,
  first-line-indent: 1.8em,
  hanging-indent: 0em,
  linebreaks: auto,
)
```

### Heading

```typ
#set heading(
  numbering: "1.1",
  supplement: [Section],
  outlined: true,
  bookmarked: true,
  hanging-indent: 0pt,
)

= Level 1
== Level 2
=== Level 3
```

### List & Enum

```typ
#set list(
  indent: 0.5em,
  body-indent: 0.5em,
  marker: ([•], [◦], [‣]),
  spacing: auto,
  tight: true,
)

#set enum(
  numbering: "1.a)",
  indent: 0.5em,
  body-indent: 0.5em,
  spacing: auto,
  tight: true,
  full: false,
  start: 1,
)
```

## Content Elements

### Image

```typ
#image(
  "photo.jpg",
  width: 80%,
  height: auto,
  alt: "Description",
  fit: "contain",  // or "cover", "stretch"
)
```

### Raw (Code Blocks)

```typ
// Inline
`code`

// Block
```rust
fn main() {
    println!("Hello");
}
\```

// Programmatic
#raw("code", lang: "python", block: true)
```

### Link

```typ
https://typst.app

#link("https://typst.app")[Typst]

#link("mailto:hello@typst.app")
```

### Quote & Cite

```typ
#quote(
  block: true,
  attribution: [Author],
)[Quoted text]

// Citations
#bibliography("refs.bib")

In the text @citation-key.
```

### Line & Shape

```typ
#line(length: 100%, stroke: 1pt)

#rect(width: 5cm, height: 3cm, fill: blue, radius: 5pt)

#circle(radius: 1cm, fill: red)

#ellipse(width: 4cm, height: 2cm, stroke: 2pt)

#polygon((0%, 0%), (50%, 100%), (100%, 0%))

#path(
  fill: green,
  ((0cm, 0cm), (1cm, 1cm), (2cm, 0cm)),
)
```

## Scripting

### Variables

```typ
#let x = 5
#let name = "Alice"
#let items = (1, 2, 3)
#let dict = (a: 1, b: 2)
```

### Functions

```typ
#let greet(name) = [Hello #name!]
#greet("World")

// With parameters
#let styled-text(..args, color: blue) = {
  text(fill: color, ..args)
}
```

### Conditionals

```typ
#if condition {
  [True case]
} else if other {
  [Other case]
} else {
  [False case]
}
```

### Loops

```typ
#for item in (1, 2, 3) {
  [Item: #item]
}

#while counter < 10 {
  [#counter]
  counter += 1
}
```

### Arrays

```typ
#let arr = (1, 2, 3)
#arr.at(0)        // 1
#arr.len()        // 3
#arr.push(4)      // Mutates array
#arr.pop()        // Returns and removes last
#arr.first()      // 1
#arr.last()       // 3
#arr.slice(1, 3)  // (2, 3)
#arr.join(", ")   // "1, 2, 3"
```

### Dictionaries

```typ
#let dict = (name: "Alice", age: 30)
#dict.name          // "Alice"
#dict.at("age")     // 30
#dict.keys()        // ("name", "age")
#dict.values()      // ("Alice", 30)
#dict.insert("city", "NYC")
```

### Context

Access document state:

```typ
#context {
  let page-num = counter(page).get()
  let heading-num = counter(heading).get()
  [Page #page-num.first()]
}
```

### Modules

```typ
// Import all
#import "utils.typ": *

// Selective import
#import "utils.typ": func1, func2

// Namespace import
#import "utils.typ" as utils
#utils.func1()

// Include (render content)
#include "chapter1.typ"
```

## Counters & State

### Counter

```typ
#let my-counter = counter("mycounter")

// Display
#context my-counter.display()

// Display with pattern
#context my-counter.display("1.1")

// Get value
#context my-counter.get()

// Step (increment)
#my-counter.step()

// Step by amount
#my-counter.step(5)

// Update to specific value
#my-counter.update(10)

// Update with function
#my-counter.update(n => n * 2)
```

### State

```typ
#let my-state = state("mystate", 0)

// Display
#context my-state.display()

// Get value
#context my-state.get()

// Update
#my-state.update(5)
#my-state.update(x => x + 1)
```

## Common Patterns

### Custom Function

```typ
#let alert(body, color: red) = {
  set text(fill: color, weight: "bold")
  block(
    fill: color.lighten(80%),
    inset: 1em,
    radius: 0.3em,
    stroke: 2pt + color,
  )[#body]
}

#alert[Important message!]
```

### Template Function

```typ
#let article(
  title: none,
  authors: (),
  abstract: none,
  body,
) = {
  set document(title: title, author: authors)
  set page(
    paper: "a4",
    margin: (x: 2cm, y: 2.5cm),
    numbering: "1",
  )
  set text(font: "Linux Libertine", size: 11pt)
  set par(justify: true)
  
  // Title
  align(center)[
    #block(text(size: 17pt, weight: "bold", title))
  ]
  
  // Authors
  pad(
    top: 0.5em,
    bottom: 0.5em,
    align(center)[
      #authors.join(", ")
    ],
  )
  
  // Abstract
  if abstract != none {
    set par(justify: false)
    set block(spacing: 1em)
    pad(
      x: 3cm,
      align(center)[
        *Abstract* \
        #abstract
      ],
    )
  }
  
  // Body
  set heading(numbering: "1.1")
  body
}

// Usage
#show: article.with(
  title: [My Paper],
  authors: ("Alice", "Bob"),
  abstract: [Summary here],
)

= Introduction
...
```

### Run-in Heading

```typ
#show heading.where(level: 2): it => {
  text(weight: "bold", it.body)
  [. ]
}

== Subsection
Content continues inline.
```

### Custom Numbering

```typ
#set heading(numbering: (..nums) => {
  let vals = nums.pos()
  if vals.len() == 1 {
    numbering("I", ..vals)
  } else {
    numbering("1.a", ..vals)
  }
})
```

## Page Layout Best Practices

### Margins

Standard margins:
- Academic: 2.5cm all sides
- Business: 2.5cm (1 inch) all sides
- Thesis: Larger left margin for binding

```typ
#set page(margin: (
  left: 3.5cm,
  right: 2.5cm,
  top: 2.5cm,
  bottom: 2.5cm,
))
```

### Line Spacing

```typ
// Single spacing
#set par(leading: 0.65em)

// 1.5 spacing
#set par(leading: 1em)

// Double spacing
#set par(leading: 1.3em)
```

### Widow & Orphan Control

```typ
#set par(linebreaks: optimized)

// For critical text
#block(breakable: false)[
  Text that must stay together
]
```

### Page Breaks

```typ
// Force page break
#pagebreak()

// Conditional page break (if weak)
#pagebreak(weak: true)

// Avoid break within
#block(breakable: false)[Content]
```

### Headers & Footers

```typ
#set page(
  header: locate(loc => {
    let page-num = counter(page).at(loc).first()
    if calc.even(page-num) {
      align(left)[Chapter Title]
    } else {
      align(right)[Section Title]
    }
  }),
  footer: context {
    let page-num = counter(page).get().first()
    align(center)[Page #page-num]
  },
)
```

## Typography Best Practices

### Font Pairing

**Academic:**
```typ
#set text(font: ("Linux Libertine", "Georgia"))
#set heading(font: ("Linux Biolinum", "Arial"))
```

**Modern:**
```typ
#set text(font: ("Inter", "Helvetica"))
#set heading(font: ("Inter", "Helvetica"))
```

**Classic:**
```typ
#set text(font: ("New Computer Modern", "Times"))
#set heading(font: ("New Computer Modern Bold", "Times"))
```

### Hierarchy

```typ
#show heading.where(level: 1): set text(size: 18pt)
#show heading.where(level: 2): set text(size: 14pt)
#show heading.where(level: 3): set text(size: 12pt, style: "italic")
```

### Emphasis

```typ
// Semantic emphasis
#emph[emphasized]
_emphasized_

// Strong importance
#strong[important]
*important*

// Small caps for acronyms
#smallcaps[usa]
```

## Common Issues & Solutions

### Overfull Lines

```typ
// Enable hyphenation
#set text(hyphenate: true)

// Adjust tracking slightly
#set text(tracking: -0.01em)

// Use microtype-like features
#set text(overhang: true)
```

### Figures Not Positioned Well

```typ
// Let Typst place figures
#figure(
  image("chart.png"),
  caption: [Chart],
  placement: auto,
)

// Or force top placement
#figure(
  placement: top,
  ...
)
```

### Table Overflows Page

```typ
// Enable table breaking
#show table: set block(breakable: true)

// Or rotate for landscape
#rotate(90deg, reflow: true)[
  #table(...)
]
```

### Inconsistent Spacing

```typ
// Use block spacing
#show heading: set block(above: 2em, below: 1em)

// Consistent paragraph spacing
#set par(spacing: 1.2em)
```

## References

- Official Documentation: https://typst.app/docs
- Tutorial: https://typst.app/docs/tutorial
- Reference: https://typst.app/docs/reference
- Community: https://forum.typst.app
- GitHub: https://github.com/typst/typst
- Package Repository: https://typst.app/universe
