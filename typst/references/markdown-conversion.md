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
| <code>\`inline code\`</code> | <code>\`inline code\`</code> |
| `[link](url)` | `#link("url")[link]` or just `url` |
| `![alt](image.png)` | `#image("image.png", alt: "alt")` |

## Paragraphs & Line Breaks

| Markdown | Typst |
|----------|-------|
| Blank line (paragraph) | Blank line (paragraph) |
| `  ` (two spaces) + newline | `\` (backslash) |
| Hard break `<br>` | `\` (backslash) |

## Lists

### Unordered Lists

**Markdown:**
```markdown
- Item 1
- Item 2
  - Nested item
  - Another nested
- Item 3
```

**Typst:**
```typ
- Item 1
- Item 2
  - Nested item
  - Another nested
- Item 3
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

**Note:** Typst auto-numbers with `+`. For specific numbers:
```typ
#enum(start: 5)[
  + Fifth item
  + Sixth item
]
```

### Mixed Nesting

**Markdown:**
```markdown
1. Ordered
   - Unordered nested
   - Another
2. Ordered
```

**Typst:**
```typ
+ Ordered
  - Unordered nested
  - Another
+ Ordered
```

## Block Quotes

**Markdown:**
```markdown
> This is a quote
> spanning multiple lines
```

**Typst:**
```typ
#quote[
  This is a quote
  spanning multiple lines
]
```

**With attribution:**

**Markdown:**
```markdown
> Quote text
> — Author
```

**Typst:**
```typ
#quote(attribution: [Author])[
  Quote text
]
```

## Code Blocks

### Without Syntax Highlighting

**Markdown:**
````markdown
```
code here
```
````

**Typst:**
````typ
```
code here
```
````

### With Syntax Highlighting

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

**Supported languages:** Same as Markdown (python, rust, javascript, c, cpp, java, etc.)

## Tables

### Basic Table

**Markdown:**
```markdown
| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Cell 1   | Cell 2   | Cell 3   |
| Cell 4   | Cell 5   | Cell 6   |
```

**Typst:**
```typ
#table(
  columns: 3,
  [Header 1], [Header 2], [Header 3],
  [Cell 1], [Cell 2], [Cell 3],
  [Cell 4], [Cell 5], [Cell 6],
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

**Markdown:**
```markdown
| Col 1 | Col 2 |
|-------|-------|
| A     | B     |
| C     | D     |
```

**Typst:**
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
or
***
or
___
```

**Typst:**
```typ
#line(length: 100%)
```

## Links

### Inline Links

**Markdown:**
```markdown
[link text](https://example.com)
```

**Typst:**
```typ
#link("https://example.com")[link text]
```

### Automatic Links

**Markdown:**
```markdown
<https://example.com>
or
https://example.com
```

**Typst:**
```typ
https://example.com
```
(Typst auto-detects URLs)

### Reference-Style Links

**Markdown:**
```markdown
[link text][ref]

[ref]: https://example.com
```

**Typst:**
```typ
// Define reference
#let refs = (
  ref: "https://example.com",
)

// Use reference
#link(refs.ref)[link text]
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

**Markdown:**
```markdown
![alt](image.png){width=50%}
```

**Typst:**
```typ
#image("image.png", width: 50%, alt: "alt")
```

### Image as Figure

**Markdown:**
```markdown
![Caption text](image.png)
```

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

Term 2
:   Definition 2
```

**Typst:**
```typ
/ Term 1: Definition 1
/ Term 2: Definition 2
```

## Task Lists

**Markdown:**
```markdown
- [x] Completed task
- [ ] Incomplete task
```

**Typst:**
```typ
// No native support, use custom function
#let task(done, body) = [
  #if done [☑] else [☐] #body
]

- #task(true)[Completed task]
- #task(false)[Incomplete task]
```

## Inline HTML

**Markdown:**
```markdown
<span style="color: red">Red text</span>
```

**Typst:**
```typ
#text(fill: red)[Red text]
```

**Note:** HTML is not supported in Typst. Convert to Typst functions.

