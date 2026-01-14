// Professional Report Template
// Usage: #import "report.typ": *
//        #show: report.with(title: "...", authors: (...), date: ...)

#let report(
  title: "Report Title",
  subtitle: none,
  authors: (),
  date: none,
  logo: none,
  abstract: none,
  body,
) = {
  // Document metadata
  set document(
    title: title,
    author: authors,
    date: date,
  )
  
  // Page setup
  set page(
    paper: "us-letter",
    margin: (x: 1in, y: 1in),
    numbering: "1",
    number-align: center + bottom,
    header: locate(loc => {
      let page-num = counter(page).at(loc).first()
      if page-num > 1 {
        align(right)[
          #text(size: 10pt, fill: gray)[#title]
          #line(length: 100%, stroke: 0.5pt + gray)
        ]
      }
    }),
  )
  
  // Typography
  set text(
    font: ("New Computer Modern", "Times New Roman"),
    size: 11pt,
    lang: "en",
  )
  
  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: 1.5em,
  )
  
  // Headings
  set heading(numbering: "1.1")
  
  show heading: set text(weight: "bold")
  
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    block(
      above: 2em,
      below: 1.5em,
      text(size: 18pt, it)
    )
  }
  
  show heading.where(level: 2): it => {
    block(
      above: 1.5em,
      below: 1em,
      text(size: 14pt, it)
    )
  }
  
  show heading.where(level: 3): it => {
    block(
      above: 1.2em,
      below: 0.8em,
      text(size: 12pt, style: "italic", it)
    )
  }
  
  // Lists
  set list(indent: 1em, body-indent: 0.5em)
  set enum(indent: 1em, body-indent: 0.5em, numbering: "1.a)")
  
  // Figures
  show figure: set block(breakable: true)
  
  // Tables
  set table(
    stroke: (x, y) => if y == 0 {
      (bottom: 1pt)
    } else {
      0.5pt
    },
    fill: (x, y) => if y == 0 {
      gray.lighten(80%)
    },
    inset: 8pt,
  )
  
  // Links
  show link: set text(fill: blue.darken(20%))
  
  // Code blocks
  show raw.where(block: true): it => {
    block(
      fill: luma(250),
      inset: 10pt,
      radius: 4pt,
      width: 100%,
      text(size: 9pt, it)
    )
  }
  
  // === TITLE PAGE ===
  align(center + horizon)[
    // Logo
    #if logo != none {
      logo
      v(2em)
    }
    
    // Title
    #text(size: 24pt, weight: "bold")[
      #title
    ]
    
    // Subtitle
    #if subtitle != none {
      v(0.5em)
      text(size: 16pt)[
        #subtitle
      ]
    }
    
    #v(3em)
    
    // Authors
    #if authors.len() > 0 {
      text(size: 14pt)[
        #authors.join(", ")
      ]
      v(1em)
    }
    
    // Date
    #if date != none {
      text(size: 12pt, fill: gray)[
        #date
      ]
    } else {
      text(size: 12pt, fill: gray)[
        #datetime.today().display("[month repr:long] [day], [year]")
      ]
    }
  ]
  
  pagebreak()
  
  // === ABSTRACT ===
  #if abstract != none {
    set par(first-line-indent: 0em)
    
    align(center)[
      #text(size: 14pt, weight: "bold")[Abstract]
    ]
    
    v(1em)
    
    block(
      width: 85%,
      par(justify: true)[#abstract]
    )
    
    pagebreak()
  }
  
  // === TABLE OF CONTENTS ===
  outline(
    title: "Contents",
    indent: auto,
  )
  
  pagebreak()
  
  // === MAIN CONTENT ===
  set par(first-line-indent: 1.5em)
  
  body
}

// Example usage (commented out)
/*
#show: report.with(
  title: "Quarterly Sales Report",
  subtitle: "Q4 2024 Analysis",
  authors: ("John Smith", "Jane Doe"),
  date: datetime(year: 2024, month: 12, day: 15).display(),
  abstract: [
    This report analyzes the sales performance for Q4 2024, 
    comparing results against targets and identifying key trends.
  ],
)

= Executive Summary
#lorem(50)

= Introduction
== Background
#lorem(30)

== Objectives
+ Analyze Q4 sales data
+ Identify trends and patterns
+ Provide recommendations

= Methodology
#lorem(40)

= Results
== Sales Performance
#lorem(50)

#figure(
  table(
    columns: 3,
    [*Region*], [*Sales*], [*Target*],
    [North], [\$500K], [\$450K],
    [South], [\$400K], [\$500K],
  ),
  caption: [Regional sales comparison],
)

= Conclusions
#lorem(30)

= Recommendations
- Focus on South region
- Expand product line
- Increase marketing spend

= References
#lorem(20)
*/
