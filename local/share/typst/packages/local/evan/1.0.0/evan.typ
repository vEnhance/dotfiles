#import "@preview/gentle-clues:1.2.0": *
#import "@preview/ctheorems:2.0.0": *

#let fonts = (
  text: ("Libertinus Serif", "Noto Serif CJK TC", "Noto Color Emoji"),
  sans: ("Noto Sans", "Noto Sans CJK TC", "Noto Color Emoji"),
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

// Displayed equations are unnumbered by default; we introduce #eqn[...] to number them.
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
  accent-color: _get-accent-color-for("abstract"),
  icon: _get-icon-for("abstract"),
  title: "Definition",
  ..args
)
#let problem(..args) = clue(
  accent-color: _get-accent-color-for("experiment"),
  icon: _get-icon-for("experiment"),
  title: "Problem",
  ..args
)
#let exercise(..args) = clue(
  accent-color: _get-accent-color-for("experiment"),
  icon: _get-icon-for("experiment"),
  title: "Exercise",
  ..args
)
#let sample(..args) = clue(
  accent-color: _get-accent-color-for("success"),
  icon: _get-icon-for("experiment"),
  title: "Sample Question",
  ..args
)
#let solution(..args) = clue(
  accent-color: _get-accent-color-for("conclusion"),
  icon: _get-icon-for("conclusion"),
  title: "Solution",
  ..args
)
#let remark(..args) = clue(
  accent-color: _get-accent-color-for("info"),
  icon: _get-icon-for("info"),
  title: "Remark",
  ..args
)
#let recipe(..args) = clue(
  accent-color: _get-accent-color-for("task"),
  icon: _get-icon-for("task"),
  title: "Recipe",
  ..args
)
#let typesig(..args) = clue(
  accent-color: _get-accent-color-for("code"),
  icon: _get-icon-for("code"),
  title: "Type signature",
  ..args
)
#let digression(..args) = clue(
  accent-color: rgb("#bbbbbb"),
  icon: _get-icon-for("quote"),
  title: "Digression",
  ..args
)

// Theorem environments
#let thm-args = (counter: "thm", base-level: 1, inset: 0.9em, above: 0.6em, below: 0.6em)
#let thm-style-plain = thm.with(..thm-args)
#let thm-style-def = thm.with(..thm-args, body-fmt: x => x) // non-italic

#let thm       = thm-style-plain.with(supplement: "Theorem", fill: rgb("#eeeeff"))
#let lem       = thm-style-plain.with(supplement: "Lemma", fill: rgb("#eeeeff"))
#let propn     = thm-style-plain.with(supplement: "Proposition", fill: rgb("#eeeeff"))
#let cor       = thm-style-plain.with(supplement: "Corollary", fill: rgb("#eeeeff"))
#let conj      = thm-style-plain.with(supplement: "Conjecture", fill: rgb("#eeeeff"))
#let ex        = thm-style-def.with(supplement: "Example", fill: rgb("#ffeeee"))
#let algo      = thm-style-def.with(supplement: "Algorithm", fill: rgb("#ddffdd"))
#let claim     = thm-style-def.with(supplement: "Claim", fill: rgb("#ddffdd"))
#let rmk       = thm-style-def.with(supplement: "Remark", fill: rgb("#eeeeee"))
#let defn      = thm-style-def.with(supplement: "Definition", fill: rgb("#ffffdd"))
#let prob      = thm-style-def.with(supplement: "Problem", fill: rgb("#eeeeee"))
#let exer      = thm-style-def.with(supplement: "Exercise", fill: rgb("#eeeeee"))
#let exerstar  = exer.with(title-fmt: (x) => { strong(x + " (*)") })
#let ques      = thm-style-def.with(supplement: "Question", fill: rgb("#eeeeee"))
#let fact      = thm-style-def.with(supplement: "Fact", fill: rgb("#eeeeee"))

#let todo = thm-style-plain.with(
  supplement: "TODO",
  numbering: none,
  fill: rgb("#ddaa77"),
  inset: 0.4em,
)
#let soln = proof.with(supplement: "Solution")

