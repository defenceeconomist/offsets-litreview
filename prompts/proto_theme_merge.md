Prompt: Proto-Mechanism Theme Merge Audit (One Theme at a Time)

ROLE
You are supporting a realist evidence synthesis. Your task is to audit whether ONE target proto-mechanism theme is redundant and
should be merged into a better-fitting existing theme.

You must classify by underlying generative causal process, not topic similarity.

INPUTS YOU WILL RECEIVE

1) target_theme_id
The theme ID to audit (e.g., PM17).

2) proto_themes_yml
The full current contents of: data/mechanism_themes/proto_themes.yml

3) proto_themes_changelog_yml
The full current contents of: data/mechanism_themes/proto_themes_changelog.yml

REFERENCE EXTRACTION (PYTHON) — USE THIS WORKFLOW EVERY TIME

Use this code structure to ensure you consistently compare the target theme to ALL other themes’ labels and explanations.
(This is a workflow reference; do not execute it.)

```python
import re
import yaml

proto = yaml.safe_load(proto_themes_yml)  # dict
themes = proto["proto_mechanism_themes"]  # list[dict]

theme_index = {
  t["theme_id"]: {
    "theme_label": t["theme_label"],
    "mechanism_explanation": t["mechanism_explanation"],
  }
  for t in themes
}

target_theme = next(t for t in themes if t["theme_id"] == target_theme_id)
other_themes = [t for t in themes if t["theme_id"] != target_theme_id]

changelog = yaml.safe_load(proto_themes_changelog_yml)
existing_ids = [
  int(re.search(r"CHG_(\\d+)$", c["change_id"]).group(1))
  for c in changelog.get("change_log", [])
  if re.search(r"CHG_(\\d+)$", c.get("change_id", ""))
]
next_change_num = (max(existing_ids) + 1) if existing_ids else 1
```

AUDIT TASK (FOR THE TARGET THEME ONLY)

1) Compare the TARGET theme’s:
- `theme_label`
- `mechanism_explanation`

against EVERY OTHER theme’s:
- `theme_label`
- `mechanism_explanation`

2) Decide ONE outcome:

A) NO MERGE (KEEP TARGET AS DISTINCT)
Choose this if no other theme clearly captures the same generative process as the target.

B) MERGE TARGET INTO AN EXISTING THEME
Choose this if another theme’s label/explanation describes the same causal process more clearly or more canonically than the
target theme.

MERGE DECISION RULES (STRICT)

- Use generative process similarity, not:
  - shared outcomes
  - shared country/programme
  - shared sector / platform
  - surface keywords

- “Same process” means: if you replaced the target theme label/explanation with the candidate’s label/explanation, you would not
lose any distinctive causal logic.

- Only recommend a merge when the overlap is strong and specific. If overlap is partial or the target theme appears to bundle
multiple distinct processes, do NOT merge in this task (record `no_change`).

EDITING RULES (STRICT)

- If you recommend NO MERGE:
  - Do not change `proto_themes.yml` theme content.

- If you recommend MERGE:
  - Do not change any mechanism `id` or `text`.
  - Move ALL mechanisms from the target theme into the destination theme’s `mechanisms` list (append).
  - Ensure each mechanism appears exactly once across all themes (no duplicates).
  - Remove the target theme from `proto_mechanism_themes` after moving its mechanisms.
  - Do not “clean up” unrelated themes.

CHANGE LOGGING (UPDATE EXISTING YAML CHANGE LOG)

Append a new entry to `data/mechanism_themes/proto_themes_changelog.yml` for this run:

- If merged: `change_type: merge`
- If not merged: `change_type: no_change`

Each entry must include:
- `change_id`: next sequential ID (CHG_###), continuing from the current max
- `theme_id`: the destination theme ID (if merged) OR the audited `target_theme_id` (if no merge)
- `summary`: 1 sentence describing what changed (include from/to theme IDs when merged)
- `rationale`: 1–2 sentences justifying the decision in terms of causal process similarity/difference
- `details`:
  - `merged_from`: list of merged theme IDs (empty if no merge)
  - `merged_into`: destination theme ID (null if no merge)
  - `reviewed_theme_id`: the audited target theme ID

OUTPUT FORMAT (TWO STRICT YAML DOCUMENTS)

Return TWO YAML documents separated by a line containing only `---`.

Document 1 will be saved to: data/mechanism_themes/proto_themes.yml
Document 2 will be saved to: data/mechanism_themes/proto_themes_changelog.yml

Document 1 MUST match this schema:

proto_mechanism_themes:
  - theme_id: PM1
    theme_label: "Label"
    mechanism_explanation: "Explanation"
    mechanisms:
      - id: MECH_001
        text: "Full mechanism statement"
        rationale: "Why it fits this theme’s causal process."

ambiguous_mechanisms:
  - id: MECH_031
    text: "Full mechanism statement"
    possible_themes: [PM2, PM4]
    explanation: "Why assignment is ambiguous; what evidence would resolve it."

Document 2 MUST match this schema:

change_log:
  - change_id: CHG_123
    change_type: merge | no_change
    theme_id: PM7
    summary: "Merged PM12 into PM54."
    rationale: "PM12 and PM54 describe the same technology-acquisition causal process; PM54 is the clearer canonical label/explanation."
    details:
      merged_from: [PM12]
      merged_into: PM54
      reviewed_theme_id: PM12

Do not include any commentary outside the TWO YAML documents.
