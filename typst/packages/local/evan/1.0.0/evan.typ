#import "@preview/ctheorems:1.1.2": *

#let fonts = (
  text: ("Linux Libertine"),
  sans: ("Noto Sans"),
  mono: ("Inconsolata"),
)
#let colors = (
  title: eastern,
  headers: maroon,
)

#let toc = {
  show outline.entry.where(level: 1): it => {
    v(1.2em, weak:true)
    text(weight:"bold", font:fonts.sans, it)
  }
  text(fill:colors.title, size:1.4em, font:fonts.sans, [*Table of contents*])
  v(0.6em)
  outline(
    title: none,
    indent: 2em,
  )
}

#let theorem = thmbox("main", "Theorem", fill: rgb("#eeeeff"), base_level: 1)
#let lemma = thmbox("main", "Lemma", fill: rgb("#eeeeff"), base_level: 1)
#let proposition = thmbox("main", "Proposition", fill: rgb("#eeeeff"), base_level: 1)
#let corollary = thmbox("main", "Corollary", fill: rgb("#eeeeff"), base_level: 1)
#let example = thmbox("main", "Example", fill: rgb("#ffeeee"), base_level: 1)
#let claim = thmbox("main", "Claim", fill: rgb("#ddffdd"), base_level: 1)
#let remark = thmbox("main", "Remark", fill: rgb("#eeeeee"), base_level: 1)
#let definition = thmbox("main", "Definition", fill: rgb("#ffffdd"), base_level: 1)
#let proof = thmproof("proof", "Proof")

// Main entry point to use in a global show rule
#let evan(
  title: none,
  author: none,
  subtitle: none,
  date: none,
  maketitle: true,
  body
) = {
  // Set document parameters
  if (title != none) {
    set document(title: title)
  }
  if (author != none) {
    set document(author: author)
  }

  // General settings
  set page(
    paper: "a4",
    margin: auto,
    header: context {
      set align(right)
      set text(size:0.8em)
      if (not maketitle or counter(page).get().first() > 1) {
        text(weight:"bold", title)
        if (author != none) {
          h(0.2em)
          sym.dash.em
          h(0.2em)
          text(style:"italic", author)
        }
      }
    },
    numbering: "1",
  )
  set par(
    justify: true
  )
  set text(
    font:fonts.text,
    size:11pt,
  )

  // Theorem environments
  show: thmrules.with(qed-symbol: $square$)

  // Change quote display
  set quote(block: true)
  show quote: set pad(x:2em, y:0em)
  show quote: it => {
    set text(style: "italic")
    v(-1em)
    it
    v(-0.5em)
  }

  // Section headers
  set heading(numbering: "1.1")
  show heading: it => {
    set text(font:fonts.sans)
    block([
      #text(fill:colors.headers, "§" + counter(heading).display())
      #h(0.2em)
      #it.body
      #v(0.4em)
    ])
  }

  // Hyperlinks should be pretty
  show link: set text(fill:blue, font:fonts.mono)

  // Title page, if maketitle is true
  if maketitle {
    v(2.5em)
    set align(center)
    set block(spacing: 2em)
    block(text(fill:colors.title, size:2em, font:fonts.sans, weight:"bold", title))
    if (subtitle != none) {
      block(text(size:1.5em, font:fonts.sans, weight:"bold", subtitle))
    }
    if (author != none) {
      block(smallcaps(text(size:1.7em, author)))
    }
    if (type(date) == "datetime") {
      block(text(size:1.2em, date.display("[day] [month repr:long] [year]")))
    }
    else if (date != none) {
      block(text(size:1.2em, date))
    }
    v(1.5em)
  }
  body
}
