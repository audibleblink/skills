// Presentation Template
// Usage: #import "presentation.typ": *
//        #show: presentation.with(title: "...", author: "...", date: ...)

#let presentation(
  title: "Presentation Title",
  subtitle: none,
  author: "",
  date: none,
  aspect-ratio: "16-9",  // or "4-3"
  theme-color: blue.darken(30%),
  body,
) = {
  // Determine dimensions based on aspect ratio
  let (width, height) = if aspect-ratio == "4-3" {
    (10in, 7.5in)
  } else {
    (10in, 5.625in)  // 16:9
  }
  
  // Document metadata
  set document(
    title: title,
    author: author,
    date: date,
  )
  
  // Page setup
  set page(
    width: width,
    height: height,
    margin: (x: 0.5in, y: 0.5in),
    numbering: none,
    header: locate(loc => {
      let page-num = counter(page).at(loc).first()
      if page-num > 1 {
        block(
          width: 100%,
          inset: (bottom: 0.2em),
          stroke: (bottom: 1.5pt + theme-color),
        )[
          #grid(
            columns: (1fr, auto),
            align: (left, right),
            text(size: 10pt, fill: gray)[#title],
            text(size: 10pt, fill: gray)[
              #counter(page).display() / #context counter(page).final().first()
            ],
          )
        ]
      }
    }),
  )
  
  // Typography
  set text(
    font: ("Inter", "Helvetica", "Arial"),
    size: 20pt,
    lang: "en",
  )
  
  set par(
    justify: false,
    leading: 0.65em,
  )
  
  // Headings (slide titles)
  show heading.where(level: 1): it => {
    set text(size: 32pt, weight: "bold", fill: theme-color)
    block(
      above: 0em,
      below: 0.8em,
      it.body
    )
  }
  
  show heading.where(level: 2): it => {
    set text(size: 24pt, weight: "semibold", fill: theme-color)
    block(
      above: 0.5em,
      below: 0.6em,
      it.body
    )
  }
  
  show heading.where(level: 3): it => {
    set text(size: 20pt, weight: "semibold")
    block(
      above: 0.4em,
      below: 0.5em,
      it.body
    )
  }
  
  // Lists
  set list(
    indent: 1em,
    body-indent: 0.5em,
    marker: text(fill: theme-color)[•],
    spacing: 0.8em,
  )
  
  set enum(
    indent: 1em,
    body-indent: 0.5em,
    numbering: n => text(fill: theme-color)[#n.],
    spacing: 0.8em,
  )
  
  // Figures
  show figure.caption: set text(size: 16pt, style: "italic")
  
  // Tables
  set table(
    stroke: (x, y) => if y == 0 {
      (bottom: 2pt + theme-color)
    } else {
      0.5pt
    },
    fill: (x, y) => if y == 0 {
      theme-color.lighten(80%)
    },
    inset: 10pt,
  )
  
  // Code blocks
  show raw.where(block: true): it => {
    set text(size: 14pt)
    block(
      fill: luma(245),
      inset: 12pt,
      radius: 4pt,
      width: 100%,
      it
    )
  }
  
  // Links
  show link: set text(fill: theme-color)
  
  // === TITLE SLIDE ===
  align(center + horizon)[
    #block(
      width: 90%,
    )[
      #text(size: 42pt, weight: "bold", fill: theme-color)[
        #title
      ]
      
      #if subtitle != none {
        v(0.5em)
        text(size: 28pt, fill: gray)[
          #subtitle
        ]
      }
      
      #v(2em)
      
      #text(size: 24pt)[
        #author
      ]
      
      #v(1em)
      
      #text(size: 18pt, fill: gray)[
        #if date != none {
          date
        } else {
          datetime.today().display("[month repr:long] [day], [year]")
        }
      ]
    ]
  ]
  
  pagebreak()
  
  // === CONTENT SLIDES ===
  body
}

// Slide helper function
#let slide(title, content) = {
  pagebreak()
  
  v(0.5em)
  
  heading(level: 1, title)
  
  content
}

// Two-column layout helper
#let two-columns(left, right) = {
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    left,
    right,
  )
}

// Highlight box helper
#let highlight-box(content, color: blue.lighten(80%)) = {
  block(
    fill: color,
    inset: 1em,
    radius: 8pt,
    width: 100%,
  )[
    #content
  ]
}

// Example usage (commented out)
/*
#show: presentation.with(
  title: "Introduction to Typst",
  subtitle: "Modern Document Creation",
  author: "Jane Smith",
  date: "December 2024",
  theme-color: blue.darken(30%),
)

= Overview

Key topics:
- What is Typst?
- Why use Typst?
- Getting started

= What is Typst?

#two-columns[
  A modern typesetting system:
  - Fast compilation
  - Clean syntax
  - Powerful scripting
][
  #image("typst-logo.png", width: 80%)
]

= Features

== Core Capabilities

- Markup-based
- Built-in styling
- Math support
- Code highlighting

= Example Code

```typst
#let greet(name) = [
  Hello #name!
]

#greet("World")
```

= Benefits

#highlight-box[
  *Fast* → Compile in milliseconds

  *Simple* → Easy to learn

  *Powerful* → Full scripting language
]

= Data Visualization

#figure(
  table(
    columns: 3,
    [*Tool*], [*Speed*], [*Ease*],
    [Typst], [Fast], [High],
    [LaTeX], [Slow], [Low],
    [Word], [Medium], [High],
  ),
  caption: [Comparison of typesetting tools],
)

= Use Cases

+ Academic papers
+ Technical reports
+ Presentations
+ Books and theses

= Getting Started

Visit: https://typst.app

Try the online editor!

= Conclusion

Typst makes document creation:
- *Faster*
- *Easier*
- *More enjoyable*

== Questions?

#align(center + horizon)[
  #text(size: 36pt)[Thank you!]
]
*/
