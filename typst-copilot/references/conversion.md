# Markdown/LaTeX to Typst Conversion

## Text Formatting

| Markdown | Typst |
|----------|-------|
| `*italic*` / `_italic_` | `_italic_` |
| `**bold**` / `__bold__` | `*bold*` |
| `***bold italic***` | `*_bold italic_*` |
| `~~strikethrough~~` | `#strike[text]` |
| `` `code` `` | `` `code` `` |
| `[link](url)` | `#link("url")[link]` |
| `![alt](img)` | `#image("img", alt: "alt")` |

## Headers

| Markdown | Typst |
|----------|-------|
| `# H1` | `= H1` |
| `## H2` | `== H2` |
| `### H3` | `=== H3` |

## Lists

**Markdown:**
```markdown
- Bullet item
1. Numbered item
```

**Typst:**
```typ
- Bullet item
+ Numbered item
```

## Block Elements

| Markdown | Typst |
|----------|-------|
| `> quote` | `#quote[quote]` |
| `---` (hr) | `#line(length: 100%)` |
| `[^1]` (footnote) | `#footnote[text]` |

## Tables

**Markdown:**
```markdown
| Col 1 | Col 2 |
|-------|-------|
| A     | B     |
```

**Typst:**
```typ
#table(
  columns: 2,
  [Col 1], [Col 2],
  [A], [B],
)
```

## Math (LaTeX to Typst)

| LaTeX | Typst |
|-------|-------|
| `$inline$` | `$inline$` |
| `$$block$$` | `$ block $` (spaces) |
| `\frac{a}{b}` | `a/b` or `frac(a, b)` |
| `\sqrt{x}` | `sqrt(x)` |
| `\int_0^1` | `integral_0^1` |
| `\sum_{i=1}^n` | `sum_(i=1)^n` |
| `\infty` | `infinity` |
| `\partial` | `diff` |
| `\alpha`, `\beta` | `alpha`, `beta` |
| `\rightarrow` | `arrow.r` |
| `\leq`, `\geq` | `lt.eq`, `gt.eq` |

## HTML to Typst

| HTML | Typst |
|------|-------|
| `<br>` | `\` |
| `<span style="color:red">` | `#text(fill: red)[...]` |
| `<sup>` | `#super[...]` |
| `<sub>` | `#sub[...]` |
