#let article(
  chapter: "chapter",
  title: none,
  chtitle: "title",
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 2.8cm, y: 2.8cm),
  width: 21cm,
  height: 29.7cm,
  lang: "en",
  region: "US",
  font: ("Cambria"),
  fontsize: 12pt,
  sectionnumbering: none,
  toc: false,
  toc_title: "Table of Contents",
  toc_depth: 1,
  toc_indent: 0em,
  doc,
  no-header-pages: (1,2,3,4,5,6,7,8,9,10,24,25,26,50,51,52,60,69,81,82,83,84,114,115,116,127,139,140,141,142,154,156,187,188,189,190,210,219,222,226,227,253,254,263,264,271),
  no-footer-pages: (1,2,3,4,5,6,7,8,9,10,24,25,26,50,51,52,60,69,81,82,83,84,114,115,116,127,139,140,141,142,154,156,187,188,189,190,210,219,222,226,227,253,254,263,264,271),
  flipped-pages: (), // Add pages here where headers and footers should be flipped
) = {
  set page(
    height: height,
    width: width,
    margin: margin,
    numbering: "1",
    // Headers are aligned left on even pages, and right on odd pages.
    header: locate(
      loc => if loc.page() in no-header-pages {
        none
      } else if calc.even(loc.page()) {
        align(left, text(11pt, fill: rgb(105,105,105), weight: "light", font: ("Gill Sans"), chapter))
      } else {
        align(right, text(11pt, fill: rgb(105,105,105), weight: "light", font: ("Gill Sans"), chtitle))
      }
    ),
    // Footers are aligned left on even pages, and right on odd pages.
    footer: locate(
      loc => if loc.page() in no-footer-pages {
        none
      } else if calc.even(loc.page()) {
        align(left, text(fill: rgb(105,105,105), weight: "light", font: ("Gill Sans"), counter(page).display("1")))
      } else {
        align(right, text(fill: rgb(105,105,105), weight: "light", font: ("Gill Sans"), counter(page).display("1")))
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
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: 1,
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

// placement: auto ensures that figures are placed in the document dynamically. This prevents whitespace if they do not fit on the current page.
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

// Insert whitespace between paragraphs
#set block(spacing: 2.1em)