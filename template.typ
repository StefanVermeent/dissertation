// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: white, width: 100%, inset: 8pt, body))
      }
    )
}


// This is an example typst template (based on the default template that ships
// with Quarto). It defines a typst function named 'article' which provides
// various customization options. This function is called from the 
// 'typst-show.typ' file (which maps Pandoc metadata function arguments)
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-show.typ' entirely. You can find 
// documentation on creating typst templates and some examples here: 
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates


#let article(
  title: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 2cm, y: 2cm),
  paper: "a4",
  lang: "en",
  region: "US",
  font: ("Times New Roman"),
  fontsize: 12pt,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
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
  inset: 6pt,
  stroke: none
)

// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)
//
// This is an example 'typst-show.typ' file (based on the default template  
// that ships with Quarto). It calls the typst function named 'article' which 
// is defined in the 'typst-template.typ' file. 
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-template.typ' entirely. You can find
// documentation on creating typst templates here and some examples here:
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

#show: doc => article(
  title: [Untitled],
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)

= 6.1 Fitting the pieces together
<fitting-the-pieces-together>
~

In the preceding chapters, I applied a methodological approach—grounded in Drift Diffusion Modeling (DDM) and structural equation modeling—to measure executive functioning (EF) abilities in people exposed to adversity. Using DDM, I translated raw performance into three distinct cognitive processes: the speed of evidence accumulation (drift rate), response caution (boundary separation), and speed of stimulus encoding and response execution (non-decision time). Using structural equation modeling, I investigated the extent to which cognitive processes are task-general (shared across tasks) or task-specific (unique to particular tasks). I investigated associations between these cognitive processes and exposure to three types of adversity: threat (all chapters), material deprivation (Chapters 2, 3, and 5), and unpredictability (Chapters 4 and 5). In addition, I investigated associations across different developmental stages, focusing on middle childhood (Chapter 2), young adulthood (Chapter 4), and adulthood (Chapters 3 and 5).

Taken together, my dissertation shows that adversity researchers analyzing raw performance (e.g., mean response time, accuracy) will overestimate the association between adversity exposure and specific EF abilities. This general conclusion is based on three key findings. The first key finding, supported by Chapters 2-4 (but not Chapter 5), is that people with more exposure to adversity show lower task-general processing speed (as measured using DDM’s drift rate parameter). That is, they respond more slowly largely due to cognitive processes that are shared across different EF tasks. The second key finding, also supported by Chapters 2-4, is that after accounting for task-general processing speed, the specific EF abilities of people with more exposure to adversity do not appear to be lower (or higher) than those of people with less exposure to adversity. In fact, in chapter 2, five out of six associations with task-specific drift rates were practically equivalent to zero, suggesting intact processing. The third key finding, supported by Chapters 2 and 4 (but not chapter 3), is that people with more exposure to adversity use different strategies on EF tasks. Specifically, I found that children with more exposure to household threat (but not material deprivation) respond more cautiously (as measured with DDM’s boundary separation parameter), and that young adults with more exposure to childhood threat and unpredictability process information more holistically.

~

= 6.2 Key finding 1: Adversity exposure is associated with task-general processing speed
<key-finding-1-adversity-exposure-is-associated-with-task-general-processing-speed>
~

In the preceding chapters, I interpret the negative association between adversity exposure and task-general drift rate as reflecting lower general speed of processing. This interpretation follows from specific patterns observed in these chapters, and aligns with previous literature. In Chapter 2, the task-general drift rate loaded equally strongly on drift rates of EF tasks as well as a basic processing speed task. Similarly, in Chapter 3, loadings were comparable across experimental conditions of EF tasks (i.e., the switch or incongruent condition, requiring EF ability), non-experimental conditions (i.e., the repeat or congruent condition, not requiring EF ability), and a basic processing speed task (not requiring EF ability). In Chapter 4, performance differences on the Flanker task were explained mostly by the strength of perceptual processing, not by the ability to inhibit distractions. Combined, these results support the view that task-general drift rate captures processes that are not unique to EF tasks.

