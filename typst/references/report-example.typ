// Example usage of the generic-report
#import "templates/_generic_report.typ": generic-report

#show: generic-report.with(
  title: "How to use a typst template",
  subtitle: "The Easy Way",
  date: "Nov 14, 2025",
  toc: true,
  page-numbers: true,
  author: " Alex Flores",
)


= Executive Summary
#lorem(50)

== Overview
#lorem(20)

= Notes
#lorem(120)

= Findings

== Finding 1
#lorem(120)

== Finding 2
#lorem(120)

= Appendix
