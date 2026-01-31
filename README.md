# Offsets Realist Evidence Synthesis (RES) Workflow

This repo supports a realist evidence synthesis workflow for offsets / industrial participation: extract defensible CMO configurations from individual documents, then synthesise them into mechanism-focused, conditional explanations (middle-range propositions) aligned to the research questions.

## Repository Structure (What Lives Where)

- Sources (PDFs, etc.): `data-raw/`
- CMO extractions (per source YAML): `data/cmo/`
- Consolidated analysis table: `data/cmo_statements.csv`
- Prompt templates (LLM instructions): `prompts/`
- Synthesis outputs (Quarto docs): `reporting/synthesis/`
- Exploration UI:
  - CMO-Explorer: `apps/cmo-explorer`

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
- For now, prefer the `.yml` extension for files under `cmo/` because `build_cmo_tables()` currently scans `cmo/` for `*.yml`.
- The `supporting_evidence` quote is capped (≈25 words): it is there to keep traceability tight.
- Use `unknown_programme` / `unknown_country` when the document does not state them (don’t guess).

### 2) Consolidate YAML into a single analysis table

This turns all extracted CMOs into a flat table used by the explorer and synthesis docs.

- Function: `R/build_cmo_tables.R`
- Output: `data/cmo_statements.csv`

Run:

```sh
Rscript -e "source('R/consolidate_cmo.R'); consolidate_cmo()"
```
ross-case patterning).

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

Practical, file-based flow for themes:

**3a) Create initial proto-themes (batch 1)**
- Input data: `data/cmo_statements.csv` (columns: `chunk_id`, `mechanism_statement`).
- Intermediate input (recommended): save the batch you send to the model, e.g. `data/mechanism_themes/batches/batch_001_input.txt`.
- Prompt: `prompts/initial_mechanism_themes.md`.
- Output (strict YAML): `data/mechanism_themes/proto_themes.yml`.
- Optional log (recommended): save the full model response for traceability, e.g. `data/mechanism_themes/logs/batch_001_output.yml`.

**3b) Iterate themes with new mechanisms (subsequent batches)**
- Inputs:
  - Existing themes: `data/mechanism_themes/proto_themes.yml`.
  - New mechanism batch (same shape as above), e.g. `data/mechanism_themes/batches/batch_002_input.txt`.
- Prompt: `prompts/iterate_mechanism_theme.md`.
- Output (strict YAML): updated themes file, either overwrite `data/mechanism_themes/proto_themes.yml` or version it (e.g. `data/mechanism_themes/proto_themes_v02.yml`).
- Optional log (recommended): save the model response for each batch, e.g. `data/mechanism_themes/logs/batch_002_output.yml`.

Notes:
- Keep all outputs **YAML-only** (no prose), matching the prompt’s schema.
- Ensure the `chunk_id` values in batches are preserved exactly in outputs.


### 4) Contextual patterning (CMO demi-regularities)

**Purpose:** for each mechanism theme, infer “demi-regularities” that describe when/how it tends to produce particular outcomes.

**Inputs**
- Theme definitions + CMO-to-theme mapping: `data/mechanism_themes/proto_themes.yml` (`theme_id`, `theme_label`, `mechanisms[].id`).
- CMO records + tags: `data/cmo/*.yml` (fields like `context`, `context_tags`, `mechanism`, `mechanism_tags`, `outcome`, `outcome_tags`, `research_questions_mapped`, evidence).
- Optional (for quick filtering/counts): `data/cmo_statements.csv` (note: this is currently a *flat* table and does not include the tag lists).

**Outputs**
- Per-theme C→M→O statements of the form “In contexts where X, mechanism Z tends to yield Y…”, each with:
  - supporting CMO IDs (`chunk_id`)
  - moderators/boundary conditions (counterexamples + what differs)
- Where to store: embed directly in an RQ synthesis doc (e.g. `reporting/synthesis/rq1.qmd`) or create a per-theme Quarto note (e.g. `reporting/patterns/PM1.qmd`) if you want a reusable theme library.

### 5) Re-describe outcomes at a higher level (outcome families)