// Restate an environment stated earlier, e.g. in an answer key.
#let recall-thm(target-label) = {
  context {
    let loc = query(target-label).first().location()
    let thms = query(selector(<meta:thm-env-counter>).after(loc))
    let thmloc = thms.first().location()
    let thm = thm-state.thm-stored.at(thmloc).last()
    (thm.fmt)(thm + (number: link(target-label, thm.number)))
  }
}

#let pmod(x) = $space (mod #x)$
#let bf(x) = $bold(upright(#x))$

/*
  HACK: thm-rules numbers every block equation (to place #qedhere and #tag).
  We need to hack it with a separate boxed-numbering, so that #qedhere doesn't invade the box;
  this _also_ increments the equation counter, which #evan fixes later.
  Also, we have to recompute the dimensions properly, ignoring the gutter from thm-rules.
  We hack this by simulating a non-block equation for the box measurement
*/
#let boxed-numbering = _ => none
#let boxed(x) = context rect(stroke: rgb("#003300") + 1.5pt,
  fill: rgb("#eeffee"),
  inset: 5pt, box(
    width: measure({
      show math.equation.where(block: true): eq => math.equation(block: false, math.display(eq.body))
      x
    }).width,
    text(fill: rgb("#000000"), {
      set math.equation(numbering: boxed-numbering)
      x
    }),
  ))

// Some shorthands
#let pm = sym.plus.minus
#let mp = sym.minus.plus
#let detmat(..args) = math.mat(delim: "|", ..args)
#let ee = $bold(upright(e))$
#let dang = sym.angle.arc
#let url(s) = { link(s, text(font:fonts.mono, s)) }

// Ersatz part command (similar to Koma-Script part in scrartcl)
#let part(s) = { heading(numbering: none, text(size: 1.4em, fill: colors.partfill, s)) }

// Unnumbered heading commands
#let h1(..args) = heading(level: 1, outlined: false, numbering: none, ..args)
#let h2(..args) = heading(level: 2, outlined: false, numbering: none, ..args)
#let h3(..args) = heading(level: 3, outlined: false, numbering: none, ..args)
#let h4(..args) = heading(level: 4, outlined: false, numbering: none, ..args)
#let h5(..args) = heading(level: 5, outlined: false, numbering: none, ..args)
#let h6(..args) = heading(level: 6, outlined: false, numbering: none, ..args)

// Main entry point to use in a global show rule
#let evan(
  title: none,
  author: none,
  subtitle: none,
  date: none,
  maketitle: true,
  report-style: false,
  body
) = {
  // Set document parameters
  if (title != none) {
    set document(title: title)
  }
  if (author != none) {
    set document(author: author)
  }

  // Figures formatting
  show figure.caption: cap => context {
    set text(0.95em)
    block(inset: (x: 5em), [
      #set align(left)
      #text(weight: "bold")[#cap.supplement #cap.counter.display(cap.numbering)]#cap.separator#cap.body
    ])
  }

  // Table formatting
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

  // Report parameters
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading and el.level == 1 and it.supplement == auto and report-style {
      ref(it.target, supplement: "Chapter")
    } else {
      it
    }
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
  /*
    HACK: thm-rules numbers every block equation (to place #qedhere and #tag).
    We thus need to undo the change to math.equation to compensate.
  */
  show math.equation.where(numbering: none, block: true)
    .or(math.equation.where(numbering: boxed-numbering, block: true)): eq => {
    eq
    counter(math.equation).update(v => v - 1)
  }

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
      #if (it.numbering != none) [
        #text(fill:colors.headers,
          (if (report-style and it.level == 1) { "Chapter " } else { "§" })
          + counter(heading).display()
          + (if (report-style and it.level == 1) { "." } else { "" })
        )
        #h(0.2em)
      ]
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
      if (type(it.dest) == label) { colors.label } else { colors.hyperlink }
    )
    it
  }
  show ref: it => {
    link(it.target, it)
  }

  // Gentle clues default font should be sans
  show: gentle-clues.with(
    title-font: "Noto Sans"
  )

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
    if (type(date) == datetime) {
      block(text(size:1.2em, date.display("[day] [month repr:long] [year]")))
    }
    else if (date != none) {
      block(text(size:1.2em, date))
    }
    v(1.5em)
  }
  body
}
