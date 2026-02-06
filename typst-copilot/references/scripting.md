# Typst Scripting Reference

## Variables

```typ
#let name = "Alice"
#let count = 42
#let items = (1, 2, 3)
#let person = (name: "Bob", age: 30)

// Destructuring
#let (a, b) = (1, 2)
```

## Arrays

```typ
#let arr = (1, 2, 3, 4, 5)

arr.len()              // 5
arr.at(2)              // 3
arr.first(), arr.last()
arr.slice(1, 3)        // (2, 3)
arr.contains(3)        // true
arr.map(x => x * 2)    // (2, 4, 6, 8, 10)
arr.filter(x => x > 2) // (3, 4, 5)
arr.fold(0, (a, b) => a + b)  // 15
arr.join(", ")         // "1, 2, 3, 4, 5"
```

## Dictionaries

```typ
#let dict = (name: "Alice", age: 25)

dict.name              // "Alice"
dict.at("age")         // 25
dict.keys()            // ("name", "age")
dict.values()          // ("Alice", 25)
```

## Functions

```typ
#let greet(name) = [Hello, #name!]
#let add(a, b) = a + b

// Default parameters
#let greet(name, greeting: "Hello") = [#greeting, #name!]

// Content function
#let highlight(body) = {
  set text(fill: red)
  body
}
#highlight[Important]
```

## Template Functions

```typ
#let article(title: none, body) = {
  set document(title: title)
  set page(paper: "a4", numbering: "1")
  set text(size: 11pt)
  set heading(numbering: "1.1")
  
  align(center, text(17pt, weight: "bold", title))
  body
}

// Usage
#show: article.with(title: [My Paper])
```

## Control Flow

```typ
#if x > 0 { [Positive] } else { [Non-positive] }

#for i in range(5) { [#i ] }
#for item in items { [#item ] }
#for (key, val) in dict { [#key: #val ] }
```

## Operators

`+`, `-`, `*`, `/`, `==`, `!=`, `<`, `>`, `<=`, `>=`, `and`, `or`, `not`, `in`, `not in`

## Strings

```typ
s.len(), s.contains("x"), s.starts-with("a"), s.ends-with("z")
s.replace("old", "new"), s.split(","), s.trim()
upper(s), lower(s)
```

## Imports

```typ
#import "file.typ": func1, func2
#import "file.typ": *
#import "file.typ": func as alias
#include "chapter.typ"  // render content
```

## Context

Access location-dependent state:

```typ
#context counter(page).display()
#context counter(page).get().first()

// Access set rule values
#set text(lang: "en")
#context text.lang  // "en"
```

## Counters & State

```typ
#let my-counter = counter("name")
#my-counter.step()
#my-counter.update(10)
#context my-counter.display()

#let my-state = state("name", 0)
#my-state.update(5)
#context my-state.get()
```
