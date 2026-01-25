# Visual Debugging Reference: Page Flow & Layout

Guide for identifying and fixing page flow and layout issues in Typst PDFs.

## Page Flow Issues

### 1. Awkward Page Breaks

**Signs:**
- Section headings at bottom of page with no following content
- Single lines isolated from their paragraph (widows/orphans)
- Figures/tables split awkwardly
- Lists broken mid-item

**Solutions:**

**Prevent heading orphans:**
```typ
#show heading: it => block(breakable: false, it)
```

**Keep content together:**
```typ
#block(breakable: false)[
  = Section Title
  Introductory paragraph that must stay with heading.
]
```

**Control widow/orphan lines:**
```typ
#set par(linebreaks: optimized)
```

**Force page break before heading:**
```typ
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  it
}
```

**Smart figure placement:**
```typ
#figure(
  image("chart.png"),
  caption: [Chart],
  placement: auto,
)
```

### 2. Widows and Orphans

**Widow:** Last line of paragraph at top of new page  
**Orphan:** First line of paragraph at bottom of page

**Solutions:**
```typ
#set par(linebreaks: optimized)

#block(breakable: false)[
  Critical paragraph that must stay together
]

#set par(leading: 0.65em)
```

### 3. Section Breaks

**Always start chapters on new page:**
```typ
#show heading.where(level: 1): it => {
  pagebreak()
  it
}
```

**Start chapters on odd (right) pages:**
```typ
#show heading.where(level: 1): it => {
  let page-num = context counter(page).get().first()
  if calc.even(page-num) { pagebreak() }
  pagebreak()
  it
}
```

**Weak page breaks (only if needed):**
```typ
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  it
}
```

### 4. List Fragmentation

**Keep short lists together:**
```typ
#block(breakable: false)[
  - Item 1
  - Item 2
  - Item 3
]
```

**Control list spacing:**
```typ
#set list(spacing: 1em)
```

### 5. Figure & Table Placement

**Use float placement:**
```typ
#figure(
  placement: auto,  // or: top, bottom
  image("chart.png"),
  caption: [Chart],
)
```

**Keep tables together:**
```typ
#show table: set block(breakable: false)
```

**Allow table breaking for long tables:**
```typ
// Headers repeat automatically with table.header()
#table(
  table.header([Col 1], [Col 2]),
  // Long table content
)
```

**Landscape orientation for wide tables:**
```typ
#rotate(90deg, reflow: true)[
  #table(columns: 10, ...)
]
```

## Layout Issues

### 1. Margin Problems

**Standard academic margins:**
```typ
#set page(margin: (
  left: 2.5cm,
  right: 2.5cm,
  top: 2.5cm,
  bottom: 2.5cm,
))
```

**Binding offset:**
```typ
#set page(margin: (
  left: 3.5cm,    // Extra space for binding
  right: 2.5cm,
  top: 2.5cm,
  bottom: 2.5cm,
))
```

**Different margins for odd/even pages:**
```typ
#set page(margin: context {
  let page-num = counter(page).get().first()
  if calc.even(page-num) {
    (inside: 3.5cm, outside: 2.5cm, y: 2.5cm)
  } else {
    (inside: 2.5cm, outside: 3.5cm, y: 2.5cm)
  }
})
```

### 2. Spacing Inconsistencies

**Consistent heading spacing:**
```typ
#show heading: set block(above: 2em, below: 1em)

#show heading.where(level: 1): set block(above: 3em, below: 1.5em)
#show heading.where(level: 2): set block(above: 2em, below: 1em)
```

**Paragraph spacing:**
```typ
#set par(spacing: 1.2em)
```

**Block element spacing:**
```typ
#set block(spacing: 1em)
```

**List spacing:**
```typ
#set list(spacing: 0.8em, tight: false)
#set enum(spacing: 0.8em, tight: false)
```

### 3. Alignment Problems

**Justify paragraphs:**
```typ
#set par(justify: true)
```

**Center figures:**
```typ
#figure(
  align(center, image("chart.png")),
  caption: [Centered figure],
)
```

**Align headings:**
```typ
#show heading.where(level: 1): set align(center)
```

**Grid alignment:**
```typ
#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: (left, right),
  [Left column],
  [Right column],
)
```

### 4. Column Layout Issues

**Set column count:**
```typ
#set page(columns: 2)

#columns(2)[
  Content in two columns
]
```

**Column gaps:**
```typ
#set page(columns: 2, column-gutter: 1em)
```

**Span across columns:**
```typ
#set page(columns: 2)

#place(
  top + center,
  scope: "parent",
  float: true,
)[
  = Full-Width Heading
]
```

### 5. Element Overlap

**Adjust header/footer placement:**
```typ
#set page(
  header-ascent: 30%,
  footer-descent: 30%,
)
```

**Control float placement:**
```typ
#place(
  top + right,
  float: true,
  clearance: 1em,
)[
  Floating content
]
```

### 6. White Space Distribution

**Establish vertical rhythm:**
```typ
#let base-size = 12pt
#let line-height = 1.5

#set text(size: base-size)
#set par(leading: line-height * base-size - base-size)
#set block(spacing: line-height * base-size)
```

**Fill remaining space:**
```typ
#block(height: 1fr)  // Pushes content to bottom
```

**Distribute space in grid:**
```typ
#grid(
  rows: (auto, 1fr, auto),
  [Header],
  [Content (fills available space)],
  [Footer],
)
```

## Diagnostic Techniques

### Visual Grid Overlay

```typ
#place(
  line(length: 100%, stroke: (dash: "dashed", paint: red)),
  dy: 0cm,
)
```

### Show Element Boundaries

```typ
#show block: it => box(stroke: blue + 0.5pt, inset: 0pt, it)
```

### Check Measurements

```typ
#context {
  let page-h = page.height
  let margin-t = page.margin.top
  let available = page-h - margin-t - page.margin.bottom
  [Available height: #available]
}
```

## Common Layout Patterns

### Title Page

```typ
#align(center + horizon)[
  #text(size: 24pt, weight: "bold")[Document Title]
  #v(2em)
  #text(size: 14pt)[Author Name]
  #v(1em)
  #text(size: 12pt)[#datetime.today().display()]
]

#pagebreak()
```

### Chapter Openings

```typ
#show heading.where(level: 1): it => {
  pagebreak()
  v(4em)
  block[
    #text(size: 10pt)[CHAPTER #counter(heading).display()]
    #v(0.5em)
    #text(size: 20pt, weight: "bold")[#it.body]
  ]
  v(2em)
}
```

## Quick Fixes Checklist

When reviewing compiled PDF:

- [ ] No headings orphaned at page bottom
- [ ] No single-line widows/orphans
- [ ] Figures placed near references
- [ ] Tables don't break awkwardly
- [ ] Consistent spacing between sections
- [ ] Margins look balanced
- [ ] Headers/footers don't overlap body
- [ ] Column layout is balanced
- [ ] Lists don't fragment awkwardly
- [ ] Page numbers in correct position
- [ ] No overlapping elements
- [ ] White space distributed evenly
