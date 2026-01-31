Prompt: Triage Theme Pair Overlap

ROLE
You are supporting a realist evidence synthesis. Your task is to triage pairs of mechanism themes to identify likely overlaps that may warrant a merge review.

INPUT
You will receive a list of theme pairs. Each pair includes:
- pair_id
- theme_a_id, theme_a_label, theme_a_explanation
- theme_b_id, theme_b_label, theme_b_explanation

TRIAGE INSTRUCTIONS
Classify each pair using only labels and explanations (do NOT read mechanism statements).

Use these triage codes:
- no_overlap: different generative processes
- possible_overlap: some shared causal logic, needs review
- likely_overlap: very similar generative process, prioritize review

Rules:
- Focus on causal process, not topic similarity.
- If mechanisms differ in type (e.g., pricing vs. learning), mark no_overlap.
- If only actors/sector/context differ but the causal logic matches, mark likely_overlap.
- If unsure, mark possible_overlap and add a short note.

OUTPUT FORMAT (STRICT YAML)
triage_pairs:
  - pair_id: P001
    theme_a_id: PM1
    theme_b_id: PM7
    triage: possible_overlap
    note: "Both involve capacity effects but differ in causal pathway."

Do not omit any pair_id.
