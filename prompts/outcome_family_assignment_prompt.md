You are assigning realist-style CMO *outcomes* into an existing, fixed set of **outcome families**.

Goal: extend `data/outcome_family_mapping.yml` so that **every CMO outcome in `data/cmo/*.yml`** is assigned to exactly one already-defined family, without changing the family definitions or previously-made assignments.

INPUTS YOU WILL RECEIVE
- `cmo_yml_files`: one or more YAML documents in the same structure as `data/cmo/*.yml`.
  - Each file is a mapping: `<source_doc_id> -> { cmos: { <cmo_id>: { outcome: "...", outcome_tags: [...], ... } } }`
- `existing_outcome_family_mapping_yml`: the current contents of `data/outcome_family_mapping.yml`.
  - It contains `families` (authoritative definitions) and may contain partial `assignments`.

TASK (DO ALL)
1) **Lock the family set**: Treat `existing_outcome_family_mapping_yml.families` as the *only* valid family set.
   - Do **not** rename, edit, delete, merge, or add families in the output.
2) **Lock existing assignments**: Treat `existing_outcome_family_mapping_yml.assignments` as read-only.
   - Do **not** change `family_id`, `confidence`, `rationale`, or `notes` for already-assigned `cmo_id`s.
3) For every `cmo_id` present in `cmo_yml_files` that is **not yet assigned**, create a new assignment:
   - `outcome_text`: copy the CMO’s `outcome` verbatim.
   - `family_id`: choose exactly one key from `existing_outcome_family_mapping_yml.families`.
   - `confidence`: low | medium | high.
   - `rationale`: 1–2 sentences explaining why this family is the best fit *based on the outcome* (optionally end with `Tags: ...` derived from `outcome_tags` if present, to match the existing style).
   - `notes`: optional (use `""` if none). If the outcome contains multiple effects, assign the primary effect and note the secondary effect here.
4) Output a single YAML file (schema below) that can overwrite `data/outcome_family_mapping.yml`.

OUTCOME FAMILY GUIDELINES (MUST APPLY)
- Classify the *effect/change* described in the outcome, not the mechanism, policy instrument, or programme design.
  - OK outcome focus: “procurement costs increase”, “interoperability improves”, “licensed production proceeds”
  - NOT outcome focus: “use offsets”, “adopt indirect offsets”, “require local content” (unless the outcome is explicitly policy evolution)
- Use `outcome_tags` only as hints; the decision must be defensible from `outcome` text.
- If none of the existing families fit, assign `other_unclear` and explain precisely what is unclear in `notes` (and what kind of family would fit).
- Be consistent with the existing assignment style and boundary choices implied by `existing_outcome_family_mapping_yml.assignments`.

COMMON BOUNDARY REMINDERS (USE THESE HEURISTICS)
- `procurement_politics_and_decision` vs `procurement_performance`:
  - Politics/decision: approval likelihood, opposition, supplier selection, legitimation, deal acceptance.
  - Performance: cost/price premium, delays/schedule, administrative burden, restricted options, efficiency/value-for-money.
- `policy_and_institutional_dynamics`:
  - Use when the outcome is explicitly about adopting/ending/redesigning an offset regime or a durable institutional/policy shift (not just “policy should…” recommendations unless the outcome is a change).
- `governance_compliance_and_evaluation`:
  - Monitoring, fulfilment, accounting credits, transparency, auditing, evaluability, disputes, enforceability, data scarcity for evaluation.

OUTPUT SCHEMA (MUST FOLLOW)
- Output ONLY valid YAML (no markdown, no commentary).
- Top-level keys MUST be exactly:
  - `schema_version`
  - `families`
  - `assignments`
  - `v_and_v_log`
- `schema_version` must be `1`.
- `families` must be copied verbatim from `existing_outcome_family_mapping_yml.families` (same keys; do not add/remove).
- `assignments` must be a mapping keyed by `cmo_id`, containing:
  - all existing assignments from `existing_outcome_family_mapping_yml.assignments` unchanged, PLUS
  - the newly created assignments for missing `cmo_id`s.
- Each `assignments[cmo_id]` value must contain exactly:
  - `outcome_text`
  - `family_id` (must exist in `families`)
  - `confidence` (low | medium | high)
  - `rationale` (1–2 sentences)
  - `notes` ("" allowed)
- `v_and_v_log` must be a list of entries, each with exactly:
  - `check`
  - `status` (pass | warn | fail)
  - `note`

V&V CHECKS (INCLUDE AT LEAST THESE IN `v_and_v_log`)
- coverage_all_cmos_assigned (every CMO ID in `cmo_yml_files` has an assignment)
- existing_assignments_unchanged (warn/fail if you changed any previously-assigned `cmo_id`)
- single_family_per_outcome (exactly one family each)
- invalid_family_id_rate (fail if any assignment uses a missing family_id)
- other_bucket_rate (warn if `other_unclear` >10% of newly added assignments)
- boundary_consistency_sanity (warn if you find many near-ties; explain the main ambiguity patterns)

NOW PRODUCE THE YAML OUTPUT.
