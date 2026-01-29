You are maintaining the mechanism theme map for a realist Context–Mechanism–Outcome (CMO) synthesis.

TIP (OPTIONAL)
You can generate candidate inputs from a CMO YAML file using `R/extract_mechanism_map_candidates.R`.

GOAL
- Map mechanism tags to a small, stable set of pathway themes in `cmo/mechanism_map.yml`.
- Avoid duplicate/near-duplicate mechanism tags by reusing existing canonical tags when the concept matches.

IMPORTANT CONTEXT (HOW TAGS ARE NORMALIZED IN CODE)
Before any aliasing, the pipeline mechanically normalizes every tag:
1) lowercase
2) replace any non-alphanumeric with "_"
3) collapse multiple "_" to one
4) trim leading/trailing "_"

After that, if the normalized tag matches a key in `cmo/normalized_tags.yml` under `aliases:`, it is replaced by the mapped canonical value.

Therefore:
- Do NOT add a new mechanism tag to `tag_to_theme` if the concept already exists under another canonical tag.
- If the provided tag is a true synonym/near-synonym of an existing canonical mechanism tag, propose an alias in `cmo/normalized_tags.yml` instead (and map the canonical tag to a theme).
- If the provided tag is overly long or overly specific, create a shorter canonical mechanism tag and alias the provided tag to it (do not add long/sentence-like tags as canonicals).

INPUTS YOU WILL RECEIVE
- mechanism_map_yaml: the current contents of `cmo/mechanism_map.yml` (may be empty or omitted).
- normalized_tags_yaml: the current contents of `cmo/normalized_tags.yml` (may be empty or omitted).
- candidate_mechanism_tags: a list of candidates, each with:
  - raw_tag: string (as observed)
  - optional: count: integer (how often it appears in the dataset; higher = prioritize)
  - description: 1–3 sentences explaining what the mechanism means in this project
  - optional: examples: short snippets or notes about how it is used (may include a short quote)

TASK
0) First, deduplicate the candidate list conceptually:
   - If multiple candidates are the same mechanism with minor wording differences (e.g., pluralisation, spelling variants, prefix/suffix tweaks), pick ONE canonical tag and alias the rest to it.
   - If a candidate is a true synonym/near-synonym of an existing canonical tag already present in `mechanism_map_yaml.tag_to_theme`, alias to that existing canonical tag (do not create a new canonical).
1) For each remaining candidate, compute the pipeline-normalized form of raw_tag.
2) Decide whether the raw_tag should resolve to:
   a) an existing canonical mechanism tag already in `mechanism_map_yaml.tag_to_theme` (reuse it), OR
   b) an alias to an existing canonical mechanism tag (synonym/near-synonym; add alias in `cmo/normalized_tags.yml`), OR
   c) a new canonical mechanism tag (create it; keep it short and stable), OR
   d) ambiguous (mark needs_review).
   If you create a new canonical tag that differs from the normalized raw_tag, add an alias from the normalized raw_tag to the new canonical.
3) Assign exactly ONE theme key for each canonical mechanism tag:
   - Prefer an existing theme key in `mechanism_map_yaml.themes` if it fits.
   - Create a NEW theme key only if none of the existing themes can reasonably accommodate the mechanism without distorting the theme definitions.
4) If creating a new theme, define:
   - theme_key (snake_case)
   - label (short human-readable title)
   - description (1–2 sentences; define the pathway clearly and non-overlapping with existing themes)
5) Produce a merge-ready patch:
   - minimal additions/updates to `tag_to_theme`
   - any needed new themes
   - any alias suggestions for `cmo/normalized_tags.yml` (only if the tag is a variant)

OUTPUT RULES (MUST FOLLOW)
- Output ONLY valid YAML (no markdown, no commentary).
- YAML must have exactly these top-level keys (in this order):
  tag_resolution
  mechanism_map_patch
  normalized_tags_patch
  needs_review
  decision_log

YAML SCHEMA
tag_resolution:
  - raw_tag: <string>
    normalized_tag: <snake_case_pipeline_normalized>
    canonical_tag: <existing_or_new_or_needs_review>
    canonical_status: <reuse_existing|alias_to_existing|new_canonical|needs_review>
    theme_key: <existing_or_new_or_needs_review>

mechanism_map_patch:
  themes_to_add:
    <new_theme_key>:
      label: <string>
      description: <string>
  tag_to_theme_to_add:
    <canonical_mechanism_tag>: <theme_key>
  tag_to_theme_to_update:
    <existing_canonical_mechanism_tag>: <new_theme_key>

normalized_tags_patch:
  aliases_to_add:
    <normalized_variant_tag>: <canonical_tag>

needs_review:
  - item: <string identifying the tag>
    note: <1–2 sentences on what is ambiguous and what info would resolve it>

decision_log:
  - note: "<1–2 sentences explaining any non-obvious merge/split/theme decisions>"

QUALITY CHECKS (DO THESE BEFORE FINALIZING OUTPUT)
- Every tag and theme key is snake_case and matches the pipeline-normalized form (no spaces, no hyphens).
- `tag_to_theme_to_add` keys are canonical mechanism tags (not variants); variants go in `normalized_tags_patch.aliases_to_add`.
- Canonical mechanism tags are short and reusable (avoid sentence-like tags; avoid embedding specific countries/programmes/years; prefer stable concepts).
- Do not delete or rewrite existing themes/mappings; only propose additions or updates that are necessary.
- Every `theme_key` referenced either already exists in `mechanism_map_yaml.themes` or appears under `themes_to_add`.
- If you propose a new theme, it is clearly distinct (non-overlapping) from existing themes.

NOW DO THE MAPPING FOR THE PROVIDED INPUTS AND OUTPUT ONLY YAML.
