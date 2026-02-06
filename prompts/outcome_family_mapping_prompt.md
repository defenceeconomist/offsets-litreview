You are normalizing realist-style CMO *outcomes* into a small, consistent set of **outcome families**.

Goal: create a stable taxonomy that makes it easy to analyze patterns by research question (RQ) without losing traceability to the original CMO statements.

INPUTS YOU WILL RECEIVE
- `cmo_yml_files`: one or more YAML documents in the same structure as `data/cmo/*.yml`.
  - Each file is a mapping: `<source_doc_id> -> { cmos: { <cmo_id>: { outcome: "...", ... } } }`

TASK (DO ALL)
1) Propose/confirm a small set of outcome families (prefer ~8–12 families + an `other_unclear` bucket).
2) Assign **every CMO outcome** to exactly one outcome family.
3) For each assignment, provide a short rationale and a confidence rating.
4) Output a single YAML file (schema below) that can be saved as `data/outcome_family_mapping.yml`.

OUTCOME FAMILY GUIDELINES (MUST APPLY)
- Families should describe the *effect/change* (outcome), not the policy instrument or mechanism.
  - OK: "Procurement cost & schedule performance"
  - NOT OK: "Offsets as industrial policy" (that is a policy framing, not an outcome)
- Prefer families that align with the project’s RQ framing:
  - rq1: alliance relevance (interoperability, security of supply, readiness)
  - rq2: durable collaboration (co-dev/co-prod, supply chains, MRO integration)
  - rq3: risks and mitigations (corruption vulnerability, export-control friction, programme fragmentation, cost/schedule impacts)
  - rq4–rq5: positive/negative comparative cases (patterns of integration vs friction)
- If an outcome statement contains multiple effects, assign the *primary* effect family and mention the secondary effect in `notes`.
- Keep family labels stable and non-overlapping; adjust boundaries rather than adding many near-duplicates.

STARTING CANDIDATE FAMILY SET (YOU MAY REFINE)
Use these as the initial taxonomy:
- `alliance_security_outcomes`: interoperability, standardization, readiness, security of supply, allied integration effects.
- `industrial_capability_and_base`: defense-industrial capacity, self-reliance, sector growth/decline, aerospace/sector-specific development.
- `technology_transfer_and_learning`: technology transfer depth/quality, absorptive capacity, skills, know-how, learning constraints.
- `partnerships_and_supply_chains`: joint ventures, co-production, long-term collaboration, supplier network integration, export-oriented linkages.
- `procurement_performance`: cost premiums, delays, efficiency, procurement process burdens, distortion of choices.
- `governance_compliance_and_evaluation`: monitoring, compliance/fulfilment, credit accounting, transparency, evaluation quality, institutional governance.
- `domestic_economic_benefits`: jobs, investment, regional development, local content impacts as *economic* outcomes (not capability per se).
- `trade_finance_and_market_effects`: trade balance, countertrade, financing constraints, market access/pricing effects.
- `policy_and_institutional_dynamics`: persistence/termination of offset regimes, policy shifts, institutionalization effects (treat as outcomes when the statement is explicitly about policy evolution).
- `other_unclear`: only when none fit; include why it’s unclear and suggest a better family if patterns recur.

OUTPUT SCHEMA (MUST FOLLOW)
- Output ONLY valid YAML (no markdown, no commentary).
- Top-level keys MUST be exactly:
  - `schema_version`
  - `families`
  - `assignments`
  - `v_and_v_log`
- `schema_version` must be `1`.
- `families` must be a mapping keyed by `family_id` (snake_case), with values containing exactly:
  - `label`
  - `description`
  - `seed_topic_model_labels` (a list; can be empty)
- `assignments` must be a mapping keyed by `cmo_id` (exactly as in `cmo_yml_files`), with values containing exactly:
  - `outcome_text` (verbatim from the CMO)
  - `family_id` (must exist in `families`)
  - `confidence` (low | medium | high)
  - `rationale` (1–2 sentences)
  - `notes` ("" allowed)
- `v_and_v_log` must be a list of entries, each with exactly:
  - `check`
  - `status` (pass | warn | fail)
  - `note`

V&V CHECKS (INCLUDE AT LEAST THESE IN `v_and_v_log`)
- coverage_all_cmos_assigned (every CMO ID got an assignment)
- single_family_per_outcome (exactly one family each)
- family_labels_stable (no near-duplicate families without justification)
- outcome_not_mechanism_or_policy (warn if many assignments feel like mechanisms/policies)
- other_bucket_rate (warn if `other_unclear` is >10%)
- topic_model_alignment_sanity (pass if seed labels broadly match the family meanings)

NOW PRODUCE THE YAML OUTPUT.