## Escaping

**Markdown:**
```markdown
\* Not italic \*
```

**Typst:**
```typ
\* Not italic \*
```

Both use backslash for escaping.

## Math (LaTeX-style)

### Inline Math

**Markdown:**
```markdown
$E = mc^2$
```

**Typst:**
```typ
$E = m c^2$
```

### Block Math

**Markdown:**
```markdown
$$
\int_0^\infty f(x) dx
$$
```

**Typst:**
```typ
$ integral_0^infinity f(x) dif x $
```

**Key differences:**
- Typst uses `integral` instead of `\int`
- Typst uses `dif` for differential operator
- Typst uses `infinity` instead of `\infty`
- Subscripts/superscripts work the same

### Common Math Symbols

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

## Advanced Conversions

### Nested Formatting

**Markdown:**
```markdown
**Bold _and italic_**
```

**Typst:**
```typ
*Bold _and italic_*
```

### Complex Lists

**Markdown:**
```markdown
1. First item
   
   Paragraph in list
   
   - Nested bullet
   
2. Second item
```

**Typst:**
```typ
+ First item
  
  Paragraph in list
  
  - Nested bullet
  
+ Second item
```

### Figures with Captions

**Markdown:**
```markdown
![Caption](image.png)
*Figure 1: Extended caption*
```

**Typst:**
```typ
#figure(
  image("image.png"),
  caption: [Extended caption],
) <fig:label>
```

## Conversion Best Practices

### 1. Preserve Structure
- Keep heading hierarchy
- Maintain list nesting
- Preserve paragraph breaks

### 2. Handle Unsupported Features
- Convert HTML to Typst functions
- Replace Markdown extensions with Typst equivalents
- Document any features that need manual attention

### 3. Typography Improvements
- Convert straight quotes to smart quotes (automatic in Typst)
- Use proper em dashes: `---` instead of `--`
- Use non-breaking spaces: `~` for phrases that shouldn't break

### 4. Images & Figures
- Convert inline images to figures when they have captions
- Add labels for cross-referencing
- Specify width/height for consistent layout

### 5. Tables
- Use `table.header()` for semantic headers
- Add alignment where appropriate
- Consider column sizing (auto vs fixed vs fractional)

### 6. Code Blocks
- Preserve language identifiers
- Ensure proper escaping for inline code

### 7. Math
- Convert LaTeX commands to Typst equivalents
- Add spacing in Typst math mode (spaces matter!)
- Use proper Typst functions (e.g., `sqrt()` instead of `\sqrt{}`)

## Conversion Workflow

1. **Parse Markdown structure**
   - Identify all elements (headings, lists, code, etc.)
   - Note nesting levels

2. **Convert headers and text**
   - Headers: `#` → `=`
   - Emphasis: preserve `_` and `*`
   - Links: convert to `#link()` or raw URLs

3. **Convert lists**
   - Unordered: keep `-`
   - Ordered: change numbers to `+`
   - Preserve nesting

4. **Convert code blocks**
   - Keep language identifiers
   - Preserve content exactly

5. **Convert tables**
   - Create `#table()` with proper columns
   - Use `table.header()` for header row
   - Set alignment if needed

6. **Convert special elements**
   - Block quotes → `#quote()`
   - Images → `#image()` or `#figure()`
   - Footnotes → `#footnote[]`
   - Math → Typst math syntax

7. **Final polish**
   - Check escaping
   - Verify math conversions
   - Test compilation

## Quick Reference: Common Patterns

| Markdown Pattern | Typst Equivalent |
|-----------------|------------------|
| `**_text_**` | `*_text_*` |
| `[text](url "title")` | `#link("url")[text]` |
| `![](img.png "title")` | `#image("img.png")` |
| <code>\`\`\`lang</code> | <code>\`\`\`lang</code> |
| `> quote` | `#quote[quote]` |
| `1. item` | `+ item` |
| `- [ ] task` | Custom function needed |
| `[^1]` | `#footnote[]` |
| `$math$` | `$math$` |
| `---` | `#line(length: 100%)` |
