You are conducting a realist evidence synthesis for a single research question.

RESEARCH QUESTION (RQ2)
Which mechanisms systematically hinder alliance-relevant outcomes, and through what governance or market conditions?

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
- Use CMOs directly mapped to `rq2` when available.
- If `research_questions_mapped` is missing/incomplete, include CMOs that clearly show hindering mechanisms, governance failures, or adverse market conditions.
- Prioritize negative or frictional pathways; include positive findings only as counterclaims or boundary conditions.

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

PRIORITY FAMILIES FOR RQ2
1. governance_compliance_and_evaluation
2. procurement_performance
3. trade_finance_and_market_effects
4. policy_and_institutional_dynamics
5. procurement_politics_and_decision

ANALYSIS REQUIREMENTS
- Use the same overall structure and heading levels as `docs/synthesis/res_rq1.qmd`.
- Include `# Evidence Used` and `# Synthesis By Outcome Family`.
- Organize the synthesis by outcome family (one section per family with evidence).
- For each family section, include: outcome family description, hindering pathway, moderators, counterclaims (and mitigation clues when present), and strength of evidence.
- Include a collapsible `Detail` callout per family containing strength-of-evidence justification and relevant quotes (and expanded moderators/counterclaims when useful).
- Clearly separate systemic barriers from one-off implementation failures.
 
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
title: "RQ2 Synthesis (Realist Evidence Synthesis)"
format: html
freeze: false
bibliography: ../references/offsets.bib
---

# Question

<restate RQ2 in one sentence>

# Evidence Used

This synthesis draws on the CMO corpus entries that are explicitly mapped to 'rq2' in `data/cmo/*.yml` and are citation-mapped via `data/cmo/pdf_to_bibtex_key.yml`.

- RQ2-coded CMOs reviewed: <n>
- Outcome families represented: <n>
- Confidence profile (as recorded in the CMO YAML): <n high; n medium; n low if present>

# Synthesis By Outcome Family

Outcome families are used here as a stable, cross-document way to group outcome tendencies while keeping traceability to the underlying CMO evidence.

## <Outcome Family Title Case>

- **Outcome family description**: <one sentence, using the taxonomy definitions>
- **Pathway**: <hindering pathway for this outcome family> [@key]
- **Moderators**: <governance/market conditions and boundary conditions> [@key]
- **Counterclaims**: <counterevidence/credible exceptions> [@key]
- **Mitigation clues** (optional): <conditions/design features that reduce hindering effects> [@key]
- **Strength of evidence**: <Strong|Moderate|Limited|Mixed>.

::: {.callout-note collapse="true" title="Detail"}

**Strength of evidence**
- Rating: **<strong|moderate|limited|mixed>**
- Why: <brief justification grounded in the evidence> [@key]

**Relevant quotes**
- "..." [@key]
- "..." [@key]

**Moderators (expanded)** (optional)
- ... [@key]

**Counterclaims (expanded)** (optional)
- ... [@key]

:::

(repeat for each family with evidence)

# Cross-Family Synthesis

### Key Enabling Contexts (Repeated)
<Identify cross-family contexts in which hindering mechanisms are least likely to fire or are credibly mitigated (e.g., strong governance, high absorptive capacity, aligned incentives, transparent enforcement).>

### Main Boundary Conditions / Failure Points
<Summarize recurring governance/market failure points and boundary conditions that intensify harm (e.g., weak enforcement, secrecy, misaligned incentives, scale constraints, export-control friction, urgency-driven shortcuts).>

### Implications for RQ2 (Conditional)
<Synthesize what this implies about which mechanisms systematically hinder alliance-relevant outcomes, under what conditions, and which mitigations are most defensible from the evidence.>

# Evidence Audit

- Total RQ2-coded CMOs reviewed: <n>
- Outcome families represented in the RQ2-coded set: <comma-separated list of family labels>
- CMOs excluded as out-of-scope: <n with reason>
- Missing citation mappings: <none or list>

# References

::: {#refs}
:::