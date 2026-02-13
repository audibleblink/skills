# Embeds

Prefix an internal link with `!` to embed its content inline.

## Embed a Note

```md
![[Note Name]]
```

## Embed a Heading or Block

```md
![[Note Name#Heading]]
![[Note Name#^block-id]]
```

## Embed an Image

```md
![[image.png]]
![[image.png|640x480]]
![[image.png|300]]
```

Width-only scales proportionally. Supports `jpg`, `png`, `gif`, `bmp`, `svg`, `webp`.

## Embed External Image

```md
![Alt text](https://example.com/image.png)
![Alt text|300](https://example.com/image.png)
```

## Embed Audio

```md
![[recording.mp3]]
```

Supports `mp3`, `webm`, `wav`, `m4a`, `ogg`, `3gp`, `flac`.

## Embed PDF

```md
![[document.pdf]]
![[document.pdf#page=3]]
![[document.pdf#height=400]]
```

## Embed a List

```md
![[My Note#^my-list-id]]
```
