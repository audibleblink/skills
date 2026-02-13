# Tags

## Inline Tags

```md
#tag-name
#nested/subtag
#camelCase
#snake_case
```

Rules:
- Must start with `#`
- Must contain at least one non-numeric character (`#1984` is invalid, `#y1984` is valid)
- Allowed characters: letters, numbers, `_`, `-`, `/`
- No spaces — use camelCase, PascalCase, snake_case, or kebab-case
- Case-insensitive (`#Tag` and `#tag` are the same)

## Tags in Properties

```yaml
---
tags:
  - project
  - status/active
---
```

## Nested Tags

Use `/` to create hierarchies: `#inbox/to-read`. Searching for `tag:inbox` matches `#inbox` and all children.
