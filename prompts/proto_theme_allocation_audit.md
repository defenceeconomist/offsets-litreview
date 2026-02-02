Prompt: Proto-Mechanism Theme Allocation Audit (One Theme at a Time)

ROLE
You are supporting a realist evidence synthesis. Your task is to audit whether mechanisms currently assigned to ONE target proto-mechanism theme are allocated to the best-fitting theme.

You must classify by underlying generative causal process, not topic similarity.

INPUTS YOU WILL RECEIVE

1) target_theme_id
The theme ID to audit (e.g., PM17).

2) proto_themes_yml
The full current contents of: data/mechanism_themes/proto_themes.yml

3) proto_themes_changelog_yml
The full current contents of: data/mechanism_themes/proto_themes_changelog.yml

REFERENCE EXTRACTION (PYTHON) — USE THIS WORKFLOW EVERY TIME

Use this code structure to ensure you consistently compare mechanisms to ALL themes’ labels and explanations.
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
candidate_mechanisms = list(target_theme.get("mechanisms", []))

changelog = yaml.safe_load(proto_themes_changelog_yml)
existing_ids = [
  int(re.search(r"CHG_(\\d+)$", c["change_id"]).group(1))
  for c in changelog.get("change_log", [])
  if re.search(r"CHG_(\\d+)$", c.get("change_id", ""))
]
next_change_num = (max(existing_ids) + 1) if existing_ids else 1
```

AUDIT TASK (FOR THE TARGET THEME ONLY)

For each mechanism currently inside the target theme:

1) Compare the mechanism (its `text`) against EVERY theme’s:
- `theme_label`
- `mechanism_explanation`

2) Decide one outcome:

A) KEEP IN TARGET THEME
Only if the target theme’s explanation is the best match to the mechanism’s causal logic.

B) REALLOCATE TO A DIFFERENT EXISTING THEME
If another theme’s label/explanation clearly fits the mechanism better than the target theme.

C) MARK AMBIGUOUS
If the mechanism plausibly fits 2+ themes and you cannot decide confidently.
Move it to `ambiguous_mechanisms` and list the likely theme IDs in `possible_themes`.

DECISION RULES (STRICT)

- Use generative process similarity, not:
  - shared outcomes
  - shared country/programme
  - shared sector / platform
  - surface keywords

- “Better fit” means: another theme’s explanation more directly states the causal process described in the mechanism.

- Do not create new themes in this task.

EDITING RULES (STRICT)

- Do not change any mechanism `id` or `text`.
- You MAY update `rationale` when a mechanism is kept or moved, but keep it short and specific to why it fits that theme.
- Ensure each mechanism appears exactly once across:
  - all themes’ `mechanisms` lists, OR
  - `ambiguous_mechanisms`
- Only move mechanisms that were originally in the target theme for this run.
  - Do not “clean up” other themes unless needed to avoid duplicates created by your move.

CHANGE LOGGING (UPDATE EXISTING YAML CHANGE LOG)

The change log file contains a history of many kinds of theme edits (e.g., `new_theme`, `merge`, `no_change`, `assignment`).

You MUST preserve all existing entries exactly as they are, and append new entry/entries for every change you make in this run:

- If moved theme-to-theme: `change_type: assignment`
- If moved to ambiguous: `change_type: ambiguous`

Each entry must include:
- `change_id`: next sequential ID (CHG_###), continuing from the current max
- `theme_id`: the destination theme ID (or `AMBIGUOUS`)
- `mechanism_id`
- `summary`: 1 sentence describing what changed (include from/to theme IDs)
- `rationale`: 1–2 sentences justifying the change in terms of causal process fit

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
    change_type: assignment | ambiguous | new_theme | merge | no_change
    theme_id: PM7 | AMBIGUOUS
    mechanism_id: MECH_022  # present for mechanism-level changes; may be absent for theme-level entries (e.g., merges)
    summary: "Moved MECH_022 from PM3 to PM7."
    rationale: "Mechanism describes X causal process; PM7 explicitly captures X, whereas PM3 captures Y."

Do not include any commentary outside the TWO YAML documents.
