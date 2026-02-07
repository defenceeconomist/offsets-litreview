You are conducting a realist evidence synthesis for a single research question.

RESEARCH QUESTION (RQ1)
Under what contexts do offsets/industrial participation mechanisms enable alliance-relevant outcomes (interoperability, readiness, security of supply, partnership durability)?

RQ1 DETAIL (HOW TO INTERPRET THE QUESTION)
- Target explanatory goal: identify context-sensitive mechanisms (not just activities) that make alliance-relevant outcomes more (or less) likely.
- Treat "offsets/industrial participation mechanisms" broadly to include: direct/indirect offsets, local content and industrial participation requirements, IRB-style schemes, co-production/licensed production, industrial cooperation agreements, MRO/sustainment work packages, training, technology transfer, and credit/multiplier/incentive rules.
- Treat "alliance-relevant outcomes" as operationally and politically salient effects for allied integration, including:
  - interoperability/standardisation (common standards, shared configurations, ability to operate together)
  - readiness and sustainment (availability, in-country maintenance/modification/upgrade competence, spares pipelines)
  - security of supply/autonomy (assured access under crisis, control over critical subsystems such as software)
  - partnership durability (trusted long-term collaboration, supply-chain embedding, stable programmatic ties)
- "Enable" means the pathway plausibly increases the likelihood/level of these outcomes compared with a counterfactual of no offset/IP leverage or a different design (flag when the source only states intent/expectation rather than observed effect).
- Core RQ1 sub-questions to answer explicitly in the write-up:
  - Which mechanisms link offsets/IP to each alliance-relevant outcome domain?
  - Under what contexts do these mechanisms fire (and under what contexts do they fail or reverse)?
  - What are the main boundary conditions (scale, governance, absorptive capacity, export controls/tech release, urgency of supply)?
  - When do procurement-performance tradeoffs (cost/delay/inefficiency) undermine the alliance outcomes?
  - What alternative pathways achieve the same alliance outcomes without traditional offsets (e.g., partnering/joint development/risk sharing)?

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
- Use CMOs directly mapped to `rq1` when available.
- If `research_questions_mapped` is missing/incomplete, include CMOs that clearly address enabling contexts and alliance-relevant outcomes.
- Exclude CMOs that are purely about domestic political legitimation unless they connect to alliance outcomes.

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

PRIORITY FAMILIES FOR RQ1
1. alliance_security_outcomes
2. partnerships_and_supply_chains
3. technology_transfer_and_learning
4. industrial_capability_and_base
5. procurement_performance (only where it conditions alliance outcomes)

ANALYSIS REQUIREMENTS
- Use the same overall structure and heading levels as `docs/synthesis/res_rq1.qmd`.
- Include `# Evidence Used` and `# Synthesis By Outcome Family`.
- Organize the synthesis by outcome family (one section per family with evidence).
- For each outcome family section, include: outcome family description, pathway, moderators, counterclaims, and strength of evidence.
- Include a collapsible `Detail` callout per family containing strength-of-evidence justification and relevant quotes (and expanded moderators/counterclaims when useful).
- Prefer traceable claims grounded in explicit CMO statements.
- Distinguish observed outcomes from author expectations/speculation.
 
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
title: "RQ1 Synthesis (Realist Evidence Synthesis)"
format: html
freeze: false
bibliography: ../references/offsets.bib
---

# Question

<restate RQ1 in one sentence>

<include brief interpretive notes and sub-questions, using the RQ1 DETAIL section above (bullets are fine)>

# Evidence Used

This synthesis draws on the CMO corpus entries that are explicitly mapped to 'rq1' in `data/cmo/*.yml` and are citation-mapped via `data/cmo/pdf_to_bibtex_key.yml`.

- RQ1-coded CMOs reviewed: <n>
- Outcome families represented: <n>
- Confidence profile (as recorded in the CMO YAML): <n high; n medium; n low if present>

# Synthesis By Outcome Family

Outcome families are used here as a stable, cross-document way to group outcome tendencies while keeping traceability to the underlying CMO evidence.

## <Outcome Family Title Case>

- **Outcome family description**: <one sentence, using the taxonomy definitions>
- **Pathway**: <mechanism-linked enabling pathway for RQ1> [@key]
- **Moderators**: <key contexts/boundary conditions> [@key]
- **Counterclaims**: <credible counterevidence/alternatives> [@key]
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
<Across outcome families, identify contexts that most consistently enable alliance-relevant outcomes (interoperability/readiness/security of supply/partnership durability).>

### Main Boundary Conditions / Failure Points
<Summarize recurring boundary conditions (scale, governance, absorptive capacity, export controls/tech release, urgency of supply) that limit or reverse the pathways.>

### Alliance-Relevant Takeaways (Conditional)
<Synthesize what this implies for when offsets/IP are likely to enable alliance-relevant outcomes, and when alternative pathways (partnering/joint development/risk sharing) are more credible.>

# Evidence Audit

- Total RQ1-coded CMOs reviewed: <n>
- Outcome families represented in the RQ1-coded set: <comma-separated list of family labels>
- CMOs excluded as out-of-scope: <n with reason>
- Missing citation mappings: <none or list>

# References

- [@bibtexKey]
