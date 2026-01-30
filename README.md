# Offsets Realist Evidence Synthesis Workflow

This project follows a realist evidence synthesis workflow to extract, de-duplicate, cluster, and synthesize mechanism evidence from sources.

## Workflow Overview

### 1) Extract CMO statements and metadata
- Collect sources (papers, reports, chapters).
- Extract Context–Mechanism–Outcome (CMO) statements and any relevant metadata (e.g., source, year, method, setting).
- Store the extracted statements in a structured format for downstream processing (e.g., `data/` or `cmo/`).

### 2) Remove near-duplicate statements/tags
- Normalize the extracted texts or tags (e.g., lowercasing, trimming).
- Use embedding-based similarity to identify near-duplicates and remove or merge them.
- Scripts: `scripts/tag_embeddings.py`, `scripts/tag_clustering.py`.

### 3) Cluster and generate a dendrogram
- Embed the normalized items.
- Run hierarchical clustering to produce a dendrogram that captures similarity structure.
- Script: `scripts/tag_clustering.py` (`build_tag_hierarchy`).

### 4) Manually create the tag hierarchy
- Use the dendrogram output to guide manual grouping.
- Curate a stable tag hierarchy that reflects substantive meaning and theory.
- Save the hierarchy for synthesis (e.g., `cmo/mechanism_map.yml` or similar).

### 5) Synthesize against research questions
- Map clustered mechanisms and CMO statements to the research questions.
- Produce narrative and tabular synthesis outputs (e.g., `report.qmd`, `synthesis/rq1.qmd`).

## Suggested Command Flow

1. Prepare input list of tags or statements (txt/csv/json).
2. Identify near-duplicates:
   - Use `group_near_duplicates` in `scripts/tag_clustering.py`.
3. Build a hierarchy:
   - Use `build_tag_hierarchy` in `scripts/tag_clustering.py`.
4. Manually curate the hierarchy from dendrogram output.
5. Run or update synthesis documents.

## Notes
- The embedding utilities are model-agnostic; you can swap in a custom embedder.
- The clustering utilities assume cosine similarity over normalized embeddings.
