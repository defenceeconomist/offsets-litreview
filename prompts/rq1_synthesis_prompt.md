You are writing a realist-style evidence synthesis for **Research Question 1 (RQ1)** using ONLY the provided Context–Mechanism–Outcome (CMO) statements.

RQ1 (MUST USE THIS WORDING)
Alliance relevance and mechanisms — Through what mechanisms do offset or industrial participation policies affect alliance-relevant outcomes such as interoperability, standardisation, security of supply, readiness, and the ability to contribute rapidly to NATO operations?

DEFINITIONS (MUST APPLY)
- Context (C): the conditions that shape whether/how the mechanism fires (institutions, procurement regime, alliance setting, industrial base maturity, governance capacity, export-control environment, programme setting).
- Mechanism (M): a generative causal process, typically framed as:
  (policy resource/constraint) + (actors’ reasoning/response) -> causal force
- Outcome (O): an observed (or credibly reported) effect. Do not overclaim beyond what the CMO states.

INPUTS YOU WILL RECEIVE
- rq_id: "rq1"
- cmo_statements: a list/table of CMO records ALREADY mapped to rq1, with (at minimum) these fields:
  - cmo_id
  - source_file
  - context
  - mechanism
  - outcome
  - context_tags (optional)
  - mechanism_tags (optional)
  - outcome_tags (optional)
  - mechanism_theme_labels (optional; preferred if available)
  - evidence_type
  - confidence (low|medium|high)
  - supporting_evidence_paraphrase

TASK
1) Triage and scope check
   - Use ONLY the provided rq1 CMO statements. If none are provided, say so and stop.
   - Treat `confidence` and `evidence_type` as strength-of-evidence signals (do not “vote count”).
   - Separate what is (a) empirically observed vs (b) conceptual/theoretical vs (c) normative/prescriptive (if evident in wording).

2) Build a mechanism-focused synthesis (RQ1)
   - Identify the main alliance-relevant outcome domains present in the CMOs. Start with:
     interoperability/standardisation; readiness/sustainment; security of supply; partnership durability/trust; (add others only if evidenced).
   - For each outcome domain:
     - Summarise 2–5 distinct mechanism pathways supported by the CMOs.
     - For each pathway, state:
       (i) enabling contexts (what must be true in the setting),
       (ii) the mechanism (what changes in actors’ behaviour/incentives/constraints),
       (iii) the alliance-relevant outcome(s).
     - Cite the supporting CMO IDs inline (at the end of each bullet/paragraph), e.g. (`some_source_pdf__cmo_003`, `other_source_pdf__cmo_001`).
   - If `mechanism_theme_labels` is provided, use it to cluster pathways and name the pathway themes; otherwise cluster using the mechanism text/tags.

3) Handle mixed/contested evidence
   - If CMOs point in different directions for a similar context/mechanism, report the divergence and explain the most plausible contextual moderators (based ONLY on the provided CMO contexts/tags).
   - Do NOT resolve conflicts by inventing missing details.

4) Produce a short “what this suggests for NATO-aligned strategy” section
   - Translate the mechanism synthesis into 4–7 practical, conditional takeaways phrased as:
     “In contexts where X, offsets/IP may support Y via mechanism Z …”
   - Each takeaway must cite at least one CMO ID.
   - Include at least one “boundary condition / risk of overreach” takeaway if the evidence base is mainly conceptual or low-confidence.

OUTPUT FORMAT (MUST FOLLOW)
- Output ONLY the full contents of a single Quarto `.qmd` file (including YAML front matter).
- The output is intended to be saved as `synthesis/rq1.qmd` (do not output the filename separately; just output the file contents).
- Use UK spelling (defence, standardisation).
- Headings MUST be derived from the provided `cmo_statements` (do not force a fixed set of domains).
- Use this structure:

---
title: "RQ1 Synthesis"
format: html
execute:
  echo: false
  message: false
  warning: false
---

## RQ1. Mechanisms Linking Offsets/IP to Alliance-Relevant Outcomes

### Outcome Domains Identified From the RQ1 CMOs
- Create 3–7 outcome domains by clustering the CMOs using outcome text and/or `outcome_tags`.
- Name each domain as a short Title Case heading (UK spelling), and include an approximate count in parentheses, e.g. “Interoperability and Standardisation (n≈8)”.

### <Outcome Domain 1 Title> (n≈#)
<mechanism-focused synthesis for this domain>

### <Outcome Domain 2 Title> (n≈#)
<mechanism-focused synthesis for this domain>

... (repeat for each derived domain)

### Synthesis: Enabling Conditions and Boundary Conditions
<cross-domain synthesis; include contested/mixed evidence and moderators>

### What This Suggests for NATO-Aligned Strategy (Conditional Takeaways)
<4–7 takeaways; each cites CMO IDs>

### Evidence (RQ1-coded CMO statements)
- Include an R code chunk that reads `data/cmo_statements.csv`, filters to RQ1 (`research_questions_mapped` contains `rq1`), and prints a table of: `source_file`, `cmo_id`, `country`, `context_tags`, `mechanism_tags`, `outcome_tags`, `mechanism_theme_labels`, `supporting_evidence_paraphrase`.
- Use exactly this chunk (you may adjust column labels, but do not change the filter logic):

```
df <- read.csv("data/cmo_statements.csv", stringsAsFactors = FALSE, na.strings = "")
rq1 <- df[grepl("(^|;)rq1(;|$)", df[["research_questions_mapped"]]), ]

keep <- rq1[, c(
  "source_file",
  "cmo_id",
  "country",
  "context_tags",
  "mechanism_tags",
  "outcome_tags",
  "mechanism_theme_labels",
  "supporting_evidence_paraphrase"
)]

names(keep) <- c(
  "Source",
  "CMO ID",
  "Country",
  "Context tags",
  "Mechanism tags",
  "Outcome tags",
  "Theme",
  "Supporting evidence (paraphrase)"
)

knitr::kable(keep)
```

QUALITY RULES (MUST FOLLOW)
- No new facts: do not introduce countries/programmes/outcomes not present in the provided CMOs.
- No uncited claims: every substantive claim must cite one or more `cmo_id`s.
- Keep it mechanism-first: contexts and mechanisms drive the structure; do not turn this into a generic literature summary.
- Be explicit about evidence limits (e.g., “conceptual/theoretical source”, “low confidence”, “single-case”).
