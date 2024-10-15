#import "@preview/ctheorems:1.1.2": *
#import "@preview/gentle-clues:1.0.0": *

#let fonts = (
  text: ("Libertinus Serif"),
  sans: ("Noto Sans"),
  mono: ("Inconsolata"),
)
#let colors = (
  title: eastern,
  headers: maroon,
  partfill: rgb("#002299"),
  label: red,
  hyperlink: blue,
  strong: rgb("#000055")
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

#let eqn(s) = {
  set math.equation(numbering: "(1)")
  s
}
#let pageref(label) = context {
  let loc = locate(label)
  let nums = counter(page).at(loc)
  link(loc, "page " + numbering(loc.page-numbering(), ..nums))
}

// Define clue environments
#let definition(..args) = clue(
  accent-color: get-accent-color-for("abstract"),
  icon: get-icon-for("abstract"),
  title: "Definition",
  ..args
)
#let problem(..args) = clue(
  accent-color: get-accent-color-for("experiment"),
  icon: get-icon-for("experiment"),
  title: "Problem",
  ..args
)
#let exercise(..args) = clue(
  accent-color: get-accent-color-for("experiment"),
  icon: get-icon-for("experiment"),
  title: "Exercise",
  ..args
)
#let sample(..args) = clue(
  accent-color: get-accent-color-for("success"),
  icon: get-icon-for("experiment"),
  title: "Sample Question",
  ..args
)
#let solution(..args) = clue(
  accent-color: get-accent-color-for("conclusion"),
  icon: get-icon-for("conclusion"),
  title: "Solution",
  ..args
)
#let remark(..args) = clue(
  accent-color: get-accent-color-for("info"),
  icon: get-icon-for("info"),
  title: "Remark",
  ..args
)
#let recipe(..args) = clue(
  accent-color: get-accent-color-for("task"),
  icon: get-icon-for("task"),
  title: "Recipe",
  ..args
)
#let typesig(..args) = clue(
  accent-color: get-accent-color-for("code"),
  icon: get-icon-for("code"),
  title: "Type signature",
  ..args
)
#let digression(..args) = clue(
  accent-color: rgb("#bbbbbb"),
  icon: get-icon-for("quote"),
  title: "Digression",
  ..args
)

// Theorem environments
#let thm = thmbox("main", "Theorem", fill: rgb("#eeeeff"), base_level: 1)
#let lem = thmbox("main", "Lemma", fill: rgb("#eeeeff"), base_level: 1)
#let prop = thmbox("main", "Proposition", fill: rgb("#eeeeff"), base_level: 1)
#let cor = thmbox("main", "Corollary", fill: rgb("#eeeeff"), base_level: 1)
#let conj = thmbox("main", "Conjecture", fill: rgb("#eeeeff"), base_level: 1)
#let ex = thmbox("main", "Example", fill: rgb("#ffeeee"), base_level: 1)
#let algo = thmbox("main", "Algorithm", fill: rgb("#ddffdd"), base_level: 1)
#let claim = thmbox("main", "Claim", fill: rgb("#ddffdd"), base_level: 1)
#let rmk = thmbox("main", "Remark", fill: rgb("#eeeeee"), base_level: 1)
#let defn = thmbox("main", "Definition", fill: rgb("#ffffdd"), base_level: 1)
#let prob = thmbox("main", "Problem", fill: rgb("#eeeeee"), base_level: 1)
#let exer = thmbox("main", "Exercise", fill: rgb("#eeeeee"), base_level: 1)
#let exerstar = thmbox("main", "* Exercise", fill: rgb("#eeeeee"), base_level: 1)
#let ques = thmbox("main", "Question", fill: rgb("#eeeeee"), base_level: 1)
#let fact = thmbox("main", "Fact", fill: rgb("#eeeeee"), base_level: 1)

#let todo = thmbox("todo", "TODO", fill: rgb("#ddaa77")).with(numbering: none)
#let proof = thmproof("proof", "Proof")
#let soln = thmproof("soln", "Solution")

#let pmod(x) = $space (mod #x)$
#let bf(x) = $bold(upright(#x))$

// Some shorthands
#let pm = sym.plus.minus
#let mp = sym.minus.plus
#let int = sym.integral
#let oint = sym.integral.cont
#let iint = sym.integral.double
#let oiint = sym.integral.surf
#let iiint = sym.integral.triple
#let oiiint = sym.integral.vol

#let url(s) = {
  link(s, text(font:fonts.mono, s))
}

// Ersatz part command (similar to Koma-Script part in scrartcl)
#let part(s) = {
  heading(numbering: none, text(size: 1.4em, fill: colors.partfill, s))
}

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

  show figure.where(kind: image): fig => {
    show image.where(width: auto): im => style(st => {
      let (width, height) = measure(im, st)
      block(width: width * 0.5, height: height * 0.5, im)
    })
    fig
  }
  show figure.where(kind: table): fig => {
    // Auto emphasize the table headers
    show table.cell.where(y: 0): set text(weight: "bold")
    let tableframe(stroke) = (x, y) => (
      left: 0pt,
      right: 0pt,
      top: if y <= 1 { stroke } else { 0pt },
      bottom: stroke,
    )
    set table(
      stroke: tableframe(rgb("#21222c")),
      fill: (_, y) => if (y==0) { rgb("#ffeeff") } else if calc.even(y) { rgb("#eaf2f5") },
    )
    fig
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
    font: fonts.text,
    size: 11pt,
    fallback: false,
  )

  // For bold elements, use sans font
  show strong: set text(font:fonts.sans, size: 0.9em)

  // Theorem environments
  show: thmrules.with(qed-symbol: $square$)

  // Change quote display
  set quote(block: true)
  show quote: set pad(x:2em, y:0em)
  show quote: it => {
    set text(style:"italic")
    v(-1em)
    it
    v(-0.5em)
  }

  // Indent lists
  set enum(indent: 1em)
  set list(indent: 1em)

  // Section headers
  set heading(numbering: "1.1")
  show heading: it => {
    block([
      #if (it.numbering != none) {
        text(fill:colors.headers, "§" + counter(heading).display())
        h(0.2em)
      }
      #it.body
      #v(0.4em)
    ])
  }
  show heading: set text(font:fonts.sans, size: 11pt)
  show heading.where(level: 1): set text(size: 14pt)
  show heading.where(level: 2): set text(size: 12pt)

  // Hyperlinks should be pretty
  show link: it => {
    set text(fill:
      if (type(it.dest) == "label") { colors.label } else { colors.hyperlink }
    )
    it
  }
  show ref: it => {
    link(it.target, it)
  }

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
