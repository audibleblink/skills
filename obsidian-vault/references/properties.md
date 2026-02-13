# Properties (Frontmatter)

YAML block at the very top of the file, delimited by `---`. Stores structured metadata.

```yaml
---
tags:
  - project
  - draft
aliases:
  - My Alias
  - Another Name
cssclasses:
  - wide-page
---
```

## Property Types

| Type        | Example Value                    |
| ----------- | -------------------------------- |
| Text        | `title: My Note`                 |
| List        | `tags:\n  - one\n  - two`        |
| Number      | `year: 2024`                     |
| Checkbox    | `favorite: true`                 |
| Date        | `date: 2024-01-15`              |
| Date & time | `time: 2024-01-15T10:30:00`     |

## Default Properties

| Property     | Type | Purpose                                    |
| ------------ | ---- | ------------------------------------------ |
| `tags`       | List | Categorize notes                           |
| `aliases`    | List | Alternative names for linking              |
| `cssclasses` | List | Apply CSS snippets to individual notes     |

## Internal Links in Properties

Surround with quotes:

```yaml
---
link: "[[Episode IV]]"
links:
  - "[[Note A]]"
  - "[[Note B]]"
---
```
