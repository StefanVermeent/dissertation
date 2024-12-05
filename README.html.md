---
title: "README"
format: html
editor: visual
keep-md: true
---




# Dissertation

## Description

This repository contains all the files necessary to produce my PhD dissertation.
Formatting was handled using [typst](https://typst.app/docs/) in combination with [Quarto](https://quarto.org/docs/output-formats/typst.html) using a custom template.
Feel free to use this template for your own dissertation or similar document, and to adapt it in any way you require.

## Reproducibility

The online version of this repository does not contain folders including data and analysis objects.
Therefore, you won't be able to render my dissertation yourself. 
If you would like to reproduce/check out source code of specific chapters, please refer to their respective GitHub repositories:

    1. Chapter 1: N/A, written specifically for the dissertation
    2. Chapter 2: <stefanvermeent.github.io/abcd_ddm/>
    3. Chapter 3: <stefanvermeent.github.io/liss_ef_2024/>
    4. Chapter 4: <stefanvermeent.github.io/attention_project/>
    5. Chapter 5: <stefanvermeent.github.io/liss_wm_profiles_2023/>
    6. Chapter 6: N/A, written specifically for the dissertation

## Directory structure

1.  [`chapters`](https://github.com/StefanVermeent/dissertation/tree/main/chapters): Quarto files for frontwork, chapters, and backwork. One file per chapter.
2.  [`data`](https://github.com/StefanVermeent/dissertation/tree/main/data): contains data objects required for rendering the chapters.
3.  [`staged_results`](https://github.com/StefanVermeent/dissertation/tree/main/staged_results): contains analysis objects required for rendering the chapters.
4.  [`functions`](https://github.com/StefanVermeent/dissertation/tree/main/functions): Custom functions.
5.  [`figures`](https://github.com/StefanVermeent/dissertation/tree/main/figures): All Figures that are not rendered from code.
5.  [`_extensions`](https://github.com/StefanVermeent/dissertation/tree/main/_extensions): Template files that handle the formatting and typesetting. See below for more information.

## Usage

### typst

Typesetting and formatting is done using [typst](https://typst.app/docs/).
Typst is an alternative to LaTeX as a markup-based typesetting system.
Most of the typesetting and formatting is handled by the file [typst-template.typ](https://github.com/StefanVermeent/dissertation/tree/main/functions), located under `/_extensions/dissertation-template`.
Changes made in this document (e.g., fonts, behavior of headers and footers) applies to the entire document.
See [this link](https://quarto.org/docs/output-formats/typst.html) for more information about using typst in conjunction with Quarto.

### Rendering

The dissertation is rendered in [dissertation.qmd](https://github.com/StefanVermeent/dissertation/blob/main/dissertation.qmd).
`dissertation.qmd` collects all the different sections of the dissertation---frontmatter, the chapters, and backmatter---and combines them all into a single pdf. 
Each section (e.g., different chapters) has their own `.qmd` file, located in [chapters](https://github.com/StefanVermeent/dissertation/tree/main/chapters.qmd).
They are called in `dissertation.qmd` using `{{< include chapters/filename.qmd >}}`.