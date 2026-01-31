Prompt: Proto-Mechanism Theme Merge / Split Audit

ROLE
You are reviewing a set of proto-mechanism themes from a realist evidence synthesis.
Your task is to assess whether any themes should be:

MERGED (they describe the same underlying generative process), or

SPLIT (one theme actually contains more than one distinct mechanism).

Your focus is theoretical coherence, not topic similarity.

INPUT

You will receive a list of themes. Each theme includes:

- theme_id
- theme_label
- mechanism_explanation
- List of mechanism statements assigned

CORE ANALYTIC QUESTION

For every theme and theme pair, ask:

“Do these mechanisms reflect one single generative process, or more than one?”

A generative process is the reason why an outcome is produced (e.g., learning, dependency, trust, signalling, institutional friction).

PART A — IDENTIFY THEMES THAT SHOULD BE MERGED

Two or more themes should be merged if:

Their mechanism explanations describe the same type of causal logic

Differences are only in wording, sector, actor, or policy context

The generative process is fundamentally the same

For each merge recommendation, explain:

Why the underlying processes are the same

What the merged theme label should be

Which original theme IDs are combined

PART B — IDENTIFY THEMES THAT SHOULD BE SPLIT

A theme should be split if:

The assigned mechanisms describe different kinds of generative processes

The current explanation is too broad to capture them coherently

You can clearly describe two (or more) distinct mechanisms inside it

For each split recommendation, explain:

What the distinct mechanisms are

Provide new theme labels and explanations

Suggest which mechanisms belong in each new theme

PART C — IDENTIFY THEMES THAT ARE THEORETICALLY COHERENT

List themes that appear internally consistent and should remain unchanged.

IMPORTANT RULES

Do NOT base merge/split decisions on:

Shared outcomes

Shared countries or programmes

Shared sectors

Surface keywords

Base decisions only on similarity or difference in underlying causal process.

If unsure, state uncertainty rather than forcing a decision.

OUTPUT FORMAT (TWO STRICT YAML DOCUMENTS)
Return TWO YAML documents separated by a line containing only `---`.
Document 1 will be saved to: data/mechanism_themes/proto_themes.yml
Document 2 will be saved to: data/mechanism_themes/proto_themes_changelog.yml

Document 1 (updated themes) MUST match this schema:
proto_mechanism_themes:
  - theme_id: PM1
    theme_label: "Trust building through co-production"
    mechanism_explanation: "Repeated joint production fosters interpersonal and organisational trust, shaping expectations for future collaboration."
    mechanisms:
      - id: MECH_001
        text: "Full mechanism statement"
        rationale: "Describes trust emerging from sustained joint work."

ambiguous_mechanisms:
  - id: MECH_031
    text: "Full mechanism statement"
    possible_themes: [PM2, PM4]
    explanation: "Could reflect dependency or political signalling depending on actor intent."

Document 2 (change log) schema:
change_log:
  - change_id: CHG_001
    change_type: "merge" | "split" | "theme_edit" | "no_change"
    theme_id: PM7
    summary: "Split PM7 into two distinct mechanisms."
    rationale: "Theme contained both administrative burden and political signalling processes."
    details:
      merged_from: [PM2, PM5]
      split_into: [PM7A, PM7B]
      retained_as_is: [PM1]
