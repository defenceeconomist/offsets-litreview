# Offsets Realist Evidence Synthesis (RES) Workflow

This repo supports a realist evidence synthesis workflow for offsets / industrial participation: extract defensible CMO configurations from individual documents, then synthesise them into mechanism-focused, conditional explanations (middle-range propositions) aligned to the research questions.

## Repository Structure (What Lives Where)

- Sources (PDFs, etc.): `data-raw/`
- CMO extractions (per source YAML): `data/cmo/`
- Consolidated analysis table: `data/cmo_statements.csv`
- Prompt templates (LLM instructions): `prompts/`
- Synthesis outputs (Quarto docs): `synthesis/`
- Exploration UI:
  - Shiny app: `apps/app.R`

## Workflow (Operational)

### 0) Decide the unit of extraction

This workflow assumes **one document at a time** (paper/report/chapter PDF). Each document produces:
- a set of CMO records (with evidence quotes + paraphrase + confidence), and
- a small V&V log.

### 1) Extract CMO configurations (per document)

- Prompt: `prompts/cmo_prompt.md`
- Output: a YAML file in `cmo/` (e.g. `cmo/articles.yml`, `cmo/arms_trade_offsets_chapters.yml`)

Expected YAML shape (top-level is a mapping keyed by the source file name):

```yaml
some_document.pdf:
  cmos:
    some_document_pdf__cmo_001: { ... }
  v_and_v_log:
    - check: evidence_traceability
      status: pass
      note: "..."
```

Notes:
- Store **one or many documents per YAML file** (e.g. one YAML per “batch”/corpus), but keep the per-document keying as above.
- For now, prefer the `.yml` extension for files under `cmo/` because `consolidate_cmo()` currently scans `cmo/` for `*.yml`.
- The `supporting_evidence` quote is capped (≈25 words): it is there to keep traceability tight.
- Use `unknown_programme` / `unknown_country` when the document does not state them (don’t guess).

### 2) Consolidate YAML into a single analysis table

This turns all extracted CMOs into a flat table used by the explorer and synthesis docs.

- Function: `R/consolidate_cmo.R`
- Output: `data/cmo_statements.csv`

Run:

```sh
Rscript -e "source('R/consolidate_cmo.R'); consolidate_cmo()"
```

Tag normalisation:
- `consolidate_cmo()` reads `cmo/normalised_tags.yml` to map aliases into stable tag IDs.
- Keep tags short and reusable (they become the handles for cross-case patterning).

### 3) Mechanism-first clustering (the start of the synthesis)

When you have a stack of CMOs, the goal is not to count them: it’s to build **middle-range explanations** about what works, for whom, under what conditions.

Operationally in this repo:
- Use `data/cmo_statements.csv` as the working table.
- Use (or add) tags/labels to support clustering and pattern detection:
  - `mechanism_tags`: the “engine” (cluster these first).
  - `context_tags`: the key conditions that modulate mechanisms.
  - `outcome_tags`: outcome families aligned to RQs.

Suggested workflow:
1. Pull all mechanisms into view (via the explorer), and create **proto-themes** by grouping similar mechanism statements.
2. Encode those proto-themes consistently via `mechanism_tags` (and, if you add a column, `mechanism_theme_labels`).

Explorer options:
- Shiny: run `Rscript apps/app.R` (or open in RStudio and run)
- Quarto: render `pages/explorer.qmd` and use the web UI

### 4) Contextual patterning (CMO demi-regularities)

For each mechanism theme, look for context patterns that change how/when it fires:

- “In contexts where X, mechanism Z tends to yield Y…”

Practical approach:
- Filter to one mechanism theme/tag at a time.
- Compare contexts (`context` + `context_tags`) and outcomes (`outcome` + `outcome_tags`) to identify moderators and boundary conditions.

### 5) Re-describe outcomes at a higher level (outcome families)

Outcomes are often messy and specific. Group them into a small set of outcome families that match the research questions (e.g. interoperability/standardisation; readiness/sustainment; security of supply; partnership durability; programme performance; risk/governance).

In this repo, that grouping is expressed through `outcome_tags` (and then used during RQ synthesis).

### 6) Build CMO chains (mechanisms rarely travel alone)

Where the evidence supports it, link CMOs into causal chains (downstream effects):

- Offset design → vendor behaviour → depth of transfer → capability trajectory → alliance-relevant effects

Chains often become the backbone of the synthesis narrative and diagrams.

### 7) Turn patterns into propositions (middle-range explanations)

Write mechanism-informed, conditional propositions:

- “When X context holds, offsets/IP may support Y via mechanism Z…”

These propositions should:
- cite the supporting CMO IDs, and
- state boundary conditions when evidence is mixed or mainly conceptual.

### 8) Write RQ-focused synthesis outputs

- RQ1 synthesis prompt: `prompts/rq1_synthesis_prompt.md`
- Output target: `synthesis/rq1.qmd`

The intended flow is:
1. Filter `data/cmo_statements.csv` to the target RQ.
2. Draft the synthesis using CMOs (mechanism-first), citing CMO IDs.
3. Save/update the Quarto document in `synthesis/`.

### 9) Optional: outcome-topic exploration (for sensemaking, not “truth”)

- Notebook: `analysis/outcome-topic-model.qmd`
- Script: `scripts/outcome_topic_model.py`
- Dependencies: `requirements.txt`

This can help surface recurring outcome language for tagging/outcome-family work, but it does not replace realist inference or V&V.

## Realist Quality Checks (V&V)

Every extracted CMO should pass a quick realist “test”:
- Does the **quote/paraphrase** actually support the CMO claim?
- Is **context** a condition (not an activity)?
- Is **mechanism** a generative process (resources/constraints + reasoning/response → causal force)?
- Is **outcome** an effect (not a plan/activity)?
- Are inferences flagged and confidence lowered accordingly?

The extractor prompt enforces these checks via each document’s `v_and_v_log`.
