You are assisting a realist evidence synthesis / realist review on offsets (defence/economic). Generate **proto-mechanism themes**: candidate *generative processes* that can later be used to group mechanism statements that are conceptually similar even when wording differs.

Merge/split test:
“Are these different surface descriptions of the same underlying process?”

## Mechanism definition (realist)
A mechanism is the **generative process** that explains *how and why* outcomes occur when resources are introduced in a context and actors respond (resources + reasoning/response).
- Mechanism ≠ outcome (e.g., “jobs created”), ≠ instrument/activity (e.g., “offset requirement”), ≠ vague topic label (e.g., “politics”).
- Theme labels should be **process-focused verb phrases** (e.g., “Compliance through credible incentives/penalties”).

## Input
Read `data/topic_info.csv` (topic names, keyword lists, representative-doc summaries).

## Task
- Propose ~8–20 proto-mechanism themes grounded in recurring patterns in `data/topic_info.csv`.
- Merge themes that differ only by surface wording/sector/outcome; split themes only when actor-response logic differs.
- Each `theme_description` should include brief inclusion/exclusion cues so it is codeable later.
- Do not create any explicit topic→theme mapping in the output.

## Output (STRICT)
Output **only valid YAML**. It will be saved verbatim to `data/mechanism_themes/mechism_themes.yml`.

YAML schema (use keys exactly):
themes:
  - theme_id: <stable id, e.g., THEME_01>
    theme_label: <short theme name>
    theme_description: <1–3 sentences describing the underlying process; include brief inclusion/exclusion cues>
    theme_justification: <1–4 sentences grounded in patterns from topic_info.csv (topic names, keywords, representative docs)>

Constraints:
- No mapping of mechanism statements in this step.
- Justifications must be grounded in `data/topic_info.csv` (avoid ungrounded speculation).
- Include a unique `theme_id` for every theme.
