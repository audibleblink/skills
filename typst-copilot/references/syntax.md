# Typst Syntax Reference

## Modes

| Mode | Entry | Purpose |
|------|-------|---------|
| Markup | Default | Text, headings, lists |
| Math | `$...$` | Formulas (spaces = block) |
| Code | `#` prefix | Logic, functions |

## Markup Syntax

| Element | Syntax |
|---------|--------|
| Strong | `*bold*` |
| Emphasis | `_italic_` |
| Raw | `` `code` `` |
| Heading | `= H1`, `== H2` |
| Bullet list | `- item` |
| Numbered list | `+ item` |
| Term list | `/ Term: def` |
| Label | `<name>` |
| Reference | `@name` |
| Line break | `\` |
| Em dash | `---` |
| Non-breaking space | `~` |

## Math Mode

```typ
$x^2$           // superscript
$x_1$           // subscript
$a/b$           // fraction
$sqrt(x)$       // square root
$sum_(i=1)^n$   // summation
$integral_0^1$  // integral
$vec(x, y)$     // vector
$mat(a, b; c, d)$  // matrix
```

**Greek:** `alpha`, `beta`, `gamma`, `delta`, `theta`, `lambda`, `pi`, `sigma`, `phi`, `omega`

**Operators:** `times`, `div`, `approx`, `equiv`, `in`, `subset`, `union`, `sect`, `forall`, `exists`, `infinity`, `arrow`

## Code Mode

```typ
#let x = 5
#let items = (1, 2, 3)
#let person = (name: "Alice", age: 30)

#if x > 0 { [Positive] }
#for i in range(5) { [#i ] }
```

## Data Types

| Type | Example |
|------|---------|
| Length | `2pt`, `1cm`, `1em` |
| Fraction | `1fr`, `2fr` |
| Ratio | `50%` |
| Color | `red`, `luma(128)`, `rgb(...)` |
| Array | `(1, 2, 3)` |
| Dictionary | `(key: "value")` |
| Content | `[*text*]` |

## Function Parameters

### `heading`
`level`, `numbering` ("1.1"), `outlined`, `body`

### `list` / `enum`
`tight`, `marker`, `numbering`, `indent`, `body-indent`, `spacing`

### `raw`
`text`, `block`, `lang`, `theme`

### `link`
`dest` (url/label), `body`

## Escape Sequences

`\\`, `\#`, `\*`, `\_`, `\$`, `\<`, `\>`, `\@`, `\u{1f600}`
