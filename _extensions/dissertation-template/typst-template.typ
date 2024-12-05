

#let article(
  chapter: "chapter",
  title: none,
  chtitle: "title",
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 2.5cm, y: 3cm),
  paper: "a4",
  lang: "en",
  region: "US",
  font: ("Cambria"),
  fontsize: 12pt,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: 1,
  toc_indent: 1.5em,
  doc,
  no-header-pages: (1,2,3,4,5,6,20),
  no-footer-pages: (1,2,3,4,5,6,20),
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
    header: locate(
      loc => if loc.page() in no-header-pages {
        none
      } else if calc.even(loc.page()) {
        align(right, text(11pt, fill: rgb(105,105,105), weight: "light", font: ("Gill Sans"), chapter))
      } else {
        align(left, text(11pt, fill: rgb(105,105,105), weight: "light", font: ("Gill Sans"), chtitle))
      }
    ),
    footer: locate(
    loc => if loc.page() in no-footer-pages {
      none
    } else if calc.even(loc.page()) {
      align(right, text(fill: rgb(105,105,105), weight: "light", font: ("Gill Sans"), counter(page).display("1")))
    } else {
      align(left, text(fill: rgb(105,105,105), weight: "light", font: ("Gill Sans"), counter(page).display("1")))
    }
  )
  )
  
  set par(
    first-line-indent: 2em, 
    justify: true
  )
  
  set quote(
    block: true,
    quotes: false
  )
  
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)


  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 50pt,
  stroke: none
)

#set figure(
  placement: auto,
  numbering: none,
)

// HANDLE HEADING FORMATTING

#show heading.where(
  level: 1
): it => block(width: 100%)[
  #set align(center)
  #set text(13pt, weight: "bold", font: ("Gill Sans"))
  #it.body
  #v(1em)
]

#show heading.where(
  level: 2
): it => block(width: 100%)[
  #set align(left)
  #set text(12pt, weight: "bold", font: ("Gill Sans"))
  #it.body
]


#show figure.caption: set align(left)
#show figure.caption: set text(10pt)
#show figure: set block(inset: (top: 0.5em, bottom: 2em))


#set block(spacing: 2em)