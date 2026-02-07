You are conducting a realist evidence synthesis for a single research question.

RESEARCH QUESTION (RQ5)
What recurrent pathways can be mapped across countries to explain positive, negative, or mixed outcomes?

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
- Use all country-coded CMOs where possible (`country != unknown_country`).
- Include multi-country syntheses when they clarify pathway recurrence.
- Classify each pathway outcome tendency as `positive`, `negative`, or `mixed` for alliance-relevant collaboration.

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
- Within each family, identify recurrent cross-country pathways.
- For each recurrent pathway, include:
  - `Pathway statement`: `Context -> Mechanism -> Outcome tendency`.
  - `Cross-country pattern`: countries/programmes where it appears.
  - `Polarity`: positive | negative | mixed.
  - An overall summary that contains: strength of evidence (rating only), pathway statement, moderators, counterclaims (plus cross-country pattern and polarity).
  - An expandable `Detail` box that contains: strength of evidence and relevant quotes (and any additional supporting detail).
- Explicitly separate recurrence from single-country idiosyncrasy.
 
DETAIL BOX (MANDATORY)
- Use Quarto's default callout as a collapsible detail box exactly in this form:
  ::: {.callout-note collapse="true" title="Detail"}
  ...
  :::

EVIDENCE-STRENGTH HEURISTIC
- `strong`: recurring in multiple countries/sources with convergent high-confidence CMOs.
- `moderate`: appears in multiple settings but with partial inconsistency.
- `limited`: sparse country coverage or low-confidence support.
- `mixed`: substantial directionally conflicting evidence across countries.

OUTPUT FORMAT (QUARTO QMD MARKDOWN ONLY)

---
title: "RQ5 Synthesis (Realist Evidence Synthesis)"
format: html
freeze: false
bibliography: ../references/offsets.bib
---

# Question

<restate RQ5 in one sentence>

# Evidence Used

This synthesis draws on country-coded CMOs where possible (`country != unknown_country`), using multi-country syntheses when they clarify cross-country pathway recurrence.

- CMOs reviewed: <n>
- Countries represented: <list>
- Outcome families represented: <n>
- Confidence profile (as recorded in the CMO YAML): <n high; n medium; n low if present>
- Recurrent pathways extracted: <n>
- Pathways classified as positive/negative/mixed: <counts>

# Synthesis By Outcome Family

Outcome families are used here as a stable, cross-document way to group outcome tendencies while keeping traceability to the underlying CMO evidence.

## <Outcome Family Title Case>

- **Outcome family description**: <one sentence, using the taxonomy definitions>

### Recurrent Pathway: <short name>

- **Pathway**: <context -> mechanism -> outcome tendency> [@key]
- **Cross-country pattern**: <countries/programmes> [@key]
- **Polarity**: <positive|negative|mixed>
- **Moderators**: <what explains cross-country divergence> [@key]
- **Counterclaims**: <credible exceptions/alternative pathways> [@key]
- **Strength of evidence**: <Strong|Moderate|Limited|Mixed>.

::: {.callout-note collapse="true" title="Detail"}

**Strength of evidence**
- Rating: **<strong|moderate|limited|mixed>**
- Why: <brief justification grounded in the evidence> [@key]

**Relevant quotes**
- "..." [@key]
- "..." [@key]

:::

(repeat for each recurrent pathway/family)

# Cross-Family Synthesis

### Key Enabling Contexts (Repeated)
<Identify recurring enabling contexts that explain positive cross-country outcomes and pathway recurrence.>

### Main Boundary Conditions / Failure Points
<Identify recurring failure points and boundary conditions associated with negative or mixed outcomes, including key moderators explaining cross-country divergence.>

### Implications for RQ5 (Conditional)
<Synthesize what this implies about which recurrent pathways explain positive/negative/mixed outcomes across countries, and what moderators most credibly explain divergence.>

# Evidence Audit

- CMOs reviewed: <n>
- Countries represented: <list>
- Outcome families represented: <comma-separated list of family labels>
- Recurrent pathways extracted: <n>
- Pathways classified as positive/negative/mixed: <counts>
- Missing citation mappings: <none or list>

# References


::: {#refs}
:::