The processing speed interpretation of task-general drift rate is consistent with recent studies applying DDM to EF tasks @frischkorn_2019@hedge_2021@loffler_2024. These studies found that speed of processing mostly—and in some cases fully—explained shared variance in drift rates across EF tasks. One study found that task-general drift rate correlated only moderately with a general intelligence factor (#emph[r] = .43) and a working memory capacity factor (#emph[r] = .41), while the latter two correlated more strongly with each other (#emph[r] = .76) @loffler_2024. This suggests that the task-general drift rate factor of EF tasks is related to, but conceptually distinct from, general intelligence and working memory capacity.

However, a competing interpretation is that shared variance among EF tasks represents executive attention, which refers to a general ability to focus on task-relevant information while ignoring irrelevant distractions @mashburn_2023@zelazo_2023. Specifically, executive attention is thought to support a person’s ability to #emph[maintain] information in working memory for immediate processing, and to #emph[disengage] from information that is no longer relevant @burgoyne_2020@shipstead_2016. Executive attention can offer a mechanistic explanation for the general factor that accounts for variance across many cognitive tasks, often referred to as general intelligence or #emph[g] @burgoyne_2022. Thus, shared variance across EF tasks could reflect general executive processes, rather than basic processing speed. A similar argument is made by #emph[process-overlap theory];, which states that the general factor reflects a shared dependence on general executive processes @kovacs_2016. Importantly, process-overlap theory does not consider the general factor to be a unitary cognitive process that #emph[causes] differences in specific abilities. Rather, the general factor arises as a statistical artifact as specific cognitive abilities draw from a shared set of general processes @kovacs_2019. This is an important distinction: while the task-general factor may resemble a unitary process in latent models, it could actually arise from a combination of (partially) independent processes.

Task-general drift rate could similarly reflect several processes. Differences in drift rates might reflect a combination of task-specific processes (e.g., EF abilities), state factors (e.g., motivation, fatigue), and trait factors (e.g., general speed of processing, functional or structural brain differences) @weigard_2021b. At the same time, task-general drift rate appears more stable over time @schubert_2016@weigard_2021. It has also shown better external validity, for instance, with self-report measures of self-control, which is conceptually similar to EF @weigard_2021. Thus, processing speed may be but one potential explanation for the negative associations we observed between adversity exposure and task-general drift rate; other explanations may include motivation, stress, fatigue, and a strategic deployment of cognitive resources. This also means that lower task-general drift rate does not necessarily (only) reflect a cognitive deficit.

More work is needed to better understand why exposure to adversity is negatively associated with task-general drift rate. To the extent that it reflects basic processing speed, it could partially be the result of structural brain changes, like reduced white matter tract integrity @fuhrmann_2020@kievit_2016. White matter tracts support information processing and communication between key networks involved in EF @ribeiro_2024. Childhood exposure to threat and deprivation has been associated with reduced white matter tract integrity @mclaughlin_2019. Changes in white matter associated with childhood adversity appear to persist into adulthood @mccarthy_jones_2018, which could explain the associations between childhood adversity and task-general drift rate in adulthood in Chapter 3. Relatedly, early exposure to cognitive deprivation (i.e., a lack of cognitive stimulation) disrupts the development of basic sensory and perceptual processes, which can have negative downstream effects on the development of EF @rosen_2019. Yet, task-general drift rate may at least partly reflect processes that are more context-dependent, such as EF engagement or task familiarity @niebaum_2023, rather than basic processing speed. Some of these processes may be more malleable than basic processing speed, e.g., through task manipulations that increase the familiarity of content, or that make people more willing to exert effort. This could make them valuable targets for interventions.

~

= 6.3 Key finding 2: Adversity exposure is not associated with specific EF abilities
<key-finding-2-adversity-exposure-is-not-associated-with-specific-ef-abilities>
~

A second consistent finding throughout my dissertation is that after controlling for task-general processing speed, adversity exposure is not associated with specific EF abilities, as measured with drift rates. In Chapter 2, I show that children with more exposure to household threat in the preceding year exhibit intact drift rates on an inhibition, attention shifting, and mental rotation task, after accounting for lower task-general processing speed. In addition, material deprivation is associated with intact drift rates on an inhibition and mental rotation task, as well as intact task-general processing speed. Chapter 3 paints a similar, but more nuanced picture, by including two inhibition tasks, three attention-shifting tasks, and a basic processing speed task. After accounting for task-general processing speed, adversity is negatively associated with several task-specific drift rates, particularly effects of childhood threat on attention-shifting tasks. However, the correlations between these task-specific drift rates were low, even between tasks that are thought to measure the same EF ability. Thus, it appears that they do not capture inhibition or attention shifting ability, but rather more unique features of individual tasks. In Chapter 4, which focuses on the Flanker task, young adults’ exposure to childhood threat and unpredictability is not associated with inhibition ability. Rather, their lower performance on the task is mostly driven by lower perceptual processing. Finally, in Chapter 5, exposure to adversity in adulthood is not associated with either working memory updating or working memory capacity.

== Interpreting task-specific associations with adversity exposure
<interpreting-task-specific-associations-with-adversity-exposure>
The finding that adversity exposure is not associated with specific EF abilities is striking given that lower raw performance on EF tasks is often interpreted as such. Such conclusions are often based on performance on a single task. For instance, lower performance on inhibition tasks has been interpreted as lower inhibition ability @farah_2006@fields_2021@mezzacappa_2004@mittal_2015@noble_2005. Similarly, higher performance on attention-shifting tasks has been interpreted as an enhanced attention shifting ability @fields_2021@howard_2020@mittal_2015@nweze_2021@young_2022. My dissertation highlights two crucial limitations of this approach. Task-general processes make it difficult to infer specific abilities based on the performance on a single task, even when using DDM rather than raw performance measures. Even after accounting for task-general processes, though, remaining variance may not capture specific EF abilities (but rather other factors, such as context or familiarity), as suggested by Chapter 3 as well as prior literature @frischkorn_2019@loffler_2024.

One reason could be that content effects mask the effects of specific EF abilities. Task performance is known to vary with task content (e.g., numbers, letters, or geometric shapes), and studies in cognitive psychology often account for this by sampling tasks with different types of content @lerche_2020. Some research shows that people from adversity may be particularly sensitive to content effects, and that their performance on EF tasks could be improved by using more real-world content @young_2022. With the exception of Chapter 2, the studies in this dissertation involved more abstract content, which may be one explanation for lower task-general processing speed. In addition, it may also explain the negative associations in Chapter 3 between childhood adversity and task-specific drift rates on attention-shifting tasks, despite drift rates between tasks correlating weakly. All attention-shifting tasks used abstract content, but the specific type of content differed across tasks. Thus, content effects may have lowered processing on these tasks in specific ways unrelated to the EF ability—the actual target of measurement in these tasks.

== Low reliability of traditional EF tasks
<low-reliability-of-traditional-ef-tasks>
Further down the psychometric path, the elephant in the room is that commonly used EF tasks may not be sufficiently reliable to detect individual differences in EF @draheim_2019@hedge_2018@rouder_2019. Many EF tasks, like the Flanker or Simon task, were developed by experimental psychologists with the aim to obtain robust group-level experimental effects (e.g., the Flanker effect, in which people are on average slower on incongruent trials compared to congruent trials) @cronbach_1957. These tasks achieve this because they minimize within-person variability. However, low within-person variability makes them less suitable for studying individual differences. In fact, a recent study showed that over 1,000 trials are needed to obtain reliable estimates of individual differences in the Stroop or Flanker effect @lee_2023. Needless to say, the studies reported in this dissertation did not even get close to these trial numbers. Nor do the majority of studies in the broader adversity and developmental literature. This is exemplified by the ABCD study, which is currently used in over 1,200 articles (#link("https://abcdstudy.org/publications/");), including the study in Chapter 2. The EF tasks included in the ABCD study contain at most a few dozen trials, with as few as 20 across conditions for the Flanker task.

An inconvenient but important conclusion is that most research in the adversity literature lacks reliable measurements to adequately assess specific EF abilities. In light of this issue, some have argued that large-scale developmental data collections should make fundamentally different trade-offs by lowering the number of participants and increasing the number of trials for cognitive tasks @lee_2023. Although I agree in theory, there are important constraints that make this unfeasible in practice. In most large cohort studies like the ABCD study, cognitive assessments are only a relatively small part, and so the time spend on cognitive tasks trades off with other important measurements. Even disregarding time as a limiting factor, administering hundreds of trials could decrease motivation and effort. These limitations may be especially large when testing children or people from disadvantaged backgrounds @niebaum_2023. The statistical techniques used in my dissertation do not by themselves solve this issue.

~

= 6.4 Key finding 3: Adversity exposure is associated with the use of different strategies
<key-finding-3-adversity-exposure-is-associated-with-the-use-of-different-strategies>
~

My dissertation finds limited evidence that exposure to adversity is associated with the use of different cognitive strategies. First, I find evidence for differences in #emph[speed-accuracy trade offs];, reflecting a person’s response caution. A person with higher response caution uses the strategy (deliberate or not) of slowing down their responses in order to increase their accuracy. In Chapter 2, I find that children who experienced more household threat in the preceding year (but not material deprivation) respond more cautiously than children with less exposure to household threat. However, I do not observe differences in response caution in young adults with more exposure to childhood threat and unpredictability (Chapter 4), nor in adults with more exposure to threat and deprivation in childhood or adulthood (Chapter 3). Thus, although exposure to threat is associated with children prioritizing accuracy over speed, the same is not true for (young) adults. Second, Chapter 4 suggests that young adults with more exposure to childhood threat and unpredictability have a more #emph[holistic processing style];, rather than a detail-oriented processing style.

== Speed-accuracy trade-offs
<speed-accuracy-trade-offs>
The results in Chapter 2 are consistent with research on optimal speed-accuracy trade-offs in the face of threats. Individuals across different species tend to be more cautious if they were recently exposed to sources of threat such as violence or predation @chittka_2009. Making a mistake (e.g., wrongly assuming that there is no predator nearby) can be very costly, and therefore it pays to accumulate more information if past environments tended to be more dangerous. However, the opposite is true in the face of immediate danger. In such cases, responding quickly can prevent serious harm, which, all else being equal, outweighs the potential cost of acting too fast (e.g., failing to seize potential resources) @pirrone_2014.

There is strong evidence that detecting and responding to threat in both scenarios is facilitated by distinct neural pathways: a fast but less accurate pathway in the case of an immediate threat, and a slower but more accurate pathway when there is no immediate threat @ledoux_2000. The first relies on short subcortical pathways that provide rapid but coarse information, and do not involve extensive evidence accumulation. Under conditions of stress, people use simpler and faster stimulus-response learning strategies and rely more on habits @schwabe_2007@schwabe_2009. In contrast, in the absence of immediate threat, processing relies on longer cortical pathways that do engage in evidence accumulation, as modeled using the DDM @trimmer_2008. Chapter 2 is consistent with this theory: the test setting did not convey an immediate threat and so did not require an immediate response, but children with more exposure to threat did accumulate more evidence.

The results of Chapter 3 and 4 are not consistent with this theory, which may be explained by the temporal gap between the exposure to adversity and the testing session. In Chapter 2, this gap was relatively small; children reported on their exposure to threat in the preceding year. Hence, it is likely that their strategies were still attuned to these recent experiences, which would explain their increased response caution. In Chapter 3 and 4, involving (young) adults, the gap was larger, especially when they retroactively reported on exposure to childhood adversity. Even though Chapter 3 did focus on adversity exposure in adulthood, the adversity measures spanned several years and thus did not necessarily reflect recent adversity exposure. It is possible that differences in how people make speed-accuracy trade-offs in response to threat exposure remain plastic, such that a preference for accuracy over speed may diminish or even disappear if threats become less frequent. This is an open and interesting question for future research.

== Holistic versus detail-oriented processing style
<holistic-versus-detail-oriented-processing-style>
Beyond speed-accuracy trade-offs, Chapter 4 also provides evidence for differences in how people with more exposure to childhood adversity process information. Across three studies, the strength of perceptual processing on the Flanker task was lower for people with more exposure to both violence and unpredictability, which may indicate a deficit in information processing. However, the strength of perceptual processing interacted with a person’s processing style. In the context of the Flanker task, strength of perceptual processing refers to the amount of visual information that people extract from the arrows. For people with more exposure to childhood violence (and to a lesser extent unpredictability), lower strength of perceptual processing was related to more holistic processing rather than featural or detail-oriented processing. In contrast, people with less exposure to childhood violence had a higher strength of perceptual processing, which was related to more detail-oriented processing.

Although the interaction between perceptual processing and holistic processing requires more research, I speculate that a more holistic processing style in people with more adversity exposure may (partially) account for lower strength of perceptual processing. It could relate to the speed-accuracy trade-off discussed above: Aside from taking more time to accumulate information, adopting a more holistic processing style facilitates the detection of potential threats compared to a more focused processing style. The Shrinking Spotlight Model used to decompose Flanker performance in Chapter 4 distinguishes between a processing parameter (i.e., strength of perceptual processing) and two attention parameters (i.e., the initial width of the attention scope, and the rate at which attention narrows over time). A more holistic processing style could affect both. On the one hand, holistic processing could lower the strength of perceptual processing as stimuli are processed as a whole instead of as individual sources of information. On the other hand, attention would be spread out more evenly across all stimuli, and narrowing attention down to the central target would be more difficult.

Unfortunately though, I could not accurately recover the two attention parameters in isolation, and instead computed a ratio between them @white_2018a. Future studies with a larger number of trials may be able to recover the attention parameters. Additionally, future research could include more direct measures of attention such as eye-tracking and pupillometry. Previous research suggests that people with a more holistic processing style have fewer fixations on individual items as well as larger saccades @schreiter_2023@schreiter_2024. Thus, it would be insightful to investigate whether such attention features provide a common explanation for holistic processing as well as a lower strength of perceptual processing on inhibition tasks.

~

= 6.4 Developing a roadmap for adversity research
<developing-a-roadmap-for-adversity-research>
~

== Integrating deficit and adaptation frameworks
<integrating-deficit-and-adaptation-frameworks>
Adversity researchers generally acknowledge that exposure to adversity can both impair and lead to adaptations in cognitive abilities @ellis_2022@frankenhuis_2013@frankenhuis_2020@noble_2021. Several studies suggest that the same person can show deficits in some abilities yet enhancements in other abilities. \
For instance, people with more exposure to adversity were slower on inhibition tasks but faster on attention-shifting tasks @mittal_2015@fields_2021, and slower on a working memory capacity task but faster on a working memory updating task @young_2018. As has become clear throughout my dissertation, such comparisons of individual tasks are problematic given that tasks share cognitive processes. A more realistic vantage point appears to be that both types of processes can operate within the same task. Using cognitive modeling, future research will be well-positioned to test more precise predictions about how deficit and adaptation processes interact.

Researchers need to deal with the fact that task performance is influenced by both task-general and ability-specific processes. Deficit frameworks can accommodate impairments in both specific abilities as well as general processing (e.g., associated with impairments in more localized as well as more widely connected brain networks) @sheridan_2014@tucker_drob_2013. Still, as impairments in general and specific processes may have different origins (e.g., functional or structural changes in the brain), differentiating them using cognitive modeling affords testing more precise predictions. Arguably, the existence of task-general processes poses a bigger challenge for adaptation frameworks, which predict that specific types of adversity enhance specific cognitive abilities @ellis_2022@frankenhuis_2013@frankenhuis_2020. Testing such predictions will require accounting for general processes and ideally sampling two or more tasks for each ability.

Abilities enhanced by adversity may even cross the boundaries of traditional EF tasks. For instance, several studies have found that people from lower socioeconomic backgrounds are more attentive to task-irrelevant sounds @dangiulli_2012b@giuliano_2018@hao_2024@stevens_2009. Children from lower socioeconomic backgrounds also appear more attentive to peripheral visual information @mezzacappa_2004. Similarly, exposure to adversity might lead to a more diffuse scope of attention to facilitate tracking the environment for potential threats and opportunities. We did not find support for our initial hypothesis (see the Introduction of Chapter 4) that this might lead people to be better at detecting subtle changes and peripheral stimuli, i.e., an enhanced ability to detect specific stimuli in the broader environment. However, as discussed in section 6.4, we did find more holistic processing. This may be an alternative manifestation of diffuse attention, where people do not so much attend to individual features in the periphery, but rather do so more holistically. Both cognitive modeling and structural equation modeling can help to illuminate such phenotypes and how they affect performance across traditional EF tasks.

Integrating deficit and adaptation frameworks also requires quantifying support in favor of the null hypothesis (i.e., intact ability), rather than only against the null hypothesis (i.e., impaired or enhanced ability) @harms_2013@lakens_2018. Cognitive adaptations may not always lead to enhancements, but could also translate to intact ability, especially when performance is simultaneously influenced by deficits @bignardi_2024@young_2024. Using practical equivalence testing, I found some evidence for intact specific abilities after accounting for task-general processing speed, especially in Chapter 2. Equally importantly, in many cases I found inconclusive results, with evidence supporting neither adversity-related differences nor practical equivalence. Throughout, I have used a standardized effect of 0.1 as the cut-off for practical equivalence, with effects smaller than 0.1 considered practically equivalent to zero. This cut-off is arbitrary: some small effects can have a substantial impact on the population level, and conversely, some effects above 0.1 may not be all that meaningful. As researchers learn more about which effects sizes are associated with meaningful outcomes (and which are not), they can adopt more theory-guided cut-offs.

== Better understanding content and context effects on EF performance
<better-understanding-content-and-context-effects-on-ef-performance>
Some developmental psychologists argue that abstract EF tasks may disadvantage from more disadvantaged backgrounds, e.g., due to less formal education @doebel_2020@frankenhuis_2020@miller_cotto_2022@niebaum_2023. Common EF tasks may disadvantage children from minority groups because they were developed for, and normed based on children from majority groups @miller_cotto_2022. Children from minority groups may in part perform lower because EF tasks are divorced from their everyday experiences and cultural and social norms. They involve unfamiliar researchers and test settings that look nothing like the environments they are used to @doebel_2020. From an adaptive perspective, it has been argued that people may perform best when task conditions, including the stimuli that are used, match the conditions in which they developed their cognitive abilities @frankenhuis_2020. Consistent with this idea, real-world content has been found to affect performance on EF tasks, and in some cases this effect is larger for people with more exposure to adversity @young_2022. Finally, abstract testing conditions may even lower children’s willingness to #emph[engage] EF, for instance, because the task does not seem relevant or because it does not seem worth the effort @niebaum_2023. Thus, to understand the effect of adversity on EF performance, we may need to understand performance in people’s broader ecological context.

Although it is important to develop more equitable and valid EF tasks, such tasks risk the same psychometric limitations that have been central in my dissertation. Researchers should not assume that more ecologically relevant tasks are less susceptible to the influence of general processes and speed-accuracy trade-offs. For instance, different types of content could affect performance through different pathways: it may influence general processes, specific abilities, response caution, or a combination of these and other factors. In any case, cognitive modeling and structural equation modeling can play a key role in better understanding which cognitive processes are affected by different types of task manipulations.

To focus on one example, cognitive modeling can illuminate which dimensions of stimulus content are responsible for closing (or widening) performance gaps. One key dimension may be how #emph[familiar] the content is to the person taking the test, that is, the extent to which a stimulus has been encountered before @niebaum_2023. On the one hand, more familiar task content may increase ability-specific drift rates. For instance, inhibiting distractors may be easier when the target stimulus is more familiar, and keeping track of information in working memory may be easier if the information relates to previous experiences. On the other hand, more familiar task content may increase task-general drift rate, for instance, if familiar content reduces the cognitive burden of the task regardless of the EF ability that is targeted. Performance differences may also arise from other content dimensions, and their influence on performance could stem from other cognitive processes. Stimuli that are more #emph[valenced] could influence response caution (e.g., being more careful when a stimulus makes you anxious) or, in some cases, response bias (e.g., a bias towards threatening stimuli). Finally, real-world stimuli may often be more visually #emph[complex] than standard abstract stimuli (e.g., numbers, shapes). This could make it more difficult to visually encode the stimulus, increasing non-decision times. Testing these effects using cognitive modeling can illuminate if and why certain types of content negatively or positively affect performance.

~

= 6.6 Concluding remarks
<concluding-remarks>
~

#set quote(block: true, attribution: Stephen J. Gould, The mismeasure of man, 1980)

We pass through this world but once. Few tragedies can be more extensive than the stunting of life, few injustices deeper than the denial of an opportunity to strive or even to hope, by a limit imposed from without, but falsely identified as lying within.
~

Cognitive assessments affect millions of lives each year. Performance scores influence academic trajectories, selection of people into jobs, and are at the basis for a variety of interventions and policies. They also shape how people view their own potential, and how their potential is viewed by others. It is therefore crucial that our interpretations of cognitive performance accurately reflect a person’s ability. My dissertation shows that for people from adverse environments, who tend to perform lower on cognitive tasks, this may often not be so. Hence, research may underestimate a person’s true EF abilities, and attempt to fix things that are not actually 'broken', while potentially overlooking areas requiring attention. Fortunately, adversity researchers can stand on the shoulders of decades of research in cognitive psychology that allows for a more precise assessment of cognitive abilities. In particular, cognitive modeling will be an indispensable instrument in the toolbox of the next generation of adversity researchers.

The use of DDM and structural equation modeling need not be limited to basic scientific research; instead, it could be directly used in applied contexts, such as clinical or high-stakes testing. Now that digital testing is widespread and affordable, there is no good reason to hold onto raw performance measures. Instead, screening and assessment batteries could directly incorporate DDM and structural equation modeling to provide more meaningful estimates of cognitive processes. Beyond that initial step, insights from these techniques could be used to tailor assessments to individuals. For instance, based on future scientific insights, assessment batteries could personalize instructions and task content in response to initial estimates of cognitive processes, and track their change over time. This way, cognitive modeling has the potential to directly impact children’s and adults’ lives.

 

#set bibliography(style: "bib-files/apa.csl")


#bibliography("bib-files/references.bib")

