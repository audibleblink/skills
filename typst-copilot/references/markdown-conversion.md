# Markdown to Typst Conversion Reference

Comprehensive mapping for converting Extended Markdown to Typst syntax.

## Headers

| Markdown | Typst |
|----------|-------|
| `# H1` | `= H1` |
| `## H2` | `== H2` |
| `### H3` | `=== H3` |
| `#### H4` | `==== H4` |
| `##### H5` | `===== H5` |
| `###### H6` | `====== H6` |

## Text Formatting

| Markdown | Typst |
|----------|-------|
| `*italic*` or `_italic_` | `_italic_` |
| `**bold**` or `__bold__` | `*bold*` |
| `***bold italic***` | `*_bold italic_*` |
| `~~strikethrough~~` | `#strike[strikethrough]` |
| `` `inline code` `` | `` `inline code` `` |
| `[link](url)` | `#link("url")[link]` |
| `![alt](image.png)` | `#image("image.png", alt: "alt")` |

## Paragraphs & Line Breaks

| Markdown | Typst |
|----------|-------|
| Blank line (paragraph) | Blank line (paragraph) |
| Two spaces + newline | `\` (backslash) |
| `<br>` | `\` (backslash) |

## Lists

### Unordered Lists

**Markdown:**
```markdown
- Item 1
- Item 2
  - Nested item
```

**Typst:**
```typ
- Item 1
- Item 2
  - Nested item
```

### Ordered Lists

**Markdown:**
```markdown
1. First
2. Second
3. Third
```

**Typst:**
```typ
+ First
+ Second
+ Third
```

**Note:** Typst auto-numbers with `+`. For specific start:
```typ
#enum(start: 5)[
  + Fifth item
  + Sixth item
]
```

## Block Quotes

**Markdown:**
```markdown
> This is a quote
```

**Typst:**
```typ
#quote[
  This is a quote
]
```

**With attribution:**
```typ
#quote(attribution: [Author])[
  Quote text
]
```

## Code Blocks

**Markdown:**
````markdown
```python
def hello():
    print("Hello")
```
````

**Typst:**
````typ
```python
def hello():
    print("Hello")
```
````

## Tables

### Basic Table

**Markdown:**
```markdown
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
```

**Typst:**
```typ
#table(
  columns: 2,
  [Header 1], [Header 2],
  [Cell 1], [Cell 2],
)
```

### Table with Alignment

**Markdown:**
```markdown
| Left | Center | Right |
|:-----|:------:|------:|
| L    | C      | R     |
```

**Typst:**
```typ
#table(
  columns: (auto, auto, auto),
  align: (left, center, right),
  [Left], [Center], [Right],
  [L], [C], [R],
)
```

### Table with Header

```typ
#table(
  columns: 2,
  table.header([Col 1], [Col 2]),
  [A], [B],
  [C], [D],
)
```

## Horizontal Rules

**Markdown:**
```markdown
---
```

**Typst:**
```typ
#line(length: 100%)
```

## Links

**Markdown:**
```markdown
[link text](https://example.com)
```

**Typst:**
```typ
#link("https://example.com")[link text]
```

Typst auto-detects URLs:
```typ
https://example.com
```

## Images

### Basic Image

**Markdown:**
```markdown
![alt text](image.png)
```

**Typst:**
```typ
#image("image.png", alt: "alt text")
```

### Image with Width

**Typst:**
```typ
#image("image.png", width: 50%, alt: "alt")
```

### Image as Figure

**Typst:**
```typ
#figure(
  image("image.png"),
  caption: [Caption text],
)
```

## Footnotes

**Markdown:**
```markdown
Text with footnote[^1]

[^1]: Footnote content
```

**Typst:**
```typ
Text with footnote#footnote[Footnote content]
```

## Definition Lists

**Markdown:**
```markdown
Term 1
:   Definition 1
```

**Typst:**
```typ
/ Term 1: Definition 1
```

## Task Lists

**Markdown:**
```markdown
- [x] Completed task
- [ ] Incomplete task
```

**Typst:**
```typ
#let task(done, body) = [
  #if done [checkbox symbol] else [empty checkbox] #body
]

- #task(true)[Completed task]
- #task(false)[Incomplete task]
```

## Math (LaTeX to Typst)

### Inline Math

**Markdown/LaTeX:**
```markdown
$E = mc^2$
```

**Typst:**
```typ
$E = m c^2$
```

### Block Math

**Markdown/LaTeX:**
```markdown
$$
\int_0^\infty f(x) dx
$$
```

**Typst:**
```typ
$ integral_0^infinity f(x) dif x $
```

### Common Math Symbol Conversions

| LaTeX | Typst |
|-------|-------|
| `\alpha` | `alpha` |
| `\beta` | `beta` |
| `\sum` | `sum` |
| `\prod` | `product` |
| `\int` | `integral` |
| `\infty` | `infinity` |
| `\partial` | `diff` |
| `\nabla` | `nabla` |
| `\sqrt{x}` | `sqrt(x)` |
| `\frac{a}{b}` | `a/b` |
| `\rightarrow` | `arrow.r` |
| `\Rightarrow` | `arrow.r.double` |
| `\leq` | `lt.eq` |
| `\geq` | `gt.eq` |

## Inline HTML to Typst

**HTML:**
```html
<span style="color: red">Red text</span>
```

**Typst:**
```typ
#text(fill: red)[Red text]
```

**Note:** HTML is not supported in Typst. Convert to Typst functions.

## Quick Reference

| Markdown Pattern | Typst Equivalent |
|-----------------|------------------|
| `**_text_**` | `*_text_*` |
| `[text](url)` | `#link("url")[text]` |
| `![](img.png)` | `#image("img.png")` |
| ` ```lang ` | ` ```lang ` |
| `> quote` | `#quote[quote]` |
| `1. item` | `+ item` |
| `[^1]` | `#footnote[]` |
| `$math$` | `$math$` |
| `---` | `#line(length: 100%)` |

## Conversion Best Practices

1. **Preserve Structure**: Keep heading hierarchy and list nesting
2. **Handle Unsupported Features**: Convert HTML to Typst functions
3. **Typography Improvements**: Use em dashes `---`, smart quotes (automatic)
4. **Images & Figures**: Add labels for cross-referencing
5. **Tables**: Use `table.header()` for semantic headers
6. **Math**: Convert LaTeX commands to Typst equivalents
