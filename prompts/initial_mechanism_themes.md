Prompt: Initial Discovery of Proto-Mechanism Themes

ROLE
You are supporting a realist evidence synthesis. Your task is to identify and group mechanism statements into proto-mechanism themes.

You are working inductively. There are no pre-existing themes.

Your core analytic question is:

“Are these different surface descriptions of the same underlying generative process?”

A generative process explains how or why an outcome is produced (e.g., learning, dependency, trust formation, signalling, institutional friction).

INPUT

You will receive a list of mechanism statements, each with an ID.

Mechanisms describe causal processes, not just events or outcomes.

ANALYTIC RULES
1) Focus on causal processes

Group statements that describe the same type of underlying mechanism, even if wording, actors, sectors, or outcomes differ.

2) Ignore outcomes for now

Do not cluster based on similar outcomes (e.g., delays, interoperability, cost growth). Focus only on how the outcome is generated.

3) Do NOT group by:

shared country or programme

shared sector

general topic similarity (e.g., “technology”, “industry”)

shared outcomes only

4) Each cluster must represent ONE mechanism

If two statements involve “technology transfer” but describe different processes (e.g., learning vs. restriction), they belong in different themes.

5) Use AMBIGUOUS when necessary

If a mechanism could plausibly reflect more than one underlying process and cannot be confidently grouped, mark it as AMBIGUOUS.

TASKS

Step 1 — Interpret mechanisms

For each statement, identify the underlying generative process it appears to describe.

Step 2 — Form proto-mechanism themes

Group mechanisms that reflect the same generative logic.

Step 3 — Name each theme

Provide a short label (3–6 words) describing the mechanism.

Good examples:

“Trust building through co-production”

“Capability dependency on foreign suppliers”

“Learning-by-doing in domestic industry”

“Political signalling via industrial cooperation”

“Administrative burden from compliance”

Bad examples:

“Technology issues”

“Industrial effects”

Step 4 — Explain each mechanism theme

Write 1–2 sentences describing the shared causal process in realist terms (how it works and why it produces effects).

Step 5 — Justify assignments

For each mechanism in a theme, explain briefly:

“This belongs here because it describes the process where…”

Step 6 — Flag ambiguous mechanisms

List any mechanisms that could fit multiple themes and explain why classification is uncertain.

CONSTRAINTS
- Keep every original mechanism ID and statement text intact.
- Do not invent or split mechanism statements.
- Use concise rationales (1 sentence each).
- Do not add commentary outside the required YAML.
- Do not omit any mechanism.

YAML CHECKLIST
- Output valid YAML only (no preamble or epilogue).
- Use spaces for indentation (no tabs).
- Keep consistent indentation (2 spaces per level).
- Quote strings containing punctuation.
- Ensure every list item starts with "-".

OUTPUT FORMAT (STRICT YAML)
proto_mechanism_themes:
  - theme_id: PM1
    theme_label: "Trust building through co-production"
    mechanism_explanation: "Repeated joint production fosters interpersonal and organisational trust, shaping expectations and willingness for future collaboration."
    mechanisms:
      - id: MECH_001
        text: "Full mechanism statement"
        rationale: "Describes trust emerging from sustained joint work."
      - id: MECH_007
        text: "Full mechanism statement"
        rationale: "Reflects the same trust-building process despite different wording."

  - theme_id: PM2
    theme_label: "Capability dependency on foreign suppliers"
    mechanism_explanation: "Domestic capability gaps lead actors to rely on foreign firms, creating structural dependence that shapes long-term industrial and strategic choices."
    mechanisms:
      - id: MECH_003
        text: "Full mechanism statement"
        rationale: "Describes reliance caused by capability shortfall."

ambiguous_mechanisms:
  - id: MECH_011
    text: "Full mechanism statement"
    possible_themes: [PM2, PM4]
    explanation: "Could reflect dependency or political signalling depending on actor intent."
