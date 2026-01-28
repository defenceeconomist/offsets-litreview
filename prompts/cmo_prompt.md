You are extracting realist-style Context–Mechanism–Outcome (CMO) configurations from ONE document at a time.

DEFINITIONS (MUST APPLY)
- Context (C): The salient conditions that shape whether/how the mechanism fires (e.g., institutional rules, alliance relationships, procurement regime, industrial base maturity, governance capacity, threat environment).
- Mechanism (M): The underlying generative causal process that produces change, typically framed as:
  (programme resources/constraints) + (actors’ reasoning/response) -> causal force
  Mechanisms are NOT the same as activities, outputs, or policies (avoid “setting up an office”, “signing an MoU” as mechanisms).
- Outcome (O): The observed (or credibly reported) effect(s), intended or unintended (e.g., interoperability, security of supply, cost/schedule impacts, corruption risk, industrial capability, alliance integration).

TASK
1) Read document_text carefully.
2) Identify and extract ALL defensible CMO configurations evidenced in the document.
   - Prefer "small" CMOs anchored to a specific claim/passage.
   - Do not stop at the first CMO; include additional distinct CMOs if the text supports them.
   - If the document only implies a CMO, you may still extract it but set confidence to low and make the inference explicit in the paraphrase.
3) Write each C, M, and O concisely (ideally 1–3 sentences each).
4) Create candidate tags in snake_case:
   - context_tags: 1–4
   - mechanism_tags: 1–4
   - outcome_tags: 1–4
5) Populate metadata fields:
   - programme: name of the programme linked to the offset deal (snake_case). If not stated, use unknown_programme (do NOT guess).
   - country: snake_case country name; use multi_country if needed; if not stated, use unknown_country.
   - research_questions_mapped: list of RQ IDs from the list below (e.g., [rq1, rq3])
   - evidence_type: one of
     case_study | comparative_case_study | theory_model | legal_analysis | policy_report | survey_experiment | systematic_review | qualitative_interviews | mixed_methods | other
   - evidence_type_narrative: 1–2 sentences describing what kind of material this is and why you chose evidence_type.
   - supporting_evidence: a SHORT direct quote (max ~25 words) that supports the CMO.
     Use double quotes inside YAML; escape internal quotes.
     If no suitable short quote exists, use "" and rely on paraphrase.
   - supporting_evidence_paraphrase: 1–2 sentences paraphrasing the supporting passage and how it supports the CMO (may note if inference is being made).
   - confidence: low | medium | high based on how directly the text supports the CMO.
   - confidence_justification: 1–2 sentences explaining the confidence rating (e.g., direct explicit CMO vs partial/implicit, specificity of evidence).

VALIDATION AND VERIFICATION (V&V) REQUIREMENTS
- Validate each CMO against the source text:
  - supporting_evidence must directly support the CMO; if not, lower confidence and say so in the paraphrase.
  - If the CMO is inferred, explicitly state that in the paraphrase and set confidence to low.
  - Ensure mechanism is a causal process (not just an activity or policy).
  - Ensure outcomes are effects (observed or credibly reported) and do not overclaim beyond the text.
  - Ensure all tags, programme, and country values are snake_case.
- Produce a V&V log summarizing checks, issues, and any adjustments.

OUTPUT RULES (MUST FOLLOW)
- Output ONLY valid YAML (no markdown, no commentary).
- The YAML top level MUST be a mapping keyed by the FILE NAME exactly as given in file_name.
- Under the file key, include ONLY:
  - cmos: a mapping from unique CMO IDs to CMO objects
  - v_and_v_log: a list of V&V entries (may be empty)
- If you find no defensible CMO, output:
  <file_name>:
    cmos: {}
    v_and_v_log:
      - check: no_defensible_cmo
        status: pass
        note: "No defensible CMO found in this document."
- Each CMO ID MUST be derived from the file name:
  a) Create file_slug by:
     - lowercasing
     - replacing all non-alphanumeric characters with underscores
     - collapsing multiple underscores to one
     - trimming leading/trailing underscores
  b) Append __cmo_### where ### is a zero-padded 3-digit index starting at 001.
- Each CMO object MUST have exactly these keys (and in this order):
  context
  mechanism
  outcome
  context_tags
  mechanism_tags
  outcome_tags
  programme
  country
  evidence_type
  evidence_type_narrative
  research_questions_mapped
  supporting_evidence
  supporting_evidence_paraphrase
  confidence
  confidence_justification
- All tags and programme/country values MUST be snake_case.
- Lists MUST be valid YAML lists (use hyphens).
- Avoid long quotations; do not invent facts not supported by the text.

V&V LOG FORMAT
- Each v_and_v_log entry MUST have exactly these keys:
  check
  status
  note
- status must be one of: pass | warn | fail
- Include at least these checks per file:
  - completeness_all_relevant_cmos
  - evidence_traceability
  - mechanism_is_causal
  - outcome_is_effect
  - snake_case_fields
  - quote_length
  - inference_flagged

RESEARCH QUESTIONS (choose any that fit; can assign multiple per CMO)
- rq1: Alliance relevance and mechanisms — Through what mechanisms do offset or industrial participation policies affect alliance-relevant outcomes such as interoperability, standardisation, security of supply, readiness, and the ability to contribute rapidly to NATO operations?
- rq2: Conditions for durable collaboration — Under what conditions do offsets lead to durable industrial collaboration with allies and close partners (co-development, co-production, licensed production, shared sustainment/MRO, trusted supply chains)?
- rq3: Risks and mitigation — What partnership risks are most commonly associated with offsets (corruption vulnerability, export-control friction, programme fragmentation, market distortion, cost/schedule impacts), and what mitigations/governance designs reduce these risks?
- rq4: Positive comparative cases — Which countries combine continuing offset/industrial participation policy with high allied programme integration, and what design features enable coexistence?
- rq5: Negative or mixed comparative cases — Which countries exhibit offset-related frictions that undermine partnership/alliance integration outcomes, and what policy design features appear implicated?

NOW DO THE EXTRACTION FOR THE PROVIDED INPUTS AND OUTPUT ONLY YAML.
