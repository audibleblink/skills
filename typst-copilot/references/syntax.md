# Typst Syntax Reference

Typst has three syntactical modes: Markup, Math, and Code.

## Mode Switching

Understanding mode transitions is essential for combining text, math, and logic.

| New Mode | Syntax | Example |
|----------|--------|---------|
| Code | Prefix with `#` | `Number: #(1 + 2)` |
| Math | Surround with `$...$` | `$-x$ is the opposite of $x$` |
| Markup | Surround with `[..]` | `let name = [*Typst!*]` |

## Markup Mode Syntax

Markup mode is the default in a Typst document. It provides lightweight syntax for common document elements.

| Element | Syntax | Function |
|---------|--------|----------|
| Paragraph break | Blank line | `parbreak` |
| Strong emphasis | `*strong*` | `strong` |
| Emphasis | `_emphasis_` | `emph` |
| Raw text | `` `code` `` | `raw` |
| Link | `https://typst.app/` | `link` |
| Label | `<intro>` | `label` |
| Reference | `@intro` | `ref` |
| Heading | `= Heading` | `heading` |
| Bullet list | `- item` | `list` |
| Numbered list | `+ item` | `enum` |
| Term list | `/ Term: description` | `terms` |
| Line break | `\` | `linebreak` |
| Smart quote | `'single'` or `"double"` | `smartquote` |
| Comment | `/* block */` or `// line` | - |
| Non-breaking space | `~` | - |
| Em dash | `---` | - |
| En dash | `--` | - |

### Heading Levels

```typst
= Level 1 Heading
== Level 2 Heading
=== Level 3 Heading
```

### Lists

```typst
- Bullet item 1
- Bullet item 2
  - Nested item

+ Numbered item 1
+ Numbered item 2

/ Term: Definition of the term
```

## Function Parameters

### `heading` Function

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `level` | auto \| int | `auto` | Heading level (1-6), auto-detected from `=` count |
| `numbering` | none \| str \| func | `none` | Number format: `"1."`, `"1.1"`, `"I.a"` |
| `supplement` | auto \| none \| content | `auto` | Reference prefix (e.g., "Section") |
| `outlined` | bool | `true` | Include in outline |
| `bookmarked` | auto \| bool | `auto` | Include in PDF bookmarks |
| `body` | content | required | Heading text |

### `list` Function (Bullet List)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tight` | bool | `true` | Reduce spacing between items |
| `marker` | content \| array \| func | `[*]` | Bullet marker(s) per level |
| `indent` | length | `0pt` | Indent from left |
| `body-indent` | length | `0.5em` | Gap between marker and text |
| `spacing` | auto \| relative | `auto` | Space between items |

### `enum` Function (Numbered List)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tight` | bool | `true` | Reduce spacing between items |
| `numbering` | str \| func | `"1."` | Number format: `"1."`, `"a)"`, `"(i)"` |
| `start` | int | `1` | Starting number |
| `full` | bool | `false` | Show full numbering (e.g., "1.1.1") |
| `indent` | length | `0pt` | Indent from left |
| `body-indent` | length | `0.5em` | Gap between number and text |

### `raw` Function (Code Block)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | str | required | Raw text content |
| `block` | bool | `false` | Display as block |
| `lang` | none \| str | `none` | Language for syntax highlighting |
| `theme` | auto \| str \| none | `auto` | Syntax highlighting theme |
| `tab-size` | int | `2` | Tab width in spaces |

### `link` Function

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `dest` | str \| label \| location \| dict | required | URL, label, or location |
| `body` | auto \| content | `auto` | Link text (auto shows URL) |

### `ref` Function

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `target` | label | required | Target label |
| `supplement` | auto \| none \| content | `auto` | Reference prefix |

## Code Mode Syntax

Code mode lets you use Typst's scripting features. Prefix with `#` to enter code mode from markup.

| Element | Syntax |
|---------|--------|
| Variable binding | `#let x = 1` |
| Function call | `#func(arg)` |
| Code block | `#{ ... }` |
| Content block | `#[ ... ]` |
| Conditional | `#if cond { } else { }` |
| Loop | `#for x in items { }` |

### Code Examples

```typst
#let title = "My Document"
#let items = (1, 2, 3)

#for item in items {
  [Item: #item]
}

#if items.len() > 0 {
  [Has items]
} else {
  [Empty]
}
```

## Data Types

| Type | Example |
|------|---------|
| None | `none` |
| Auto | `auto` |
| Boolean | `true`, `false` |
| Integer | `10`, `0xff` |
| Float | `3.14`, `1e5` |
| Length | `2pt`, `3mm`, `1em` |
| Angle | `90deg`, `1rad` |
| Fraction | `2fr` |
| Ratio | `50%` |
| String | `"text"` |
| Label | `<name>` |
| Content block | `[*text*]` |
| Array | `(1, 2, 3)` |
| Dictionary | `(a: 1, b: 2)` |

## Escape Sequences

| Character | Escape |
|-----------|--------|
| `\` | `\\` |
| `#` | `\#` |
| `*` | `\*` |
| `_` | `\_` |
| `$` | `\$` |
| `<` | `\<` |
| `>` | `\>` |
| `@` | `\@` |
| Unicode | `\u{1f600}` -> emoji |

## Paths

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

## Identifiers

- Can contain letters, numbers, hyphens (`-`), underscores (`_`)
- Must start with letter or underscore
- Kebab-case recommended: `my-variable`
- Examples: `my-func`, `_internal`, `π`
