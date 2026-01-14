# Visual Debugging Reference: Page Flow & Layout

Guide for identifying and fixing page flow and layout issues in Typst PDFs.

## Page Flow Issues

### 1. Awkward Page Breaks

**Problem:** Content breaks at inappropriate points, disrupting reading flow.

**Signs:**
- Section headings at bottom of page with no following content
- Single lines isolated from their paragraph (widows/orphans)
- Figures/tables split awkwardly
- Lists broken mid-item

**Solutions:**

**Prevent heading orphans:**
```typ
#show heading: it => {
  block(breakable: false, it)
}
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
  placement: auto,  // Lets Typst decide best placement
)
```

### 2. Widows and Orphans

**Widow:** Last line of paragraph at top of new page
**Orphan:** First line of paragraph at bottom of page

**Visual identification:**
- Single line isolated at page break
- Paragraph starts/ends with minimal text

**Solutions:**

```typ
// Enable optimization
#set par(linebreaks: optimized)

// Prevent breaks in critical content
#block(breakable: false)[
  Critical paragraph that must stay together
]

// Adjust spacing to encourage better breaks
#set par(leading: 0.65em)
```

### 3. Section Breaks

**Problem:** Sections don't start on appropriate pages.

**Solutions:**

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
  // Break to odd page
  let page-num = context counter(page).get().first()
  if calc.even(page-num) {
    pagebreak()
  }
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

**Problem:** Lists break across pages awkwardly, separating items from their context.

**Solutions:**

**Keep short lists together:**
```typ
#block(breakable: false)[
  - Item 1
  - Item 2
  - Item 3
]
```

**Control list spacing to encourage better breaks:**
```typ
#set list(spacing: 1em)
```

### 5. Figure & Table Placement

**Problem:** Figures/tables appear far from their references or break awkwardly.

**Solutions:**

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
#table(
  // Long table content
)
// Headers repeat automatically with table.header()
```

**Landscape orientation for wide tables:**
```typ
#rotate(90deg, reflow: true)[
  #table(
    columns: 10,
    // Many columns
  )
]
```

## Layout Issues

### 1. Margin Problems

**Signs:**
- Content too close to edges
- Inconsistent margins
- Header/footer overlaps with body

**Solutions:**

**Standard academic margins:**
```typ
#set page(margin: (
  left: 2.5cm,
  right: 2.5cm,
  top: 2.5cm,
  bottom: 2.5cm,
))
```

**Binding offset (for printed docs):**
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

**Signs:**
- Uneven spacing between elements
- Headings too close to previous content
- Lists cramped or too spread out

**Solutions:**

**Consistent heading spacing:**
```typ
#show heading: set block(
  above: 2em,
  below: 1em,
)

// Different spacing by level
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

**Signs:**
- Text not aligned to grid
- Mixed alignments within sections
- Figures not centered properly

**Solutions:**

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

**Grid alignment for complex layouts:**
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

**Signs:**
- Unbalanced columns
- Column breaks at wrong places
- Content overflows column

**Solutions:**

**Set column count:**
```typ
#set page(columns: 2)

// Or for specific sections
#columns(2)[
  Content in two columns
]
```

**Column gaps:**
```typ
#set page(
  columns: 2,
  column-gutter: 1em,
)
```

**Span across columns:**
```typ
#set page(columns: 2)

// Full-width heading
#place(
  top + center,
  scope: "parent",
  float: true,
)[
  = Full-Width Heading
]

// Regular two-column content follows
```

### 5. Element Overlap

**Signs:**
- Header/footer overlaps body
- Floating elements cover text
- Margin notes collide

**Solutions:**

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
  clearance: 1em,  // Space around floating element
)[
  Floating content
]
```

### 6. White Space Distribution

**Signs:**
- Large gaps between elements
- Cramped sections
- Inconsistent vertical rhythm

**Solutions:**

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
#block(height: 1fr)  // Pushes following content to bottom
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

### 1. Visual Grid Overlay

Show the underlying grid structure:

```typ
// Temporary debugging
#place(
  line(length: 100%, stroke: (dash: "dashed", paint: red)),
  dy: 0cm,
)
```

### 2. Highlight Page Breaks

Mark where pages break during development:

```typ
#show page: it => {
  place(
    bottom + center,
    text(fill: red, size: 8pt)[Page break here]
  )
  it
}
```

### 3. Show Element Boundaries

```typ
// Debug mode: show all boxes
#show block: it => box(
  stroke: blue + 0.5pt,
  inset: 0pt,
  it,
)
```

### 4. Check Measurements

```typ
#context {
  let page-h = page.height
  let margin-t = page.margin.top
  let margin-b = page.margin.bottom
  let available = page-h - margin-t - margin-b
  
  [Available height: #available]
}
```

## Common Layout Patterns

### 1. Title Page

```typ
#align(center + horizon)[
  #text(size: 24pt, weight: "bold")[
    Document Title
  ]
  
  #v(2em)
  
  #text(size: 14pt)[
    Author Name
  ]
  
  #v(1em)
  
  #text(size: 12pt)[
    #datetime.today().display()
  ]
]

#pagebreak()
```

### 2. Two-Column with Title Spanning

```typ
#set page(columns: 2)

// Title spans both columns
#place(
  top + center,
  scope: "parent",
  float: true,
)[
  = Document Title
  
  Author information
]

// Content flows in columns
#lorem(100)
```

### 3. Academic Paper Layout

```typ
#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  numbering: "1",
)

#set par(
  justify: true,
  leading: 0.65em,
  first-line-indent: 1.8em,
)

#set heading(numbering: "1.1")

// Title
#align(center)[
  #text(size: 17pt, weight: "bold")[Title]
  
  #v(0.5em)
  
  #text(size: 12pt)[Authors]
]

#v(2em)

// Abstract
#align(center)[
  #block(
    width: 80%,
    par(justify: false, first-line-indent: 0em)[
      *Abstract*
      
      #lorem(50)
    ]
  )
]

#v(2em)

// Content
= Introduction
#lorem(100)
```

### 4. Chapter Openings

```typ
#show heading.where(level: 1): it => {
  pagebreak()
  
  v(4em)
  
  block[
    #text(size: 10pt, weight: "regular")[
      CHAPTER #counter(heading).display()
    ]
    
    #v(0.5em)
    
    #text(size: 20pt, weight: "bold")[
      #it.body
    ]
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

## Advanced Techniques

### Conditional Layout

```typ
#let conditional-break(level) = {
  context {
    let loc = here()
    let remaining = page.height - loc.position().y
    
    if remaining < 5cm {
      pagebreak(weak: true)
    }
  }
}

#show heading: it => {
  conditional-break(it.level)
  it
}
```

### Custom Grid Systems

```typ
#let baseline-grid(content) = {
  set par(leading: 0.5em)
  set block(spacing: 1em)
  content
}

#baseline-grid[
  Content aligned to baseline grid
]
```

### Responsive Margins

```typ
#let adaptive-margins(content) = context {
  let page-h = page.height
  let margin = if page-h > 25cm {
    3cm
  } else {
    2cm
  }
  
  set page(margin: margin)
  content
}
```

## Resources

- Page layout principles
- Typography vertical rhythm
- Grid systems
- Print vs digital considerations
- Accessibility in layout
