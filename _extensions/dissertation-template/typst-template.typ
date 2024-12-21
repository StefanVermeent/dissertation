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
  no-header-pages: (1,2,3,4,17,18,19,20,44,45,46,75,76,77,78,107,108,109,110,121,133,134,135,136,145,146,179,180,181,182,203,204,213,216,246,256),
  no-footer-pages: (1,2,3,4,17,18,19,20,44,45,46,75,76,77,78,107,108,109,110,121,133,134,135,136,145,146,179,180,181,182,203,204,213,216,246,256),
  flipped-pages: (54,63,123), // Add pages here where headers and footers should be flipped
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
    // Headers are aligned left on even pages, and right on odd pages.
    header: locate(
      loc => if loc.page() in no-header-pages {
        none
      } else if loc.page() in flipped-pages {
        // Flipped headers
        if calc.even(loc.page()) {
          none
        } else {
          none
        }
      } else if calc.even(loc.page()) {
        align(right, text(11pt, fill: rgb(105,105,105), weight: "light", font: ("Gill Sans"), chapter))
      } else {
        align(left, text(11pt, fill: rgb(105,105,105), weight: "light", font: ("Gill Sans"), chtitle))
      }
    ),
    // Footers are aligned left on even pages, and right on odd pages.
    footer: locate(
      loc => if loc.page() in no-footer-pages {
        none
      } else if loc.page() in flipped-pages {
        // Flipped footers
        if calc.even(loc.page()) {
          place(
            dx: 25cm,  // Adjust X position for right alignment
           dy: -16.4cm, // Adjust Y position for footer placement
            rotate(-90deg, 
              text(fill: rgb(105,105,105), weight: "light", font: ("Gill Sans"), counter(page).display("1"))
            )
          )
        } else {
          place(
           dx: 25cm, // Adjust X position for left alignment
            dy: -0.7cm, // Adjust Y position for footer placement
            rotate(-90deg, 
              text(fill: rgb(105,105,105), weight: "light", font: ("Gill Sans"), counter(page).display("1"))
            )
          )
        }
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
#set block(spacing: 2em)