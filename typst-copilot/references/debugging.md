# Visual Debugging: Page Flow & Layout

## Page Break Issues

**Heading orphaned at page bottom:**
```typ
#show heading: it => block(breakable: false, it)
```

**Force page break before chapters:**
```typ
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  it
}
```

**Keep content together:**
```typ
#block(breakable: false)[
  = Section
  Must stay with heading.
]
```

## Widow/Orphan Lines

```typ
#set par(linebreaks: optimized)
```

## Figure/Table Placement

**Float placement:**
```typ
#figure(
  placement: auto,  // or: top, bottom
  image("img.png"),
  caption: [Caption],
)
```

**Keep table together:**
```typ
#show table: set block(breakable: false)
```

**Repeating headers for long tables:**
```typ
#table(
  table.header([Col 1], [Col 2]),
  // rows...
)
```

## Spacing Consistency

```typ
#show heading: set block(above: 2em, below: 1em)
#set par(spacing: 1.2em)
#set list(spacing: 0.8em)
```

## Margin Issues

**Standard margins:**
```typ
#set page(margin: (x: 2.5cm, y: 2.5cm))
```

**Binding offset:**
```typ
#set page(margin: (left: 3.5cm, right: 2.5cm, y: 2.5cm))
```

## Column Layout

```typ
#set page(columns: 2, column-gutter: 1em)

// Span across columns
#place(top + center, scope: "parent", float: true)[
  = Full-Width Heading
]
```

## Diagnostic Overlays

**Show element boundaries:**
```typ
#show block: it => box(stroke: blue + 0.5pt, it)
```

**Check measurements:**
```typ
#context [Available: #(page.height - page.margin.top - page.margin.bottom)]
```
