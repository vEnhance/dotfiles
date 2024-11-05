#import "@preview/gentle-clues:1.0.0": *
#import "theorems.typ": *

#let fonts = (
  text: ("Libertinus Serif", "Noto Color Emoji"),
  sans: ("Noto Sans", "Noto Color Emoji"),
  mono: ("Inconsolata", "Noto Color Emoji"),
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
#let thm-args = (padding: (x: 0.5em, y: 0.6em), outset: 0.9em, counter: "thm")
#let thm = thm-plain("Theorem",  fill: rgb("#eeeeff"), ..thm-args)
#let lem = thm-plain("Lemma", fill: rgb("#eeeeff"), ..thm-args)
#let prop = thm-plain("Proposition", fill: rgb("#eeeeff"), ..thm-args)
#let cor = thm-plain("Corollary", fill: rgb("#eeeeff"), ..thm-args)
#let conj = thm-plain("Conjecture", fill: rgb("#eeeeff"), ..thm-args)
#let ex = thm-def("Example", fill: rgb("#ffeeee"), ..thm-args)
#let algo = thm-def("Algorithm", fill: rgb("#ddffdd"), ..thm-args)
#let claim = thm-def("Claim", fill: rgb("#ddffdd"), ..thm-args)
#let rmk = thm-def("Remark", fill: rgb("#eeeeee"), ..thm-args)
#let defn = thm-def("Definition", fill: rgb("#ffffdd"), ..thm-args)
#let prob = thm-def("Problem", fill: rgb("#eeeeee"), ..thm-args)
#let exer = thm-def("Exercise", fill: rgb("#eeeeee"), ..thm-args)
#let exerstar = thm-def("* Exercise", fill: rgb("#eeeeee"), ..thm-args)
#let ques = thm-def("Question", fill: rgb("#eeeeee"), ..thm-args)
#let fact = thm-def("Fact", fill: rgb("#eeeeee"), ..thm-args)

#let todo = thm-plain("TODO", fill: rgb("#ddaa77"), padding: (x: 0.2em, y: 0.2em), outset: 0.4em).with(numbering: none)
#let proof = thm-proof("Proof")
#let soln = thm-proof("Solution")

#let pmod(x) = $space (mod #x)$
#let bf(x) = $bold(upright(#x))$
#let boxed(x) = rect(stroke: rgb("#003300") + 1.5pt,
  fill: rgb("#eeffee"),
  inset: 5pt, text(fill: rgb("#000000"), x))

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

  show figure.caption: cap => context {
    set text(0.95em)
    block(inset: (x: 5em), [
      #set align(left)
      #text(weight: "bold")[#cap.supplement #cap.counter.display(cap.numbering)]#cap.separator#cap.body
    ])
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
  show: thm-rules.with(qed-symbol: $square$)

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
