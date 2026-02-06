# Typst Layout Reference

## Page Setup

```typ
#set page(
  paper: "a4",  // or "us-letter", "a5"
  margin: (x: 2cm, y: 3cm),
  columns: 1,
  numbering: "1",
  number-align: center + bottom,
  header: [...],
  footer: [...],
)
```

### Headers/Footers
```typ
#set page(
  header: context [
    Document Title
    #h(1fr)
    #counter(page).display()
  ],
)
```

## Spacing

```typ
#h(1cm)    // horizontal fixed
#h(1fr)    // horizontal flex (fills space)
#v(1cm)    // vertical fixed
#v(1fr)    // vertical flex
```

## Alignment

```typ
#align(center)[Centered]
#align(right)[Right]
#align(center + horizon)[Centered both axes]
```

## Blocks and Boxes

```typ
// Block (breaks across pages by default)
#block(
  width: 100%,
  fill: luma(230),
  inset: 1em,
  radius: 4pt,
)[Content]

// Box (inline, no breaking)
#box(fill: yellow, inset: 4pt)[Inline]
```

## Grid

```typ
#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [Col 1], [Col 2],
)

// Varying widths
#grid(
  columns: (auto, 1fr, 2fr),
  [...], [...], [...],
)
```

## Tables

```typ
#table(
  columns: 3,
  inset: 10pt,
  align: horizon,
  fill: (x, y) => if y == 0 { luma(230) },
  table.header([*A*], [*B*], [*C*]),
  [1], [2], [3],
)

// Spanning
table.cell(colspan: 2)[Spans 2]
table.cell(rowspan: 2)[Spans 2 rows]
```

### `table` Parameters
`columns`, `rows`, `fill`, `align`, `stroke` (default: `1pt + black`), `inset` (default: `5pt`)

## Figures

```typ
#figure(
  image("img.png", width: 80%),
  caption: [Description],
  placement: auto,  // or: top, bottom, none
) <fig:label>

// Reference: @fig:label
```

### `image` Parameters
`path`, `width`, `height`, `alt`, `fit` ("cover", "contain", "stretch")

## Columns

```typ
#set page(columns: 2)

// Or inline
#columns(2, gutter: 1em)[
  First column.
  #colbreak()
  Second column.
]
```

## Positioning

```typ
// Absolute
#place(top + right, dx: -1cm, dy: 1cm)[Positioned]

// Relative shift
#move(dx: 5pt, dy: -3pt)[Shifted]
```

## Transforms

```typ
#rotate(45deg)[Rotated]
#scale(x: 150%)[Scaled]
```

## Page Breaks

```typ
#pagebreak()           // force
#pagebreak(weak: true) // only if needed
```

## Length Units

`pt` (1/72 in), `mm`, `cm`, `in`, `em` (font-relative), `%` (container), `fr` (flex)
