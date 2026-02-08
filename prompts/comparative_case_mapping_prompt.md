You are extracting a **comparative case mapping** from ONE document (PDF) at a time.

GOAL
Create structured, comparable case records for **countries and programmes** discussed in the document, using a consistent rubric:
1) policy design
2) depth of collaboration
3) alliance integration markers
4) documented risks

IMPORTANT (NON-NEGOTIABLE)
- Do NOT guess. If a field is not supported by the document_text, set it to null / unknown_* and record it in unknowns.
- Evidence traceability matters: attach short quotes (≤ ~25 words) and page references wherever possible.
- Output ONLY valid YAML (no markdown, no commentary).

INPUTS YOU WILL RECEIVE
- file_name: the exact PDF filename (e.g., "some_report.pdf")
- document_text: plain text extracted from the PDF (may include page markers like "p. 12", "Page 12", "[PAGE 12]" or form-feed separators)
- target (optional): if provided, focus ONLY on that country/programme; otherwise extract ALL defensible cases mentioned
  - target_country: string or null
  - target_programme: string or null

DEFINITIONS (APPLY STRICTLY)
- Case: a document-supported description of a country and a specific programme/deal/policy instance OR a country-level offsets/industrial participation regime if programmes are not separable.
- Programme: the named procurement programme / offset deal / industrial participation scheme being discussed. If the document is only country-level policy, use unknown_programme and treat the policy as the "programme" in narrative fields.
- Evidence item: a traceable support unit with {page, quote, paraphrase}. If page cannot be determined from document_text, use null.

RUBRIC (CONSISTENT STRUCTURE ACROSS CASES)
For each case, populate these four rubric blocks. Each block MUST include:
- summary: 1–3 sentences grounded in the text
- rating: an integer 0–3 OR null if insufficient evidence
- rating_justification: 1–2 sentences explaining the rating, explicitly tied to the evidence provided
- evidence: 1+ evidence_items if anything substantive is claimed; otherwise []

Rating guidance (use consistently; do not over-interpret):
- null = insufficient evidence in document_text (default if unclear or not stated)
- 0 = explicitly described as absent/none/minimal
- 1 = present but shallow/limited (mention-level or narrow)
- 2 = present and substantive (clear, multi-faceted, with some specifics)
- 3 = present and deep/integrated (institutionalised, sustained, multi-dimensional, with strong specifics)

POLICY DESIGN (what is the policy/programme design?)
Capture design features such as: mandatory vs voluntary; direct vs indirect; thresholds; % requirements; eligible activities; multipliers/credits; governance/implementing agency; compliance/enforcement; transparency/reporting; objectives (capability, jobs, ToT, exports); evaluation/audit references.

DEPTH OF COLLABORATION (what kind of industrial/defence collaboration actually occurs?)
Capture: ToT/training; licensed production; assembly; local content; joint venture; co-development; shared sustainment/MRO; R&D collaboration; supply-chain integration; interoperability/standards work; long-term partnering.

ALLIANCE INTEGRATION MARKERS (signals of alignment/integration with alliances/partners)
Capture markers explicitly mentioned, e.g.: NATO/EU/EDA/PESCO/OCCAR/NSPA participation; FMS; interoperability standards (STANAGs, etc.); joint programmes; common platforms; shared basing/exercises; intelligence/security agreements; export-control alignment/friction; trusted supply-chain initiatives.

DOCUMENTED RISKS (what risks are documented, and how?)
Capture risks explicitly documented: corruption/opacity; cost inflation; schedule delays; market distortion; capability shortfalls; export-control/IP restrictions; technology leakage; dependence/lock-in; political backlash; legal challenges; alliance friction; governance failure; data unreliability; offset non-fulfilment.

TASK
1) Read document_text carefully.
2) Identify ALL distinct defensible cases (country + programme or country policy case).
   - If target_country/target_programme are provided, extract ONLY matching case(s).
3) For each case, populate:
   - country (snake_case; or unknown_country)
   - programme (snake_case; or unknown_programme)
   - case_title: short human-readable label (string)
   - timeframe: a string like "1999–2004" OR null
   - domain: one of [air, land, maritime, space, cyber, multi_domain, defence_industrial_policy, unknown] (choose best fit)
   - actors:
       - buyer_country: snake_case or unknown_country
       - supplier_countries: YAML list (may be empty)
       - local_firms: YAML list (may be empty)
       - foreign_firms: YAML list (may be empty)
   - policy_design (rubric block)
   - collaboration_depth (rubric block)
   - alliance_integration_markers (rubric block)
   - documented_risks (rubric block)
   - comparability_tags: YAML list of short snake_case tags (e.g., [mandatory_offsets, licensed_production, nato_interoperability])
   - unknowns: YAML list of missing-but-relevant items the document does NOT provide (e.g., ["offset_percentage", "enforcement_penalties"])
   - notes: brief, document-grounded clarifications (string; may be "")

EVIDENCE ITEM FORMAT (used inside each rubric block)
Each evidence item MUST have exactly these keys:
- page: integer OR null
- quote: a SHORT direct quote (≤ ~25 words). Use double quotes inside YAML; escape internal quotes.
- paraphrase: 1 sentence explaining what the quote supports.

VALIDATION AND VERIFICATION (V&V) REQUIREMENTS
- Every rating must be defensible from the provided evidence items.
- If a rubric block has rating != null, it should usually have >= 1 evidence item.
- If you infer anything, set rating to null (or lower it) and explicitly state the limitation in rating_justification and unknowns.
- Keep quotes short; do not paste long passages.
- country and programme MUST be snake_case.

OUTPUT RULES (MUST FOLLOW)
- Output ONLY valid YAML (no markdown, no commentary).
- The YAML top level MUST be a mapping keyed by the FILE NAME exactly as given in file_name.
- Under the file key, include ONLY:
  - cases: a mapping from unique CASE IDs to case objects
  - v_and_v_log: a list of V&V entries (may be empty)
- If you find no defensible case, output:
  <file_name>:
    cases: {}
    v_and_v_log:
      - check: no_defensible_case
        status: pass
        note: "No defensible comparative case mapping found in this document."

CASE ID RULES
- Each CASE ID MUST be derived from the file name:
  a) Create file_slug by:
     - lowercasing
     - replacing all non-alphanumeric characters with underscores
     - collapsing multiple underscores to one
     - trimming leading/trailing underscores
  b) Append __case_### where ### is a zero-padded 3-digit index starting at 001.

CASE OBJECT KEYS (MUST APPEAR IN THIS ORDER)
country
programme
case_title
timeframe
domain
actors
policy_design
collaboration_depth
alliance_integration_markers
documented_risks
comparability_tags
unknowns
notes

RUBRIC BLOCK KEYS (MUST APPEAR IN THIS ORDER)
summary
rating
rating_justification
evidence

V&V LOG FORMAT
- Each v_and_v_log entry MUST have exactly these keys:
  check
  status
  note
- status must be one of: pass | warn | fail
- Include at least these checks per file:
  - completeness_all_relevant_cases
  - evidence_traceability
  - rubric_consistency
  - snake_case_fields
  - quote_length
  - ratings_defensible

NOW DO THE EXTRACTION FOR THE PROVIDED INPUTS AND OUTPUT ONLY YAML.
