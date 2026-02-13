# Internal Links (Wikilinks)

## Basic Link

```md
[[Note Name]]
[[Note Name.md]]
```

## Link with Display Text

```md
[[Note Name|Custom Display Text]]
```

## Link to Heading

```md
[[Note Name#Heading]]
[[Note Name#Heading|Display Text]]
[[#Heading in Current Note]]
```

## Link to Subheading

```md
[[Note Name#Heading#Subheading]]
```

## Link to Block

```md
[[Note Name#^block-id]]
```

Define a block ID by appending `^block-id` at end of a paragraph:

```md
This is a paragraph with a block identifier. ^my-block
```

For structured blocks (lists, quotes, tables), put the ID on a separate line with blank lines around it:

```md
> A blockquote

^quote-id

Next paragraph.
```

## Markdown-style Internal Links

```md
[Display Text](Note%20Name.md)
[Display Text](Note%20Name.md#Heading)
```

URL-encode spaces as `%20` when using markdown format.
