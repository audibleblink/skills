# Typst Styling Reference

## Set Rules

Apply default properties to elements:

```typ
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true, leading: 0.65em)
#set page(paper: "a4", margin: 2cm, numbering: "1")
#set heading(numbering: "1.1")
```

**Scoped:**
```typ
#[
  #set text(fill: blue)
  This is blue.
]
```

## Show Rules

Transform element appearance:

```typ
// Basic transformation
#show heading: it => {
  set text(fill: blue)
  it
}

// Show-set shorthand
#show heading: set text(fill: navy)
#show raw: set text(font: "Fira Code")

// Selective with where
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  text(size: 18pt, it.body)
}

// Text replacement
#show "typst": [*Typst*]
#show regex("\d+"): set text(fill: blue)
```

## Function Parameters

### `text`
| Param | Values |
|-------|--------|
| `font` | `"Font Name"` or `("Font", "Fallback")` |
| `size` | `11pt`, `1em` |
| `fill` | `black`, `blue`, `rgb(...)` |
| `weight` | `"regular"`, `"bold"`, 100-900 |
| `style` | `"normal"`, `"italic"` |
| `lang` | `"en"`, `"de"` |
| `hyphenate` | `true`, `false`, `auto` |

### `par`
| Param | Values |
|-------|--------|
| `leading` | `0.65em` (line spacing) |
| `spacing` | `1.2em` (paragraph spacing) |
| `justify` | `true`, `false` |
| `linebreaks` | `auto`, `"optimized"` |
| `first-line-indent` | `0pt`, `1.8em` |

### `block`
| Param | Values |
|-------|--------|
| `fill` | background color |
| `stroke` | border |
| `radius` | corner radius |
| `inset` | padding |
| `above`/`below` | spacing |
| `breakable` | `true`, `false` |

## Common Patterns

**LaTeX-like styling:**
```typ
#set page(margin: 1.75in)
#set par(leading: 0.55em, spacing: 0.55em, first-line-indent: 1.8em, justify: true)
#set text(font: "New Computer Modern")
#show heading: set block(above: 1.4em, below: 1em)
```

**Heading hierarchy:**
```typ
#show heading.where(level: 1): set text(size: 18pt)
#show heading.where(level: 2): set text(size: 14pt)
#show heading.where(level: 3): set text(size: 12pt, style: "italic")
```
