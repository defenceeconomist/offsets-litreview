You are normalizing tags used in a realist Context–Mechanism–Outcome (CMO) synthesis.

GOAL
- Reduce duplicates and near-duplicates across sources by mapping variants/synonyms to a canonical tag.
- Keep tags usable for aggregation and cross-case comparison (consistent, not overly specific).

IMPORTANT CONTEXT (HOW TAGS ARE NORMALIZED IN CODE)
The pipeline already performs mechanical normalization of every tag before any aliasing:
1) lowercase
2) replace any non-alphanumeric with "_"
3) collapse multiple "_" to one
4) trim leading/trailing "_"

After that, if the normalized tag matches a key in `cmo/normalized_tags.yml` under `aliases:`, it is replaced by the mapped canonical value.

Therefore:
- Do NOT waste effort on purely mechanical casing/punctuation fixes; assume the above normalization will happen automatically.
- Focus on semantic normalization: spelling variants (defence/defense), plural/singular, synonyms, and overly-specific variants that should collapse to one canonical tag.

INPUTS YOU WILL RECEIVE
- existing_aliases_yaml: the current contents of `cmo/normalized_tags.yml` (may be empty or omitted).
- mechanism_map_yaml: the current contents of `cmo/mechanism_map.yml` (may be empty or omitted).
- raw_tags:
  - context_tags: list of observed raw context tags (strings)
  - mechanism_tags: list of observed raw mechanism tags (strings)
  - outcome_tags: list of observed raw outcome tags (strings)
Optionally, you may also be given counts and/or short examples (snippets) of how a tag was used.

TASK
1) Apply the mechanical normalization described above to every raw tag (mentally) to identify the "pipeline-normalized" form.
2) For each tag type (context/mechanism/outcome), cluster tags that are the same concept.
   - Prefer an existing canonical form when available:
     - If a tag already appears as a canonical value in `existing_aliases_yaml`, reuse it.
     - For mechanism tags, prefer reusing tags already present as keys in `mechanism_map_yaml.tag_to_theme` when the concept matches.
   - Prefer UK spelling and UK defense terminology conventions already used in this repo (e.g., defence not defense; standardisation not standardization).
   - Prefer singular noun forms unless plurality is meaningful.
   - Keep canonical tags short, concrete, and stable; avoid adding unnecessary qualifiers (e.g., prefer `export_control_friction` over `export_control_friction_delays_in_practice`).
3) Produce an alias mapping (variants -> canonical) suitable to paste into `cmo/normalized_tags.yml`.
   - Map ONLY true variants/synonyms to a canonical tag.
   - Do NOT map distinct concepts together. If unsure, mark as `needs_review`.
   - Do NOT create alias entries where key == value.
4) If you propose any NEW canonical tags:
   - List them explicitly under `new_canonical_tags:` grouped by tag type.
   - For NEW mechanism canonical tags not present in `mechanism_map_yaml.tag_to_theme`, suggest a theme key under `mechanism_theme_suggestions:` using ONLY one of the existing theme keys from `mechanism_map_yaml.themes` (or `needs_review` if unclear).
5) Provide a short decision log for tricky calls.

OUTPUT RULES (MUST FOLLOW)
- Output ONLY valid YAML (no markdown, no commentary).
- YAML must have exactly these top-level keys (in this order):
  aliases_to_add
  new_canonical_tags
  mechanism_theme_suggestions
  needs_review
  decision_log

YAML SCHEMA
aliases_to_add:
  context_tags:
    <alias_key>: <canonical_value>
  mechanism_tags:
    <alias_key>: <canonical_value>
  outcome_tags:
    <alias_key>: <canonical_value>

new_canonical_tags:
  context_tags: [<canonical_tag>, ...]
  mechanism_tags: [<canonical_tag>, ...]
  outcome_tags: [<canonical_tag>, ...]

mechanism_theme_suggestions:
  <new_mechanism_tag>: <theme_key_or_needs_review>

needs_review:
  context_tags: [<tag_or_pair>, ...]
  mechanism_tags: [<tag_or_pair>, ...]
  outcome_tags: [<tag_or_pair>, ...]

decision_log:
  - note: "<1–2 sentences explaining any non-obvious merge/split decisions>"

QUALITY CHECKS (DO THESE BEFORE FINALIZING OUTPUT)
- Every alias key and value is snake_case and matches the pipeline-normalized form (no spaces, no hyphens).
- No alias maps a tag to itself.
- Prefer existing canonical tags when possible; new tags are minimized.
- For mechanism tags, avoid introducing a new canonical tag if an existing `tag_to_theme` key matches the concept.
- `needs_review` is used for genuine ambiguity (not as a dump).

NOW DO THE NORMALIZATION FOR THE PROVIDED INPUTS AND OUTPUT ONLY YAML.
