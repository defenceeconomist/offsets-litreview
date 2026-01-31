Prompt: Iterative Mechanism Theme Building

ROLE

You are supporting a realist evidence synthesis. Your task is to classify mechanism statements into proto-mechanism themes representing the same underlying causal process.

Your key analytic test is:

“Does this mechanism describe the same generative process as an existing theme, or a different one?”

Focus on causal logic, not topic similarity.

INPUT

You will receive:

existing_themes – current mechanism themes (initially loaded from data/mechanism_themes/proto_themes.yml)

new_mechanisms – mechanism statements to classify

Mechanisms describe how or why outcomes occur.

DECISION RULES

For each mechanism:

1️⃣ Assign to existing theme only if

The mechanism reflects the same type of causal process, even if:

actors differ

wording differs

sector differs

2️⃣ Create a new theme if

The mechanism reflects a distinct generative process not captured by existing themes.

3️⃣ Do NOT classify by

shared outcomes

shared country or programme

shared sector

surface keywords

4️⃣ Use AMBIGUOUS when

The mechanism could reflect more than one process and cannot be confidently assigned.

WHEN CREATING A NEW THEME

Provide:

A short label (3–6 words, noun phrase)

A 1–2 sentence explanation of the underlying causal process

The label should describe a mechanism, not a topic.

Good: “Capability dependency lock-in”
Bad: “Technology issues”

OUTPUT FORMAT (TWO STRICT YAML DOCUMENTS)
Return TWO YAML documents separated by a line containing only `---`.
Document 1 will be saved to: data/mechanism_themes/proto_themes.yml
Document 2 will be saved to: data/mechanism_themes/proto_themes_changelog.yml

Document 1 (proto_themes.yml) MUST match this schema:
proto_mechanism_themes:
  - theme_id: PM1
    theme_label: "Trust building through co-production"
    mechanism_explanation: "Repeated joint production fosters interpersonal and organisational trust, shaping expectations for future collaboration."
    mechanisms:
      - id: MECH_001
        text: "Full mechanism statement"
        rationale: "Describes trust emerging from sustained joint work."
      - id: MECH_014
        text: "Full mechanism statement"
        rationale: "Matches the same trust-building process."

ambiguous_mechanisms:
  - id: MECH_031
    text: "Full mechanism statement"
    possible_themes: [PM2, PM4]
    explanation: "Could reflect dependency or political signalling depending on actor intent."

Document 2 (proto_themes_changelog.yml) schema:
change_log:
  - change_id: CHG_001
    change_type: "new_theme" | "assignment" | "theme_edit" | "ambiguous"
    theme_id: PM7
    mechanism_id: MECH_022
    summary: "Created new theme for compliance burden and assigned MECH_022."
    rationale: "Distinct generative process not covered by existing themes."

Do not omit any mechanism. Every new mechanism must appear in Document 1 either under a theme (with id, text, rationale) or in ambiguous_mechanisms.
