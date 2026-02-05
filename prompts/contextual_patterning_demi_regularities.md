Prompt: Contextual Patterning (CMO Demi-Regularities)

ROLE
You are supporting a realist evidence synthesis. Your task is to infer per-theme “demi-regularities”: conditional C→M→O tendencies that explain when/how a mechanism theme tends to produce particular outcomes.

You are not doing statistics. You are producing defensible, evidence-traceable pattern statements grounded ONLY in the provided extracted CMO records.

INPUTS
You will receive:

1) proto_themes_yml
- Loaded from: data/mechanism_themes/proto_themes.yml
- Contains: proto_mechanism_themes[].theme_id, theme_label, mechanism_explanation, mechanisms[].id
- IMPORTANT: mechanisms[].id values are CMO identifiers (a.k.a. chunk_id) that must be found in the CMO YAML bundle below.

2) cmo_statements.csv
- Loaded from data/cmo_statements.csv
- A CSV with CMO statments and the following relevant columns:
    file_id
    chunk_id
    context_statement
    mechanism_statement
    outcome_statement
    confidence (low|medium|high)
    confidence_justification
    evidence_paraphrase (supporting evidence paraphrased)
    evidence_quote (supporting evidence quote)
 
DEFINITIONS (MUST APPLY)
- Context (C): salient conditions that shape whether/how the mechanism fires (settings, constraints, incentives, capacities). Not a program activity.
- Mechanism (M): the generative causal process (resources/constraints + actors’ reasoning/response → causal force). Not an activity or policy label.
- Outcome (O): observed/reported effect(s), intended or unintended. Not an activity or plan.
- Demi-regularity: a recurring tendency (not a universal law) stated conditionally: “In contexts where X, mechanism Z tends to yield Y…”, including boundary conditions and counterexamples.

TASK
For EACH proto-mechanism theme:

Step 1 — Assemble the evidence set
- Collect the set of CMO records whose chunk_id matches the theme’s mechanisms[].id.
- If any mechanisms[].id cannot be found in cmo_yml_bundle, list them under missing_cmo_ids for that theme (do not guess).

Step 2 — Characterize what varies and what repeats
- Summarize the recurring context conditions (paraphrase context text).
- Summarize recurring outcome tendencies (paraphrase outcome text).
- Identify meaningful within-theme variation:
  - outcomes that differ for similar contexts
  - contexts that appear to strengthen, weaken, or reverse the tendency
  - cases that look like “failures to fire” (mechanism present but outcome absent or opposite)

Step 3 — Write demi-regularity statements
- Produce 2–6 demi-regularities per theme (fewer if evidence is thin).
- Each statement MUST be of the form:
  “In contexts where [X], [MECHANISM THEME LOGIC] tends to yield [Y].”
- Keep [X] and [Y] specific enough to be meaningful, but general enough to cover multiple CMO records.
- Tie the mechanism phrasing to the theme_label/mechanism_explanation; do not invent a new mechanism unrelated to the theme.

Step 4 — Add moderators and boundary conditions
- For each demi-regularity, specify:
  - moderators: conditions that strengthen/weaken the tendency
  - boundary_conditions: conditions under which the tendency is unlikely to hold
  - counterexamples: CMO IDs that do not fit the tendency, and what differs about them
- Only claim a moderator/boundary condition if you can point to at least one supporting CMO ID.

Step 5 — Evidence traceability and confidence
- Every demi-regularity MUST include supporting_cmo_ids (chunk_id list).
- Where possible, include 1–2 short “anchor quotes” drawn from supporting_evidence fields of the linked CMOs (do not exceed ~25 words per quote).
- Provide confidence per demi-regularity (low|medium|high) based on:
  - number and diversity of supporting CMOs
  - internal consistency (few/clear counterexamples vs many/unclear)
  - source confidence ratings (if provided) and evidence_type (if present)
- If evidence is mainly theory_model or otherwise non-empirical, reflect that in confidence_justification (do not dismiss it; just be explicit).

IMPORTANT RULES
- Do not invent facts beyond the provided CMO records.
- Do not “average away” contradictions: surface them as moderators/counterexamples.
- Prefer concise, realist-style causal phrasing over narrative prose.
- Keep chunk_id values EXACT; do not edit or shorten them.

OUTPUT FORMAT (STRICT YAML ONLY)
Output valid YAML only (no markdown, no commentary).

Schema:
demi_regularities_by_theme:
  - theme_id: PM1
    theme_label: "..."
    mechanism_explanation: "..."
    cmo_ids_in_theme: [chunk_id_1, chunk_id_2]
    missing_cmo_ids: [chunk_id_x]
    demi_regularities:
      - demi_regularity_id: "PM1_DR_01"
        statement: "In contexts where ..., ... tends to yield ...."
        context_conditions:
          - "..."
        outcome_tendencies:
          - "..."
        supporting_cmo_ids: [chunk_id_1, chunk_id_2]
        anchor_quotes:
          - cmo_id: chunk_id_1
            quote: "..."
        moderators:
          - condition: "..."
            effect: "strengthens" | "weakens" | "reverses" | "enables" | "inhibits"
            supporting_cmo_ids: [chunk_id_2]
        boundary_conditions:
          - condition: "..."
            supporting_cmo_ids: [chunk_id_3]
        counterexamples:
          - cmo_id: chunk_id_4
            note: "Does not fit because ..."
        confidence: low | medium | high
        confidence_justification: "..."
    theme_notes:
      - "1–3 bullets on coverage/gaps and what to look for next."

YAML CHECKLIST
- Output YAML only.
- Use spaces for indentation (2 spaces).
- Quote strings containing punctuation.
- Ensure every list item starts with "-".

NOW DO THE PATTERNING FOR THE PROVIDED INPUTS AND OUTPUT ONLY YAML.
