// Professional Report Template
// #show: report.with(title: "...", authors: (...), date: ...)

#let report(
  title: "Report Title",
  subtitle: none,
  authors: (),
  date: none,
  logo: none,
  abstract: none,
  body,
) = {
  set document(title: title, author: authors, date: date)
  
  set page(
    paper: "us-letter",
    margin: (x: 1in, y: 1in),
    numbering: "1",
    number-align: center + bottom,
    header: context {
      if counter(page).get().first() > 1 {
        align(right)[
          #text(size: 10pt, fill: gray)[#title]
          #line(length: 100%, stroke: 0.5pt + gray)
        ]
      }
    },
  )
  
  set text(font: ("New Computer Modern", "Times New Roman"), size: 11pt, lang: "en")
  set par(justify: true, leading: 0.65em, first-line-indent: 1.5em)
  set heading(numbering: "1.1")
  
  show heading: set text(weight: "bold")
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    block(above: 2em, below: 1.5em, text(size: 18pt, it))
  }
  show heading.where(level: 2): it => block(above: 1.5em, below: 1em, text(size: 14pt, it))
  
  set list(indent: 1em, body-indent: 0.5em)
  set enum(indent: 1em, body-indent: 0.5em, numbering: "1.a)")
  show figure: set block(breakable: true)
  show link: set text(fill: blue.darken(20%))
  show raw.where(block: true): it => block(fill: luma(250), inset: 10pt, radius: 4pt, width: 100%, text(size: 9pt, it))
  
  // Title page
  align(center + horizon)[
    #if logo != none { logo; v(2em) }
    #text(size: 24pt, weight: "bold")[#title]
    #if subtitle != none { v(0.5em); text(size: 16pt)[#subtitle] }
    #v(3em)
    #if authors.len() > 0 { text(size: 14pt)[#authors.join(", ")]; v(1em) }
    #text(size: 12pt, fill: gray)[#if date != none { date } else { datetime.today().display("[month repr:long] [day], [year]") }]
  ]
  
  pagebreak()
  
  // Abstract
  if abstract != none {
    set par(first-line-indent: 0em)
    align(center)[#text(size: 14pt, weight: "bold")[Abstract]]
    v(1em)
    block(width: 85%, par(justify: true)[#abstract])
    pagebreak()
  }
  
  // TOC
  outline(title: "Contents", indent: auto)
  pagebreak()
  
  // Content
  set par(first-line-indent: 1.5em)
  body
}
