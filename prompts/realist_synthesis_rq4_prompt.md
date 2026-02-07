You are conducting a realist evidence synthesis for a single research question.

RESEARCH QUESTION (RQ4)
How can each pathway be summarized with enabling/limiting conditions and alliance-relevant outcomes?

INPUTS
- `cmo_yml_files`: one or more files in `data/cmo/*.yml` structure.
- `outcome_family_mapping_yml`: `data/outcome_family_mapping.yml`.
- `pdf_to_bibtex_key_yml`: `data/cmo/pdf_to_bibtex_key.yml`.
- `offsets_bibtex`: `docs/references/offsets.bib`.

CITATION REQUIREMENT (MANDATORY)
1. Resolve `pdf_filename -> bibtex_key` using `pdf_to_bibtex_key_yml.pdf_to_bibtex_key`.
2. Verify each `bibtex_key` exists in `offsets_bibtex`.
3. Cite claims and quotes in Quarto/Pandoc markdown citation format: `[@bibtexKey]` or `[@key1; @key2]`.
4. End with `# References` listing only cited keys as `- [@bibtexKey]`.

SCOPE AND FILTERING
- Build pathway summaries from CMOs across the corpus.
- Use `research_questions_mapped` as a guide, but prioritize pathway completeness over strict RQ tags when needed.
- Focus on pathway-level synthesis rather than isolated single-study claims.

USE ONLY THESE OUTCOME FAMILIES
- alliance_security_outcomes
- partnerships_and_supply_chains
- industrial_capability_and_base
- technology_transfer_and_learning
- governance_compliance_and_evaluation
- procurement_performance
- procurement_politics_and_decision
- domestic_economic_benefits
- trade_finance_and_market_effects
- policy_and_institutional_dynamics
- other_unclear

OUTCOME FAMILY DESCRIPTIONS (FOR THE WRITE-UP)
- Alliance Security Outcomes: Interoperability, standardization, readiness/sustainment, security of supply, deterrence, and other alliance/security effects.
- Procurement Politics and Decision Outcomes: Deal approval dynamics, supplier selection, political acceptance/legitimation, and procurement likelihood (distinct from cost/schedule performance).
- Procurement Performance: Cost/price premia, delays, administrative burden, restricted options, and other value-for-money/efficiency impacts.
- Governance, Compliance and Evaluation: Monitoring, fulfilment, enforceability, credit accounting, transparency, disputes, auditing, and evaluability/evaluation quality.
- Industrial Capability and Base: Defense-industrial capacity, self-reliance, sector growth/decline, and shifts in the domestic defense-industrial base.
- Technology Transfer and Learning: Transfer depth/quality, licensing/know-how, skills, absorptive capacity, and learning-by-doing (including constraints on transfer).
- Partnerships and Supply Chains: Joint ventures, co-production/co-development, supplier-network integration, and durable industrial linkages.
- Domestic Economic Benefits: Jobs, investment, regional development, and other economic/development effects (including opportunity-cost framing).
- Trade Finance and Market Effects: Exports/countertrade, trade balance/FX/financing constraints, market access/competitiveness, and related market-position effects.
- Policy and Institutional Dynamics: Adoption, persistence, termination, or redesign of offset regimes; durable institutional or regulatory shifts.
- Other / Unclear: Use only when none of the above fit; explain what is unclear.

ANALYSIS REQUIREMENTS
- Use the same overall structure and heading levels as `docs/synthesis/res_rq1.qmd`.
- Include `# Evidence Used` and `# Synthesis By Outcome Family`.
- Organize the synthesis by outcome family.
- Within each family, extract 1-3 recurrent pathways.
- Each pathway must be written as:
  - `Context (enabling/limiting conditions) -> Mechanism -> Outcome tendency`.
- For each pathway, include:
  - An overall summary that contains: strength of evidence (rating only), pathway statement (C-M-O), moderators, counterclaims, and alliance relevance.
  - An expandable `Detail` box that contains: strength of evidence and relevant quotes (and any additional supporting detail).
- Do not merge substantively different mechanisms into one pathway.
 
DETAIL BOX (MANDATORY)
- Use Quarto's default callout as a collapsible detail box exactly in this form:
  ::: {.callout-note collapse="true" title="Detail"}
  ...
  :::

EVIDENCE-STRENGTH HEURISTIC
- `strong`: multiple sources and mostly high-confidence CMOs with convergent findings.
- `moderate`: multiple sources with some inconsistency or medium-confidence dominance.
- `limited`: sparse evidence or mostly low-confidence/inferred claims.
- `mixed`: substantial contradictory findings with no clear directional pattern.

OUTPUT FORMAT (QUARTO QMD MARKDOWN ONLY)

---
title: "RQ4 Synthesis (Realist Evidence Synthesis)"
format: html
freeze: false
bibliography: ../references/offsets.bib
---

# Question

<restate RQ4 in one sentence>

# Evidence Used

This synthesis builds pathway summaries from CMOs across the corpus, using `research_questions_mapped` as a guide but prioritising pathway completeness over strict RQ tags when needed.

- CMOs reviewed: <n>
- Outcome families represented: <n>
- Confidence profile (as recorded in the CMO YAML): <n high; n medium; n low if present>
- Pathways extracted: <n>

# Synthesis By Outcome Family

Outcome families are used here as a stable, cross-document way to group pathway tendencies while keeping traceability to the underlying CMO evidence.

## <Outcome Family Title Case>

- **Outcome family description**: <one sentence, using the taxonomy definitions>

### Pathway: <short name>

- **C-M-O**: <context -> mechanism -> outcome tendency> [@key]
- **Moderators**: <enabling/limiting conditions> [@key]
- **Counterclaims**: <credible exceptions/alternative mechanisms> [@key]
- **Alliance relevance**: <how this pathway links to alliance-relevant outcomes> [@key]
- **Strength of evidence**: <Strong|Moderate|Limited|Mixed>.

::: {.callout-note collapse="true" title="Detail"}

**Strength of evidence**
- Rating: **<strong|moderate|limited|mixed>**
- Why: <brief justification grounded in the evidence> [@key]

**Relevant quotes**
- "..." [@key]
- "..." [@key]

:::

(repeat for each pathway and family with evidence)

# Cross-Family Synthesis

### Key Enabling Contexts (Repeated)
<Summarize the most common enabling conditions across pathways and families (what contexts repeatedly appear when pathways succeed).>

### Main Boundary Conditions / Failure Points
<Summarize the most common limiting conditions/boundary conditions across pathways (where and why pathways fail or reverse).>

### Implications for RQ4 (Conditional)
<Synthesize what this implies about how pathways can be summarized as enabling/limiting conditions linked to alliance-relevant outcomes (and how to communicate these as conditional propositions).>

# Evidence Audit

- CMOs reviewed: <n>
- Outcome families represented: <comma-separated list of family labels>
- Pathways extracted: <n>
- Missing citation mappings: <none or list>

# References


::: {#refs}
:::