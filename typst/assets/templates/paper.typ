// Academic Paper Template
// Usage: #import "paper.typ": *
//        #show: paper.with(title: "...", authors: (...), keywords: (...))

#let paper(
  title: "Paper Title",
  authors: (),
  affiliations: (),
  abstract: none,
  keywords: (),
  bibliography-file: none,
  body,
) = {
  // Document metadata
  set document(
    title: title,
    author: authors.map(a => a.name),
    keywords: keywords,
  )
  
  // Page setup
  set page(
    paper: "a4",
    margin: (x: 2cm, y: 2.5cm),
    numbering: "1",
    number-align: center + bottom,
  )
  
  // Typography
  set text(
    font: ("Linux Libertine", "Georgia", "Times New Roman"),
    size: 10pt,
    lang: "en",
  )
  
  set par(
    justify: true,
    leading: 0.52em,
  )
  
  // Headings
  set heading(numbering: "1.1")
  
  show heading: set text(font: ("Linux Biolinum", "Arial", "Helvetica"))
  
  show heading.where(level: 1): it => {
    set text(size: 13pt, weight: "bold")
    set align(center)
    block(above: 1.5em, below: 1em, smallcaps(it.body))
  }
  
  show heading.where(level: 2): it => {
    set text(size: 11pt, weight: "bold")
    block(above: 1.2em, below: 0.8em, it)
  }
  
  show heading.where(level: 3): it => {
    set text(size: 10pt, weight: "bold", style: "italic")
    block(above: 1em, below: 0.6em)[
      #it.body.
    ]
  }
  
  // Lists
  set list(indent: 1em, body-indent: 0.5em, spacing: 0.5em)
  set enum(indent: 1em, body-indent: 0.5em, spacing: 0.5em)
  
  // Figures
  show figure.caption: set text(size: 9pt)
  show figure: set block(breakable: true)
  
  // Tables
  set table(
    stroke: (x, y) => if y == 0 { (bottom: 0.7pt) } else { 0.4pt },
    inset: 6pt,
  )
  
  // References
  show link: set text(fill: blue.darken(30%))
  
  // Code blocks
  show raw.where(block: true): it => {
    set text(size: 8pt)
    block(
      fill: luma(245),
      inset: 8pt,
      radius: 2pt,
      width: 100%,
      it
    )
  }
  
  // === TITLE AND AUTHORS (one-column) ===
  
  // Title
  align(center)[
    #block(
      above: 1em,
      below: 1em,
      text(size: 17pt, weight: "bold", title)
    )
  ]
  
  // Authors
  align(center)[
    #grid(
      columns: (1fr,) * calc.min(authors.len(), 3),
      gutter: 1em,
      ..authors.map(author => [
        #text(size: 11pt)[#author.name] \
        #text(size: 9pt, style: "italic")[#author.affiliation] \
        #if "email" in author {
          text(size: 8pt, fill: gray)[#author.email]
        }
      ])
    )
  ]
  
  v(1.5em)
  
  // Abstract
  #if abstract != none {
    set par(justify: false, first-line-indent: 0em)
    
    block(
      width: 100%,
      inset: (x: 1.5cm, y: 0.5em),
    )[
      #align(center)[
        #text(size: 10pt, weight: "bold")[Abstract]
      ]
      
      #abstract
      
      #if keywords.len() > 0 {
        v(0.5em)
        text(size: 9pt)[
          *Keywords:* #keywords.join(", ")
        ]
      }
    ]
  }
  
  v(2em)
  
  // === MAIN CONTENT (two-column) ===
  set page(columns: 2, column-gutter: 1em)
  
  body
  
  // === BIBLIOGRAPHY ===
  #if bibliography-file != none {
    show bibliography: set text(size: 9pt)
    set par(first-line-indent: 0em)
    
    bibliography(bibliography-file, title: "References", style: "ieee")
  }
}

// Example usage (commented out)
/*
#show: paper.with(
  title: "A Novel Approach to Machine Learning in Climate Science",
  authors: (
    (
      name: "Alice Smith",
      affiliation: "Department of Computer Science, University X",
      email: "alice@university.edu"
    ),
    (
      name: "Bob Johnson",
      affiliation: "Climate Research Institute",
      email: "bob@climate.org"
    ),
  ),
  abstract: [
    This paper presents a novel approach to applying machine learning 
    techniques in climate science. We demonstrate significant improvements 
    in prediction accuracy over traditional methods.
  ],
  keywords: ("machine learning", "climate science", "neural networks", "prediction"),
  bibliography-file: "refs.bib",
)

= Introduction

Climate change represents one of the most pressing challenges of our time 
@ipcc2021. Machine learning has emerged as a powerful tool for analyzing 
complex climate data @doe2020.

== Background

#lorem(40)

== Related Work

Previous studies have explored @smith2019 the application of neural networks...

= Methodology

== Data Collection

#lorem(30)

#figure(
  table(
    columns: 3,
    [*Dataset*], [*Size*], [*Source*],
    [NOAA], [10TB], [Public],
    [NASA], [5TB], [Public],
  ),
  caption: [Data sources used in this study],
) <tab:data>

== Model Architecture

We utilize a deep learning architecture consisting of...

= Results

== Performance Metrics

As shown in @tab:results, our approach achieves...

#figure(
  image("results.png", width: 80%),
  caption: [Comparison of model performance],
) <fig:results>

= Discussion

== Implications

#lorem(35)

== Limitations

This study has several limitations...

= Conclusions

We have demonstrated that machine learning can significantly improve 
climate predictions. Future work should explore...

= Acknowledgments

This research was supported by Grant XYZ-123.
*/