**Purpose:** normalize messy, specific outcomes into a small set of “outcome families” aligned to the research questions.

**Inputs**
- Outcome statements + existing tags: `data/cmo/*.yml` (`outcome`, `outcome_tags`) and/or `data/cmo_statements.csv` (`outcome_statement`).
- Your current RQ framing (implicitly via `research_questions_mapped` and the synthesis doc outline).

**Outputs**
- Updated/cleaned `outcome_tags` in `data/cmo/*.yml` (consistent families + sub-tags as needed).
- Refreshed `data/cmo_statements.csv` after re-running consolidation (so any rewritten outcome text is reflected in the working table).

### 6) Build CMO chains (mechanisms rarely travel alone)

**Purpose:** connect CMOs into plausible downstream pathways (mechanisms rarely travel alone).

**Inputs**
- A set of related CMOs (by theme, outcome family, and/or RQ): `data/cmo/*.yml` and/or `data/cmo_statements.csv`.
- Demi-regularities from step 4 (to provide “linking logic” and moderators).

**Outputs**
- One or more chain candidates (ordered links), e.g. “Offset design → vendor behaviour → depth of transfer → capability trajectory → alliance-relevant effects”, each citing the supporting CMO IDs.
- Where to store: usually embedded in the relevant RQ synthesis doc (e.g. `reporting/synthesis/rq1.qmd`), optionally with a diagram (Mermaid) for reuse.

### 7) Turn patterns into propositions (middle-range explanations)

**Purpose:** convert patterns into defensible, mechanism-informed conditional propositions (middle-range explanations).

**Inputs**
- Demi-regularities (step 4), outcome families (step 5), and any chain candidates (step 6).
- CMO IDs + evidence (for traceability): `data/cmo/*.yml` (and the corresponding rows in `data/cmo_statements.csv`).

**Outputs**
- A small set of propositions of the form “When X context holds, offsets/IP may support Y via mechanism Z…”, each:
  - citing the supporting CMO IDs
  - stating boundary conditions when evidence is mixed or mainly conceptual
- Where to store: typically as a section in the relevant RQ synthesis doc (e.g. “Conditional takeaways” in `reporting/synthesis/rq1.qmd`).

### 8) Write RQ-focused synthesis outputs

**Purpose:** produce the “deliverable” narrative per research question (mechanism-first, CMO-cited).

**Inputs**
- Working table: `data/cmo_statements.csv` filtered to the target RQ (`research_question_mapped`).
- Theme structure (optional but recommended): `data/mechanism_themes/proto_themes.yml` (to organise the narrative mechanism-first).
- Your outcome families, propositions, and chains from steps 5–7.

**Outputs**
- Quarto synthesis doc per RQ, e.g. `reporting/synthesis/rq1.qmd`.
- Rendered HTML under `_output/` when you run `quarto render`.

### 9) Optional: exploration notebooks (for sensemaking, not “truth”)

**Purpose:** exploratory analysis to help you see patterns (not a replacement for realist inference or V&V).

**Inputs**
- Usually: `data/cmo_statements.csv`.
- Sometimes: `data/mechanism_themes/proto_themes.yml` and cached artifacts (e.g. `data/embeddings_cache.sqlite`).

**Outputs**
- Analysis notebooks in `reporting/analysis/` rendered to `_output/reporting/analysis/` (plus any cached artifacts written under `data/`).

**Current notebooks**
- `reporting/analysis/mechanism-cosine-similarity.qmd` (mechanism embeddings/similarity; writes embedding artifacts under `data/`)
- `reporting/analysis/theme-by-rq-crosstab.qmd` (counts CMOs by mechanism theme × research question)

## Realist Quality Checks (V&V)

Every extracted CMO should pass a quick realist “test”:
- Does the **quote/paraphrase** actually support the CMO claim?
- Is **context** a condition (not an activity)?
- Is **mechanism** a generative process (resources/constraints + reasoning/response → causal force)?
- Is **outcome** an effect (not a plan/activity)?
- Are inferences flagged and confidence lowered accordingly?

The extractor prompt enforces these checks via each document’s `v_and_v_log`.
