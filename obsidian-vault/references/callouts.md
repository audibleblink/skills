# Callouts

Blockquote-based admonitions with type identifiers.

## Basic Callout

```md
> [!note] Optional Title
> Callout body content.
> Supports **Markdown**, [[Wikilinks]], and ![[embeds]].
```

## Foldable Callouts

```md
> [!tip]- Collapsed by default
> Hidden content.

> [!tip]+ Expanded by default
> Visible content.
```

## Nested Callouts

```md
> [!question] Outer
> > [!todo] Inner
> > > [!example] Deepest
```

## Supported Types

| Type       | Aliases                   |
| ---------- | ------------------------- |
| `note`     |                           |
| `abstract` | `summary`, `tldr`         |
| `info`     |                           |
| `todo`     |                           |
| `tip`      | `hint`, `important`       |
| `success`  | `check`, `done`           |
| `question` | `help`, `faq`             |
| `warning`  | `caution`, `attention`    |
| `failure`  | `fail`, `missing`         |
| `danger`   | `error`                   |
| `bug`      |                           |
| `example`  |                           |
| `quote`    | `cite`                    |

Unsupported types default to `note` styling. Type identifiers are case-insensitive.
