Prompt: Proto-Mechanism Theme Allocation Audit (One Theme at a Time)

ROLE
You are supporting a realist evidence synthesis. Your task is to audit whether mechanisms currently assigned to ONE target proto-mechanism theme are allocated to the best-fitting theme.

You must classify by underlying generative causal process, not topic similarity.

INPUTS YOU WILL RECEIVE

1) target_theme_id
The theme ID to audit (e.g., PM17).

2) proto_themes_yml
The full current contents of: data/mechanism_themes/proto_themes.yml

3) proto_themes_changelog_yml
The full current contents of: data/mechanism_themes/proto_themes_changelog.yml

REFERENCE EXTRACTION (PYTHON) — USE THIS WORKFLOW EVERY TIME

Use this code structure to ensure you consistently compare mechanisms to ALL themes’ labels and explanations.
(This is a workflow reference; do not execute it.)

```python
import re
import yaml

proto = yaml.safe_load(proto_themes_yml)  # dict
themes = proto["proto_mechanism_themes"]  # list[dict]

theme_index = {
  t["theme_id"]: {
    "theme_label": t["theme_label"],
    "mechanism_explanation": t["mechanism_explanation"],
  }
  for t in themes
}

target_theme = next(t for t in themes if t["theme_id"] == target_theme_id)
candidate_mechanisms = list(target_theme.get("mechanisms", []))

changelog = yaml.safe_load(proto_themes_changelog_yml)
existing_ids = [
  int(re.search(r"CHG_(\\d+)$", c["change_id"]).group(1))
  for c in changelog.get("change_log", [])
  if re.search(r"CHG_(\\d+)$", c.get("change_id", ""))
]
next_change_num = (max(existing_ids) + 1) if existing_ids else 1
```

AUDIT TASK (FOR THE TARGET THEME ONLY)

For each mechanism currently inside the target theme:

1) Compare the mechanism (its `text`) against EVERY theme’s:
- `theme_label`
- `mechanism_explanation`

2) Decide one outcome:

A) KEEP IN TARGET THEME
Only if the target theme’s explanation is the best match to the mechanism’s causal logic.

B) REALLOCATE TO A DIFFERENT EXISTING THEME
If another theme’s label/explanation clearly fits the mechanism better than the target theme.

C) MARK AMBIGUOUS
If the mechanism plausibly fits 2+ themes and you cannot decide confidently.
Move it to `ambiguous_mechanisms` and list the likely theme IDs in `possible_themes`.

DECISION RULES (STRICT)

- Use generative process similarity, not:
  - shared outcomes
  - shared country/programme
  - shared sector / platform
  - surface keywords

- “Better fit” means: another theme’s explanation more directly states the causal process described in the mechanism.

- Do not create new themes in this task.

EDITING RULES (STRICT)

- Do not change any mechanism `id` or `text`.
- You MAY update `rationale` when a mechanism is kept or moved, but keep it short and specific to why it fits that theme.
- Ensure each mechanism appears exactly once across:
  - all themes’ `mechanisms` lists, OR
  - `ambiguous_mechanisms`
- Only move mechanisms that were originally in the target theme for this run.
  - Do not “clean up” other themes unless needed to avoid duplicates created by your move.

CHANGE LOGGING (UPDATE EXISTING YAML CHANGE LOG)

The change log file contains a history of many kinds of theme edits (e.g., `new_theme`, `merge`, `no_change`, `assignment`).

You MUST preserve all existing entries exactly as they are, and append new entry/entries for every change you make in this run:

- If moved theme-to-theme: `change_type: assignment`
- If moved to ambiguous: `change_type: ambiguous`

Each entry must include:
- `change_id`: next sequential ID (CHG_###), continuing from the current max
- `theme_id`: the destination theme ID (or `AMBIGUOUS`)
- `mechanism_id`
- `summary`: 1 sentence describing what changed (include from/to theme IDs)
- `rationale`: 1–2 sentences justifying the change in terms of causal process fit

OUTPUT FORMAT (TWO STRICT YAML DOCUMENTS)

Return TWO YAML documents separated by a line containing only `---`.

Document 1 will be saved to: data/mechanism_themes/proto_themes.yml
Document 2 will be saved to: data/mechanism_themes/proto_themes_changelog.yml

Document 1 MUST match this schema:

proto_mechanism_themes:
  - theme_id: PM1
    theme_label: "Label"
    mechanism_explanation: "Explanation"
    mechanisms:
      - id: MECH_001
        text: "Full mechanism statement"
        rationale: "Why it fits this theme’s causal process."

ambiguous_mechanisms:
  - id: MECH_031
    text: "Full mechanism statement"
    possible_themes: [PM2, PM4]
    explanation: "Why assignment is ambiguous; what evidence would resolve it."

Document 2 MUST match this schema:

change_log:
  - change_id: CHG_123
    change_type: assignment | ambiguous | new_theme | merge | no_change
    theme_id: PM7 | AMBIGUOUS
    mechanism_id: MECH_022  # present for mechanism-level changes; may be absent for theme-level entries (e.g., merges)
    summary: "Moved MECH_022 from PM3 to PM7."
    rationale: "Mechanism describes X causal process; PM7 explicitly captures X, whereas PM3 captures Y."

Do not include any commentary outside the TWO YAML documents.

INPUTS

1) target_theme_id
PM34

2) proto_themes_yml
```yaml
proto_mechanism_themes:
- theme_id: PM1
  theme_label: Legitimation through economic framing
  mechanism_explanation: Presenting offsets as economic benefits or conditional support shifts decision-makers’ and publics’
    cost-benefit reasoning, making purchases more politically acceptable.
  mechanisms:
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_001
    text: By offering cost offsets framed as economic benefits, sellers provide an inducement that shifts decision-makers’
      reasoning from reluctance to acceptance.
    rationale: Frames offsets as economic benefits that shift decision-makers toward acceptance.
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_002
    text: By embedding compensatory work in an offset package, officials can present support to domestic producers as a condition
      of purchase rather than a visible subsidy, reducing political costs.
    rationale: Uses offset packaging to present support as a purchase condition, lowering political exposure.
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_003
    text: By making offsets appear to deliver large economic benefits (even if illusory), officials reduce perceived net costs
      and increase public acceptance.
    rationale: Emphasises perceived benefits to reduce net-cost perceptions and build public acceptance.
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_021
    text: Promised offset benefits provide an argument that reframes the purchase as economically beneficial, reducing resistance.
    rationale: Reframes the purchase as economically beneficial to reduce resistance.
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_003
    text: Because expected benefits are more salient than expected costs, officials adopt offsets even when net welfare effects
      are ambiguous.
    rationale: Benefit salience drives adoption despite ambiguous net welfare.
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_010
    text: Buyer ability to extract economic activity and know-how via offsets increases willingness to import superior foreign
      systems, reinforcing exporter dominance while forcing work-sharing back to buyer countries.
    rationale: Ability to extract activity and know-how via offsets increases willingness to buy foreign systems.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_001
    text: Politicians use offset promises as persuasive rhetoric to frame weapons purchases as delivering wider economic development
      benefits.
    rationale: Offset promises frame purchases as economic development, increasing acceptability.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_005
    text: By creating concentrated local benefits for the military, politicians, and firms, offsets generate supportive coalitions
      that reduce political resistance to procurement.
    rationale: Concentrated local benefits build supportive coalitions that reduce political resistance.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_001
    text: By offering offsets (including technology transfer and production arrangements) as inducements in defense sales,
      the US reinforces alliance ties and supports interoperability and extended production.
    rationale: Offsets as inducements in sales reinforce alliances and interoperability, increasing acceptance.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_018
    text: Offsets and arms sales reinforce political and alliance-building signals, which Taiwan values as assurance of ongoing
      US security commitment.
    rationale: Offsets and arms sales signal alliance commitment and assurance.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_001
    text: Officials emphasized offsets as promised economic benefits to shift public and political reasoning toward acceptance
      of the arms purchase.
    rationale: Offsets framed as promised benefits shift public/political acceptance.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_003
    text: Promoters emphasize job creation and investment narratives to legitimize offsets as development tools, even as the
      job-creation emphasis later weakens.
    rationale: Job-creation narratives legitimate offsets as development tools.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_017
    text: Promised regional industrial participation benefits (e.g., Ferrostaal steel projects) can act as decisive inducements
      in selecting higher-priced bids.
    rationale: Promised regional benefits act as inducements in bid selection.
  - id: 01_introduction_and_overview_pdf__cmo_011
    text: Arms sales paired with technology-transfer offsets build local capacity and simultaneously serve as a tool to reinforce
      diplomatic and military ties.
    rationale: Transfers build local capacity while reinforcing diplomatic/military ties.
  - id: 01_introduction_and_overview_pdf__cmo_012
    text: Offsets are used to redirect some procurement-related value toward domestic industrial/technological upgrading and
      to improve political acceptability; purchasers may pay a premium to place work locally.
    rationale: Offsets redirect value to domestic upgrading and improve political acceptability.
- theme_id: PM2
  theme_label: Compliance shaped by incentives and monitoring
  mechanism_explanation: 'Delivery depends on the enforcement regime: transparency and credible incentives/penalties encourage
    compliance, while weak oversight and accounting games reduce real fulfilment.'
  mechanisms:
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_004
    text: Shifts in conditions, contractor fortunes, or bad faith reduce the ability and incentives to complete promised offset
      activities, especially when enforcement is weak.
    rationale: Weak enforcement and changing conditions reduce incentives and capacity to fulfil obligations.
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_005
    text: Structuring offset agreements to maximize transparency and create credible incentives/penalties increases supplier
      compliance with offset obligations.
    rationale: Transparency plus credible incentives/penalties raise compliance with obligations.
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_006
    text: By counting pre-existing transactions as meeting offset obligations, suppliers inflate apparent offset delivery
      without creating genuinely additional business.
    rationale: Counts pre-existing transactions to appear compliant without additional delivery.
  - id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_006
    text: Suppliers may accept obligations but later default, and although buyers can attempt incentive contracts, enforcement
      is difficult in practice.
    rationale: Enforcement difficulties allow suppliers to default despite contractual attempts to incentivize compliance.
  - id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_013
    text: Suppliers can promise offsets to win contracts and later renege or deliver less value, because timing and enforcement
      frictions weaken purchaser leverage.
    rationale: Timing and enforcement frictions enable reneging or under-delivery after contract award.
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_019
    text: If the exporter would have pursued the same partnerships through normal due diligence regardless of offset credit,
      then the offset does not cause the business relationship; it only changes accounting labels.
    rationale: Credits can relabel business relationships that would occur anyway, inflating apparent delivery.
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_008
    text: Long fulfillment horizons and crediting practices allow firms to receive offset credit exceeding transactional fulfillment
      value.
    rationale: Crediting practices can overstate fulfillment relative to real value delivered.
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_016
    text: Licensed production/technology sharing associated with offsets increases opportunities for diversion, while enforcement
      is inadequate and undetected transfers likely exceed detected cases.
    rationale: Weak enforcement allows diversion of licensed production and technology sharing.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_005
    text: The threat of reduced consideration for future bids provides an informal enforcement incentive to meet offset targets.
    rationale: Informal threat of future bid exclusion incentivizes compliance.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_006
    text: Multipliers and penalty-backed obligations increase incentives for investment and technology transfer into pre-determined
      local sectors.
    rationale: Multipliers and penalties strengthen incentives for investment and transfer.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_013
    text: When pre-existing or follow-on work is counted as offset credit, the true incremental value of offsets is overstated
      and accountability weakens.
    rationale: Counting pre-existing work as credit inflates delivery and weakens accountability.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_014
    text: Credit banking relaxes immediate delivery constraints and enables long-term, multi-project clearing, but can reduce
      transparency about what is delivered for a given contract.
    rationale: Credit banking reduces transparency about delivery tied to a contract.
  - id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_005
    text: Reducing multipliers or evaluating them case-by-case limits artificial inflation of offset value and shifts emphasis
      to verifiable projects.
    rationale: Reducing multipliers or reviewing them case-by-case limits inflated credit values.
  - id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_006
    text: Restricting banking (time limits, transfer limits, caps on proportion satisfied) preserves closer coupling between
      current procurement and compensatory activity.
    rationale: Restricting banking preserves coupling between procurement and compensatory activity.
  - id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_007
    text: Denmark avoids financial penalties because it acknowledges penalties raise import prices, instead using supplier
      blacklisting; Norway uses withheld-payment sanctions; Finland/Sweden accept economic sanctions.
    rationale: Sanctions/blacklisting create enforcement incentives without necessarily raising prices via penalties.
  - id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_011
    text: Complex and heterogeneous offset arrangements decouple headline percentage values from actual work delivered, complicating
      audits and comparisons.
    rationale: Complex arrangements decouple headline percentages from real delivery, complicating audits.
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_006
    text: Because supplier contribution to deal initiation cannot be established and some projects would have occurred anyway,
      fulfillment rates can be inflated by multiplier pricing, consultants, and advance crediting.
    rationale: Multipliers and advance crediting inflate fulfillment where projects would occur anyway.
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_013
    text: Lack of clear requirements and approval criteria enables retroactive crediting and preferential treatment, reducing
      competition and potentially raising prices.
    rationale: Vague criteria enable retroactive crediting and preferential treatment, undermining competition.
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_014
    text: Making policy more specific, setting approval criteria in advance, and requiring competitive bidding and continuous
      monitoring improves transparency and limits distortions.
    rationale: Clear criteria, competitive bidding, and monitoring improve transparency and reduce distortions.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_003
    text: Because additionality is difficult to measure and work may be re-labeled or low quality, credited projects do not
      reliably represent new economic activity.
    rationale: Relabeling or low-quality work undermines additionality and accountability.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_012
    text: Through pre-compensations (offset banking credits), suppliers count normal trade flows as offsets against future
      obligations.
    rationale: Pre-compensation credits allow normal trade to count against future obligations.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_005
    text: By applying multipliers (including exceptionally high ones), policymakers can inflate credited offset value beyond
      underlying transaction costs, enabling “headline” offset totals.
    rationale: High multipliers inflate credited offset value beyond underlying transactions.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_006
    text: Non-terminable agreements and liquidated damages (up to 100% of outstanding obligations) raise expected costs of
      non-compliance and are intended to enforce delivery.
    rationale: Strong penalties and non-terminable agreements raise non-compliance costs to enforce delivery.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_009
    text: Parallel bargaining and the option to specify projects allow the buyer to attempt to reduce ambiguity and lock suppliers
      into concrete deliverables.
    rationale: Parallel bargaining and project specification reduce ambiguity and lock suppliers into deliverables.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_010
    text: Because credited value is set to reflect value to the economy rather than actual provision costs, administrative
      crediting can decouple “credit” from real effort.
    rationale: Administrative crediting can decouple value credited from real effort.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_012
    text: Multipliers and differing valuation conventions enable large gaps between “nominal,” “net,” and “gross” reported
      offset values, complicating verification.
    rationale: Multipliers and valuation conventions create large gaps between nominal and net values.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_013
    text: By insisting on specific offset projects and obligations rather than an open agreement, Poland attempts to lock
      in hard commitments and reduce supplier discretion.
    rationale: Specific projects and obligations reduce supplier discretion and lock in commitments.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_015
    text: Low liquidated-damages rates reduce the expected cost of non-performance, making it rational for a supplier to pay
      penalties instead of fully discharging obligations in some cases.
    rationale: Low liquidated damages lower expected non-performance costs, enabling strategic non-compliance.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_018
    text: Multipliers raise credited value for higher-priority activities (technology transfer, training, licensing/copro)
      and thereby steer supplier effort toward capability-building deliverables.
    rationale: Multipliers steer effort toward capability-building deliverables by inflating credit values.
  - id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_012
    text: A knowledgeable negotiating team can secure more favorable, capability-relevant terms and reduce asymmetric-information
      risks in offset contracting.
    rationale: Skilled negotiators reduce information asymmetry and secure better capability terms.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_013
    text: The threat of banning contractors from future competitions increases incentives to fulfill offset obligations.
    rationale: Future-ban threats increase incentives to fulfill obligations.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_001
    text: Mandating offset obligations and tracking acquittals creates stronger compliance incentives and clearer reporting,
      even though compliance may not equal net benefit.
    rationale: Mandated obligations and tracking strengthen compliance incentives and reporting.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_003
    text: Eligibility criteria plus multipliers steer suppliers toward higher-valued activities (e.g., R&D and training) by
      making them “count” more toward obligations.
    rationale: Eligibility criteria and multipliers steer suppliers toward higher-valued activities.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_004
    text: Project Deeds, Credit Deeds, and liquidated damages create enforceable commitments and rewards for longer-term programs,
      increasing follow-through on planned activity.
    rationale: Deeds and liquidated damages create enforceable commitments and follow-through.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_014
    text: Assigning multipliers (value weights) to activities and embedding deliverables in contracts with liquidated damages
      increases compliance leverage while signalling which activities are most valued.
    rationale: Multipliers and liquidated damages increase compliance leverage and signal priorities.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_017
    text: Allowing credits and waivers creates a flexible “bank and trade” system that encourages suppliers to exceed participation
      targets and aligns NZIP and offsets requirements.
    rationale: Credits and waivers create flexible banking that encourages exceeding targets.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_005
    text: A quantified obligation (percent of imported content) plus a defined fulfillment window compels suppliers to design
      “credit-generating” projects to meet targets.
    rationale: Quantified obligations and windows compel design of credit-generating projects.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_007
    text: If paying penalties is easier than delivering substantive participation, suppliers may renege and accept the financial
      cost rather than implement projects.
    rationale: If penalties are cheaper, suppliers may choose to pay rather than perform.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_005
    text: A high required offset percentage increases supplier effort to maximize creditable projects and diversify investment
      offerings.
    rationale: High required percentages increase supplier effort to maximize creditable projects.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_006
    text: Ongoing negotiation and re-scoping allows obligators and agencies to adjust project lists to meet credits and feasibility
      constraints over time.
    rationale: Ongoing negotiation/re-scoping adjusts project lists to meet credits and feasibility.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_014
    text: Credit-maximizing “shrewd investments” can make interventions appear larger in reports than their on-the-ground
      developmental impact.
    rationale: Credit-maximizing investments inflate reported impact versus real development.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_025
    text: If the whole product value can be claimed as export credit, vendors can inflate credited performance relative to
      actual local value-added.
    rationale: Claiming full product value inflates export credit relative to local value-added.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_026
    text: When projects are not clearly additional to the offset deal, attributing outcomes to offsets becomes problematic
      and encourages narrative-driven reporting.
    rationale: Unclear additionality encourages narrative-driven reporting.
  - id: 01_introduction_and_overview_pdf__cmo_017
    text: When post-obligation purchases can be credited as banked offset, vendors continue placing work to build credit for
      future obligations.
    rationale: Banked credits motivate continued placements to build future credit.
- theme_id: PM3
  theme_label: Cost pass-through via pricing
  mechanism_explanation: Suppliers internalise offset costs and recover them by raising the weapon sale price, shifting the
    burden to buyers.
  mechanisms:
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_007
    text: Vendors incorporate offset premiums into the weapons selling price to recoup offset costs.
    rationale: Passes offset costs into the sale price to recover premiums.
  - id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_004
    text: Because there is no unique benchmark price, suppliers can embed offset-related costs into the offered weapons price
      without the buyer being able to verify price padding.
    rationale: Lack of benchmark prices enables embedding offset costs into the sale price.
  - id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_005
    text: Suppliers accept offset obligations only when the overall package yields satisfactory returns, adjusting the weapons
      price upward if needed or walking away otherwise.
    rationale: Suppliers raise prices to maintain returns or exit if obligations undermine profitability.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_011
    text: Vendors treat offset costs as a pricing issue and attempt to load costs into the primary contract price, while buyers
      escalate targets to reduce pass-through.
    rationale: Vendors price offset costs into contracts while buyers push back via higher targets.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_006
    text: Suppliers pass on offset-related administrative and production costs through higher negotiated prices, weakening
      market discipline.
    rationale: Administrative and production costs are passed through in higher negotiated prices.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_013
    text: Suppliers incur offset-related overhead and transfer costs that are priced into the contract, while buyers accept
      higher prices as an investment.
    rationale: Offset overhead and transfer costs are priced into contracts as buyer-accepted investments.
  - id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_006
    text: Currency devaluation reduces the real (USD-equivalent) value of government payments, increasing contract risk and
      prompting renegotiation or exit threats.
    rationale: Currency devaluation raises contract risk and prompts renegotiation or exit threats.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_010
    text: Supplier-provided credit can be priced into higher selling prices or structured as subsidies to the exporting firm,
      reducing value-for-money and increasing failure risk.
    rationale: Supplier credit priced into higher prices or subsidies reduces value-for-money.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_024
    text: Requiring local participation in assembly can add cost relative to alternative sourcing, creating a local-content
      premium.
    rationale: Local participation in assembly can create a local-content price premium.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_004
    text: When prices are not fixed or comparable, monitoring compliance with “no price increase” requirements becomes difficult,
      increasing the risk of hidden price padding.
    rationale: No-price-increase requirements are hard to verify, raising padding risk.
  - id: 01_introduction_and_overview_pdf__cmo_007
    text: Vendors incorporate the expected cost premium of offset obligations into bid prices, raising acquisition costs relative
      to an equivalent off-the-shelf purchase.
    rationale: Offset cost premiums are priced into bids, raising acquisition costs.
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_004
    text: Suppliers insure against penalty and compliance risks by raising contract values, and administrative burdens also
      increase costs, obscuring the true price premium of offsets.
    rationale: Compliance risk and administrative burdens are priced into contract values, increasing acquisition costs.
- theme_id: PM4
  theme_label: Offsets crowd out civilian resources
  mechanism_explanation: Offset activity can absorb scarce capital, labour, or productive capacity, diverting resources away
    from civilian sectors that would otherwise drive development.
  mechanisms:
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_008
    text: Military-sector offset work diverts productive resources away from civilian production that contributes more directly
      to development.
    rationale: Military offset work redirects productive resources away from civilian development uses.
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_013
    text: When offset activity is financed domestically, it crowds out local investment opportunities by absorbing limited
      capital from within the purchasing country.
    rationale: Domestic financing absorbs scarce capital, displacing other investments.
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_015
    text: If offset projects simply hire already skilled workers from the limited local pool, they preempt labor needed by
      domestic civilian producers.
    rationale: Hiring scarce skilled workers for offsets deprives civilian producers of needed labour.
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_013
    text: Allocating taxpayer resources to offset-related military industry imposes opportunity costs by diverting funds from
      civilian social sectors with potentially higher social returns.
    rationale: Public funds diverted to offset-related military industry crowd out higher-return civilian uses.
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_013
    text: Direct offsets shift work away from domestic suppliers toward foreign subcontractors, with suppliers bearing a large
      share of displacement.
    rationale: Direct offsets displace domestic suppliers, shifting work abroad.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_018
    text: Large outbound offset obligations can outweigh inbound industrial participation work, producing net job losses in
      the longer term.
    rationale: Large outbound obligations can outweigh inbound work, reducing net jobs.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_007
    text: Financing infrastructure for short runs creates sunk costs and excess capacity that cannot be efficiently utilized
      once the offset work ends.
    rationale: Short-run infrastructure creates sunk costs and excess capacity once work ends.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_016
    text: Capital- and skill-intensive offset activities generate relatively few jobs per unit of spending, driving up cost
      per job.
    rationale: Capital-intensive offsets yield few jobs per spend, increasing cost per job.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_017
    text: Opportunity costs mean that allocating large budgets to arms with offsets can reduce the number of jobs created
      relative to alternative civilian spending.
    rationale: Opportunity costs of offset-linked arms spending reduce job creation versus civilian uses.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_019
    text: Large, capital-intensive IDZ projects require substantial additional state investment and incentives, creating hidden
      costs that are often excluded from official offset assessments.
    rationale: Capital-intensive projects require extra state incentives, creating hidden costs.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_022
    text: More diverse input requirements in shipbuilding create larger local employment multipliers than ship repair.
    rationale: Diverse input requirements create larger local employment multipliers.
- theme_id: PM5
  theme_label: External finance expands resource pool
  mechanism_explanation: When funding comes from external sources, offsets inject new resources rather than reallocating domestic
    capital, easing the net drain of purchases.
  mechanisms:
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_011
    text: External grant funding adds resources for development projects, partially counterbalancing the resource drain of
      the arms purchase.
    rationale: External grants inject new resources that offset the arms purchase drain.
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_012
    text: When offset investment is financed from outside the purchasing country, it increases net capital availability rather
      than reshuffling scarce domestic finance.
    rationale: Foreign-financed investment adds net capital rather than reallocating domestic funds.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_004
    text: Offset-linked work and partly foreign-financed investments provide access to specialized production and know-how
      that would otherwise be unaffordable.
    rationale: Offset-linked investments provide access to specialized production and know-how.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_002
    text: By offering long-term, low-interest credit and accepting rupee-based countertrade, the Soviet supplier reduces India’s
      immediate hard-currency constraint, making acquisitions financially feasible.
    rationale: Long-term credit and countertrade ease hard-currency constraints, enabling acquisition.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_015
    text: Targeted soft loans and equity investments provide liquidity and capital enabling firm survival, facility expansion,
      and market growth.
    rationale: Soft loans/equity provide liquidity and capital for survival and expansion.
- theme_id: PM6
  theme_label: Additional trade yields net gains
  mechanism_explanation: Counterpurchase that generates genuinely additional exports creates new revenue streams and supports
    employment.
  mechanisms:
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_010
    text: When counterpurchase creates genuinely additional export sales (not otherwise achievable or less profitable without
      the deal), it increases revenue and supports productive civilian employment.
    rationale: Genuinely additional counterpurchase exports create new revenue and jobs.
  - id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_003
    text: By requiring reciprocal purchases to be additional (“new activity”), the offset policy aims to create exports that
      would not otherwise occur.
    rationale: Additionality requirements aim to create exports that would not otherwise occur.
- theme_id: PM7
  theme_label: Training expands local skill supply
  mechanism_explanation: Mandated employer-funded training expands the local skill base, increasing labour supply instead
    of depleting it.
  mechanisms:
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_016
    text: Requiring employer-financed training that raises lower-skilled workers to the needed level expands the local skill
      pool rather than draining it.
    rationale: Employer-funded training increases the skill pool rather than drawing it down.
- theme_id: PM8
  theme_label: Transferability and contextual fit
  mechanism_explanation: 'Spillovers hinge on transferability and fit: military-origin skills/technologies often mismatch
    civilian contexts, and careful selection and implementation reduce adaptation failures and costs.'
  mechanisms:
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_014
    text: Skills developed for performance-driven, cost-insensitive military production are not easily transferable (or require
      costly reshaping) to civilian production needs.
    rationale: Military-production skills do not transfer easily to civilian needs without costly reshaping.
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_017
    text: Because military technologies often require costly reshaping for civilian uses, pursuing civilian technology directly
      is generally more cost-effective.
    rationale: Military technologies need costly adaptation, making civilian tech more efficient.
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_018
    text: When transferred technologies are incompatible with the receiving environment, they fail to function effectively
      or to integrate into productive systems.
    rationale: Incompatible transferred technologies fail to function or integrate productively.
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_019
    text: Selecting appropriate technologies and implementing transfer carefully increases the likelihood that transferred
      technologies are usable and development-relevant.
    rationale: Careful selection and implementation improve usability of transferred technologies.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_015
    text: Vendors manage risk by transferring aged or limited-scope technology and restricting access via IP/legal barriers
      and black-boxing, limiting learning.
    rationale: IP restrictions and black-boxing limit learning from transferred technology.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_006
    text: By withholding core technologies, limiting exports, and charging extra for uncovered transfers, the supplier retains
      leverage and constrains the buyer’s independent capability development.
    rationale: Withholding core tech and export limits constrain independent capability development.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_020
    text: Political constraints limit the depth of technology transfer and can result in systems with restricted capabilities
      relative to Taiwan’s needs.
    rationale: Political constraints limit depth of transfer and system capability.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_008
    text: Indigenous design efforts can build higher-level capability, but continued reliance on foreign components constrains
      autonomy and increases program risk.
    rationale: Reliance on foreign components constrains autonomy and raises program risk.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_010
    text: When primes allocate relatively low-tech tasks, local participation may yield limited technology upgrading and weaker
      capability deepening.
    rationale: Low-tech task allocation limits technology upgrading and capability deepening.
- theme_id: PM9
  theme_label: Barter eases constraints, reduces transparency
  mechanism_explanation: Barter arrangements relax financial constraints but reduce transparency, creating mutual advantage
    for supplier and buyer.
  mechanisms:
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_009
    text: Barter bypasses financial constraints and reduces transaction transparency, which can advantage both supplier and
      purchasing government.
    rationale: Barter circumvents finance constraints while lowering transparency for both parties.
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_002
    text: Non-monetary offset trade substitutes in-kind exchanges for cash payment, bypassing credit-market constraints.
    rationale: In-kind trade substitutes for cash and bypasses credit constraints.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_001
    text: Familiarity with countertrade and bundling makes actors more willing and able to operate in compensatory arrangements
      and navigate opaque deal structures.
    rationale: Familiarity with countertrade/bundling improves ability to operate in compensatory arrangements.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_011
    text: By paying for imports through commodities and rupee trade, India expands and diversifies exports and obtains inputs/capital
      goods without immediate hard-currency outlays.
    rationale: Commodity/rupee trade expands exports and secures inputs without hard currency.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_012
    text: If exchange rates are unfavorable or exports are diverted from hard-currency markets, countertrade imposes hidden
      costs that accumulate as debt and repayment burdens.
    rationale: Countertrade can impose hidden costs and debt burdens when FX terms are unfavorable.
- theme_id: PM10
  theme_label: Offsets as supplier differentiator
  mechanism_explanation: When core capability requirements are fixed, offset offers differentiate suppliers and influence
    selection.
  mechanisms:
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_020
    text: Offsets function as a differentiator between suppliers when core capability requirements are fixed.
    rationale: Offsets become a competitive lever when core requirements are fixed.
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_009
    text: Competitive pressure among sellers makes offsets a feature of bidding; firms include offsets when doing so increases
      expected profits by preventing loss of sales to rivals.
    rationale: Competitive pressure makes offsets a bidding feature when they protect expected profits.
  - id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_003
    text: Offsets (along with credits/loan guarantees) become competitive tools rather than purely political add-ons, pushing
      Nordic policies to become more specific and technology-focused.
    rationale: Offsets become competitive tools used to win bids, not just political add-ons.
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_001
    text: Firms compete by offering attractive offset packages, and buyer governments use bargaining leverage to demand optimally
      beneficial compensation arrangements.
    rationale: Firms compete on offsets and buyers leverage that competition to demand better compensation.
  - id: 01_introduction_and_overview_pdf__cmo_015
    text: Suppliers use offset packages as a competitive differentiator that can tip purchasing decisions when core product
      offerings are otherwise comparable.
    rationale: Offset packages act as a competitive differentiator when products are comparable.
  - id: 01_introduction_and_overview_pdf__cmo_018
    text: If one exporter limits offset offerings, purchasers shift to alternative suppliers; thus firms offer offsets while
      simultaneously downplaying domestic harms to policymakers.
    rationale: Competitive pressure leads firms to offer offsets to avoid losing sales.
- theme_id: PM11
  theme_label: Domestic industry influence on offsets
  mechanism_explanation: Domestic arms-industry influence shapes procurement demands, pushing governments to require direct
    offsets that effectively subsidize local military industry.
  mechanisms:
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_022
    text: Domestic arms-industry influence pushes governments to demand direct offsets that subsidize local military industry
      as part of foreign procurement.
    rationale: Domestic arms-industry influence drives demands for direct offsets that subsidize local industry.
- theme_id: PM12
  theme_label: Development-oriented indirect offset design
  mechanism_explanation: Specifying development-oriented indirect offsets and emphasizing transparency increases the likelihood
    that promised activities are realized and development-relevant.
  mechanisms:
  - id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_023
    text: Requiring development-oriented indirect offsets (capital inflows, appropriate technology transfer, transferable
      skills, and/or new markets) and emphasizing transparency increases the chance of realization and development relevance.
    rationale: Targets indirect offsets and transparency to improve realization and development relevance.
- theme_id: PM13
  theme_label: Offsets shift competition to bundled content
  mechanism_explanation: Requiring offset packages redirects competition away from price/quality and toward bundled content,
    even when that content is unrelated to the procured item.
  mechanisms:
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_001
    text: By requiring benefits packages alongside the base good, offsets redirect competition away from price/quality toward
      bundled content that may be unrelated to the procured item.
    rationale: Benefits packages shift competition from price/quality to bundled content.
- theme_id: PM14
  theme_label: Rent extraction via offset requirements
  mechanism_explanation: Offset policy compels suppliers to transfer economic activity domestically, extracting rents from
    the price margin and enabling governments to pursue multiple objectives through procurement.
  mechanisms:
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_002
    text: Offset policy extracts rent off the price margin by requiring sellers to transfer economic activity into the domestic
      economy, allowing governments to pursue multiple objectives through procurement.
    rationale: Uses offset requirements to extract rents and channel activity into the domestic economy.
- theme_id: PM15
  theme_label: Flexibility reduces mandate diseconomies
  mechanism_explanation: Rigid, one-size mandates constrain negotiation and force offsets where market exchange would be superior,
    creating diseconomies of scale and scope; variable policies increase flexibility and reduce these losses.
  mechanisms:
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_004
    text: A one-size-fits-all mandate constrains negotiation dimensions and creates diseconomies of scale and scope by forcing
      offsets where market exchange would be superior.
    rationale: One-size mandates force offsets where market exchange is superior, creating diseconomies.
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_010
    text: A variable offset policy increases negotiation flexibility and the opportunity set, allowing comparison of price-margin
      exchange versus offsets and reducing diseconomies of scope.
    rationale: Variable policies expand negotiation options and reduce diseconomies of scope.
  - id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_007
    text: Bureaucratically mandated, fixed-percentage offset schemes reduce negotiation flexibility by forcing in-kind enhancements
      instead of allowing negotiators to choose the most advantageous mix of price and content.
    rationale: Fixed-percentage schemes force in-kind content and reduce negotiation flexibility.
  - id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_008
    text: High local content targets force inclusion of uncompetitive domestic subcontractors, generating price premiums that
      are factored into bid prices or motivate reneging when premiums are constrained.
    rationale: High local-content mandates force uncompetitive subcontracting, raising prices or inducing reneging.
  - id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_012
    text: Untargeted bundle targets ignore complementarities and may force inefficient bundling choices compared to separately
      sourcing requirements from specialized vendors.
    rationale: Untargeted bundling ignores complementarities and forces inefficient package choices.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_004
    text: Flexible, negotiated approaches (case-by-case) can maximize mutual benefit without necessarily reducing technology
      transfer, while rigid prescription increases stress as demands rise.
    rationale: Flexible negotiation improves fit and reduces stress compared to rigid prescriptions.
  - id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_008
    text: Political pressure from partners leads the JSF Program Office to add “strategic best value” set-asides to ensure
      some work is reserved for partner-nation contractors meeting cost/schedule.
    rationale: Set-asides adjust competitive allocation to manage political pressure, reducing pure price/content flexibility.
  - id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_008
    text: Policies explicitly prohibit offsets from influencing supplier choice until systems meet requirements, preventing
      offsets from distorting capability selection.
    rationale: Offset exclusion from supplier choice prevents distortion of capability selection.
  - id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_010
    text: When subcontracts are awarded commercially, partner nations must pay for participation and accept less than full
      influence and less than full industrial participation.
    rationale: Commercial subcontracting reduces influence and participation for partners who pay to join.
  - id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_012
    text: Recognizing higher costs and lower-than-expected gains prompts policy revisions to allow less than 100% offsets
      or even zero in specific cases.
    rationale: Recognizing high costs and low gains triggers policy relaxation of offset requirements.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_011
    text: If procurement occurs late, offset arrangements focus on subcontracting rather than integrating the buyer into earlier
      R&D collaboration.
    rationale: Late procurement shifts offsets toward subcontracting rather than early R&D collaboration.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_017
    text: By limiting offsets to tie-break situations (equivalent tenders) and capping their weight, decision-makers reduce
      reliance on compensations while preserving a political compromise.
    rationale: Limiting offsets to tie-breaks reduces reliance while preserving political compromise.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_004
    text: Mandatory 100% offsets and a 50% direct-offset requirement force suppliers to structure deals around local production/content
      rather than purely financial or indirect benefits.
    rationale: Mandatory direct-offset shares force deal structures toward local content.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_014
    text: Negotiation constraints and valuation choices can yield offset packages that diverge from statutory composition
      targets.
    rationale: Negotiation constraints and valuation choices can diverge from statutory composition targets.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_019
    text: Treating direct offsets as tariff-like protection provides demand and time for restructuring, while specificity
      and scrutiny aim to narrow promise-delivery gaps.
    rationale: Direct offsets act as protection to enable restructuring; scrutiny narrows promise-delivery gaps.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_011
    text: Flexible negotiation norms allow offset packages to be tailored to domestic technological capacity and workforce-cost
      considerations rather than meeting a rigid ratio.
    rationale: Flexible negotiation tailors offsets to domestic capacity rather than rigid ratios.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_017
    text: Integrating offsets with diversification of defense-based industries and indigenous R&D can align procurement incentives
      and reduce debt and foreign-exchange burdens over time.
    rationale: Aligning offsets with diversification/R&D reduces debt and FX burdens over time.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_009
    text: Policy constraints limit the formation of cross-national industrial alliances and restrict access to multinational
      work share models.
    rationale: Policy constraints limit cross-national alliances and work share models.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_010
    text: If Japan pursues domestic programs primarily for kokusanka and bargaining leverage, it may reduce its ability to
      buy into multinational workshare models and receive offset-like benefits.
    rationale: Domestic-first strategies can reduce access to multinational workshare benefits.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_012
    text: High offset percentages and preference for technology transfers/domestic production force foreign suppliers to provide
      industrial participation and technology inputs to compete.
    rationale: High offset requirements force suppliers to provide participation and tech inputs to compete.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_019
    text: Coordinated offset procedures and targeted technology inputs steer industrial cooperation toward selected sectors
      rather than comprehensive self-sufficiency.
    rationale: Coordinated procedures steer cooperation toward selected sectors, not full self-sufficiency.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_024
    text: Rigid domestic-first strategies can impede creative alliances and reduce the flow of imported technologies through
      globalized program structures.
    rationale: Rigid domestic-first strategies impede alliances and technology inflows.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_002
    text: Different national objectives shape offset selection (broad industrialization vs targeted technology transfer for
      maintenance/upgrade capability).
    rationale: National objectives shape offset selection between broad industrialization and targeted transfer.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_018
    text: By concentrating on areas with comparative strengths and avoiding sectors deemed non-viable, Singapore maintains
      limited but competitive capabilities while foregoing autarky.
    rationale: Strategic focus on viable sectors avoids autarky while maintaining competitiveness.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_002
    text: A fixed percentage obligation tied to imported content creates a predictable compliance target and shapes contractor
      planning toward eligible offset activities.
    rationale: Fixed percentage obligations create predictable targets guiding contractor planning.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_010
    text: Concentrating demand into long-term sectoral plans and working with fewer, larger primes enables outsourcing of
      lower-tier oversight and may stabilize workloads.
    rationale: Concentrating demand and fewer primes stabilize workloads and reduce oversight burdens.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_012
    text: Voluntary local participation offers, grounded in commercial practice and focused on niches, align procurement with
      what small local industries can competitively deliver.
    rationale: Voluntary local participation aligns with competitive niches and commercial practice.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_016
    text: A mandatory percentage obligation plus a minimum local value-added threshold shapes supplier choices toward genuinely
      local production/value-add rather than simple pass-through.
    rationale: Local value-added thresholds steer suppliers toward genuine local production.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_019
    text: Shifting industry involvement from in-country production toward through-life support focuses limited domestic capacity
      on sustainment functions most relevant to readiness for imported systems.
    rationale: Shifting focus to through-life support targets limited capacity toward readiness-relevant functions.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_020
    text: Partner status via an access fee and a competitiveness-based sourcing model excludes traditional offsets and limits
      participation to established, highly competitive firms, with reciprocal work emerging informally.
    rationale: Partner access fees and competitiveness sourcing limit participation to established firms.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_025
    text: When offsets are applied broadly across imports rather than targeted to specific capabilities, they become poorly
      focused; insisting on vague capability enhancement at no additional cost can undermine negotiations and deliver counterproductive
      results.
    rationale: Broad, vague offsets undermine negotiations and can be counterproductive.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_003
    text: Defence industrial participation policy is used to steer limited resources toward niche firms and strategic logistic
      support capabilities rather than comprehensive autarky.
    rationale: Policy steers resources toward niche firms and support capabilities, not autarky.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_008
    text: Using indirect offsets and investment commitments broadens the space for meeting obligations through non-defence
      projects, potentially diluting linkage to defence capability needs.
    rationale: Indirect offsets broaden compliance options and can dilute defence capability linkages.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_021
    text: Seeing peers achieve licensed assembly can raise expectations and highlight domestic opportunity costs when local
      participation is limited.
    rationale: Peer comparisons raise expectations and highlight opportunity costs of limited participation.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_024
    text: Converting equipment for specialty work can expand niche capacity while reducing capability for traditional bulk
      output, creating internal tradeoffs.
    rationale: Specialty conversions create internal capability tradeoffs.
  - id: 01_introduction_and_overview_pdf__cmo_004
    text: Once policymakers recognise indirect offsets impose real costs and weak performance, they demote indirect offsets
      to a fallback while shifting emphasis to direct local-content requirements.
    rationale: Poor indirect offset performance shifts emphasis to direct local-content requirements.
  - id: 01_introduction_and_overview_pdf__cmo_005
    text: Procurement choices prioritise industrial/economic benefits (including offsets/IRBs) over strictly military performance
      when security pressures are perceived as lower.
    rationale: Industrial/economic benefits prioritized over military performance when security pressure is low.
  - id: 01_introduction_and_overview_pdf__cmo_016
    text: Direct/indirect offsets are adopted as a cheaper alternative that still channels compensatory work to the domestic
      defence industrial base.
    rationale: Offsets used as cheaper alternative while still channeling compensatory work.
- theme_id: PM16
  theme_label: Offsets justified in high-hazard exchanges
  mechanism_explanation: Offsets can substitute for poorly functioning markets in high-hazard exchanges and yield reputational
    or capability gains; imposing offsets in low-hazard contexts or misaligned with seller capabilities creates opportunity
    costs and raises costs.
  mechanisms:
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_005
    text: Offsets are advisable only when exchange hazard is high and expected recipient benefits are high, because offsets
      can substitute for poorly functioning markets and unlock reputational/capability gains.
    rationale: Offsets substitute for poorly functioning markets when hazards and expected benefits are high.
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_012
    text: Imposing offsets in low-hazard categories forces content-based contracting where price-margin savings would be superior,
      creating opportunity costs.
    rationale: Imposing offsets in low-hazard categories creates opportunity costs versus price-margin savings.
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_014
    text: Direct offsets better safeguard hazardous exchanges by tying performance to the procured system, while indirect
      offsets are more applicable for wider development objectives but can raise costs if outside seller capabilities.
    rationale: Direct vs indirect offsets should match exchange hazards and seller capabilities to avoid cost inflation.
- theme_id: PM17
  theme_label: Administrative burden and rent-seeking
  mechanism_explanation: Offset regimes can generate administrative burdens and rent-seeking, including proposal overload,
    superficial evaluation criteria, and discretionary behaviour that raises costs without improving transfer outcomes.
  mechanisms:
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_006
    text: In this setting, offsets add administrative burden and rent-seeking costs without improving technology transfer
      or exchange integrity.
    rationale: Offsets add administrative burden and rent-seeking without improving transfer or exchange integrity.
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_011
    text: Variable offset policies increase discretion between price and content, attracting internal and external rent-seeking;
      strict mandatory triggers constrain discretion and can reduce rent-seeking.
    rationale: Discretion in variable policies attracts rent-seeking, while strict triggers constrain it.
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_013
    text: Broad mandates generate proposal overload and encourage superficial evaluation criteria (e.g., workload and jobs)
      rather than technology-transfer quality, while atomistic sellers add offset burdens that raise prices with little reputational
      effect.
    rationale: Broad mandates overload evaluation and encourage superficial criteria, raising costs with little reputational
      effect.
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_007
    text: Managing offset obligations imposes transaction costs that consume resources (personnel, legal/monitoring, travel/communications),
      estimated as a share of sale value.
    rationale: Managing offset obligations consumes resources through transaction and monitoring costs.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_012
    text: Divergent valuation methods generate negotiation friction and can derail procurement bids or complicate offset strategy
      agreements.
    rationale: Valuation disagreements create negotiation friction and derail or complicate deals.
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_008
    text: High management burdens and pressure to fulfill large obligations lead to labor-intensive monitoring and reliance
      on seemingly artificial projects.
    rationale: High management burdens drive intensive monitoring and artificial project selection.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_010
    text: Firms lobby for continued protections and contract steering, which entrenches overcapacity and delays managerial
      reforms.
    rationale: Lobbying sustains protections, entrenching inefficiencies and delaying reforms.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_014
    text: Regional quota politics require explicit partitioning of offset work, steering allocations to satisfy rent-seeking
      groups rather than industrial coherence.
    rationale: Regional quota politics steer work to satisfy rent-seeking rather than coherence.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_007
    text: Exemptions from disclosure and appeal requirements reduce oversight and make it easier to structure offsetting arrangements
      without full public scrutiny.
    rationale: Disclosure/appeal exemptions reduce oversight and increase scope for opaque arrangements.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_015
    text: Corruption scandals undermine political legitimacy and contract continuity, leading to abandonment of technology-transfer
      and offset components.
    rationale: Corruption scandals undermine legitimacy and derail offset/transfer components.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_015
    text: Raising offset requirements and leveraging diversified supplier competition pressures bidders to increase offset
      offerings, but incomplete information and corruption allegations can distort decisions.
    rationale: Incomplete information and corruption can distort offset decisions under competitive pressure.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_011
    text: When a local prime controls compliance and subcontracting access, it can use market power to extract rents and reinforce
      dominance rather than optimize national strategic outcomes.
    rationale: Local prime market power can extract rents and reinforce dominance.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_022
    text: Without agreed outcomes, outputs, or performance measures, monitoring data cannot be used to demonstrate whether
      policy is making progress toward its objectives.
    rationale: Lack of agreed outcomes/metrics weakens monitoring and evaluation.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_023
    text: Even when obligations are acquitted, acquittal categories dominated by local content and countertrade do not automatically
      translate into defence or economy-wide gains without targeted assessment.
    rationale: Acquittal categories do not guarantee gains without targeted assessment.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_006
    text: Dividing management between Armscor and DTI can increase coordination burdens and monitoring complexity across defence
      and non-defence project streams.
    rationale: Split management increases coordination burdens and monitoring complexity.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_018
    text: When offsets are used to “direct” investment toward selected sectors/regions, projects may be chosen for political
      fit rather than commercial viability, increasing failure risk.
    rationale: Political direction of investment can override commercial viability, raising failure risk.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_019
    text: Without reliable data and transparency, analysts cannot quantify net benefits or verify claims about jobs and investment
      delivery.
    rationale: Lack of data/transparency prevents verification of net benefits.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_021
    text: Secrecy and commission-driven bargaining create corruption vulnerabilities that trigger investigations and political
      instability, imposing governance costs.
    rationale: Secrecy and commission-driven bargaining create corruption vulnerabilities.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_022
    text: Formal investigations can clear some accusations while still identifying irregular practices and conflicts of interest,
      leading to personnel consequences.
    rationale: Investigations identify irregular practices and conflicts of interest.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_023
    text: When the executive treats earlier strategic-policy approval as equivalent to procurement approval, accountability
      and scrutiny of major purchases can be reduced.
    rationale: Treating strategic-policy approval as procurement approval reduces scrutiny.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_024
    text: When offset promises are uncertain and hard to verify, governments may be left with high costs and limited, unproven
      benefits, motivating calls to reorient development strategy.
    rationale: Unverifiable promises leave high costs and motivate reorientation calls.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_001
    text: When agencies lack coherent, time-consistent criteria for selecting and spatially allocating projects, offsets are
      less likely to reinforce integrated regional development.
    rationale: Lack of coherent criteria weakens integrated regional development reinforcement.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_002
    text: When comprehensive planning frameworks are not implemented, regional development policy defaults to narrower corridor/zone
      approaches that offsets are then asked to complement.
    rationale: Absence of comprehensive frameworks defaults policy to narrower approaches.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_004
    text: Joint administration across agencies requires sustained coordination and information sharing, affecting how projects
      are identified, credited, and monitored.
    rationale: Joint administration requires sustained coordination and information sharing.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_007
    text: Without rigorous evaluation, headline export/return estimates can overstate substantive value-added and downstream
      linkages.
    rationale: Without rigorous evaluation, headline estimates overstate value-added and linkages.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_013
    text: When there is insufficient pressure to target marginal locations, vendors default to more familiar or commercially
      convenient regions and sectors.
    rationale: Insufficient pressure allows vendor default to convenient regions/sectors.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_016
    text: When vendors choose projects that fit established sectoral strengths and infrastructures, offsets reinforce existing
      geographic and industrial patterns rather than diversify peripheral economies.
    rationale: Projects that fit existing strengths reinforce incumbent patterns.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_018
    text: Offsets deliverables create political and bureaucratic reasons to sustain and expand large regional projects even
      when commercial fundamentals weaken.
    rationale: Political/bureaucratic reasons sustain large projects despite weak fundamentals.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_023
    text: Without integration between offset offerings and downstream industrial strategies, potential beneficiation and job-creation
      synergies are missed.
    rationale: Lack of integration with industrial strategy misses beneficiation/job synergies.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_027
    text: When monitoring capacity is weak and hidden costs are excluded from assessments, officials overestimate net benefits;
      independent auditing can mitigate this.
    rationale: Weak monitoring and hidden costs lead to overestimated benefits; audits mitigate.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_028
    text: With vendor discretion and emphasis on capital-intensive core projects, offsets confirm rather than challenge existing
      patterns, and employment effects remain limited in peripheral regions.
    rationale: Vendor discretion and core-project focus reinforce existing patterns and limit peripheral jobs.
  - id: 01_introduction_and_overview_pdf__cmo_003
    text: Limited disclosure and strategic presentation of claims by interested parties reduces data availability and impedes
      independent assessment.
    rationale: Limited disclosure impedes independent assessment.
- theme_id: PM18
  theme_label: Objective ambiguity undermines evaluation
  mechanism_explanation: Mixed objectives and unclear incidence of benefits make it difficult to specify evaluation criteria
    and determine net beneficiaries of mandated offsets.
  mechanisms:
  - id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_002
    text: Mixed objectives and unclear incidence of benefits make it difficult to specify evaluation criteria and to identify
      who gains net benefits from mandated offsets.
    rationale: Mixed objectives obscure evaluation criteria and who gains net benefits.
- theme_id: PM19
  theme_label: Supplier coaching and reputational certification
  mechanism_explanation: Suppliers teach efficient routines to control costs and quality, and successful completion provides
    reputational certification that lowers domestic firms’ market-entry transaction costs.
  mechanisms:
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_007
    text: To minimize its own costs and ensure quality, the seller has incentives to teach efficient routines; successful
      completion also provides a reputational “stamp of approval” that lowers the domestic firm’s market-entry transaction
      costs.
    rationale: Supplier coaching and reputational stamps reduce transaction costs for domestic firms.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_016
    text: Licensed production enables cumulative learning and adaptation, allowing host countries to introduce upgrades and
      improved variants.
    rationale: Licensed production enables cumulative learning and adaptation.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_004
    text: Joint ventures between foreign firms and local companies transmit technology, capital, and know-how through sustained
      interaction and personnel exchange.
    rationale: Joint ventures transmit technology and know-how through sustained interaction.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_009
    text: Conditioning imports on technology transfer creates repeated user/supplier interactions and training that accelerates
      domestic learning-by-doing.
    rationale: Repeated interactions and training accelerate learning-by-doing.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_010
    text: Codifying offsets with explicit technology and quality objectives aligns procurement negotiations around modernization
      of production methods and acquisition of new technologies.
    rationale: Explicit technology objectives align negotiations around modernization and capability acquisition.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_013
    text: On-site foreign specialists and overseas training transfer tacit production knowledge and engineering skills to
      domestic staff.
    rationale: On-site specialists and overseas training transfer tacit skills.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_014
    text: Component production for imported platforms and associated technical training embed supplier standards and engineering
      practices in domestic firms.
    rationale: Component production and training embed supplier standards and practices.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_004
    text: Even when early licensed production is inefficient, sustained production and learning-by-doing can build a technical
      base that improves later absorption of more advanced technologies.
    rationale: Learning-by-doing in licensed production builds technical base over time.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_005
    text: Licensed production and incremental technology transfer build production competence for mid-level systems and components,
      but do not automatically close frontier technology gaps.
    rationale: Incremental transfer builds mid-level competence but not frontier gaps.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_005
    text: Starting from “the end of a process” (final assembly) and working backward to component manufacturing enables learning-by-doing
      and gradual deepening of domestic production content.
    rationale: Starting with final assembly enables learning-by-doing and gradual deepening.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_006
    text: Licensed production and subcontracting allow workforce skill accumulation and gradual expansion of indigenous manufacturing
      responsibilities.
    rationale: Licensed production/subcontracting accumulates skills and responsibilities over time.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_007
    text: A joint venture co-development program transfers design and production know-how while creating an exportable product
      with shared workshare.
    rationale: Joint venture co-development transfers know-how and creates exportable products.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_016
    text: Licensed production in chosen domains provides experience that can be leveraged into indigenous design and subsequent
      domestic production.
    rationale: Licensed production experience supports later indigenous design/production.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_009
    text: Subcontracting and licensed production provide orders and learning-by-doing pathways that can help domestic firms
      build niche capabilities and credibility.
    rationale: Subcontracting and licensed production enable learning-by-doing and niche capability building.
  - id: 01_introduction_and_overview_pdf__cmo_014
    text: Equity participation aligns incentives by tying foreign partners to the domestic firm’s profitability, increasing
      willingness to share technological and marketing skills beyond a one-off obligation.
    rationale: Equity participation aligns incentives and encourages deeper skill sharing.
- theme_id: PM20
  theme_label: Alliance incentives via offset waivers
  mechanism_explanation: Governments use bargaining power or offset waivers to encourage alliances, boosting investment and
    reputational capital while preserving competitive selection.
  mechanisms:
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_008
    text: Government uses bargaining power to encourage alliances without mandating offsets (e.g., best-endeavors), preserving
      market competition while enabling collaboration.
    rationale: Uses bargaining power to encourage alliances without mandatory offsets.
  - id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_009
    text: By waiving offset requirements for foreign firms that enter strategic alliances, the program increases long-term
      investment and channels reputational capital to domestic firms while maintaining competitive selection.
    rationale: Offset waivers for alliances incentivize investment and reputational capital while maintaining competition.
- theme_id: PM21
  theme_label: Market access conditioned on reciprocity
  mechanism_explanation: Requiring reciprocal activity as a condition of market access imposes trade-restricting requirements
    on exporters.
  mechanisms:
  - id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_001
    text: By mandating reciprocal activity (countertrade, local content, or bundled enhancements) as a condition of market
      access, the importing state imposes trade-restricting requirements on exporters.
    rationale: Conditions market access on reciprocal activity, restricting trade.
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_001
    text: Exemption from liberal trade rules allows states to restrict transfers and to condition sales on reciprocal arrangements,
      producing illiberal contracting practices.
    rationale: Exemptions allow sales to be conditioned on reciprocity, restricting trade access.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_003
    text: By requiring compensatory transactions (local production, countertrade, bundling), the state conditions access to
      procurement contracts on delivering industrial work and technology-related benefits.
    rationale: Procurement access is conditioned on compensatory industrial work and technology benefits.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_012
    text: A cross-service 100% offset rule increases bargaining leverage by making full compensation a standard condition
      of market access for major deals.
    rationale: 100% offset rule increases bargaining leverage by standardizing full compensation.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_020
    text: If a supplier is unwilling to transfer advanced technology (e.g., software source code), it cannot meet the buyer’s
      autonomy-focused offset conditions.
    rationale: Market access conditioned on advanced-tech transfer; refusal blocks access.
  - id: 01_introduction_and_overview_pdf__cmo_001
    text: To reconcile cheaper imports with domestic economic expectations, purchasers impose offset obligations that compel
      foreign vendors (and subcontractors) to place additional purchases/investment in the buyer’s economy.
    rationale: Offset obligations compel vendors to place additional purchases/investment domestically.
- theme_id: PM22
  theme_label: Offsets reveal local supplier capability
  mechanism_explanation: Local content requirements compel primes to search for and engage domestic suppliers, reducing information
    imperfections about local capability.
  mechanisms:
  - id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_009
    text: Local content requirements force primes to search and engage domestic suppliers, addressing an information imperfection
      about local capability.
    rationale: Forces supplier search, addressing information gaps about local capability.
- theme_id: PM23
  theme_label: Sourcing persists only when viable
  mechanism_explanation: Offset-induced sourcing ends when obligations expire unless continued local production is economically
    worthwhile, so effects may be temporary.
  mechanisms:
  - id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_010
    text: Once the mandated transaction ends, primes discontinue domestic sourcing unless continued work in the host economy
      makes local supply chain relocation worthwhile.
    rationale: Sourcing continues only if relocation and ongoing work are economically attractive.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_009
    text: Once the foreign supplier fulfills its obligations, subcontracting benefits end, preventing accumulation of sustained
      industrial collaboration.
    rationale: Subcontracting benefits end after obligations, preventing sustained collaboration.
- theme_id: PM24
  theme_label: Indirect offsets stimulate targeted exports
  mechanism_explanation: Indirect offsets that require exporter purchases act like sector-specific price adjustments, stimulating
    exports in targeted sectors.
  mechanisms:
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_001
    text: By requiring the exporter to purchase goods from the importing country as an indirect offset, the deal functions
      like a sector-specific price adjustment that stimulates exports in the chosen sector.
    rationale: Exporter purchase requirements function as targeted export stimuli.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_002
    text: Indirect compensations redirect purchase-linked activity into non-military sectors, which is expected to stimulate
      broader domestic economic activity.
    rationale: Indirect compensations redirect activity into non-military sectors to stimulate broader economy.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_018
    text: Offset obligations can compel sellers to accept unrelated technology projects and to purchase commodities from the
      buyer as part of the deal.
    rationale: Offsets can compel unrelated technology projects or commodity purchases as compensations.
- theme_id: PM25
  theme_label: Opacity enables price discrimination
  mechanism_explanation: Lower visibility of offset-related pricing permits price discrimination or dumping in world markets
    that would be harder under transparent pricing.
  mechanisms:
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_003
    text: Lower visibility enables difficult-to-detect price discrimination and dumping of product in world markets.
    rationale: Low visibility enables difficult-to-detect price discrimination and dumping.
- theme_id: PM26
  theme_label: Buyback hostage aligns incentives
  mechanism_explanation: Buyback obligations make sellers responsible for absorbing output, aligning incentives to avoid transferring
    obsolete technology that would undermine buyback viability.
  mechanisms:
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_004
    text: Buyback requirements hold the seller “hostage” by making it responsible for buying back output, aligning incentives
      so the seller avoids transferring outdated technology that would undermine buyback viability.
    rationale: Buyback requirements align incentives to avoid obsolete tech transfer.
- theme_id: PM27
  theme_label: Depreciation drives tech licensing
  mechanism_explanation: As technologies depreciate, sellers are incentivized to license them via offsets to monetise value
    before it declines further.
  mechanisms:
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_005
    text: Depreciation creates an incentive for arms sellers to license technology via offsets to monetize it while it is
      still valuable.
    rationale: Depreciation encourages licensing to capture remaining value.
- theme_id: PM28
  theme_label: Exporter networks reduce market entry costs
  mechanism_explanation: Large exporters’ established distribution networks lower market-penetration costs for buyer-country
    products compared to what domestic firms could achieve alone.
  mechanisms:
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_006
    text: Large exporting firms with established networks can market buyer-country products more cheaply than the buyer can,
      reducing market penetration costs.
    rationale: Exporter networks market buyer products more cheaply, reducing entry costs.
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_015
    text: Offset transactions reduce foreign firms’ costs and/or raise quality and market-competitiveness, while technology
      transfer back to the US is rare.
    rationale: Offsets reduce foreign firms’ costs/improve quality, affecting competitiveness via networks/know-how.
- theme_id: PM29
  theme_label: Bundled contracting reduces transaction costs
  mechanism_explanation: Offsets can be embedded in complex bundles that lower transaction costs and reallocate rents under
    market imperfections.
  mechanisms:
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_007
    text: Offsets can function as part of complex bundled contracting that reduces transaction costs and reallocates rents
      under these imperfections.
    rationale: Bundling offsets reduces transaction costs and reallocates rents.
- theme_id: PM30
  theme_label: Second-best offsets distort allocation
  mechanism_explanation: Using offsets as substitutes for broader macro or trade reforms distorts resource allocation and
    locks in inefficient sector-specific fixes.
  mechanisms:
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_008
    text: Using offsets as a second-best substitute for appropriate macro/trade reforms distorts resource allocation and embeds
      inefficient sector-specific fixes in procurement.
    rationale: Offsets act as second-best fixes that embed distortions.
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_014
    text: By encouraging bilateralism and reallocating investment/purchases across countries, mandatory offsets impose externalities
      on third parties and conflict with free-trade norms.
    rationale: Mandatory offsets distort investment and trade, imposing externalities on third parties.
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_014
    text: By introducing offset-linked competition and support for foreign firms’ cost/quality improvements, indirect offsets
      impose “hidden injuries” on non-defense sectors that may not know why competition intensified.
    rationale: Offsets act as second-best interventions that distort competition across sectors.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_016
    text: By subsidizing uncompetitive enterprises and steering work non-competitively, offsets inhibit or distort European
      defense-industrial restructuring.
    rationale: Offsets subsidize uncompetitive firms and distort restructuring toward inefficiency.
  - id: 01_introduction_and_overview_pdf__cmo_006
    text: Offset obligations steer work to politically prioritised regions and firms, sustaining inefficient producers and
      discouraging rationalisation by masking underlying industrial weaknesses.
    rationale: Politically steered offsets sustain inefficient producers and mask weaknesses.
- theme_id: PM31
  theme_label: Labour rents drive opposition to offsets
  mechanism_explanation: Anticipated losses of employment and labour-market rents motivate unions to oppose offsets and seek
    regulation that limits production shifting.
  mechanisms:
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_010
    text: Anticipated loss of labor-market rents and employment prompts unions to oppose offsets and to seek regulation that
      limits competitive arms exports involving production shifting.
    rationale: Union opposition reflects expected job and rent losses from production shifting.
- theme_id: PM32
  theme_label: Offset competition redistributes rents
  mechanism_explanation: Offset-induced competition shifts surplus between domestic firms and buyers, creating distributive
    conflict even when aggregate national net effects are small.
  mechanisms:
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_011
    text: Offset-induced competition reallocates profits between domestic firms and buyers, creating distributive conflict
      even when aggregate national net effects are small.
    rationale: Offset competition reallocates profits between firms and buyers, generating distributive conflict.
- theme_id: PM33
  theme_label: Export subsidies offset scale gains
  mechanism_explanation: When exports are subsidized, taxpayers finance production, offsetting or reversing unit-cost savings
    from scale economies.
  mechanisms:
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_012
    text: When exports are subsidized, taxpayers finance part of the export production, offsetting (or reversing) any unit-cost
      savings from scale.
    rationale: Subsidy financing by taxpayers erodes or reverses scale-based unit cost savings.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_017
    text: Where domestic production requires subsidies to match incumbent supplier costs, job creation is achieved at high
      public cost and may not be efficient.
    rationale: Subsidy-dependent production creates jobs at high public cost.
- theme_id: PM34
  theme_label: Capability gains not self-sustaining
  mechanism_explanation: Technology transfer and buyback can yield temporary gains, but exporters continue advancing and recipients
    without sustained momentum fall behind again.
  mechanisms:
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_015
    text: Technology transfer and training offsets do not create this capital in a self-sustaining way, and exporters continue
      to advance technologically, leaving recipients behind.
    rationale: Transferred capabilities are not self-sustaining as exporters advance faster.
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_018
    text: Even with buyback, exporters can profit from outdated technology combined with low-cost labor; after the offset
      agreement ends, recipients without sustained capability momentum fall behind again.
    rationale: Outdated tech and temporary arrangements leave recipients behind once agreements end.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_010
    text: When offset programs focus on immediate assembly/work placement without embedding longer-term capability development,
      benefits decay after project completion.
    rationale: Short-term assembly without capability embedding leads to benefit decay post-project.
  - id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_003
    text: When development is complete, offsets offer few opportunities for acquiring new technology, limiting technology-transfer
      potential.
    rationale: Offsets offer few new technology opportunities once development is complete.
  - id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_005
    text: Reliance on offset-dependent work reduces design and systems-integration experience compared with independent national
      programs or substantive collaboration.
    rationale: Offset-dependent work can erode design and integration capability over time.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_008
    text: Unpredictable timing disrupts planning for replacement and upgrade investment flows and repeatedly forces organizations
      to restart learning and marketing efforts.
    rationale: Unpredictable timing forces repeated restarts of learning and marketing efforts.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_020
    text: When domestic orders are small and volatile and export markets are limited, offset-driven investments struggle to
      maintain production runs and skills over time.
    rationale: Small domestic orders and limited exports undermine sustaining production runs and skills.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_005
    text: Because domestic demand is insufficient to sustain large production runs, firms rely on exports to keep lines viable
      and recoup investments made to absorb foreign technology.
    rationale: Insufficient domestic demand forces reliance on exports to sustain production runs.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_006
    text: Loss of key customers and reduced attractiveness of less sophisticated systems depress demand, cutting cashflow
      that sustained firms and the learning/production base.
    rationale: Loss of customers reduces demand and erodes the learning/production base.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_007
    text: When external political and security alignments shift, prospective buyers may abandon planned purchases, leaving
      sunk development costs unrecovered.
    rationale: Shifts in alignments lead to cancelled purchases and unrecovered sunk costs.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_008
    text: When military demand and state support decline, firms with a viable civil product line can pivot resources and revenues
      to preserve industrial and human-capital capability.
    rationale: Firms pivot to civil lines to preserve capability when military demand falls.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_016
    text: Collaborative design and production transfer advanced competencies, but without export demand, unit costs rise and
      commercial viability suffers.
    rationale: Advanced competencies transferred, but without export demand unit costs rise and viability suffers.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_021
    text: When domestic orders are very small, fixed costs of local assembly cannot be spread, making local production economically
      unviable unless export orders materialize.
    rationale: Small orders make local assembly economically unviable without exports.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_022
    text: When licensing focuses on assembly of imported kits and local engineering investment is limited, technology absorption
      stalls even if the enterprise remains commercially active.
    rationale: Assembly-focused licensing without local engineering stalls absorption.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_023
    text: Collaboration and personnel exchange can build indigenous capability, but project complexity and lack of export
      orders drive cost inflation and delays.
    rationale: Complex collaboration without exports drives cost inflation and delays.
  - id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_001
    text: As weapon unit costs grow faster than fiscal capacity, procurement quantities shrink, reducing production runs and
      undermining the scale economies needed for domestic defense production.
    rationale: Rising unit costs and shrinking quantities undermine scale economies.
  - id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_002
    text: The need to match modern adversary capabilities pushes buyers toward expensive modern systems, while small-scale
      domestic production cannot compete on cost, forcing reliance on imports or niche/obsolete production.
    rationale: Small-scale domestic production cannot compete on cost, forcing imports or niche output.
  - id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_003
    text: When fiscal space tightens, subsidies and sustained demand fall, preventing “infant” defense industries from maturing
      into commercially viable enterprises.
    rationale: Tight fiscal space reduces subsidies and demand, stalling infant industry maturation.
  - id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_007
    text: Limited spare-parts guarantees reduce confidence in long-term supportability for potential external customers.
    rationale: Limited spares guarantees reduce confidence in supportability, undermining export credibility.
  - id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_008
    text: Loss of specialized human capital reduces production quality, R&D capability, and credibility with prospective export
      customers.
    rationale: Loss of human capital degrades production quality and export credibility.
  - id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_009
    text: Without large orders, average unit costs remain high; exports are required to reach break-even quantities, but market
      and credibility constraints impede exports.
    rationale: Without large orders, costs remain high; export constraints prevent reaching scale.
  - id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_010
    text: Very small fleet size raises unit costs and creates uncertainty about long-term spare parts supply, discouraging
      buyers and undermining sustainment economics.
    rationale: Small fleet sizes raise unit costs and undermine sustainment economics, discouraging buyers.
  - id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_011
    text: Without regional coordination, Argentina cannot pool demand or harmonize support arrangements needed to achieve
      economies of scale.
    rationale: Lack of regional coordination prevents pooled demand and scale economies.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_003
    text: Reliance on imported components and difficulties in absorbing licensed technology generate delays and cost overruns,
      and can raise foreign-exchange spending above off-the-shelf import costs.
    rationale: Absorption difficulties raise costs and delays, increasing FX burdens beyond imports.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_007
    text: When domestic producers cannot meet cost/lead-time expectations, buyback obligations are unattractive to sellers
      and fail to generate sustained export-linked production.
    rationale: Uncompetitive domestic production makes buyback obligations unattractive, limiting sustained exports.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_009
    text: Easy access to relatively inexpensive imported systems reduces incentives to invest in indigenous R&D and to accept
      the risks and costs of domestic development.
    rationale: Easy imports reduce incentives for indigenous R&D and domestic development.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_013
    text: Growing domestic defense industry activity increases demand for imported materials and inputs, raising foreign exchange
      requirements even when some offsets reduce direct-import FX needs.
    rationale: Domestic industry expansion raises imported input demand, increasing FX requirements.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_014
    text: Easy credit availability encourages approval of larger procurement volumes, which can create persistent debt-service
      and resource-diversion burdens over time.
    rationale: Easy credit encourages larger buys and creates debt-service burdens.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_008
    text: Reduced demand and fewer technology inflows lower capacity utilization and make self-sufficiency unattainable, turning
      domestic industry into a cost burden.
    rationale: Reduced demand and inflows lower utilization and make self-sufficiency costly.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_016
    text: When production is concentrated and capacity is underutilized, technology transfers diffuse poorly, multiplier effects
      are minimized, and dependence on foreign spares/maintenance persists.
    rationale: Underutilization limits diffusion and leaves dependence on foreign spares.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_022
    text: Limited program-management capacity and weak diffusion pathways reduce multiplier effects of offsets and limit broad-based
      industrial gains.
    rationale: Weak diffusion and program management limit multiplier effects and broad gains.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_009
    text: Guaranteed demand and subsidized investment expand production scale and workforce even when products do not match
      user needs.
    rationale: Subsidized demand expands scale even without user-need alignment.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_010
    text: When subsidies shield firms from market discipline, excess capacity and overstaffing persist and accumulate debt,
      reducing commercial viability.
    rationale: Subsidies reduce discipline, leading to excess capacity, debt, and weak viability.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_011
    text: Failure to obtain FAA certification blocks overseas marketing and export orders, cutting revenue needed to sustain
      production and development.
    rationale: Lack of certification blocks exports, cutting revenue for sustaining production.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_012
    text: External conditionality cuts off subsidies, forcing restructuring, layoffs, and suspension of ambitious indigenous
      programs reliant on continued funding.
    rationale: External conditionality cuts subsidies and forces restructuring of ambitious programs.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_017
    text: For certain complex platforms, Singapore continues to rely on licensed production rather than indigenous design,
      reflecting scale and competitiveness constraints.
    rationale: Scale and competitiveness constraints keep reliance on licensed production.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_008
    text: Competitive tendering under thin and uneven demand can create excess capacity and high transaction costs, undermining
      suppliers’ ability to invest for long-term capability.
    rationale: Thin demand and competitive tendering create excess capacity and high transaction costs.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_002
    text: In a policy vacuum, firms reduce dependence on defence turnover by shifting to non-defence work and exports as a
      survival strategy.
    rationale: Firms shift to non-defense work/exports to reduce dependence in a policy vacuum.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_013
    text: Capability erosion reduces suppliers’ ability to meet quality and schedule requirements, making primes less confident
      integrating local inputs.
    rationale: Capability erosion reduces ability to meet quality and schedule requirements.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_014
    text: When domestic firms perform work without sufficient capability, quality problems can emerge and delay platform delivery
      schedules.
    rationale: Insufficient capability leads to quality problems and delivery delays.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_008
    text: Weak linkages and limited technology diffusion mean offsets provide limited “injection” to regional development,
      with benefits mostly as spin-offs.
    rationale: Weak linkages and diffusion limit regional development impacts.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_009
    text: DIP-linked orders can act as a lifeline for defence firms, while broader procurement and supply-chain dynamics can
      still constrain independent defence-industrial ambitions.
    rationale: DIP-linked orders provide lifeline but broader dynamics constrain autonomy.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_010
    text: Channeling DIP business to existing defence-firm locations concentrates benefits where capacity already exists and
      leaves peripheral regions with little to no benefit.
    rationale: Channeling business to existing locations concentrates benefits and bypasses periphery.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_020
    text: When offsets are not directed into shipbuilding proper, local shipbuilding capability and accumulated expertise
      can erode, despite related activity in repair.
    rationale: Lack of shipbuilding-directed offsets erodes local capability despite repair work.
- theme_id: PM35
  theme_label: Offsets displace rather than add trade
  mechanism_explanation: Offset-related export arrangements can reallocate sales and foreign exchange rather than create new
    demand, leaving net gains unchanged and diverting purchases from other suppliers.
  mechanisms:
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_016
    text: When exports are shipped for the exporter to sell as part of an offset, the importing country foregoes the foreign
      exchange it would have earned from selling those exports itself, leaving the net foreign-exchange position unchanged.
    rationale: Exporter-sold offsets leave the importer’s net foreign exchange position unchanged.
  - id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_017
    text: Because world demand is not increased by offset obligations, purchases are diverted from other suppliers/countries,
      and military spending can reduce overall demand.
    rationale: Offset purchases divert demand across suppliers without increasing total demand.
- theme_id: PM36
  theme_label: Illiberal contracting builds cross-border ties
  mechanism_explanation: Illiberal procurement practices create cross-national production and state–firm ties that extend
    beyond price/quality competition, including enduring supplier relationships.
  mechanisms:
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_002
    text: Illiberal contracting latitude (refusals, buy_domestic, and offsets) creates state-to-state and firm-to-state ties
      that extend beyond normal price/quality competition.
    rationale: Illiberal contracting latitude creates ties beyond standard price/quality competition.
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_003
    text: Greater buyer leverage increases demands for offsets (components, technology transfer, marketing/investment), intensifying
      cross-national linkages in procurement.
    rationale: Buyer leverage increases offset demands and intensifies cross-national linkages.
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_004
    text: Offsets create “diagonalized” exchanges by requiring primes to subcontract, market unrelated goods, and transfer
      technology across borders and sectors.
    rationale: Offsets require cross-border subcontracting and marketing across sectors.
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_011
    text: By shifting component production overseas, primes export parts of their own capability and create enduring supplier
      relationships for buyer firms.
    rationale: Offshoring components creates enduring supplier relationships for buyer firms.
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_012
    text: Once buyer-country firms secure component roles via coproduction/subcontracting, they can supply not only the original
      prime but also other manufacturers, competing with domestic suppliers.
    rationale: Offset-enabled component roles create cross-border supplier ties and market entry beyond the initial prime.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_002
    text: Buyer leverage in a buyer’s market enables purchasing states to extract concessions (offsets/industrial participation)
      from offshore vendors.
    rationale: Buyer leverage extracts concessions and intensifies cross-national industrial linkages.
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_007
    text: Offsets link procurement to licensing/collaboration and technology transfer pathways aligned with each country’s
      strategic-industrial objectives.
    rationale: Offsets link procurement to collaboration and transfer pathways aligned with strategic objectives.
  - id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_009
    text: By tying offsets to export expectations and participation in production for non-domestic customers, domestic firms
      gain access to international supply chains and markets.
    rationale: Offsets tied to export participation integrate firms into international supply chains.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_015
    text: Replacing offsets with participation in structural international industrial cooperation shifts incentives toward
      long-term centers of excellence and niche specialization.
    rationale: Replacing offsets with structural cooperation shifts incentives toward long-term specialization.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_018
    text: Offsets provide short-run contract work but reduce incentives and pathways for sustained international industrial
      cooperation, increasing vulnerability to external restructuring.
    rationale: Offsets short-run work reduces incentives for sustained international cooperation, increasing vulnerability.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_002
    text: Interoperability requirements drive import of Western systems and motivate use of offsets to link acquisitions to
      domestic supply-chain transformation.
    rationale: Interoperability-driven imports motivate offsets to link acquisitions to supply-chain transformation.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_008
    text: Requirements for local partners or licensed importers push suppliers to establish or use domestic intermediaries
      and industrial ties in-country.
    rationale: Local partner requirements create domestic intermediaries and industrial ties.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_011
    text: By channeling projects and orders to domestic recipients (and tying them to technology transfer/training), offsets
      are expected to build competencies and integrate firms into allied division of labor.
    rationale: Offsets channel projects to build competencies and integrate firms into allied division of labor.
  - id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_004
    text: Selling or conceding defense-industrial assets provides short-term fiscal relief and shifts operational responsibilities
      to private actors.
    rationale: Asset concessions shift operational responsibilities to private actors.
  - id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_005
    text: A concession contract provides revenue and work packages to sustain a domestic maintenance/upgrade facility even
      when new indigenous production is not viable.
    rationale: Concession contracts sustain maintenance facilities when new production is not viable.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_008
    text: Growing indigenous capacity improves the buyer’s bargaining leverage in new negotiations, enabling demands for more
      advanced transfers.
    rationale: Growing indigenous capacity increases bargaining leverage for advanced transfers.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_003
    text: Multinational programs seek allied “buy in” at design and development stages, replacing post-production offsets
      with pre-production work share and technology transfer agreements.
    rationale: Allied buy-in shifts to pre-production work share and transfer agreements.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_004
    text: International partnering, joint development, and risk sharing integrate allies into programs and standards earlier,
      creating interoperability without relying on post-sale compensation.
    rationale: Joint development integrates allies early, creating interoperability without post-sale offsets.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_011
    text: US calls for greater self-reliance and loosened export restrictions increase access to technology transfers and
      work share agreements that build domestic capability.
    rationale: Export restrictions and self-reliance shifts increase access to transfer and workshare.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_017
    text: Consolidation and joint ventures increase efficiency and provide access to foreign capital, technology inputs, and
      global market reach.
    rationale: Consolidation/JVs increase efficiency and access to capital, technology, markets.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_023
    text: As long as these drivers remain, contracts continue to incorporate technology transfers and work share features,
      whether as traditional offsets or pre-production sharing.
    rationale: Drivers sustain inclusion of transfer/workshare features in contracts.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_019
    text: Commercial subcontracting and global MRO activities diversify revenue sources, stabilizing the defense-industrial
      base beyond offsets or captive domestic demand.
    rationale: Commercial subcontracting and global MRO diversify revenues beyond captive demand.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_020
    text: Co-development alliances, joint ventures, and overseas acquisitions keep domestic industry open to foreign technology
      and capital and allow specialization in global supply chains.
    rationale: Co-development/JVs/overseas acquisitions keep industry open to foreign tech and supply chains.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_006
    text: Requiring demonstrated independence through exports pressures foreign-owned subsidiaries to develop export activity
      as evidence of substantive local commitment.
    rationale: Export requirements pressure subsidiaries to demonstrate local commitment.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_007
    text: Requiring tenderers to identify local capability and submit AII plans that foster partnerships encourages structured
      prime–subcontractor relationships and visible opportunity creation.
    rationale: AII plans encourage structured prime–subcontractor partnerships.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_013
    text: Encouraging suppliers to build commercial relationships with local firms creates pathways for sustained support
      and potential cost reductions over the equipment life cycle.
    rationale: Commercial relationships create pathways for sustained support and lifecycle cost reductions.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_018
    text: Treating Australian and New Zealand industry as a combined industrial base and subcontracting local content on a
      best-endeavors basis enables cross-border work allocation within a trusted partner group.
    rationale: Treating AU/NZ as a combined base enables cross-border work allocation.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_021
    text: Interoperability requirements narrow acceptable sourcing options toward US systems and programs, reinforcing a procurement
      path dependence toward US-led industrial participation models.
    rationale: Interoperability requirements reinforce path dependence toward US-led programs.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_011
    text: Equity purchases and joint ventures integrate local firms into multinational networks without necessarily expanding
      domestic production capacity via new plant investment.
    rationale: Equity/JVs integrate firms into multinational networks without new plant expansion.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_012
    text: Local subsidiaries can leverage domestic relationships to influence government-to-government dealings in ways that
      benefit both parent firms and local units.
    rationale: Local subsidiaries leverage relationships to influence government dealings.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_015
    text: Existing technical capacity attracts joint ventures and technology transfer, enabling local firms to integrate into
      multinational supply chains and potentially expand exports.
    rationale: Existing capacity attracts JVs and transfers, integrating firms into supply chains.
  - id: 01_introduction_and_overview_pdf__cmo_002
    text: Because vendors cannot readily meet offset obligations through local purchasing, offset packages pivot toward inward
      investment and joint-venture style commitments to satisfy obligations and inject capability.
    rationale: Inward investment and JV commitments used when local purchasing is infeasible.
  - id: 01_introduction_and_overview_pdf__cmo_008
    text: Offset policy is oriented toward international joint ventures (with equity/capital and facilitation by offset-obligated
      firms) in non-defence sectors where market demand and growth prospects are stronger.
    rationale: Offsets steer JV equity/capital into non-defence sectors with stronger market demand.
  - id: 01_introduction_and_overview_pdf__cmo_010
    text: Technology transfer is tolerated because exporters gain royalties, strengthen allies against threats, and avoid
      losing sales to competitor suppliers if licences are denied.
    rationale: Exporters tolerate transfer for royalties, alliance gains, and competitive sales pressure.
  - id: 01_introduction_and_overview_pdf__cmo_013
    text: Moving to joint development/production defines industrial tasks earlier and reduces the need to administer offset
      applications, making participation more predictable for domestic industry.
    rationale: Joint development defines tasks earlier and reduces offset administration burden.
- theme_id: PM37
  theme_label: Buyer pool expansion loosens controls
  mechanism_explanation: When exports and offsets expand the buyer pool, services shift from restraint to facilitation, adopting
    more permissive stances on offsets.
  mechanisms:
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_005
    text: When exports (and offsets) help increase the buyer pool, services shift from proliferation restraint toward making
      sales work for customers, adopting a more permissive stance on offsets.
    rationale: Expanding buyers shifts services toward permissive, sales-enabling practices.
- theme_id: PM38
  theme_label: Firms build offset-management capacity
  mechanism_explanation: As offset requirements expand, firms develop specialized offset organizations and negotiate longer,
    more complex contracts to manage obligations.
  mechanisms:
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_006
    text: Firms build in-house offset organizations that operate like trading companies (marketing offset products, arranging
      subcontracting, technology search/transfer, credit sourcing, and offset-credit trading).
    rationale: Firms create in-house offset organizations to manage trading and crediting tasks.
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_009
    text: As more countries adopt offsets and escalate requirements (toward 100%+), firms adapt by expanding offset operations
      and negotiating longer, more complex contracts.
    rationale: Escalating requirements drive expansion of offset operations and longer contracts.
- theme_id: PM39
  theme_label: Hidden injuries from offset competition
  mechanism_explanation: Offset-linked competition and support for foreign firms’ cost/quality improvements can impose unseen
    harms on non-defence sectors that may not recognize the source of intensified competition.
  mechanisms:
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_014
    text: By introducing offset-linked competition and support for foreign firms’ cost/quality improvements, indirect offsets
      impose “hidden injuries” on non-defense sectors that may not know why competition intensified.
    rationale: Offset-linked competition creates hidden harms in non-defence sectors.
  - id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_004
    text: Offset promises provide a tool to justify imports by claiming protection of jobs and technology, even when costs/efficiency
      losses exist.
    rationale: Offset promises justify imports by claiming job/technology protection despite inefficiencies.
- theme_id: PM40
  theme_label: Offsets accelerate next-generation development
  mechanism_explanation: Interoperability demands and technology sharing can be used to justify accelerating next-generation
    development to maintain an edge.
  mechanisms:
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_017
    text: Interoperability demands and offset-driven technology sharing can be used to justify accelerating next-generation
      development to maintain an edge.
    rationale: Technology sharing pressures justify accelerated next-generation development.
- theme_id: PM41
  theme_label: Economic priorities override security restraint
  mechanism_explanation: Economic imperatives can dominate foreign-policy concerns, shifting lead roles toward economic agencies
    and weakening arms-control functions.
  mechanisms:
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_018
    text: Economic imperatives gain ascendancy over foreign-policy/security concerns, shifting lead roles toward defense/economic
      agencies and weakening arms-control functions.
    rationale: Economic imperatives shift authority away from arms-control toward economic agencies.
- theme_id: PM42
  theme_label: Offsets increase defence budget appeal
  mechanism_explanation: Linking military imports to offsets that build non-defence capabilities makes military spending more
    attractive in budget competition, potentially increasing total weapons purchases.
  mechanisms:
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_019
    text: By linking military imports to offsets that build non-defense capabilities, governments make military spending more
      attractive in budget competition and may increase total weapons purchases.
    rationale: Offsets tied to non-defence capabilities raise budget attractiveness for military spending.
- theme_id: PM43
  theme_label: Opacity weakens cost discipline
  mechanism_explanation: Offset-driven procurement reduces incentives to minimize costs, and price opacity makes it difficult
    to judge whether paid prices are reasonable.
  mechanisms:
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_020
    text: Offset-driven procurement reduces incentives to minimize purchase costs (e.g., off-the-shelf), while price opacity
      makes it hard to judge whether paid prices are reasonable.
    rationale: Offsets and price opacity reduce cost-minimizing incentives and visibility.
- theme_id: PM44
  theme_label: Offsets preserve market power
  mechanism_explanation: Prime contractors benefit from offsets and exclusion from free-trade rules because offsets expand
    markets and preserve pricing power, even while firms compete on individual deals.
  mechanisms:
  - id: 05_arms_trade_as_illiberal_trade_pdf__cmo_021
    text: Prime contractors have shared incentives to maintain offset practices and exclusion from free-trade regimes because
      offsets expand markets and preserve pricing power, even while firms compete on deals.
    rationale: Offsets expand markets and preserve pricing power, sustaining firm incentives to maintain the regime.
- theme_id: PM45
  theme_label: Security urgency overrides offset aims
  mechanism_explanation: When security urgency or treaty quid-pro-quo dominates decisions, governments de-emphasize offsets
    and select off-the-shelf purchases.
  mechanisms:
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_003
    text: When security urgency or treaty quid-pro-quo dominates decision-making, governments de-emphasize offsets and choose
      off-the-shelf purchases.
    rationale: Security urgency reduces emphasis on offsets and favors off-the-shelf buying.
- theme_id: PM46
  theme_label: Absorptive capacity conditions outcomes
  mechanism_explanation: Effective technology absorption depends on skilled workforce, innovative subcontractors, IP constraints,
    and supportive national R&D policy; lacking these limits sustained gains.
  mechanisms:
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_008
    text: Effective absorption requires skilled workforce, diversified innovative subcontractor base, and the ability to evolve
      technologies under IP constraints, supported by national science-and-technology policy and R&D culture.
    rationale: Absorptive capacity and policy conditions determine whether transfer yields lasting gains.
  - id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_002
    text: Smaller domestic industrial capacity limits the ability to absorb and execute large offset obligations, prompting
      policy adjustments (e.g., lower required percentages or thresholds).
    rationale: Limited domestic capacity constrains absorption, prompting lower targets or thresholds.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_003
    text: A strong R&D and human-capital base increases absorptive capacity, allowing foreign technology transfer via procurement
      to be internalized and extended domestically.
    rationale: Strong R&D and human capital raise absorptive capacity for transfer.
  - id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_020
    text: Without high local technological absorptive capacity and supportive civil-military science and technology strategy,
      offsets struggle to embed and extend technology transfers.
    rationale: Weak absorptive capacity and S&T strategy limit embedding of transfers.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_011
    text: “Technologically sophisticated conservatism” and limited social/intellectual capital densification reduce the likelihood
      that offsets embed and extend technology transfers.
    rationale: Limited social/intellectual capital reduces embedding of transfers.
  - id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_012
    text: When procurement choices overlook local capabilities, opportunities for domestic capability utilization and spin-off
      conversion are reduced.
    rationale: Overlooking local capability reduces utilization and spin-off potential.
- theme_id: PM47
  theme_label: Opacity and bargaining drive uncertainty
  mechanism_explanation: Information opacity and strategic bargaining over technology flows create uncertainty and complicate
    verification of long-run benefits.
  mechanisms:
  - id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_009
    text: Information opacity and strategic bargaining over technology flows make outcomes uncertain and complicate verification
      of long-run benefits.
    rationale: Opacity and bargaining over tech flows complicate verification of long-run benefits.
- theme_id: PM48
  theme_label: Institutional path dependence in offset policy
  mechanism_explanation: State–industry relationships and historical policy trajectories shape how offsets are perceived and
    operationalized in procurement and exports.
  mechanisms:
  - id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_001
    text: Different state-industry relationships and policy histories shape how offsets are perceived and operationalized
      in procurement and exports.
    rationale: State–industry histories condition how offsets are perceived and implemented.
- theme_id: PM49
  theme_label: Second-best import offset rules
  mechanism_explanation: When open domestic procurement coexists with foreign protectionism, governments adopt systematic
    import offset rules as a second-best response to offshore content.
  mechanisms:
  - id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_002
    text: Because open procurement at home coexists with protectionism abroad, the UK treats import offsets (industrial participation)
      as a second-best necessity and sets systematic rules to request IP on significant offshore content.
    rationale: Protectionism abroad and openness at home motivate systematic import offset rules.
- theme_id: PM50
  theme_label: Offset design to protect value-for-money
  mechanism_explanation: By specifying defence-related, new, technically equivalent work within contract scope and at no additional
    cost, buyers attempt to secure offset benefits without undermining value for money.
  mechanisms:
  - id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_003
    text: By requesting defense-related, new, technically equivalent work at no additional cost and within contract duration,
      the MoD attempts to secure offset benefits without sacrificing value-for-money procurement.
    rationale: Constraints on offset work aim to preserve value-for-money while gaining benefits.
- theme_id: PM51
  theme_label: Offset reciprocity and supply-chain risk
  mechanism_explanation: High offset demands in one market raise reciprocal expectations elsewhere; shifting toward more indirect
    offsets can reduce financial risk and preserve established supply chains.
  mechanisms:
  - id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_004
    text: High offset demands in one market raise reciprocal expectations in others; using more indirect offsets can reduce
      financial risk and preserve established supply chains.
    rationale: Reciprocity pressures prompt indirect offsets to reduce risk and protect supply chains.
- theme_id: PM52
  theme_label: Additionality enforced through credit rules
  mechanism_explanation: Conditioning offset credit on demonstrable market use aims to deter paper transfers and improve additionality
    and effectiveness.
  mechanisms:
  - id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_005
    text: By conditioning credit on demonstrable market use, the UK attempts to discourage paper transfers and improve additionality
      and effectiveness.
    rationale: Credit conditions deter paper transfers and improve additionality.
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_009
    text: When additionality cannot be established and costs are unknown, demanding 100% offsets can yield questionable net
      value and misdirect defense budget resources toward general export promotion.
    rationale: Questionable additionality makes 100% offset demands low-value and misdirected.
  - id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_002
    text: Allowing firms to count business that would have occurred anyway (e.g., civil aero-engine purchases) as offset credit
      undermines additionality and overstates benefits.
    rationale: Counting baseline business as credit undermines additionality and inflates claimed benefits.
- theme_id: PM53
  theme_label: Embedded offsets via procurement structure
  mechanism_explanation: Procurement structures (e.g., supplier cartels and consortia requirements) embed workshare and direct
    offsets without explicit IP policy.
  mechanisms:
  - id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_006
    text: By structuring procurement through an “open” supplier cartel and requiring foreign suppliers to participate in German
      consortia, Germany embeds direct offsets/work share into the procurement system without an explicit IP policy.
    rationale: Consortia requirements embed offsets via procurement structure.
- theme_id: PM54
  theme_label: Technology acquisition via licensed production
  mechanism_explanation: Licensed production and collaboration are used to acquire technology and build dual-use capacity,
    accepting higher costs when transfer benefits are prioritised.
  mechanisms:
  - id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_007
    text: Licensed production, collaboration, and offset-like work requirements were used to acquire technology and build
      dual-use capacity, accepting costs for production under license when it delivered transfer.
    rationale: Licensed production is accepted for its technology transfer and dual-use capacity gains.
  - id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_001
    text: By tying arms purchases to compensatory work and know-how transfer, procurement decisions channel resources to domestic
      firms that sustain and upgrade capabilities.
    rationale: Offsets tied to compensatory work channel resources to domestic capability sustainment.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_001
    text: By using licensed production, coproduction, and joint ventures as direct-offset style channels, Brazil acquires
      military technology from industrialized countries and builds domestic production capability.
    rationale: Licensed production and joint ventures are used to acquire technology and build capability.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_002
    text: By making technology transfer a procurement requirement, Brazil steers suppliers toward delivering know-how, training,
      and process upgrades instead of only economic side-payments.
    rationale: Technology-transfer requirements steer suppliers toward know-how and process upgrades.
  - id: 01_introduction_and_overview_pdf__cmo_009
    text: Offsets are implemented as licensed production, transferring know-how and embedding domestic capabilities despite
      a recognised price premium.
    rationale: Licensed production transfers know-how and embeds capability despite price premium.
  - id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_004
    text: By preferring offsets that involve domestic participation in development/manufacture and learning to maintain/support
      equipment, policies aim to sustain skills and lifecycle support capability.
    rationale: Participation in development/manufacture and support builds skills and lifecycle support capability.
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_016
    text: By abandoning civil offsets and focusing on military offsets in prioritized technology fields, policy aims to secure
      long-term defense technological competence rather than diffuse economic objectives.
    rationale: Military offsets targeted to priority technology fields build long-term defense technological competence.
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_017
    text: Direct military offsets build local capacity to maintain and modify imported systems, supporting lifecycle readiness
      and security of supply.
    rationale: Direct offsets build maintenance and modification capability for imported systems.
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_018
    text: Indirect military offsets are targeted to prioritized technology fields and evaluated for qualitative and long-term
      impact, sustaining competence across the defense technology base.
    rationale: Targeted indirect offsets sustain competence in prioritized technology fields over the long term.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_017
    text: Technology transfer, worker training, assembly/part-manufacture, and eventual transfer of the production line enable
      progressive localization (“polonization”) of production.
    rationale: Technology transfer, training, and production-line transfer enable progressive localization of production.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_015
    text: By concentrating on key technologies (e.g., fuselage and systems integration) and importing other components, firms
      can build autonomy in high-value areas while avoiding inefficient local production.
    rationale: Selective localization builds autonomy in high-value technologies while avoiding inefficient local production.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_017
    text: Creating domestic entities responsible for software development, technology absorption, and training increases national
      autonomy over operation and evolution of complex systems.
    rationale: Domestic software/absorption/training entities increase autonomy over operating and evolving complex systems.
  - id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_019
    text: Requiring trade-compensation reinvestment and technology transfer for software maintenance increases buyer control
      over sustainment and upgrades.
    rationale: Transfer and reinvestment requirements build software sustainment and upgrade control.
  - id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_013
    text: Overambitious autonomy goals can misallocate resources; accepting partial technological dependence while negotiating
      for targeted transfer reduces unrealistic expectations.
    rationale: Targeted transfer within partial dependence focuses capability-building on feasible, high-value areas.
  - id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_016
    text: Technology-assistance offsets can be designed to support domestic development (e.g., LCA, indigenous carrier) by
      transferring relevant know-how, but value can be undermined by overpricing or limited implementation.
    rationale: Technology-assistance offsets transfer relevant know-how when well-implemented.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_002
    text: Technology transfers and production offsets provide recipients with know-how and work share that can enable domestic
      substitutes and spillovers into commercial industry.
    rationale: Transfers and work share build domestic substitute capability and spillovers.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_005
    text: Japan instead pursues extensive technology transfers and licensed local production from the US, which function similarly
      to offsets by delivering industrial and political benefits.
    rationale: Licensed production and transfer function as offsets by embedding domestic production/technology capability.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_006
    text: By ranking domestic procurement first and licensed local production second, Japan channels demand and learning into
      domestic firms, maintaining production/technology capability.
    rationale: Domestic demand and licensed production channel learning into domestic firms, sustaining capability.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_007
    text: Maintaining an advanced domestic production base supports sustainment (operating ratio and sustainability) and provides
      negotiating leverage when introducing equipment from abroad.
    rationale: Domestic production base supports sustainment and increases bargaining leverage.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_014
    text: By maintaining financial/budgetary leadership and embedding technology transfers from foreign suppliers, Korea builds
      domestic manufacturing and integration capability while preserving export flexibility.
    rationale: Embedded transfers build manufacturing/integration capability while preserving export flexibility.
  - id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_021
    text: Offset agreements can establish domestic and regional maintenance/repair infrastructure and generate sizable industrial
      contracts tied to procurement.
    rationale: Offset-linked transfer and contracts can build domestic maintenance and repair infrastructure.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_001
    text: By conditioning arms purchases on licensed production, coproduction, and technology transfer, offsets provide foreign
      technical inputs that shorten the learning timeline.
    rationale: Licensed production and transfer shorten learning timelines for domestic capability.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_003
    text: State-owned “strategic enterprises” created in key sectors use offsets and state backing to build domestic technology,
      skills, and infrastructure.
    rationale: Offsets plus state backing build domestic technology, skills, and supporting infrastructure.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_004
    text: By explicitly using offsets to acquire research, design, and manufacturing expertise, IPTN attempts to compress
      the timeline for “mastery” of aviation technology.
    rationale: Offsets acquire R&D and manufacturing expertise, compressing the learning curve.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_013
    text: By using offsets selectively for technology transfer and training that support maintenance, repair, and upgrades,
      Singapore builds readiness-relevant capabilities without pursuing comprehensive autarky.
    rationale: Selective transfer and training build maintenance/upgrade capability without comprehensive autarky.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_014
    text: Requiring technology transfer and training within ICPs steers procurement toward building local maintenance and
      upgrade competencies.
    rationale: Transfer and training requirements steer procurement toward local maintenance/upgrade competence.
  - id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_015
    text: Collaboration with foreign firms on specialized repair/manufacturing (e.g., turbine blade overhaul) builds domestic
      capabilities that support aircraft and submarine sustainment.
    rationale: Repair/manufacturing collaboration builds specialized domestic sustainment capability.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_005
    text: Targeting offsets to maintenance, adaptation, munitions, spares, and long-term technologies concentrates effort
      on capabilities tied to self-reliance; abandoning ill-focused offsets shifts capability-building to more specific contract
      provisions.
    rationale: Targeting offset activity to sustainment and adaptation concentrates effort on self-reliance capabilities.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_009
    text: When local content is not feasible, substituting SIDA activities (R&D, exports, technology transfer, training, infrastructure)
      attempts to deliver capability gains through alternative investments that may carry cost premiums.
    rationale: Alternative SIDA activities substitute for local content to deliver capability gains.
  - id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_015
    text: Contractual undertakings to direct business (including maintenance capability, technology transfers, joint ventures,
      and exports support) create pathways to build local industrial capability.
    rationale: Contractual undertakings and transfers create pathways to build local industrial capability.
- theme_id: PM55
  theme_label: Subsidiary entry then consolidation
  mechanism_explanation: Allowing foreign subsidiaries enables participation and capability build-up, but later consolidation
    absorbs or removes affiliates as domestic firms grow.
  mechanisms:
  - id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_008
    text: Allowing foreign suppliers to establish subsidiaries enabled participation and capability build-up; later consolidation
      absorbed or eliminated these affiliates as German firms grew.
    rationale: Subsidiary entry enables capability build-up before consolidation absorbs affiliates.
- theme_id: PM56
  theme_label: Fair-return reform improves collaboration
  mechanism_explanation: Moving from strict juste_retour to global_balance reduces fragmentation and improves collaborative
    efficiency, but requires political agreement and offsets/waivers.
  mechanisms:
  - id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_009
    text: Shifting from strict juste_retour to global_balance reduces fragmentation and can improve collaborative efficiency,
      but requires political agreement and offsets/waivers.
    rationale: Global-balance approaches reduce fragmentation but need political agreement.
- theme_id: PM57
  theme_label: Export support builds offset capacity
  mechanism_explanation: Government export-support organisations help firms navigate offset rules and identify creditable
    projects, especially for smaller exporters lacking offset staff.
  mechanisms:
  - id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_010
    text: Government export support organizations (e.g., UK DESO) help firms navigate offset rules, build projects, and identify
      credit opportunities, especially for smaller exporters lacking offset staff.
    rationale: Export support bodies reduce coordination burdens for firms without offset staff.
- theme_id: PM58
  theme_label: Complex governance raises transaction costs
  mechanism_explanation: Multi-layer governance structures and non-competitive work splitting increase transaction costs,
    blur accountability, and slow decisions.
  mechanisms:
  - id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_001
    text: Non-competitive work splitting and multi-layer committee structures increase transaction costs, blur accountability,
      and slow decisions.
    rationale: Non-competitive work splitting and committees raise transaction costs and slow decisions.
- theme_id: PM62
  theme_label: Early partnership enables high-tech roles
  mechanism_explanation: Early partnership and competitive best-value allocation can provide access to development roles and
    high-technology work shares when technology access agreements and export controls allow.
  mechanisms:
  - id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_006
    text: Early partnership and competitive “best value” work allocation provide access to development roles and potential
      high-technology work shares, conditional on technology access agreements and export-control approvals.
    rationale: Early competitive partnerships enable access to high-tech roles when approvals permit.
- theme_id: PM63
  theme_label: Partnership structures shape risk exposure
  mechanism_explanation: Exclusive partnerships create win–lose exposure tied to prime selection, while suppliers in multiple
    teams hedge risk based on competitive advantage.
  mechanisms:
  - id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_007
    text: Exclusive partnership yields “win-lose” exposure tied to prime selection, while suppliers in both teams hedge risk
      (“win-win”) based on competitive advantage.
    rationale: Exclusive vs multi-team partnerships alter risk exposure and hedging.
- theme_id: PM64
  theme_label: IP studies as biased marketing signals
  mechanism_explanation: Contractor-provided industrial participation studies function as marketing and can be biased, requiring
    cautious interpretation of claimed technology benefits.
  mechanisms:
  - id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_009
    text: Contractor-provided industrial participation studies function as marketing and are subject to bias, requiring cautious
      interpretation and valuation of uncertain technology benefits.
    rationale: Vendor-provided studies act as marketing and bias perceived technology benefits.
- theme_id: PM65
  theme_label: Partnership packages build durable collaboration
  mechanism_explanation: Broader partnership packages aim to create durable collaboration beyond meeting offset percentages,
    linking defence and non-defence opportunities.
  mechanisms:
  - id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_010
    text: Broader packages promising long-term partnerships and non-defense opportunities attempt to create durable collaboration
      beyond meeting an offset percentage.
    rationale: Partnership packages seek durable collaboration beyond offset percentage compliance.
- theme_id: PM66
  theme_label: Offsets as import compensation
  mechanism_explanation: Rising imports trigger requirements for compensatory offsets (work share, countertrade, transfer)
    to rebalance domestic industrial participation.
  mechanisms:
  - id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_001
    text: As imports of components/subsystems rise (e.g., to save costs or avoid domestic development), governments require
      foreign suppliers to compensate through offsets (work share, countertrade, technology transfer).
    rationale: Imports prompt compensatory offsets to rebalance domestic participation.
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_011
    text: Linking offset requirements to import contracts creates compensatory commercial/industrial work intended to expand
      production and sustain employment.
    rationale: Linking offsets to imports compels compensatory industrial work to sustain domestic activity.
  - id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_016
    text: By requiring buyback and local sourcing, offsets redirect procurement-related spending toward domestic suppliers
      (including subsidiaries) and expand a local industrial footprint.
    rationale: Buyback and local sourcing compensate for imports by redirecting spending to domestic suppliers.
- theme_id: PM74
  theme_label: Disclosure constraints obscure evaluation
  mechanism_explanation: Limited data access and vested interests constrain disclosure, making it difficult to separate fact
    from fiction in offset evaluation.
  mechanisms:
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_002
    text: Limited data access and vested interests in industry and government constrain disclosure and complicate separating
      fact from fiction.
    rationale: Data access limits and vested interests obscure evaluation.
- theme_id: PM75
  theme_label: Counterfactual uncertainty undermines additionality
  mechanism_explanation: When counterfactual outcomes are unknown, analysts must assume them, creating fundamental uncertainty
    about additionality.
  mechanisms:
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_003
    text: Because it is unknown what would have happened without the offset obligation, analysts must assume a counterfactual,
      introducing fundamental uncertainty about additionality.
    rationale: Unknown counterfactuals create fundamental uncertainty about additionality.
- theme_id: PM77
  theme_label: Heterogeneity limits generalization
  mechanism_explanation: Differences in offset types and goals produce divergent effects and require different evaluation
    approaches, limiting generalization.
  mechanisms:
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_005
    text: Heterogeneity in offset types and goals produces different economic effects and requires different evaluation methods,
      limiting generalization.
    rationale: Diverse offset types require different evaluation methods and limit generalization.
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_012
    text: Indirect offsets (reciprocal purchases unrelated to the arms deal) obscure causal attribution and complicate evaluation
      compared to direct offsets.
    rationale: Indirect offsets complicate causal attribution relative to direct offsets.
- theme_id: PM78
  theme_label: Exports concentrate in incumbents
  mechanism_explanation: Offset-generated exports concentrate in existing trade relations and traditional products from large
    exporters, limiting SME exports and job creation.
  mechanisms:
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_007
    text: Offset-generated exports concentrate in existing trade relations and traditional products from large exporters,
      limiting SME exports and job creation.
    rationale: Exports concentrate in incumbents, limiting SME gains.
- theme_id: PM80
  theme_label: Firm gains but weak national benefit
  mechanism_explanation: Offset receipt can correlate with firm income/employment gains even when national net benefits are
    limited and misaligned with policy goals.
  mechanisms:
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_010
    text: Statistical association between receiving offsets and firm income/employment growth can coexist with limited national
      net benefit and poor alignment with policy goals.
    rationale: Firm-level gains can coexist with weak national net benefit.
- theme_id: PM81
  theme_label: Offsets extend activity beyond program life
  mechanism_explanation: Emphasis on indirect offsets is used to extend industrial activity beyond the life of a specific
    procurement program, sustaining work over time.
  mechanisms:
  - id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_015
    text: Emphasis on indirect offsets was initially used to extend industrial activity beyond the life of a specific procurement
      program.
    rationale: Indirect offsets are used to extend industrial activity beyond a single program.
ambiguous_mechanisms:
- id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_001
  text: By routinely embedding licensed production, technology transfer, countertrade/barter, and long-term credit into
    procurement, India uses procurement-linked resources to build domestic capability and manage foreign exchange constraints.
  possible_themes: [PM54, PM5]
  explanation: Mechanism combines technology acquisition via licensed production/transfer with external finance and countertrade
    to ease foreign-exchange constraints.
```

3) proto_themes_changelog_yml
```yaml
change_log:
- change_id: CHG_021
  change_type: assignment
  theme_id: PM1
  mechanism_id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_021
  summary: Assigned to PM1 (economic framing legitimation).
  rationale: Mechanism reframes the purchase as economically beneficial to reduce resistance.
- change_id: CHG_022
  change_type: new_theme
  theme_id: PM11
  mechanism_id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_022
  summary: Created PM11 for domestic industry influence on offset demands.
  rationale: Domestic arms-industry influence drives demands for direct offsets that subsidize local industry.
- change_id: CHG_023
  change_type: new_theme
  theme_id: PM12
  mechanism_id: 01_do_offsets_mitigate_or_magnify_the_military_burden_pdf__cmo_023
  summary: Created PM12 for development-oriented indirect offset design.
  rationale: Targeted indirect offsets and transparency increase realization and development relevance.
- change_id: CHG_024
  change_type: new_theme
  theme_id: PM13
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_001
  summary: Created PM13 for competition shifts toward bundled content.
  rationale: Benefits packages shift competition from price/quality to bundled content.
- change_id: CHG_025
  change_type: new_theme
  theme_id: PM14
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_002
  summary: Created PM14 for rent extraction via offset requirements.
  rationale: Offsets extract rents by compelling domestic economic activity.
- change_id: CHG_026
  change_type: assignment
  theme_id: PM1
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_003
  summary: Assigned to PM1 (benefit salience legitimation).
  rationale: Benefit salience drives adoption despite ambiguous net welfare.
- change_id: CHG_027
  change_type: new_theme
  theme_id: PM15
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_004
  summary: Created PM15 for flexibility vs rigid mandates.
  rationale: One-size mandates force offsets where market exchange is superior, creating diseconomies.
- change_id: CHG_028
  change_type: new_theme
  theme_id: PM16
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_005
  summary: Created PM16 for offsets justified in high-hazard exchanges.
  rationale: Offsets substitute for poorly functioning markets when hazards and benefits are high.
- change_id: CHG_029
  change_type: new_theme
  theme_id: PM17
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_006
  summary: Created PM17 for administrative burden and rent-seeking.
  rationale: Offsets add administrative burden and rent-seeking without improving transfer outcomes.
- change_id: CHG_030
  change_type: new_theme
  theme_id: PM19
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_007
  summary: Created PM19 for supplier coaching and reputational certification.
  rationale: Supplier teaching and reputational stamps reduce domestic firms' transaction costs.
- change_id: CHG_031
  change_type: new_theme
  theme_id: PM20
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_008
  summary: Created PM20 for alliance incentives via offset waivers.
  rationale: Bargaining power encourages alliances without mandatory offsets.
- change_id: CHG_032
  change_type: new_theme
  theme_id: PM20
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_009
  summary: Added second mechanism to PM20.
  rationale: Offset waivers incentivize investment and reputational capital while maintaining competition.
- change_id: CHG_033
  change_type: assignment
  theme_id: PM15
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_010
  summary: Assigned to PM15 (flexibility reduces diseconomies).
  rationale: Variable policies expand negotiation options and reduce diseconomies of scope.
- change_id: CHG_034
  change_type: assignment
  theme_id: PM17
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_011
  summary: Assigned to PM17 (rent-seeking from discretion).
  rationale: Discretion attracts rent-seeking while strict triggers constrain it.
- change_id: CHG_035
  change_type: assignment
  theme_id: PM16
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_012
  summary: Assigned to PM16 (offsets misapplied in low-hazard settings).
  rationale: Offsets in low-hazard categories create opportunity costs.
- change_id: CHG_036
  change_type: assignment
  theme_id: PM17
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_013
  summary: Assigned to PM17 (overload and superficial evaluation).
  rationale: Broad mandates overload evaluation and raise costs with little reputational effect.
- change_id: CHG_037
  change_type: assignment
  theme_id: PM16
  mechanism_id: 02_using_procurement_offsets_as_an_economic_development_strategy_pdf__cmo_014
  summary: Assigned to PM16 (direct vs indirect offsets matched to hazard).
  rationale: Offset type should match exchange hazard and seller capabilities to avoid cost inflation.
- change_id: CHG_038
  change_type: new_theme
  theme_id: PM21
  mechanism_id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_001
  summary: Created PM21 for market access conditioned on reciprocity.
  rationale: Offsets impose trade-restricting reciprocal requirements as a condition of market access.
- change_id: CHG_039
  change_type: new_theme
  theme_id: PM18
  mechanism_id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_002
  summary: Created PM18 for objective ambiguity undermining evaluation.
  rationale: Mixed objectives make evaluation criteria and net benefits hard to specify.
- change_id: CHG_040
  change_type: assignment
  theme_id: PM6
  mechanism_id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_003
  summary: Assigned to PM6 (additional trade gains).
  rationale: Additionality requirement aims to create new exports.
- change_id: CHG_041
  change_type: assignment
  theme_id: PM3
  mechanism_id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_004
  summary: Assigned to PM3 (cost pass-through via pricing).
  rationale: Offset costs can be embedded in prices when benchmarks are absent.
- change_id: CHG_042
  change_type: assignment
  theme_id: PM3
  mechanism_id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_005
  summary: Assigned to PM3 (profitability/price adjustment).
  rationale: Suppliers adjust prices or exit to preserve returns under offset obligations.
- change_id: CHG_043
  change_type: assignment
  theme_id: PM2
  mechanism_id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_006
  summary: Assigned to PM2 (enforcement challenges).
  rationale: Default risk persists because enforcement is difficult in practice.
- change_id: CHG_044
  change_type: assignment
  theme_id: PM15
  mechanism_id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_007
  summary: Assigned to PM15 (rigid mandate reduces flexibility).
  rationale: Fixed-percentage schemes constrain negotiation and force in-kind enhancements.
- change_id: CHG_045
  change_type: assignment
  theme_id: PM15
  mechanism_id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_008
  summary: Assigned to PM15 (mandated local content raises costs).
  rationale: High local content forces uncompetitive subcontracting, raising prices or inducing reneging.
- change_id: CHG_046
  change_type: new_theme
  theme_id: PM22
  mechanism_id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_009
  summary: Created PM22 for local capability discovery.
  rationale: Local content requirements force search and engagement with domestic suppliers.
- change_id: CHG_047
  change_type: new_theme
  theme_id: PM23
  mechanism_id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_010
  summary: Created PM23 for sourcing persistence only if viable.
  rationale: Sourcing ends when obligations expire unless ongoing production is worthwhile.
- change_id: CHG_048
  change_type: assignment
  theme_id: PM3
  mechanism_id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_011
  summary: Assigned to PM3 (cost pass-through when market power is weak).
  rationale: Vendors price expected offsets into the offer when cross-subsidization cannot be forced.
- change_id: CHG_049
  change_type: assignment
  theme_id: PM15
  mechanism_id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_012
  summary: Assigned to PM15 (inefficient bundling).
  rationale: Untargeted bundle targets ignore complementarities and force inefficient choices.
- change_id: CHG_050
  change_type: assignment
  theme_id: PM2
  mechanism_id: 03_mandatory_defense_offsets_conceptual_foundations_pdf__cmo_013
  summary: Assigned to PM2 (post-award reneging).
  rationale: Timing and enforcement frictions weaken leverage after contract award.
- change_id: CHG_051
  change_type: new_theme
  theme_id: PM24
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_001
  summary: Created PM24 for sector-specific export stimulus.
  rationale: Indirect offset purchases operate like sector-specific price adjustments.
- change_id: CHG_052
  change_type: assignment
  theme_id: PM9
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_002
  summary: Assigned to PM9 (barter/in-kind bypasses credit constraints).
  rationale: In-kind offsets substitute for cash payment under credit constraints.
- change_id: CHG_053
  change_type: new_theme
  theme_id: PM25
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_003
  summary: Created PM25 for opacity enabling price discrimination.
  rationale: Lower visibility enables price discrimination and dumping.
- change_id: CHG_054
  change_type: new_theme
  theme_id: PM26
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_004
  summary: Created PM26 for buyback hostage effect.
  rationale: Buyback requirements align incentives against obsolete tech transfer.
- change_id: CHG_055
  change_type: new_theme
  theme_id: PM27
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_005
  summary: Created PM27 for depreciation-driven licensing.
  rationale: Depreciation encourages licensing to monetize value before it declines.
- change_id: CHG_056
  change_type: new_theme
  theme_id: PM28
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_006
  summary: Created PM28 for exporter networks reducing entry costs.
  rationale: Exporter networks reduce market penetration costs for buyer-country products.
- change_id: CHG_057
  change_type: new_theme
  theme_id: PM29
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_007
  summary: Created PM29 for bundled contracting reducing transaction costs.
  rationale: Bundled contracting reduces transaction costs and reallocates rents.
- change_id: CHG_058
  change_type: new_theme
  theme_id: PM30
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_008
  summary: Created PM30 for second-best policy distortions.
  rationale: Offsets used as substitutes for reforms distort resource allocation.
- change_id: CHG_059
  change_type: assignment
  theme_id: PM10
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_009
  summary: Assigned to PM10 (offsets as competitive differentiator).
  rationale: Firms include offsets to avoid losing sales to rivals when profitable.
- change_id: CHG_060
  change_type: new_theme
  theme_id: PM31
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_010
  summary: Created PM31 for labour-rent protection opposition.
  rationale: Unions oppose offsets to protect employment and labour-market rents.
- change_id: CHG_061
  change_type: no_change
  theme_id: ALL
  summary: Split/merge audit found no clear changes; themes retained as-is.
  rationale: Reviewed labels and mechanism explanations for overlap or internal incoherence; none met merge/split criteria.
  details:
    merged_from: []
    split_into: []
    retained_as_is:
    - PM1
    - PM2
    - PM3
    - PM4
    - PM5
    - PM6
    - PM7
    - PM8
    - PM9
    - PM10
    - PM11
    - PM12
    - PM13
    - PM14
    - PM15
    - PM16
    - PM17
    - PM18
    - PM19
    - PM20
    - PM21
    - PM22
    - PM23
    - PM24
    - PM25
    - PM26
    - PM27
    - PM28
    - PM29
    - PM30
    - PM31
- change_id: CHG_062
  change_type: new_theme
  theme_id: PM32
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_011
  summary: Created PM32 for rent redistribution from offset competition.
  rationale: Offset-induced competition shifts surplus between firms and buyers, creating distributive conflict.
- change_id: CHG_063
  change_type: new_theme
  theme_id: PM33
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_012
  summary: Created PM33 for subsidy financing offsetting scale gains.
  rationale: Taxpayer-financed subsidies offset or reverse unit-cost savings from scale.
- change_id: CHG_064
  change_type: assignment
  theme_id: PM4
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_013
  summary: Assigned to PM4 (crowding out civilian resources).
  rationale: Public resources diverted to military offsets impose opportunity costs on civilian sectors.
- change_id: CHG_065
  change_type: assignment
  theme_id: PM30
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_014
  summary: Assigned to PM30 (trade distortion externalities).
  rationale: Mandatory offsets reallocate investment and purchases, imposing third-party externalities.
- change_id: CHG_066
  change_type: new_theme
  theme_id: PM34
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_015
  summary: Created PM34 for non-sustaining capability gains.
  rationale: Technology transfer and training do not keep pace with exporter advances.
- change_id: CHG_067
  change_type: new_theme
  theme_id: PM35
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_016
  summary: Created PM35 for trade displacement/no net forex gains.
  rationale: Exporter-sold offsets leave net foreign exchange unchanged.
- change_id: CHG_068
  change_type: assignment
  theme_id: PM35
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_017
  summary: Assigned to PM35 (trade diversion without demand growth).
  rationale: Offset purchases divert demand across suppliers without increasing total demand.
- change_id: CHG_069
  change_type: assignment
  theme_id: PM34
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_018
  summary: Assigned to PM34 (temporary gains, outdated tech).
  rationale: Outdated technology and limited momentum leave recipients behind after agreements end.
- change_id: CHG_070
  change_type: assignment
  theme_id: PM2
  mechanism_id: 04_economic_aspects_of_arms_trade_offsets_pdf__cmo_019
  summary: Assigned to PM2 (accounting relabeling).
  rationale: Offset credits can relabel relationships that would occur anyway.
- change_id: CHG_071
  change_type: assignment
  theme_id: PM21
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_001
  summary: Assigned to PM21 (reciprocity conditions).
  rationale: Exemptions allow sales to be conditioned on reciprocal arrangements.
- change_id: CHG_072
  change_type: new_theme
  theme_id: PM36
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_002
  summary: Created PM36 for cross-border ties from illiberal contracting.
  rationale: Illiberal contracting latitude creates state–firm ties beyond price competition.
- change_id: CHG_073
  change_type: assignment
  theme_id: PM36
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_003
  summary: Assigned to PM36 (buyer leverage intensifies linkages).
  rationale: Greater buyer leverage increases offset demands and cross-national linkages.
- change_id: CHG_074
  change_type: assignment
  theme_id: PM36
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_004
  summary: Assigned to PM36 (diagonalized exchanges).
  rationale: Offsets require cross-border subcontracting and technology transfer across sectors.
- change_id: CHG_075
  change_type: new_theme
  theme_id: PM37
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_005
  summary: Created PM37 for buyer pool expansion loosening controls.
  rationale: Sales incentives shift services from restraint to permissive offset stances.
- change_id: CHG_076
  change_type: new_theme
  theme_id: PM38
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_006
  summary: Created PM38 for firm offset-management capacity.
  rationale: Firms build in-house offset organizations to manage obligations.
- change_id: CHG_077
  change_type: assignment
  theme_id: PM17
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_007
  summary: Assigned to PM17 (transaction cost burden).
  rationale: Managing offsets imposes material transaction costs on firms.
- change_id: CHG_078
  change_type: assignment
  theme_id: PM2
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_008
  summary: Assigned to PM2 (credit inflation).
  rationale: Crediting practices allow reported fulfillment to exceed delivered value.
- change_id: CHG_079
  change_type: assignment
  theme_id: PM38
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_009
  summary: Assigned to PM38 (expanded offset operations).
  rationale: Rising requirements drive expanded offset operations and longer contracts.
- change_id: CHG_080
  change_type: assignment
  theme_id: PM1
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_010
  summary: Assigned to PM1 (offset extraction increases acceptance).
  rationale: Offset-driven extraction of activity increases willingness to import foreign systems.
- change_id: CHG_081
  change_type: assignment
  theme_id: PM36
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_011
  summary: Assigned to PM36 (enduring supplier ties).
  rationale: Offshoring components creates lasting supplier relationships for buyer firms.
- change_id: CHG_082
  change_type: assignment
  theme_id: PM36
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_012
  summary: Assigned to PM36 (cross-border supplier ties).
  rationale: Offset-enabled component roles create durable cross-border supplier relationships.
- change_id: CHG_083
  change_type: assignment
  theme_id: PM4
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_013
  summary: Assigned to PM4 (displacement of domestic suppliers).
  rationale: Direct offsets shift work away from domestic suppliers toward foreign subcontractors.
- change_id: CHG_084
  change_type: new_theme
  theme_id: PM39
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_014
  summary: Created PM39 for hidden injuries from offset competition.
  rationale: Indirect offsets intensify competition and impose unseen harms on non-defence sectors.
- change_id: CHG_085
  change_type: assignment
  theme_id: PM28
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_015
  summary: Assigned to PM28 (competitiveness via exporter networks).
  rationale: Offsets reduce foreign firms’ costs and improve quality, affecting competitiveness.
- change_id: CHG_086
  change_type: assignment
  theme_id: PM2
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_016
  summary: Assigned to PM2 (weak enforcement enables diversion).
  rationale: Licensed production creates diversion risk under inadequate enforcement.
- change_id: CHG_087
  change_type: new_theme
  theme_id: PM40
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_017
  summary: Created PM40 for acceleration of next-generation development.
  rationale: Interoperability demands and tech sharing justify accelerating next-gen development.
- change_id: CHG_088
  change_type: new_theme
  theme_id: PM41
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_018
  summary: Created PM41 for economic priorities overriding security restraint.
  rationale: Economic imperatives shift authority away from arms-control toward economic agencies.
- change_id: CHG_089
  change_type: new_theme
  theme_id: PM42
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_019
  summary: Created PM42 for offsets increasing defence budget appeal.
  rationale: Offsets tied to non-defence capabilities make military spending more attractive.
- change_id: CHG_090
  change_type: new_theme
  theme_id: PM43
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_020
  summary: Created PM43 for opacity weakening cost discipline.
  rationale: Offsets and price opacity reduce cost-minimizing incentives and visibility.
- change_id: CHG_091
  change_type: new_theme
  theme_id: PM44
  mechanism_id: 05_arms_trade_as_illiberal_trade_pdf__cmo_021
  summary: Created PM44 for offsets preserving market power.
  rationale: Offsets expand markets and preserve pricing power, sustaining regime incentives.
- change_id: CHG_092
  change_type: assignment
  theme_id: PM1
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_001
  summary: Assigned to PM1 (offset rhetoric legitimates purchases).
  rationale: Offset promises frame purchases as economic development benefits.
- change_id: CHG_093
  change_type: assignment
  theme_id: PM36
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_002
  summary: Assigned to PM36 (buyer leverage extracts linkages).
  rationale: Buyer leverage in a buyer’s market extracts concessions and linkages.
- change_id: CHG_094
  change_type: new_theme
  theme_id: PM45
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_003
  summary: Created PM45 for security urgency overriding offsets.
  rationale: Security urgency de-emphasizes offsets and favors off-the-shelf purchases.
- change_id: CHG_095
  change_type: assignment
  theme_id: PM15
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_004
  summary: Assigned to PM15 (flexibility improves outcomes).
  rationale: Case-by-case negotiation maximizes mutual benefit versus rigid prescriptions.
- change_id: CHG_096
  change_type: assignment
  theme_id: PM2
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_005
  summary: Assigned to PM2 (informal enforcement incentives).
  rationale: Threat of reduced future consideration incentivizes meeting offset targets.
- change_id: CHG_097
  change_type: assignment
  theme_id: PM2
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_006
  summary: Assigned to PM2 (penalty-backed incentives).
  rationale: Multipliers and penalties strengthen incentives for investment and transfer.
- change_id: CHG_098
  change_type: assignment
  theme_id: PM36
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_007
  summary: Assigned to PM36 (strategic collaboration pathways).
  rationale: Offsets link procurement to collaboration and transfer aligned with national objectives.
- change_id: CHG_099
  change_type: new_theme
  theme_id: PM46
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_008
  summary: Created PM46 for absorptive capacity conditions.
  rationale: Workforce, subcontractor base, IP constraints, and R&D policy condition absorption.
- change_id: CHG_100
  change_type: new_theme
  theme_id: PM47
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_009
  summary: Created PM47 for opacity and bargaining uncertainty.
  rationale: Opacity and bargaining over tech flows complicate verification of benefits.
- change_id: CHG_101
  change_type: assignment
  theme_id: PM34
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_010
  summary: Assigned to PM34 (benefits decay without capability embedding).
  rationale: Short-term assembly without capability embedding leads to benefit decay.
- change_id: CHG_102
  change_type: assignment
  theme_id: PM3
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_011
  summary: Assigned to PM3 (cost pass-through pricing).
  rationale: Vendors treat offset costs as a pricing issue and load them into contract prices.
- change_id: CHG_103
  change_type: assignment
  theme_id: PM17
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_012
  summary: Assigned to PM17 (negotiation friction).
  rationale: Divergent valuation methods create friction and complicate agreements.
- change_id: CHG_104
  change_type: assignment
  theme_id: PM2
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_013
  summary: Assigned to PM2 (credit inflation via baseline work).
  rationale: Counting pre-existing work as credit inflates delivery and weakens accountability.
- change_id: CHG_105
  change_type: assignment
  theme_id: PM2
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_014
  summary: Assigned to PM2 (credit banking opacity).
  rationale: Credit banking relaxes delivery constraints but reduces transparency.
- change_id: CHG_106
  change_type: assignment
  theme_id: PM8
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_015
  summary: Assigned to PM8 (restricted transfer limits learning).
  rationale: Aged tech, IP barriers, and black-boxing limit learning.
- change_id: CHG_107
  change_type: assignment
  theme_id: PM19
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_016
  summary: Assigned to PM19 (learning-by-doing in licensed production).
  rationale: Licensed production enables cumulative learning and adaptation.
- change_id: CHG_108
  change_type: assignment
  theme_id: PM33
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_017
  summary: Assigned to PM33 (subsidy-funded job creation).
  rationale: Domestic production requires subsidies to match incumbents, creating high public costs.
- change_id: CHG_109
  change_type: assignment
  theme_id: PM4
  mechanism_id: 06_defense_offsets_policy_versus_pragmatism_pdf__cmo_018
  summary: Assigned to PM4 (net job losses from outbound obligations).
  rationale: Outbound obligations outweigh inbound work, reducing net jobs.
- change_id: CHG_110
  change_type: new_theme
  theme_id: PM48
  mechanism_id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_001
  summary: Created PM48 for institutional path dependence in offset policy.
  rationale: State–industry histories shape how offsets are perceived and operationalized.
- change_id: CHG_111
  change_type: new_theme
  theme_id: PM49
  mechanism_id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_002
  summary: Created PM49 for second-best import offset rules.
  rationale: Protectionism abroad and openness at home motivate systematic import offset rules.
- change_id: CHG_112
  change_type: new_theme
  theme_id: PM50
  mechanism_id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_003
  summary: Created PM50 for value-for-money-protecting offset design.
  rationale: Specifying new, equivalent work within contract scope preserves value-for-money.
- change_id: CHG_113
  change_type: new_theme
  theme_id: PM51
  mechanism_id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_004
  summary: Created PM51 for reciprocity pressure and supply-chain risk.
  rationale: Reciprocal expectations prompt indirect offsets to reduce risk and protect supply chains.
- change_id: CHG_114
  change_type: new_theme
  theme_id: PM52
  mechanism_id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_005
  summary: Created PM52 for additionality enforced through credit rules.
  rationale: Credit conditioned on market use deters paper transfers and improves additionality.
- change_id: CHG_115
  change_type: new_theme
  theme_id: PM53
  mechanism_id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_006
  summary: Created PM53 for embedded offsets via procurement structure.
  rationale: Consortia requirements embed offsets without explicit IP policy.
- change_id: CHG_116
  change_type: new_theme
  theme_id: PM54
  mechanism_id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_007
  summary: Created PM54 for technology acquisition via licensed production.
  rationale: Licensed production is accepted to obtain technology and dual-use capacity.
- change_id: CHG_117
  change_type: new_theme
  theme_id: PM55
  mechanism_id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_008
  summary: Created PM55 for subsidiary entry then consolidation.
  rationale: Subsidiaries enable capability build-up before consolidation absorbs affiliates.
- change_id: CHG_118
  change_type: new_theme
  theme_id: PM56
  mechanism_id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_009
  summary: Created PM56 for fair-return reform improving collaboration.
  rationale: Global-balance approaches reduce fragmentation but require political agreement.
- change_id: CHG_119
  change_type: new_theme
  theme_id: PM57
  mechanism_id: 07_comparing_british_and_german_offset_strategies_pdf__cmo_010
  summary: Created PM57 for export support building offset capacity.
  rationale: Export-support organisations help firms navigate offset rules and identify creditable projects.
- change_id: CHG_120
  change_type: new_theme
  theme_id: PM58
  mechanism_id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_001
  summary: Created PM58 for complex governance raising transaction costs.
  rationale: Non-competitive work splitting and committee structures slow decisions.
- change_id: CHG_121
  change_type: new_theme
  theme_id: PM59
  mechanism_id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_002
  summary: Created PM59 for additionality undermined by baseline credit.
  rationale: Allowing baseline business as credit overstates benefits.
- change_id: CHG_122
  change_type: assignment
  theme_id: PM34
  mechanism_id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_003
  summary: Assigned to PM34 (limited tech transfer post-development).
  rationale: Offsets offer few tech opportunities once development is complete.
- change_id: CHG_123
  change_type: new_theme
  theme_id: PM60
  mechanism_id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_004
  summary: Created PM60 for offset-based import justification.
  rationale: Offset promises justify imports despite efficiency losses.
- change_id: CHG_124
  change_type: assignment
  theme_id: PM34
  mechanism_id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_005
  summary: Assigned to PM34 (erosion of design capability).
  rationale: Offset-dependent work reduces design and integration capability over time.
- change_id: CHG_125
  change_type: new_theme
  theme_id: PM62
  mechanism_id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_006
  summary: Created PM62 for early partnership enabling high-tech roles.
  rationale: Early partnership with competitive allocation grants access to high-tech roles with approvals.
- change_id: CHG_126
  change_type: new_theme
  theme_id: PM63
  mechanism_id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_007
  summary: Created PM63 for partnership structures shaping risk exposure.
  rationale: Exclusive partnerships create win–lose exposure; multi-team hedges risk.
- change_id: CHG_127
  change_type: assignment
  theme_id: PM15
  mechanism_id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_008
  summary: Assigned to PM15 (set-asides reduce flexibility).
  rationale: Strategic best-value set-asides adjust allocation under political pressure.
- change_id: CHG_128
  change_type: new_theme
  theme_id: PM64
  mechanism_id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_009
  summary: Created PM64 for IP studies as biased marketing signals.
  rationale: Contractor-provided IP studies function as marketing and are subject to bias.
- change_id: CHG_129
  change_type: new_theme
  theme_id: PM65
  mechanism_id: 08_offsets_and_the_joint_strike_fighter_in_the_uk_and_the_netherlands_pdf__cmo_010
  summary: Created PM65 for partnership packages building durable collaboration.
  rationale: Broader packages aim for durable collaboration beyond offset compliance.
- change_id: CHG_130
  change_type: new_theme
  theme_id: PM66
  mechanism_id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_001
  summary: Created PM66 for offsets as import compensation.
  rationale: Rising imports trigger compensatory offset requirements.
- change_id: CHG_131
  change_type: assignment
  theme_id: PM46
  mechanism_id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_002
  summary: Assigned to PM46 (absorptive capacity constraints).
  rationale: Limited domestic capacity constrains absorption, prompting lower targets.
- change_id: CHG_132
  change_type: assignment
  theme_id: PM10
  mechanism_id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_003
  summary: Assigned to PM10 (offsets as competitive tool).
  rationale: Offsets and credits are used competitively, making policies more specific.
- change_id: CHG_133
  change_type: assignment
  theme_id: PM7
  mechanism_id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_004
  summary: Assigned to PM7 (sustaining skills and support capability).
  rationale: Offsets in development/manufacture maintain skills and lifecycle support.
- change_id: CHG_134
  change_type: assignment
  theme_id: PM2
  mechanism_id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_005
  summary: Assigned to PM2 (limiting multiplier inflation).
  rationale: Case-by-case multiplier evaluation limits inflated credit values.
- change_id: CHG_135
  change_type: assignment
  theme_id: PM2
  mechanism_id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_006
  summary: Assigned to PM2 (banking limits).
  rationale: Restrictions on banking preserve procurement-delivery coupling.
- change_id: CHG_136
  change_type: assignment
  theme_id: PM2
  mechanism_id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_007
  summary: Assigned to PM2 (sanctions as enforcement).
  rationale: Blacklisting/withheld payments/sanctions incentivize compliance.
- change_id: CHG_137
  change_type: assignment
  theme_id: PM15
  mechanism_id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_008
  summary: Assigned to PM15 (exclude offsets from supplier selection).
  rationale: Offsets barred from selection prevent distortion of capability choice.
- change_id: CHG_138
  change_type: assignment
  theme_id: PM36
  mechanism_id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_009
  summary: Assigned to PM36 (supply-chain integration).
  rationale: Offsets tied to exports integrate firms into international supply chains.
- change_id: CHG_139
  change_type: assignment
  theme_id: PM15
  mechanism_id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_010
  summary: Assigned to PM15 (paid subcontracting reduces influence).
  rationale: Commercial subcontracting reduces influence and participation.
- change_id: CHG_140
  change_type: assignment
  theme_id: PM2
  mechanism_id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_011
  summary: Assigned to PM2 (audit difficulty from complexity).
  rationale: Heterogeneous arrangements decouple headline percentages from delivery.
- change_id: CHG_141
  change_type: assignment
  theme_id: PM15
  mechanism_id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_012
  summary: Assigned to PM15 (policy relaxation after poor returns).
  rationale: High costs and low gains drive relaxation of offset requirements.
- change_id: CHG_142
  change_type: assignment
  theme_id: PM10
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_001
  summary: Assigned to PM10 (offset package competition).
  rationale: Firms compete on offsets and buyers leverage that competition.
- change_id: CHG_143
  change_type: new_theme
  theme_id: PM74
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_002
  summary: Created PM74 for disclosure constraints obscuring evaluation.
  rationale: Limited data access and vested interests constrain disclosure.
- change_id: CHG_144
  change_type: new_theme
  theme_id: PM75
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_003
  summary: Created PM75 for counterfactual uncertainty undermining additionality.
  rationale: Unknown counterfactuals create fundamental uncertainty about additionality.
- change_id: CHG_145
  change_type: new_theme
  theme_id: PM76
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_004
  summary: Created PM76 for compliance risk increasing prices.
  rationale: Suppliers raise prices to insure against penalties and compliance risks.
- change_id: CHG_146
  change_type: new_theme
  theme_id: PM77
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_005
  summary: Created PM77 for heterogeneity limiting generalization.
  rationale: Different offset types require different evaluation methods.
- change_id: CHG_147
  change_type: assignment
  theme_id: PM2
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_006
  summary: Assigned to PM2 (fulfillment inflation).
  rationale: Multiplier pricing and advance crediting inflate fulfillment.
- change_id: CHG_148
  change_type: new_theme
  theme_id: PM78
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_007
  summary: Created PM78 for exports concentrating in incumbents.
  rationale: Offset exports concentrate in existing relations and large exporters.
- change_id: CHG_149
  change_type: assignment
  theme_id: PM17
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_008
  summary: Assigned to PM17 (monitoring burden).
  rationale: High management burdens drive labor-intensive monitoring and artificial projects.
- change_id: CHG_150
  change_type: assignment
  theme_id: PM52
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_009
  summary: Assigned to PM52 (questionable value of 100% offsets).
  rationale: Uncertain additionality and costs make full offsets low-value.
- change_id: CHG_151
  change_type: new_theme
  theme_id: PM80
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_010
  summary: Created PM80 for firm gains with weak national benefit.
  rationale: Firm-level gains can coexist with weak national net benefit.
- change_id: CHG_152
  change_type: no_change
  theme_id: ALL
  summary: Split/merge audit found no clear changes; themes retained as-is.
  rationale: Reviewed labels and mechanism explanations for overlap or internal incoherence; none met merge/split criteria.
  details:
    merged_from: []
    split_into: []
    retained_as_is:
    - PM1
    - PM2
    - PM3
    - PM4
    - PM5
    - PM6
    - PM7
    - PM8
    - PM9
    - PM10
    - PM11
    - PM12
    - PM13
    - PM14
    - PM15
    - PM16
    - PM17
    - PM18
    - PM19
    - PM20
    - PM21
    - PM22
    - PM23
    - PM24
    - PM25
    - PM26
    - PM27
    - PM28
    - PM29
    - PM30
    - PM31
    - PM32
    - PM33
    - PM34
    - PM35
    - PM36
    - PM37
    - PM38
    - PM39
    - PM40
    - PM41
    - PM42
    - PM43
    - PM44
    - PM45
    - PM46
    - PM47
    - PM48
    - PM49
    - PM50
    - PM51
    - PM52
    - PM53
    - PM54
    - PM55
    - PM56
    - PM57
    - PM58
    - PM59
    - PM60
    - PM61
    - PM62
    - PM63
    - PM64
    - PM65
    - PM66
    - PM67
    - PM68
    - PM69
    - PM70
    - PM71
    - PM72
    - PM73
    - PM74
    - PM75
    - PM76
    - PM77
    - PM78
    - PM79
    - PM80
- change_id: CHG_153
  change_type: assignment
  theme_id: PM7
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_011
  summary: Assigned to PM7 (compensatory work sustains production).
  rationale: Offsets link imports to compensatory work that sustains employment.
- change_id: CHG_154
  change_type: assignment
  theme_id: PM77
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_012
  summary: Assigned to PM77 (indirect offsets complicate evaluation).
  rationale: Indirect offsets obscure causal attribution compared to direct offsets.
- change_id: CHG_155
  change_type: assignment
  theme_id: PM2
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_013
  summary: Assigned to PM2 (retroactive crediting and preferential treatment).
  rationale: Vague criteria enable retroactive crediting and reduce competition.
- change_id: CHG_156
  change_type: assignment
  theme_id: PM2
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_014
  summary: Assigned to PM2 (criteria improve transparency).
  rationale: Specific criteria, competitive bidding, and monitoring improve transparency.
- change_id: CHG_157
  change_type: new_theme
  theme_id: PM81
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_015
  summary: Created PM81 for extending activity beyond program life.
  rationale: Indirect offsets are used to extend industrial activity beyond a program.
- change_id: CHG_158
  change_type: assignment
  theme_id: PM7
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_016
  summary: Assigned to PM7 (focus on defence tech competence).
  rationale: Military offsets in prioritized tech fields aim to secure long-term competence.
- change_id: CHG_159
  change_type: assignment
  theme_id: PM7
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_017
  summary: Assigned to PM7 (direct offsets build maintenance capacity).
  rationale: Direct military offsets build local maintenance and modification capacity.
- change_id: CHG_160
  change_type: assignment
  theme_id: PM7
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_018
  summary: Assigned to PM7 (targeted indirect offsets sustain competence).
  rationale: Indirect offsets targeted to tech fields sustain defence competence.
- change_id: CHG_161
  change_type: assignment
  theme_id: PM54
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_001
  summary: Assigned to PM54 (capability sustainment via compensatory work).
  rationale: Compensatory work and know-how transfer channel resources to domestic capability.
- change_id: CHG_162
  change_type: assignment
  theme_id: PM24
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_002
  summary: Assigned to PM24 (indirect offsets stimulate non-military activity).
  rationale: Indirect compensations redirect activity into non-military sectors.
- change_id: CHG_163
  change_type: assignment
  theme_id: PM2
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_003
  summary: Assigned to PM2 (additionality unreliable).
  rationale: Relabeled or low-quality projects undermine additionality.
- change_id: CHG_164
  change_type: assignment
  theme_id: PM5
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_004
  summary: Assigned to PM5 (access to specialized know-how).
  rationale: Offset-linked investments provide access to specialized production and know-how.
- change_id: CHG_165
  change_type: assignment
  theme_id: PM1
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_005
  summary: Assigned to PM1 (coalition-building legitimation).
  rationale: Offsets generate supportive coalitions that reduce resistance.
- change_id: CHG_166
  change_type: assignment
  theme_id: PM3
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_006
  summary: Assigned to PM3 (cost pass-through).
  rationale: Offset-related administrative and production costs are passed through in prices.
- change_id: CHG_167
  change_type: assignment
  theme_id: PM4
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_007
  summary: Assigned to PM4 (sunk costs and excess capacity).
  rationale: Short-run infrastructure creates sunk costs and excess capacity.
- change_id: CHG_168
  change_type: assignment
  theme_id: PM34
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_008
  summary: Assigned to PM34 (disrupted learning from timing volatility).
  rationale: Unpredictable timing disrupts planning and forces repeated learning restarts.
- change_id: CHG_169
  change_type: assignment
  theme_id: PM23
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_009
  summary: Assigned to PM23 (benefits end post-fulfillment).
  rationale: Subcontracting benefits end when obligations finish.
- change_id: CHG_170
  change_type: assignment
  theme_id: PM17
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_010
  summary: Assigned to PM17 (lobbying entrenches inefficiency).
  rationale: Firm lobbying sustains protections and delays reform.
- change_id: CHG_171
  change_type: assignment
  theme_id: PM15
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_011
  summary: Assigned to PM15 (late procurement limits collaboration).
  rationale: Late procurement shifts offsets toward subcontracting rather than R&D collaboration.
- change_id: CHG_172
  change_type: assignment
  theme_id: PM2
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_012
  summary: Assigned to PM2 (banked pre-compensations).
  rationale: Pre-compensation credits count normal trade flows against obligations.
- change_id: CHG_173
  change_type: assignment
  theme_id: PM3
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_013
  summary: Assigned to PM3 (overhead priced into contracts).
  rationale: Offset overhead and transfer costs are priced into contracts.
- change_id: CHG_174
  change_type: assignment
  theme_id: PM17
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_014
  summary: Assigned to PM17 (regional rent-seeking).
  rationale: Regional quota politics steer work to satisfy rent-seeking groups.
- change_id: CHG_175
  change_type: assignment
  theme_id: PM36
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_015
  summary: Assigned to PM36 (structural cooperation shifts incentives).
  rationale: Structural cooperation shifts incentives to long-term specialization.
- change_id: CHG_176
  change_type: assignment
  theme_id: PM30
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_016
  summary: Assigned to PM30 (distorted restructuring).
  rationale: Offsets subsidize uncompetitive firms and distort restructuring.
- change_id: CHG_177
  change_type: assignment
  theme_id: PM15
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_017
  summary: Assigned to PM15 (tie-break caps reduce reliance).
  rationale: Limiting offsets to tie-breaks reduces reliance while preserving compromise.
- change_id: CHG_178
  change_type: assignment
  theme_id: PM36
  mechanism_id: 11_offsets_in_belgium_between_scylla_and_charybdis_pdf__cmo_018
  summary: Assigned to PM36 (short-run work weakens cooperation).
  rationale: Offsets provide short-run work but reduce incentives for sustained cooperation.
- change_id: CHG_179
  change_type: assignment
  theme_id: PM9
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_001
  summary: Assigned to PM9 (countertrade familiarity).
  rationale: Familiarity with countertrade supports compensatory arrangements.
- change_id: CHG_180
  change_type: assignment
  theme_id: PM36
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_002
  summary: Assigned to PM36 (linking imports to supply-chain transformation).
  rationale: Offsets tie interoperability-driven imports to domestic industrial transformation.
- change_id: CHG_181
  change_type: assignment
  theme_id: PM21
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_003
  summary: Assigned to PM21 (procurement access conditioned on compensations).
  rationale: Access is conditioned on delivering industrial work and tech benefits.
- change_id: CHG_182
  change_type: assignment
  theme_id: PM15
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_004
  summary: Assigned to PM15 (mandatory direct-offset shares).
  rationale: Direct-offset requirements force local content structures.
- change_id: CHG_183
  change_type: assignment
  theme_id: PM2
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_005
  summary: Assigned to PM2 (multiplier inflation).
  rationale: High multipliers inflate credited values beyond actual costs.
- change_id: CHG_184
  change_type: assignment
  theme_id: PM2
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_006
  summary: Assigned to PM2 (penalty-backed enforcement).
  rationale: Non-terminable agreements and damages raise compliance costs.
- change_id: CHG_185
  change_type: assignment
  theme_id: PM17
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_007
  summary: Assigned to PM17 (reduced oversight).
  rationale: Disclosure/appeal exemptions reduce oversight.
- change_id: CHG_186
  change_type: assignment
  theme_id: PM36
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_008
  summary: Assigned to PM36 (local partner requirements).
  rationale: Local partner requirements create domestic industrial ties.
- change_id: CHG_187
  change_type: assignment
  theme_id: PM2
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_009
  summary: Assigned to PM2 (project specificity reduces discretion).
  rationale: Parallel bargaining and specified projects lock suppliers into deliverables.
- change_id: CHG_188
  change_type: assignment
  theme_id: PM2
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_010
  summary: Assigned to PM2 (credit decoupled from effort).
  rationale: Administrative crediting decouples credited value from real effort.
- change_id: CHG_189
  change_type: assignment
  theme_id: PM36
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_011
  summary: Assigned to PM36 (competency building and integration).
  rationale: Offsets build competencies and integrate firms into allied division of labor.
- change_id: CHG_190
  change_type: assignment
  theme_id: PM2
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_012
  summary: Assigned to PM2 (nominal/net/gross gaps).
  rationale: Valuation conventions create large reporting gaps.
- change_id: CHG_191
  change_type: assignment
  theme_id: PM2
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_013
  summary: Assigned to PM2 (hard commitments).
  rationale: Specific obligations reduce supplier discretion.
- change_id: CHG_192
  change_type: assignment
  theme_id: PM15
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_014
  summary: Assigned to PM15 (composition target divergence).
  rationale: Negotiation constraints can diverge from statutory composition targets.
- change_id: CHG_193
  change_type: assignment
  theme_id: PM2
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_015
  summary: Assigned to PM2 (low penalties enable non-compliance).
  rationale: Low liquidated damages make non-performance rational.
- change_id: CHG_194
  change_type: assignment
  theme_id: PM7
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_016
  summary: Assigned to PM7 (local sourcing expands footprint).
  rationale: Buyback and local sourcing expand domestic industrial footprint.
- change_id: CHG_195
  change_type: assignment
  theme_id: PM7
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_017
  summary: Assigned to PM7 (progressive localization).
  rationale: Transfer/training enable progressive localization of production.
- change_id: CHG_196
  change_type: assignment
  theme_id: PM24
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_018
  summary: Assigned to PM24 (unrelated compensations).
  rationale: Offsets can compel unrelated technology projects and commodity purchases.
- change_id: CHG_197
  change_type: assignment
  theme_id: PM15
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_019
  summary: Assigned to PM15 (protective direct offsets with scrutiny).
  rationale: Direct offsets act as protection; scrutiny narrows promise-delivery gaps.
- change_id: CHG_198
  change_type: assignment
  theme_id: PM34
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_020
  summary: Assigned to PM34 (insufficient demand to sustain skills).
  rationale: Small orders and limited exports undermine sustained production.
- change_id: CHG_199
  change_type: assignment
  theme_id: PM54
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_001
  summary: Assigned to PM54 (licensed production and JV acquisition).
  rationale: Licensed production and joint ventures build domestic capability.
- change_id: CHG_200
  change_type: assignment
  theme_id: PM54
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_002
  summary: Assigned to PM54 (transfer requirements).
  rationale: Technology-transfer requirements steer suppliers to deliver know-how.
- change_id: CHG_201
  change_type: assignment
  theme_id: PM46
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_003
  summary: Assigned to PM46 (absorptive capacity).
  rationale: Strong R&D and human capital increase absorption.
- change_id: CHG_202
  change_type: assignment
  theme_id: PM19
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_004
  summary: Assigned to PM19 (JV knowledge transmission).
  rationale: Joint ventures transmit technology through sustained interaction.
- change_id: CHG_203
  change_type: assignment
  theme_id: PM34
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_005
  summary: Assigned to PM34 (insufficient demand for scale).
  rationale: Domestic demand shortfalls force reliance on exports to sustain production.
- change_id: CHG_204
  change_type: assignment
  theme_id: PM34
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_006
  summary: Assigned to PM34 (demand collapse erodes capability).
  rationale: Loss of key customers reduces demand and erodes the learning base.
- change_id: CHG_205
  change_type: assignment
  theme_id: PM34
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_007
  summary: Assigned to PM34 (alignment shifts cancel purchases).
  rationale: Shifts in alignments lead to sunk costs and canceled orders.
- change_id: CHG_206
  change_type: assignment
  theme_id: PM34
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_008
  summary: Assigned to PM34 (civil pivot preserves capability).
  rationale: Firms pivot to civil products to preserve capabilities when demand falls.
- change_id: CHG_207
  change_type: assignment
  theme_id: PM19
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_009
  summary: Assigned to PM19 (learning-by-doing).
  rationale: Repeated interactions and training accelerate learning-by-doing.
- change_id: CHG_208
  change_type: assignment
  theme_id: PM19
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_010
  summary: Assigned to PM19 (technology objectives align negotiations).
  rationale: Explicit objectives align negotiations around modernization.
- change_id: CHG_209
  change_type: assignment
  theme_id: PM15
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_011
  summary: Assigned to PM15 (flexible negotiation).
  rationale: Flexible norms tailor packages to capacity rather than rigid ratios.
- change_id: CHG_210
  change_type: assignment
  theme_id: PM21
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_012
  summary: Assigned to PM21 (100% offset rule leverage).
  rationale: Full-compensation rule increases bargaining leverage.
- change_id: CHG_211
  change_type: assignment
  theme_id: PM19
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_013
  summary: Assigned to PM19 (tacit skills transfer).
  rationale: Specialists and training transfer tacit production knowledge.
- change_id: CHG_212
  change_type: assignment
  theme_id: PM19
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_014
  summary: Assigned to PM19 (embedded standards).
  rationale: Component production and training embed supplier standards.
- change_id: CHG_213
  change_type: assignment
  theme_id: PM7
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_015
  summary: Assigned to PM7 (focus on high-value autonomy).
  rationale: Focus on key technologies builds autonomy while avoiding inefficient local production.
- change_id: CHG_214
  change_type: assignment
  theme_id: PM34
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_016
  summary: Assigned to PM34 (viability without exports).
  rationale: Advanced competencies transfer but lack of export demand raises unit costs.
- change_id: CHG_215
  change_type: assignment
  theme_id: PM7
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_017
  summary: Assigned to PM7 (software autonomy).
  rationale: Domestic software/training entities increase autonomy over system evolution.
- change_id: CHG_216
  change_type: assignment
  theme_id: PM2
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_018
  summary: Assigned to PM2 (multipliers steer effort).
  rationale: Multipliers steer supplier effort toward capability-building deliverables.
- change_id: CHG_217
  change_type: assignment
  theme_id: PM7
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_019
  summary: Assigned to PM7 (sustainment control).
  rationale: Reinvestment and transfer requirements increase buyer control over sustainment.
- change_id: CHG_218
  change_type: assignment
  theme_id: PM21
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_020
  summary: Assigned to PM21 (advanced-tech transfer condition).
  rationale: Market access conditioned on advanced tech transfer.
- change_id: CHG_219
  change_type: assignment
  theme_id: PM34
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_021
  summary: Assigned to PM34 (small orders undermine viability).
  rationale: Fixed costs of assembly cannot be spread without exports.
- change_id: CHG_220
  change_type: assignment
  theme_id: PM34
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_022
  summary: Assigned to PM34 (assembly-only licensing stalls absorption).
  rationale: Assembly-focused licensing without engineering stalls absorption.
- change_id: CHG_221
  change_type: assignment
  theme_id: PM34
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_023
  summary: Assigned to PM34 (complex collaboration cost inflation).
  rationale: Complex collaboration without exports drives costs and delays.
- change_id: CHG_222
  change_type: assignment
  theme_id: PM34
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_001
  summary: Assigned to PM34 (scale economies erode).
  rationale: Shrinking quantities undermine scale economies.
- change_id: CHG_223
  change_type: assignment
  theme_id: PM34
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_002
  summary: Assigned to PM34 (imports replace non-competitive domestic output).
  rationale: Small-scale domestic production cannot compete on cost.
- change_id: CHG_224
  change_type: assignment
  theme_id: PM34
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_003
  summary: Assigned to PM34 (fiscal tightening stalls maturation).
  rationale: Subsidies and demand fall prevent infant industry maturation.
- change_id: CHG_225
  change_type: assignment
  theme_id: PM36
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_004
  summary: Assigned to PM36 (asset concessions shift responsibility).
  rationale: Asset concessions shift operational responsibilities to private actors.
- change_id: CHG_226
  change_type: assignment
  theme_id: PM36
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_005
  summary: Assigned to PM36 (concessions sustain maintenance).
  rationale: Concession contracts sustain maintenance/upgrade facilities.
- change_id: CHG_227
  change_type: assignment
  theme_id: PM3
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_006
  summary: Assigned to PM3 (currency risk raises costs).
  rationale: Currency devaluation increases contract risk and renegotiation.
- change_id: CHG_228
  change_type: assignment
  theme_id: PM34
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_007
  summary: Assigned to PM34 (supportability undermines exports).
  rationale: Limited spares guarantees reduce confidence and export credibility.
- change_id: CHG_229
  change_type: assignment
  theme_id: PM34
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_008
  summary: Assigned to PM34 (human capital loss).
  rationale: Loss of specialized human capital degrades quality and credibility.
- change_id: CHG_230
  change_type: assignment
  theme_id: PM34
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_009
  summary: Assigned to PM34 (scale requires exports).
  rationale: High unit costs persist without large orders and export markets.
- change_id: CHG_231
  change_type: assignment
  theme_id: PM34
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_010
  summary: Assigned to PM34 (small fleet sizes raise costs).
  rationale: Small fleets raise unit costs and undermine sustainment economics.
- change_id: CHG_232
  change_type: assignment
  theme_id: PM34
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_011
  summary: Assigned to PM34 (no regional pooling).
  rationale: Lack of coordination prevents pooled demand and scale economies.
- change_id: CHG_233
  change_type: assignment
  theme_id: PM2
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_012
  summary: Assigned to PM2 (skilled negotiation reduces asymmetry).
  rationale: Knowledgeable negotiators reduce information asymmetry.
- change_id: CHG_234
  change_type: assignment
  theme_id: PM7
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_013
  summary: Assigned to PM7 (targeted transfer within partial dependence).
  rationale: Accepting partial dependence and targeted transfer avoids misallocation.
- change_id: CHG_235
  change_type: assignment
  theme_id: PM7
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_001
  summary: Assigned to PM7 (procurement-linked capability building).
  rationale: Licensed production and transfer build capability and manage FX constraints.
- change_id: CHG_236
  change_type: assignment
  theme_id: PM5
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_002
  summary: Assigned to PM5 (credit eases FX constraint).
  rationale: Long-term credit/countertrade eases hard-currency constraints.
- change_id: CHG_237
  change_type: assignment
  theme_id: PM34
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_003
  summary: Assigned to PM34 (absorption delays/costs).
  rationale: Absorption difficulties raise costs and delays beyond imports.
- change_id: CHG_238
  change_type: assignment
  theme_id: PM19
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_004
  summary: Assigned to PM19 (learning-by-doing).
  rationale: Sustained production builds technical base.
- change_id: CHG_239
  change_type: assignment
  theme_id: PM19
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_005
  summary: Assigned to PM19 (mid-level competence only).
  rationale: Incremental transfer builds competence but not frontier gaps.
- change_id: CHG_240
  change_type: assignment
  theme_id: PM8
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_006
  summary: Assigned to PM8 (withheld core tech).
  rationale: Supplier withholding constrains independent capability.
- change_id: CHG_241
  change_type: assignment
  theme_id: PM34
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_007
  summary: Assigned to PM34 (buyback unattractive).
  rationale: Domestic producers cannot meet expectations, limiting exports.
- change_id: CHG_242
  change_type: assignment
  theme_id: PM36
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_008
  summary: Assigned to PM36 (capacity boosts leverage).
  rationale: Indigenous capacity increases bargaining leverage.
- change_id: CHG_243
  change_type: assignment
  theme_id: PM34
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_009
  summary: Assigned to PM34 (imports reduce R&D incentives).
  rationale: Easy imports reduce incentives for indigenous R&D.
- change_id: CHG_244
  change_type: assignment
  theme_id: PM3
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_010
  summary: Assigned to PM3 (credit priced into higher prices).
  rationale: Supplier credit is priced into higher selling prices.
- change_id: CHG_245
  change_type: assignment
  theme_id: PM9
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_011
  summary: Assigned to PM9 (countertrade expands exports).
  rationale: Commodity trade expands exports without hard currency.
- change_id: CHG_246
  change_type: assignment
  theme_id: PM9
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_012
  summary: Assigned to PM9 (countertrade hidden costs).
  rationale: Unfavorable FX terms create hidden costs and debt burdens.
- change_id: CHG_247
  change_type: assignment
  theme_id: PM34
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_013
  summary: Assigned to PM34 (imported input demand).
  rationale: Domestic industry expansion raises imported input demand and FX needs.
- change_id: CHG_248
  change_type: assignment
  theme_id: PM34
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_014
  summary: Assigned to PM34 (credit encourages overbuying).
  rationale: Easy credit encourages larger procurement and debt burdens.
- change_id: CHG_249
  change_type: assignment
  theme_id: PM17
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_015
  summary: Assigned to PM17 (corruption undermines legitimacy).
  rationale: Corruption scandals derail offset and transfer components.
- change_id: CHG_250
  change_type: assignment
  theme_id: PM7
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_016
  summary: Assigned to PM7 (technology assistance supports development).
  rationale: Technology-assistance offsets can support domestic development.
- change_id: CHG_251
  change_type: assignment
  theme_id: PM15
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_017
  summary: Assigned to PM15 (align offsets with diversification).
  rationale: Offsets integrated with diversification/R&D reduce burdens.
- change_id: CHG_252
  change_type: assignment
  theme_id: PM1
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_001
  summary: Assigned to PM1 (offset inducements reinforce alliances).
  rationale: Offsets as inducements reinforce alliances and interoperability.
- change_id: CHG_253
  change_type: assignment
  theme_id: PM7
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_002
  summary: Assigned to PM7 (spillovers and substitutes).
  rationale: Transfers/work share enable domestic substitutes and commercial spillovers.
- change_id: CHG_254
  change_type: assignment
  theme_id: PM36
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_003
  summary: Assigned to PM36 (pre-production buy-in).
  rationale: Allied buy-in shifts to pre-production workshare and transfer.
- change_id: CHG_255
  change_type: assignment
  theme_id: PM36
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_004
  summary: Assigned to PM36 (early integration).
  rationale: Joint development integrates allies early and builds interoperability.
- change_id: CHG_256
  change_type: assignment
  theme_id: PM7
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_005
  summary: Assigned to PM7 (licensed production benefits).
  rationale: Licensed production delivers industrial and political benefits.
- change_id: CHG_257
  change_type: assignment
  theme_id: PM7
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_006
  summary: Assigned to PM7 (domestic-first channels learning).
  rationale: Domestic-first procurement channels demand and learning into domestic firms.
- change_id: CHG_258
  change_type: assignment
  theme_id: PM7
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_007
  summary: Assigned to PM7 (domestic base supports sustainment/leverage).
  rationale: Advanced domestic base supports sustainment and bargaining leverage.
- change_id: CHG_259
  change_type: assignment
  theme_id: PM34
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_008
  summary: Assigned to PM34 (self-sufficiency becomes cost burden).
  rationale: Reduced demand and inflows lower utilization and make self-sufficiency costly.
- change_id: CHG_260
  change_type: assignment
  theme_id: PM15
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_009
  summary: Assigned to PM15 (policy constraints limit alliances).
  rationale: Policy constraints limit cross-national alliances and workshare models.
- change_id: CHG_261
  change_type: assignment
  theme_id: PM15
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_010
  summary: Assigned to PM15 (domestic-first reduces workshare access).
  rationale: Domestic-first strategies reduce ability to buy into multinational workshare.
- change_id: CHG_262
  change_type: assignment
  theme_id: PM36
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_011
  summary: Assigned to PM36 (policy shifts increase access).
  rationale: Loosened export restrictions increase access to transfers and workshare.
- change_id: CHG_263
  change_type: assignment
  theme_id: PM15
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_012
  summary: Assigned to PM15 (high offsets force participation).
  rationale: High offsets require participation and tech inputs to compete.
- change_id: CHG_264
  change_type: assignment
  theme_id: PM2
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_013
  summary: Assigned to PM2 (ban threats enforce delivery).
  rationale: Threat of banning contractors raises compliance incentives.
- change_id: CHG_265
  change_type: assignment
  theme_id: PM7
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_014
  summary: Assigned to PM7 (embedded transfers build capability).
  rationale: Embedded transfers build manufacturing/integration capability.
- change_id: CHG_266
  change_type: assignment
  theme_id: PM17
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_015
  summary: Assigned to PM17 (decision distortion risk).
  rationale: Incomplete information and corruption can distort decisions.
- change_id: CHG_267
  change_type: assignment
  theme_id: PM34
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_016
  summary: Assigned to PM34 (diffusion fails under underutilization).
  rationale: Underutilization limits diffusion and maintains dependence on foreign spares.
- change_id: CHG_268
  change_type: assignment
  theme_id: PM36
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_017
  summary: Assigned to PM36 (consolidation/JVs boost efficiency).
  rationale: Consolidation and JVs increase efficiency and access to capital/tech/markets.
- change_id: CHG_269
  change_type: assignment
  theme_id: PM1
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_018
  summary: Assigned to PM1 (alliance signalling).
  rationale: Offsets and arms sales reinforce alliance signals.
- change_id: CHG_270
  change_type: assignment
  theme_id: PM15
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_019
  summary: Assigned to PM15 (targeted cooperation).
  rationale: Coordinated procedures steer cooperation toward selected sectors.
- change_id: CHG_271
  change_type: assignment
  theme_id: PM8
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_020
  summary: Assigned to PM8 (political constraints limit transfer).
  rationale: Political constraints limit depth of transfer and capability.
- change_id: CHG_272
  change_type: assignment
  theme_id: PM7
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_021
  summary: Assigned to PM7 (maintenance infrastructure).
  rationale: Offsets establish maintenance/repair infrastructure and contracts.
- change_id: CHG_273
  change_type: assignment
  theme_id: PM34
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_022
  summary: Assigned to PM34 (weak diffusion limits gains).
  rationale: Weak diffusion pathways limit multiplier effects.
- change_id: CHG_274
  change_type: assignment
  theme_id: PM36
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_023
  summary: Assigned to PM36 (drivers sustain offsets/workshare).
  rationale: Drivers keep transfer/workshare features in contracts.
- change_id: CHG_275
  change_type: assignment
  theme_id: PM15
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_024
  summary: Assigned to PM15 (rigid domestic-first impedes alliances).
  rationale: Domestic-first strategies impede alliances and technology inflows.
- change_id: CHG_276
  change_type: assignment
  theme_id: PM7
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_001
  summary: Assigned to PM7 (licensed production shortens learning).
  rationale: Licensed production and transfer shorten learning timelines.
- change_id: CHG_277
  change_type: assignment
  theme_id: PM15
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_002
  summary: Assigned to PM15 (objectives shape offset selection).
  rationale: National objectives shape selection between broad vs targeted transfer.
- change_id: CHG_278
  change_type: assignment
  theme_id: PM7
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_003
  summary: Assigned to PM7 (state-backed capability building).
  rationale: State-backed offsets build domestic tech, skills, and infrastructure.
- change_id: CHG_279
  change_type: assignment
  theme_id: PM7
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_004
  summary: Assigned to PM7 (compressed mastery via transfer).
  rationale: Offsets acquire expertise to compress mastery timelines.
- change_id: CHG_280
  change_type: assignment
  theme_id: PM19
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_005
  summary: Assigned to PM19 (learning-by-doing sequencing).
  rationale: Final-assembly-first enables learning-by-doing and deepening.
- change_id: CHG_281
  change_type: assignment
  theme_id: PM19
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_006
  summary: Assigned to PM19 (skill accumulation).
  rationale: Licensed production accumulates workforce skills and responsibilities.
- change_id: CHG_282
  change_type: assignment
  theme_id: PM19
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_007
  summary: Assigned to PM19 (JV co-development transfer).
  rationale: JV co-development transfers know-how and creates exportable products.
- change_id: CHG_283
  change_type: assignment
  theme_id: PM8
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_008
  summary: Assigned to PM8 (foreign component dependence).
  rationale: Reliance on foreign components constrains autonomy.
- change_id: CHG_284
  change_type: assignment
  theme_id: PM34
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_009
  summary: Assigned to PM34 (subsidized demand misalignment).
  rationale: Guaranteed demand expands scale despite weak user fit.
- change_id: CHG_285
  change_type: assignment
  theme_id: PM34
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_010
  summary: Assigned to PM34 (subsidies reduce discipline).
  rationale: Subsidies create excess capacity and debt.
- change_id: CHG_286
  change_type: assignment
  theme_id: PM34
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_011
  summary: Assigned to PM34 (certification blocks exports).
  rationale: No FAA certification blocks export revenue.
- change_id: CHG_287
  change_type: assignment
  theme_id: PM34
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_012
  summary: Assigned to PM34 (external conditionality).
  rationale: External conditionality cuts subsidies and forces restructuring.
- change_id: CHG_288
  change_type: assignment
  theme_id: PM7
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_013
  summary: Assigned to PM7 (targeted MRO capability).
  rationale: Targeted transfer builds MRO readiness without autarky.
- change_id: CHG_289
  change_type: assignment
  theme_id: PM7
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_014
  summary: Assigned to PM7 (local MRO competencies).
  rationale: Transfer/training builds local maintenance competencies.
- change_id: CHG_290
  change_type: assignment
  theme_id: PM7
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_015
  summary: Assigned to PM7 (specialized repair capability).
  rationale: Specialized repair collaborations build sustainment capability.
- change_id: CHG_291
  change_type: assignment
  theme_id: PM19
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_016
  summary: Assigned to PM19 (licensed production leverage).
  rationale: Licensed production experience supports later indigenous design.
- change_id: CHG_292
  change_type: assignment
  theme_id: PM34
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_017
  summary: Assigned to PM34 (scale constraints).
  rationale: Scale constraints keep reliance on licensed production.
- change_id: CHG_293
  change_type: assignment
  theme_id: PM15
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_018
  summary: Assigned to PM15 (strategic sector focus).
  rationale: Strategic focus avoids autarky while maintaining competitiveness.
- change_id: CHG_294
  change_type: assignment
  theme_id: PM36
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_019
  summary: Assigned to PM36 (diversified revenue).
  rationale: Commercial subcontracting and MRO diversify revenues.
- change_id: CHG_295
  change_type: assignment
  theme_id: PM36
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_020
  summary: Assigned to PM36 (global tech/capital openness).
  rationale: JVs and acquisitions keep industry open to foreign tech.
- change_id: CHG_296
  change_type: assignment
  theme_id: PM2
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_001
  summary: Assigned to PM2 (compliance incentives).
  rationale: Mandated obligations and tracking strengthen compliance.
- change_id: CHG_297
  change_type: assignment
  theme_id: PM15
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_002
  summary: Assigned to PM15 (predictable targets).
  rationale: Fixed percentage targets guide contractor planning.
- change_id: CHG_298
  change_type: assignment
  theme_id: PM2
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_003
  summary: Assigned to PM2 (criteria/multipliers steer effort).
  rationale: Criteria and multipliers steer suppliers toward high-valued activities.
- change_id: CHG_299
  change_type: assignment
  theme_id: PM2
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_004
  summary: Assigned to PM2 (enforceable commitments).
  rationale: Deeds and damages increase follow-through.
- change_id: CHG_300
  change_type: assignment
  theme_id: PM7
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_005
  summary: Assigned to PM7 (self-reliance targeting).
  rationale: Targeted offsets focus on maintenance/spares and self-reliance.
- change_id: CHG_301
  change_type: assignment
  theme_id: PM36
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_006
  summary: Assigned to PM36 (export independence pressure).
  rationale: Export requirements pressure subsidiaries to demonstrate local commitment.
- change_id: CHG_302
  change_type: assignment
  theme_id: PM36
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_007
  summary: Assigned to PM36 (partnerships via AII plans).
  rationale: AII plans foster structured prime–subcontractor partnerships.
- change_id: CHG_303
  change_type: assignment
  theme_id: PM34
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_008
  summary: Assigned to PM34 (thin demand creates excess capacity).
  rationale: Thin demand and competition create excess capacity and high transaction costs.
- change_id: CHG_304
  change_type: assignment
  theme_id: PM7
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_009
  summary: Assigned to PM7 (alternative capability investments).
  rationale: SIDA investments deliver capability gains when local content is infeasible.
- change_id: CHG_305
  change_type: assignment
  theme_id: PM15
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_010
  summary: Assigned to PM15 (demand concentration stabilizes).
  rationale: Long-term sector plans and fewer primes stabilize workloads.
- change_id: CHG_306
  change_type: assignment
  theme_id: PM17
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_011
  summary: Assigned to PM17 (prime market power rents).
  rationale: Local prime controls compliance and can extract rents.
- change_id: CHG_307
  change_type: assignment
  theme_id: PM15
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_012
  summary: Assigned to PM15 (voluntary local participation).
  rationale: Voluntary offers align procurement with competitive niches.
- change_id: CHG_308
  change_type: assignment
  theme_id: PM36
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_013
  summary: Assigned to PM36 (sustained support relationships).
  rationale: Commercial relationships create pathways for sustained support.
- change_id: CHG_309
  change_type: assignment
  theme_id: PM2
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_014
  summary: Assigned to PM2 (multipliers + damages).
  rationale: Multipliers and damages increase compliance leverage.
- change_id: CHG_310
  change_type: assignment
  theme_id: PM7
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_015
  summary: Assigned to PM7 (directed business builds capability).
  rationale: Undertakings to direct business build local capability.
- change_id: CHG_311
  change_type: assignment
  theme_id: PM15
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_016
  summary: Assigned to PM15 (local value-added thresholds).
  rationale: Value-added thresholds steer toward genuine local production.
- change_id: CHG_312
  change_type: assignment
  theme_id: PM2
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_017
  summary: Assigned to PM2 (bank-and-trade flexibility).
  rationale: Credits/waivers create flexible banking to exceed targets.
- change_id: CHG_313
  change_type: assignment
  theme_id: PM36
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_018
  summary: Assigned to PM36 (combined industrial base).
  rationale: AU/NZ combined base enables cross-border allocation.
- change_id: CHG_314
  change_type: assignment
  theme_id: PM15
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_019
  summary: Assigned to PM15 (through-life support focus).
  rationale: Through-life support targets limited capacity to readiness functions.
- change_id: CHG_315
  change_type: assignment
  theme_id: PM15
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_020
  summary: Assigned to PM15 (partner access model).
  rationale: Access fees and competitiveness sourcing limit participation.
- change_id: CHG_316
  change_type: assignment
  theme_id: PM36
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_021
  summary: Assigned to PM36 (interoperability path dependence).
  rationale: Interoperability requirements reinforce US-led program paths.
- change_id: CHG_317
  change_type: assignment
  theme_id: PM17
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_022
  summary: Assigned to PM17 (metrics absence).
  rationale: No agreed outcomes/metrics undermines monitoring.
- change_id: CHG_318
  change_type: assignment
  theme_id: PM17
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_023
  summary: Assigned to PM17 (acquittal not equal gains).
  rationale: Acquittal categories do not ensure gains without assessment.
- change_id: CHG_319
  change_type: assignment
  theme_id: PM3
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_024
  summary: Assigned to PM3 (local-content premium).
  rationale: Local participation in assembly adds cost premium.
- change_id: CHG_320
  change_type: assignment
  theme_id: PM15
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_025
  summary: Assigned to PM15 (broad offsets undermine negotiations).
  rationale: Vague offsets can be counterproductive in negotiations.
- change_id: CHG_321
  change_type: assignment
  theme_id: PM1
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_001
  summary: Assigned to PM1 (public legitimation).
  rationale: Offsets framed as benefits shift public/political acceptance.
- change_id: CHG_322
  change_type: assignment
  theme_id: PM34
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_002
  summary: Assigned to PM34 (policy vacuum triggers diversification).
  rationale: Firms shift to non-defence work/exports in policy vacuum.
- change_id: CHG_323
  change_type: assignment
  theme_id: PM15
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_003
  summary: Assigned to PM15 (resource steering to niches).
  rationale: Policy steers resources toward niche firms and support capabilities.
- change_id: CHG_324
  change_type: assignment
  theme_id: PM3
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_004
  summary: Assigned to PM3 (hidden padding risk).
  rationale: No-price-increase rules are hard to verify, risking padding.
- change_id: CHG_325
  change_type: assignment
  theme_id: PM2
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_005
  summary: Assigned to PM2 (quantified obligations).
  rationale: Percent obligations and windows compel credit-generating projects.
- change_id: CHG_326
  change_type: assignment
  theme_id: PM17
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_006
  summary: Assigned to PM17 (split management burdens).
  rationale: Split management increases coordination burdens.
- change_id: CHG_327
  change_type: assignment
  theme_id: PM2
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_007
  summary: Assigned to PM2 (penalties vs performance).
  rationale: Suppliers may pay penalties rather than deliver projects.
- change_id: CHG_328
  change_type: assignment
  theme_id: PM15
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_008
  summary: Assigned to PM15 (indirect offsets broaden compliance).
  rationale: Indirect offsets broaden compliance space and dilute defence linkage.
- change_id: CHG_329
  change_type: assignment
  theme_id: PM19
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_009
  summary: Assigned to PM19 (learning-by-doing orders).
  rationale: Subcontracting/licensed production build niche capabilities.
- change_id: CHG_330
  change_type: assignment
  theme_id: PM8
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_010
  summary: Assigned to PM8 (low-tech allocation limits upgrading).
  rationale: Low-tech task allocation limits capability deepening.
- change_id: CHG_331
  change_type: assignment
  theme_id: PM36
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_011
  summary: Assigned to PM36 (equity/JV integration).
  rationale: Equity/JVs integrate firms into multinational networks.
- change_id: CHG_332
  change_type: assignment
  theme_id: PM36
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_012
  summary: Assigned to PM36 (subsidiary influence).
  rationale: Local subsidiaries leverage relationships in government dealings.
- change_id: CHG_333
  change_type: assignment
  theme_id: PM34
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_013
  summary: Assigned to PM34 (capability erosion).
  rationale: Capability erosion reduces quality/schedule performance.
- change_id: CHG_334
  change_type: assignment
  theme_id: PM34
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_014
  summary: Assigned to PM34 (quality/delay risks).
  rationale: Insufficient capability causes quality problems and delays.
- change_id: CHG_335
  change_type: assignment
  theme_id: PM36
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_015
  summary: Assigned to PM36 (capacity attracts JV/transfer).
  rationale: Existing capacity attracts JVs and supply-chain integration.
- change_id: CHG_336
  change_type: assignment
  theme_id: PM4
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_016
  summary: Assigned to PM4 (high cost per job).
  rationale: Capital-intensive offsets create few jobs per spend.
- change_id: CHG_337
  change_type: assignment
  theme_id: PM4
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_017
  summary: Assigned to PM4 (opportunity costs).
  rationale: Offsets reduce job creation compared to civilian spending.
- change_id: CHG_338
  change_type: assignment
  theme_id: PM17
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_018
  summary: Assigned to PM17 (political project selection).
  rationale: Political direction can override commercial viability.
- change_id: CHG_339
  change_type: assignment
  theme_id: PM17
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_019
  summary: Assigned to PM17 (lack of transparency).
  rationale: No reliable data prevents verification of net benefits.
- change_id: CHG_340
  change_type: assignment
  theme_id: PM46
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_020
  summary: Assigned to PM46 (absorptive capacity limits).
  rationale: Weak absorptive capacity limits embedding of transfers.
- change_id: CHG_341
  change_type: assignment
  theme_id: PM17
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_021
  summary: Assigned to PM17 (corruption vulnerability).
  rationale: Secrecy and commission-driven bargaining create corruption risks.
- change_id: CHG_342
  change_type: assignment
  theme_id: PM17
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_022
  summary: Assigned to PM17 (irregular practices).
  rationale: Investigations identify irregular practices and conflicts.
- change_id: CHG_343
  change_type: assignment
  theme_id: PM17
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_023
  summary: Assigned to PM17 (reduced scrutiny).
  rationale: Strategic-policy approval reduces procurement scrutiny.
- change_id: CHG_344
  change_type: assignment
  theme_id: PM17
  mechanism_id: 19_defense_industrial_participation_the_south_african_experience_pdf__cmo_024
  summary: Assigned to PM17 (unverifiable promises).
  rationale: Unverifiable offset promises leave high costs and limited benefits.
- change_id: CHG_345
  change_type: assignment
  theme_id: PM17
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_001
  summary: Assigned to PM17 (incoherent criteria).
  rationale: Incoherent selection criteria weaken regional development coherence.
- change_id: CHG_346
  change_type: assignment
  theme_id: PM17
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_002
  summary: Assigned to PM17 (default to narrower frameworks).
  rationale: Lack of comprehensive planning defaults to corridor approaches.
- change_id: CHG_347
  change_type: assignment
  theme_id: PM1
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_003
  summary: Assigned to PM1 (legitimation via job narratives).
  rationale: Job/investment narratives legitimate offsets as development tools.
- change_id: CHG_348
  change_type: assignment
  theme_id: PM17
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_004
  summary: Assigned to PM17 (coordination burden).
  rationale: Joint administration requires sustained coordination.
- change_id: CHG_349
  change_type: assignment
  theme_id: PM2
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_005
  summary: Assigned to PM2 (high percentage increases effort).
  rationale: High required percentages increase supplier effort to maximize credits.
- change_id: CHG_350
  change_type: assignment
  theme_id: PM2
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_006
  summary: Assigned to PM2 (ongoing renegotiation).
  rationale: Re-scoping adjusts project lists to meet credits/feasibility.
- change_id: CHG_351
  change_type: assignment
  theme_id: PM17
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_007
  summary: Assigned to PM17 (overstated estimates).
  rationale: Headline estimates overstate value-added without evaluation.
- change_id: CHG_352
  change_type: assignment
  theme_id: PM34
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_008
  summary: Assigned to PM34 (weak diffusion).
  rationale: Weak linkages limit regional development impacts.
- change_id: CHG_353
  change_type: assignment
  theme_id: PM34
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_009
  summary: Assigned to PM34 (lifeline but constrained autonomy).
  rationale: DIP-linked orders sustain firms but autonomy is constrained.
- change_id: CHG_354
  change_type: assignment
  theme_id: PM34
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_010
  summary: Assigned to PM34 (benefits concentrated).
  rationale: Business is channelled to existing locations, leaving periphery out.
- change_id: CHG_355
  change_type: assignment
  theme_id: PM46
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_011
  summary: Assigned to PM46 (limited social capital).
  rationale: Limited social/intellectual capital reduces transfer embedding.
- change_id: CHG_356
  change_type: assignment
  theme_id: PM46
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_012
  summary: Assigned to PM46 (overlooked local capability).
  rationale: Overlooking local capability reduces utilization and spin-offs.
- change_id: CHG_357
  change_type: assignment
  theme_id: PM17
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_013
  summary: Assigned to PM17 (vendor defaults to convenience).
  rationale: Insufficient pressure leads vendors to default to convenient regions/sectors.
- change_id: CHG_358
  change_type: assignment
  theme_id: PM2
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_014
  summary: Assigned to PM2 (credit inflation).
  rationale: Credit-maximizing investments inflate reported impacts.
- change_id: CHG_359
  change_type: assignment
  theme_id: PM5
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_015
  summary: Assigned to PM5 (liquidity via soft loans/equity).
  rationale: Soft loans/equity provide liquidity for survival and expansion.
- change_id: CHG_360
  change_type: assignment
  theme_id: PM17
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_016
  summary: Assigned to PM17 (reinforcing incumbents).
  rationale: Projects fit existing strengths and reinforce incumbent patterns.
- change_id: CHG_361
  change_type: assignment
  theme_id: PM1
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_017
  summary: Assigned to PM1 (inducements for bid choice).
  rationale: Promised regional benefits act as bid inducements.
- change_id: CHG_362
  change_type: assignment
  theme_id: PM17
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_018
  summary: Assigned to PM17 (political sustainment).
  rationale: Political/bureaucratic reasons sustain weak projects.
- change_id: CHG_363
  change_type: assignment
  theme_id: PM4
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_019
  summary: Assigned to PM4 (hidden costs).
  rationale: Capital-intensive IDZ projects require extra state incentives.
- change_id: CHG_364
  change_type: assignment
  theme_id: PM34
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_020
  summary: Assigned to PM34 (shipbuilding capability erosion).
  rationale: Shipbuilding capability erodes without directed offsets.
- change_id: CHG_365
  change_type: assignment
  theme_id: PM15
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_021
  summary: Assigned to PM15 (expectations and opportunity costs).
  rationale: Peer comparisons raise expectations and highlight opportunity costs.
- change_id: CHG_366
  change_type: assignment
  theme_id: PM4
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_022
  summary: Assigned to PM4 (input diversity boosts multipliers).
  rationale: More diverse inputs create larger local employment multipliers.
- change_id: CHG_367
  change_type: assignment
  theme_id: PM17
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_023
  summary: Assigned to PM17 (strategy misalignment).
  rationale: No integration with downstream strategies misses synergies.
- change_id: CHG_368
  change_type: assignment
  theme_id: PM15
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_024
  summary: Assigned to PM15 (internal capability tradeoffs).
  rationale: Specialty conversions create capability tradeoffs.
- change_id: CHG_369
  change_type: assignment
  theme_id: PM2
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_025
  summary: Assigned to PM2 (export credit inflation).
  rationale: Claiming full product value inflates export credit.
- change_id: CHG_370
  change_type: assignment
  theme_id: PM2
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_026
  summary: Assigned to PM2 (unclear additionality).
  rationale: Unclear additionality encourages narrative-driven reporting.
- change_id: CHG_371
  change_type: assignment
  theme_id: PM17
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_027
  summary: Assigned to PM17 (weak monitoring).
  rationale: Weak monitoring and hidden costs overstate benefits.
- change_id: CHG_372
  change_type: assignment
  theme_id: PM17
  mechanism_id: 20_defense_offsets_and_regional_development_in_south_africa_pdf__cmo_028
  summary: Assigned to PM17 (core project focus).
  rationale: Vendor discretion and core-project focus reinforce existing patterns.
- change_id: CHG_373
  change_type: assignment
  theme_id: PM21
  mechanism_id: 01_introduction_and_overview_pdf__cmo_001
  summary: Assigned to PM21 (offset obligations compel purchases).
  rationale: Offsets compel vendors to place additional purchases/investment locally.
- change_id: CHG_374
  change_type: assignment
  theme_id: PM36
  mechanism_id: 01_introduction_and_overview_pdf__cmo_002
  summary: Assigned to PM36 (pivot to inward investment).
  rationale: Packages pivot to inward investment and JVs to satisfy obligations.
- change_id: CHG_375
  change_type: assignment
  theme_id: PM17
  mechanism_id: 01_introduction_and_overview_pdf__cmo_003
  summary: Assigned to PM17 (limited disclosure).
  rationale: Limited disclosure impedes independent assessment.
- change_id: CHG_376
  change_type: assignment
  theme_id: PM15
  mechanism_id: 01_introduction_and_overview_pdf__cmo_004
  summary: Assigned to PM15 (shift to direct offsets).
  rationale: Poor indirect performance shifts emphasis to direct local content.
- change_id: CHG_377
  change_type: assignment
  theme_id: PM15
  mechanism_id: 01_introduction_and_overview_pdf__cmo_005
  summary: Assigned to PM15 (industrial benefits prioritized).
  rationale: Industrial benefits prioritized over military performance when security pressure is low.
- change_id: CHG_378
  change_type: assignment
  theme_id: PM30
  mechanism_id: 01_introduction_and_overview_pdf__cmo_006
  summary: Assigned to PM30 (political steering sustains inefficiency).
  rationale: Politically steered offsets sustain inefficient producers.
- change_id: CHG_379
  change_type: assignment
  theme_id: PM3
  mechanism_id: 01_introduction_and_overview_pdf__cmo_007
  summary: Assigned to PM3 (price premium pass-through).
  rationale: Offset cost premiums are priced into bids.
- change_id: CHG_380
  change_type: assignment
  theme_id: PM36
  mechanism_id: 01_introduction_and_overview_pdf__cmo_008
  summary: Assigned to PM36 (JV orientation to non-defence).
  rationale: Offsets steer JV capital to non-defence sectors with demand.
- change_id: CHG_381
  change_type: assignment
  theme_id: PM54
  mechanism_id: 01_introduction_and_overview_pdf__cmo_009
  summary: Assigned to PM54 (licensed production embeds capability).
  rationale: Licensed production transfers know-how despite price premium.
- change_id: CHG_382
  change_type: assignment
  theme_id: PM36
  mechanism_id: 01_introduction_and_overview_pdf__cmo_010
  summary: Assigned to PM36 (tolerated transfer for royalties/alliances).
  rationale: Exporters tolerate transfer for royalties and alliance gains.
- change_id: CHG_383
  change_type: assignment
  theme_id: PM1
  mechanism_id: 01_introduction_and_overview_pdf__cmo_011
  summary: Assigned to PM1 (capacity + diplomatic ties).
  rationale: Transfers build capacity and reinforce ties.
- change_id: CHG_384
  change_type: assignment
  theme_id: PM1
  mechanism_id: 01_introduction_and_overview_pdf__cmo_012
  summary: Assigned to PM1 (acceptability via domestic upgrading).
  rationale: Offsets improve acceptability by upgrading domestic capability.
- change_id: CHG_385
  change_type: assignment
  theme_id: PM36
  mechanism_id: 01_introduction_and_overview_pdf__cmo_013
  summary: Assigned to PM36 (early task definition).
  rationale: Joint development reduces offset administration burden.
- change_id: CHG_386
  change_type: assignment
  theme_id: PM19
  mechanism_id: 01_introduction_and_overview_pdf__cmo_014
  summary: Assigned to PM19 (equity aligns incentives).
  rationale: Equity aligns incentives and deepens skill sharing.
- change_id: CHG_387
  change_type: assignment
  theme_id: PM10
  mechanism_id: 01_introduction_and_overview_pdf__cmo_015
  summary: Assigned to PM10 (offsets as differentiator).
  rationale: Offsets tip decisions when products are comparable.
- change_id: CHG_388
  change_type: assignment
  theme_id: PM15
  mechanism_id: 01_introduction_and_overview_pdf__cmo_016
  summary: Assigned to PM15 (cheaper alternative offsets).
  rationale: Offsets used as cheaper alternative to other arrangements.
- change_id: CHG_389
  change_type: assignment
  theme_id: PM2
  mechanism_id: 01_introduction_and_overview_pdf__cmo_017
  summary: Assigned to PM2 (banked credit incentives).
  rationale: Banked credits motivate continued placements.
- change_id: CHG_390
  change_type: assignment
  theme_id: PM10
  mechanism_id: 01_introduction_and_overview_pdf__cmo_018
  summary: Assigned to PM10 (competitive pressure).
  rationale: Firms offer offsets to avoid losing sales.
- change_id: CHG_391
  change_type: assignment
  theme_id: PM54
  mechanism_id: 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_004
  summary: Moved 09_nordic_offset_policies_changes_and_challenges_pdf__cmo_004 from PM7 to PM54.
  rationale: Mechanism describes capability acquisition through domestic participation and learning (development/manufacture and
    through-life support), which aligns with PM54’s technology acquisition via collaboration. PM7 is narrowly about employer-funded
    training expanding the labour pool.
- change_id: CHG_392
  change_type: assignment
  theme_id: PM66
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_011
  summary: Moved 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_011 from PM7 to PM66.
  rationale: Mechanism links import contracts to compensatory industrial work, matching PM66’s import-compensation logic (offsets
    used to rebalance domestic industrial participation as imports rise). PM7 focuses on employer-funded training expanding skill
    supply.
- change_id: CHG_393
  change_type: assignment
  theme_id: PM54
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_016
  summary: Moved 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_016 from PM7 to PM54.
  rationale: Mechanism describes focusing offsets on prioritized military technology fields to secure long-term technological
    competence, which fits PM54’s technology acquisition and capability-building orientation. PM7 is about expanding the labour
    pool via employer-funded training.
- change_id: CHG_394
  change_type: assignment
  theme_id: PM54
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_017
  summary: Moved 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_017 from PM7 to PM54.
  rationale: Mechanism is about building domestic maintenance/modification capability for imported systems (through direct military
    offsets), aligning with PM54’s technology/capability acquisition via collaboration. PM7 is limited to employer-funded training
    expanding the skill pool.
- change_id: CHG_395
  change_type: assignment
  theme_id: PM54
  mechanism_id: 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_018
  summary: Moved 10_evaluating_defense_offsets_the_experience_in_finland_and_sweden_pdf__cmo_018 from PM7 to PM54.
  rationale: Mechanism describes targeted, qualitatively evaluated military offsets sustaining long-term competence in key
    technology fields, which fits PM54’s focus on technology acquisition and capability build-up. PM7 is specifically about
    employer-funded training expanding labour supply.
- change_id: CHG_396
  change_type: assignment
  theme_id: PM66
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_016
  summary: Moved 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_016 from PM7 to PM66.
  rationale: Mechanism requires buyback/local sourcing to redirect procurement spending toward domestic suppliers, which is
    compensatory import-offset logic consistent with PM66. PM7 is about employer-funded training expanding local skill supply.
- change_id: CHG_397
  change_type: assignment
  theme_id: PM54
  mechanism_id: 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_017
  summary: Moved 12_the_defense_industry_in_poland_an_offsets_based_revival_pdf__cmo_017 from PM7 to PM54.
  rationale: Mechanism bundles technology transfer, training, assembly, and production-line transfer to localize production,
    directly matching PM54’s technology acquisition via licensed production/collaboration. PM7 is about expanding the labour pool
    via employer-funded training.
- change_id: CHG_398
  change_type: assignment
  theme_id: PM54
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_015
  summary: Moved 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_015 from PM7 to PM54.
  rationale: Mechanism describes selective localization of high-value technologies to build autonomy while avoiding inefficient
    production, aligning with PM54’s technology acquisition/capability-building process. PM7 focuses on employer-funded training
    expanding skill supply.
- change_id: CHG_399
  change_type: assignment
  theme_id: PM54
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_017
  summary: Moved 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_017 from PM7 to PM54.
  rationale: Mechanism creates domestic entities for software development, absorption, and training to increase autonomy over
    complex systems, which is a technology/capability acquisition pathway captured by PM54. PM7 is narrowly about employer-funded
    training expanding the labour pool.
- change_id: CHG_400
  change_type: assignment
  theme_id: PM54
  mechanism_id: 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_019
  summary: Moved 13_offsets_and_the_development_of_the_brazilian_arms_industry_pdf__cmo_019 from PM7 to PM54.
  rationale: Mechanism requires technology transfer and reinvestment for software maintenance to increase sustainment/upgrade
    control, fitting PM54’s technology acquisition via collaboration. PM7 concerns employer-funded training increasing labour
    supply.
- change_id: CHG_401
  change_type: assignment
  theme_id: PM54
  mechanism_id: 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_013
  summary: Moved 14_the_argentine_defense_industry_an_evaluation_pdf__cmo_013 from PM7 to PM54.
  rationale: Mechanism is about negotiating targeted transfer while accepting partial dependence to avoid misallocation, which is
    still fundamentally about technology acquisition choices and capability-building (PM54). PM7 is specifically about employer-funded
    training expanding the local skill pool.
- change_id: CHG_402
  change_type: ambiguous
  theme_id: AMBIGUOUS
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_001
  summary: Moved 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_001 from PM7 to AMBIGUOUS (possible PM54, PM5).
  rationale: Mechanism combines technology acquisition (licensed production/technology transfer) with external-finance/countertrade
    elements aimed at easing foreign-exchange constraints. This spans distinct causal processes covered separately by PM54 and PM5.
- change_id: CHG_403
  change_type: assignment
  theme_id: PM54
  mechanism_id: 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_016
  summary: Moved 15_the_role_of_offsets_in_indian_defense_procurement_policy_pdf__cmo_016 from PM7 to PM54.
  rationale: Mechanism describes technology-assistance offsets transferring know-how to support domestic development, aligning with
    PM54’s technology acquisition via collaboration. PM7 is about employer-funded training expanding labour supply.
- change_id: CHG_404
  change_type: assignment
  theme_id: PM54
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_002
  summary: Moved 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_002 from PM7 to PM54.
  rationale: Mechanism links technology transfer and production work share to domestic substitutes and spillovers, fitting PM54’s
    technology acquisition/capability build-up process. PM7 is narrowly about employer-funded training expanding the local skill base.
- change_id: CHG_405
  change_type: assignment
  theme_id: PM54
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_005
  summary: Moved 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_005 from PM7 to PM54.
  rationale: Mechanism describes licensed local production and extensive transfer functioning like offsets to deliver industrial
    capability gains, aligning with PM54. PM7 focuses on employer-funded training expanding labour supply.
- change_id: CHG_406
  change_type: assignment
  theme_id: PM54
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_006
  summary: Moved 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_006 from PM7 to PM54.
  rationale: Mechanism channels learning through domestic procurement and licensed production to sustain capability, which fits
    PM54’s technology acquisition/collaboration logic. PM7 is about employer-funded training expanding the skill pool.
- change_id: CHG_407
  change_type: assignment
  theme_id: PM54
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_007
  summary: Moved 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_007 from PM7 to PM54.
  rationale: Mechanism emphasizes sustaining an advanced domestic production base to support sustainment and leverage, aligning
    with PM54’s capability-building focus. PM7 is specifically about employer-funded training expanding labour supply.
- change_id: CHG_408
  change_type: assignment
  theme_id: PM54
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_014
  summary: Moved 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_014 from PM7 to PM54.
  rationale: Mechanism embeds technology transfers to build domestic manufacturing and integration capability, which fits PM54’s
    technology acquisition pathway. PM7 concerns employer-funded training expanding the labour pool.
- change_id: CHG_409
  change_type: assignment
  theme_id: PM54
  mechanism_id: 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_021
  summary: Moved 16_offset_policies_and_trends_in_japan_south_korea_and_taiwan_pdf__cmo_021 from PM7 to PM54.
  rationale: Mechanism establishes domestic maintenance/repair infrastructure via procurement-linked industrial contracts, aligning
    with PM54’s technology/capability acquisition via collaboration. PM7 is about employer-funded training expanding skill supply.
- change_id: CHG_410
  change_type: assignment
  theme_id: PM54
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_001
  summary: Moved 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_001 from PM7 to PM54.
  rationale: Mechanism conditions purchases on licensed production/coproduction/transfer to shorten learning timelines, directly
    matching PM54. PM7 is limited to employer-funded training expanding the labour pool.
- change_id: CHG_411
  change_type: assignment
  theme_id: PM54
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_003
  summary: Moved 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_003 from PM7 to PM54.
  rationale: Mechanism combines offsets with state backing to build domestic technology/skills/infrastructure, which is a
    capability-building pathway consistent with PM54’s collaboration/transfer logic. PM7 focuses on employer-funded training expanding
    labour supply.
- change_id: CHG_412
  change_type: assignment
  theme_id: PM54
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_004
  summary: Moved 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_004 from PM7 to PM54.
  rationale: Mechanism uses offsets to acquire R&D/design/manufacturing expertise and compress mastery timelines, aligning with
    PM54’s technology acquisition process. PM7 is about employer-funded training expanding the local skill pool.
- change_id: CHG_413
  change_type: assignment
  theme_id: PM54
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_013
  summary: Moved 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_013 from PM7 to PM54.
  rationale: Mechanism uses targeted transfer and training to build maintenance/upgrade capability without autarky, fitting PM54’s
    technology acquisition/capability-building orientation. PM7 is narrowly about employer-funded training expanding skill supply.
- change_id: CHG_414
  change_type: assignment
  theme_id: PM54
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_014
  summary: Moved 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_014 from PM7 to PM54.
  rationale: Mechanism requires transfer and training to build local maintenance/upgrade competencies, consistent with PM54’s
    technology acquisition via collaboration. PM7 is about employer-funded training expanding the labour pool.
- change_id: CHG_415
  change_type: assignment
  theme_id: PM54
  mechanism_id: 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_015
  summary: Moved 17_offsets_and_defense_industrialization_in_indonesia_and_singapore_pdf__cmo_015 from PM7 to PM54.
  rationale: Mechanism relies on collaboration with foreign firms for specialized repair/manufacturing to build sustainment
    capability, aligning with PM54’s collaboration-driven capability acquisition. PM7 focuses on employer-funded training expanding
    skill supply.
- change_id: CHG_416
  change_type: assignment
  theme_id: PM54
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_005
  summary: Moved 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_005 from PM7 to PM54.
  rationale: Mechanism targets offset activity to sustainment/adaptation and long-term technologies to build self-reliance-relevant
    capability, which aligns better with PM54’s capability-building via directed collaboration than with PM7’s labour-supply training
    focus.
- change_id: CHG_417
  change_type: assignment
  theme_id: PM54
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_009
  summary: Moved 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_009 from PM7 to PM54.
  rationale: Mechanism substitutes R&D, exports support, technology transfer, training, and infrastructure for local content to
    generate capability gains, fitting PM54’s technology/capability acquisition framing. PM7 is about employer-funded training expanding
    the labour pool.
- change_id: CHG_418
  change_type: assignment
  theme_id: PM54
  mechanism_id: 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_015
  summary: Moved 18_defense_offsets_in_australia_and_new_zealand_pdf__cmo_015 from PM7 to PM54.
  rationale: Mechanism uses contractual undertakings (transfer, joint ventures, directed business) to build local industrial and
    maintenance capability, aligning with PM54’s collaboration-driven capability acquisition. PM7 focuses on expanding labour supply via
    employer-funded training.

- change_id: CHG_419
  change_type: no_change
  theme_id: PM7
  summary: Reviewed PM7; no merge.
  rationale: No other theme more canonically captures the same causal process of employer-financed training expanding the
    available skill pool; related themes focus on technology acquisition or absorptive capacity rather than
    labour-supply expansion.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM7
- change_id: CHG_420
  change_type: no_change
  theme_id: PM11
  summary: Reviewed PM11; no merge.
  rationale: No other theme captures the same causal process of domestic arms-industry influence pushing governments to
    demand direct offsets; related themes address institutional histories or legitimation rather than industry
    pressure shaping requirements.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM11
- change_id: CHG_421
  change_type: no_change
  theme_id: PM12
  summary: Reviewed PM12; no merge.
  rationale: No other theme captures the same causal process of designing indirect offsets to be development-oriented
    through targeting and transparency; adjacent themes focus on additionality rules or evaluation constraints
    rather than design-for-development.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM12
- change_id: CHG_422
  change_type: no_change
  theme_id: PM13
  summary: Reviewed PM13; no merge.
  rationale: No other theme captures the same causal process of shifting competition from price/quality toward bundled
    offset content; related themes cover selection differentiation or distributive impacts but not the
    competition-basis shift itself.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM13
- change_id: CHG_423
  change_type: no_change
  theme_id: PM14
  summary: Reviewed PM14; no merge.
  rationale: No other theme captures the same causal process of rent extraction through mandatory offset requirements;
    related themes address pricing pass-through or administrative rent-seeking rather than extracting rents
    via compulsory local activity.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM14
- change_id: CHG_424
  change_type: no_change
  theme_id: PM18
  summary: Reviewed PM18; no merge.
  rationale: No other theme captures the same causal process of ambiguous objectives undermining evaluation; related
    evaluation themes focus on disclosure limits or heterogeneity rather than goal ambiguity.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM18
- change_id: CHG_425
  change_type: no_change
  theme_id: PM22
  summary: Reviewed PM22; no merge.
  rationale: No other theme captures the same causal process of capability discovery via forced supplier search under local
    content requirements; related themes address supplier selection dynamics or absorptive capacity rather
    than information discovery.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM22
- change_id: CHG_426
  change_type: no_change
  theme_id: PM25
  summary: Reviewed PM25; no merge.
  rationale: No other theme captures the same causal process of opacity enabling price discrimination or dumping in
    markets; related opacity themes concern procurement cost discipline and bargaining uncertainty rather than
    market-price discrimination.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM25
- change_id: CHG_427
  change_type: no_change
  theme_id: PM26
  summary: Reviewed PM26; no merge.
  rationale: No other theme captures the same causal process of buyback/hostage requirements aligning incentives around
    technology transfer; related compliance themes focus on enforcement generally rather than hostage-style
    incentive alignment.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM26
- change_id: CHG_428
  change_type: no_change
  theme_id: PM27
  summary: Reviewed PM27; no merge.
  rationale: No other theme captures the same causal process of depreciation driving licensing to monetise declining value;
    other technology-transfer themes focus on learning, absorption, or incentives rather than depreciation
    timing.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM27
- change_id: CHG_429
  change_type: no_change
  theme_id: PM29
  summary: Reviewed PM29; no merge.
  rationale: No other theme captures the same causal process of bundled contracting reducing transaction costs under market
    imperfections; superficially related governance themes describe cost increases from complexity rather than
    cost reductions from bundling.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM29
- change_id: CHG_430
  change_type: no_change
  theme_id: PM31
  summary: Reviewed PM31; no merge.
  rationale: No other theme captures the same causal process of labour-rent protection motivating union opposition to
    offsets; related political-economy themes address other distributive conflicts rather than organised
    labour’s rent-defense mechanism.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM31
- change_id: CHG_431
  change_type: no_change
  theme_id: PM32
  summary: Reviewed PM32; no merge.
  rationale: No other theme captures the same causal process of offset-induced competition redistributing rents between
    firms and buyers; related themes discuss broader sectoral harms or allocation distortions rather than this
    buyer–firm surplus shift.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM32
- change_id: CHG_432
  change_type: no_change
  theme_id: PM37
  summary: Reviewed PM37; no merge.
  rationale: No other theme captures the same causal process of expanded export/buyer pools shifting agencies from
    restraint toward facilitation; related themes address economic framing or security urgency but not this
    organisational shift toward permissiveness.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM37
- change_id: CHG_433
  change_type: no_change
  theme_id: PM40
  summary: Reviewed PM40; no merge.
  rationale: No other theme captures the same causal process of offsets accelerating next-generation development through
    early development participation; related themes cover collaboration generally but not acceleration of
    frontier development timelines.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM40
- change_id: CHG_434
  change_type: no_change
  theme_id: PM41
  summary: Reviewed PM41; no merge.
  rationale: No other theme captures the same causal process of economic priorities overriding security restraint and
    weakening arms-control functions; related themes address security urgency or procurement legitimation
    rather than institutional arms-control weakening.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM41
- change_id: CHG_435
  change_type: no_change
  theme_id: PM42
  summary: Reviewed PM42; no merge.
  rationale: No other theme captures the same causal process of offsets increasing defence budget appeal in budget
    competition and potentially increasing purchases; related legitimation themes focus on acceptability, not
    budget-competition dynamics.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM42
- change_id: CHG_436
  change_type: no_change
  theme_id: PM43
  summary: Reviewed PM43; no merge.
  rationale: No other theme captures the same causal process of opacity weakening cost-minimisation incentives and cost
    discipline in procurement; related opacity themes address price discrimination or bargaining uncertainty,
    not procurement cost discipline.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM43
- change_id: CHG_437
  change_type: no_change
  theme_id: PM44
  summary: Reviewed PM44; no merge.
  rationale: No other theme captures the same causal process of offsets helping primes preserve market power via expanded
    markets and trade-rule exemptions; related competition or pricing themes do not capture this industry-
    level collective incentive.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM44
- change_id: CHG_438
  change_type: no_change
  theme_id: PM45
  summary: Reviewed PM45; no merge.
  rationale: No other theme captures the same causal process of security urgency/treaty quid-pro-quo crowding out offset
    aims and leading to off-the-shelf procurement; related themes focus on economic priorities or offset
    bargaining rather than urgency-driven de-emphasis.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM45
- change_id: CHG_439
  change_type: no_change
  theme_id: PM47
  summary: Reviewed PM47; no merge.
  rationale: No other theme captures the same causal process of opacity and bargaining producing uncertainty in offset
    delivery and valuation; related opacity themes focus on cost discipline or market pricing rather than
    bargaining-driven uncertainty.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM47
- change_id: CHG_440
  change_type: no_change
  theme_id: PM48
  summary: Reviewed PM48; no merge.
  rationale: No other theme captures the same causal process of institutional path dependence shaping how offsets are
    perceived and operationalised; related themes address specific interest-group pressures but not cross-
    historical policy trajectories.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM48
- change_id: CHG_441
  change_type: no_change
  theme_id: PM49
  summary: Reviewed PM49; no merge.
  rationale: No other theme captures the same causal process of second-best import offset rules emerging from asymmetric
    openness/protectionism; related themes cover value-for-money design rather than structural trade
    asymmetry.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM49
- change_id: CHG_442
  change_type: no_change
  theme_id: PM50
  summary: Reviewed PM50; no merge.
  rationale: No other theme captures the same causal process of designing offset requirements to protect value-for-money
    (scope, novelty, technical equivalence, no additional cost); related themes focus on evaluation
    uncertainty rather than design constraints.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM50
- change_id: CHG_443
  change_type: no_change
  theme_id: PM51
  summary: Reviewed PM51; no merge.
  rationale: No other theme captures the same causal process of reciprocity pressures and supply-chain risk shaping offset
    types; related themes address trade restriction or procurement structures rather than reciprocity-driven
    risk management.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM51
- change_id: CHG_444
  change_type: no_change
  theme_id: PM53
  summary: Reviewed PM53; no merge.
  rationale: No other theme captures the same causal process of embedding offsets via procurement structures
    (cartels/consortia) without explicit policy; related themes concern compliance regimes or export support
    rather than structural embedding.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM53
- change_id: CHG_445
  change_type: no_change
  theme_id: PM55
  summary: Reviewed PM55; no merge.
  rationale: No other theme captures the same causal process of subsidiary entry enabling capability build-up followed by
    consolidation; related themes address collaboration or networks rather than this entry–consolidation
    trajectory.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM55
- change_id: CHG_446
  change_type: no_change
  theme_id: PM56
  summary: Reviewed PM56; no merge.
  rationale: No other theme captures the same causal process of fair-return (juste retour) reform improving collaborative
    efficiency via global-balance arrangements; related themes cover partnership packages but not return-rule
    reform.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM56
- change_id: CHG_447
  change_type: no_change
  theme_id: PM57
  summary: Reviewed PM57; no merge.
  rationale: No other theme captures the same causal process of export-support organisations building firms’ capacity to
    navigate offsets and identify creditable projects; related themes describe export outcomes rather than
    capability-building support.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM57
- change_id: CHG_448
  change_type: no_change
  theme_id: PM58
  summary: Reviewed PM58; no merge.
  rationale: No other theme captures the same causal process of multi-layer governance and non-competitive work splitting
    raising transaction costs and blurring accountability; related transaction-cost themes describe cost
    reductions from bundling, not governance frictions.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM58
- change_id: CHG_449
  change_type: merge
  theme_id: PM52
  summary: Merged PM59 into PM52.
  rationale: PM59’s mechanism concerns additionality being undermined by what counts as credit; PM52 already captures
    additionality shaped by credit rules and is the clearer canonical theme.
  details:
    merged_from: [PM59]
    merged_into: PM52
    reviewed_theme_id: PM59
- change_id: CHG_450
  change_type: merge
  theme_id: PM39
  summary: Merged PM60 into PM39.
  rationale: PM60’s mechanism is already captured within PM39, so PM60 adds no distinct causal logic beyond the existing
    theme content.
  details:
    merged_from: [PM60]
    merged_into: PM39
    reviewed_theme_id: PM60
- change_id: CHG_451
  change_type: merge
  theme_id: PM34
  summary: Merged PM61 into PM34.
  rationale: PM61’s mechanism is already captured within PM34, so PM61 adds no distinct causal logic beyond the existing
    theme content.
  details:
    merged_from: [PM61]
    merged_into: PM34
    reviewed_theme_id: PM61
- change_id: CHG_452
  change_type: no_change
  theme_id: PM62
  summary: Reviewed PM62; no merge.
  rationale: No other theme captures the same causal process of early partnership enabling access to high-technology roles
    under best-value allocation and export-control constraints; related themes focus on dependence harms or
    generic collaboration.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM62
- change_id: CHG_453
  change_type: no_change
  theme_id: PM63
  summary: Reviewed PM63; no merge.
  rationale: No other theme captures the same causal process of partnership structure shaping risk exposure (win–lose vs
    hedged participation); related themes address collaboration durability rather than risk allocation.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM63
- change_id: CHG_454
  change_type: no_change
  theme_id: PM64
  summary: Reviewed PM64; no merge.
  rationale: No other theme captures the same causal process of contractor-provided IP studies acting as biased marketing
    signals; related evaluation themes focus on disclosure constraints or counterfactual uncertainty, not
    marketing bias.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM64
- change_id: CHG_455
  change_type: no_change
  theme_id: PM65
  summary: Reviewed PM65; no merge.
  rationale: No other theme captures the same causal process of partnership packages linking defence and non-defence
    opportunities to build durable collaboration beyond offset percentages; related themes cover access to
    high-tech roles rather than durability-building packages.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM65
- change_id: CHG_456
  change_type: merge
  theme_id: PM2
  summary: Merged PM67 into PM2.
  rationale: PM67 duplicates a mechanism already represented under PM2’s compliance/monitoring framing, making PM67
    redundant.
  details:
    merged_from: [PM67]
    merged_into: PM2
    reviewed_theme_id: PM67
- change_id: CHG_457
  change_type: merge
  theme_id: PM2
  summary: Merged PM68 into PM2.
  rationale: PM68 duplicates a mechanism already represented under PM2’s compliance/monitoring framing, making PM68
    redundant.
  details:
    merged_from: [PM68]
    merged_into: PM2
    reviewed_theme_id: PM68
- change_id: CHG_458
  change_type: merge
  theme_id: PM2
  summary: Merged PM69 into PM2.
  rationale: PM69 duplicates a mechanism already represented under PM2’s compliance/monitoring framing, making PM69
    redundant.
  details:
    merged_from: [PM69]
    merged_into: PM2
    reviewed_theme_id: PM69
- change_id: CHG_459
  change_type: merge
  theme_id: PM15
  summary: Merged PM70 into PM15.
  rationale: PM70 duplicates a mechanism already represented under PM15’s flexibility/mandate framing, making PM70
    redundant.
  details:
    merged_from: [PM70]
    merged_into: PM15
    reviewed_theme_id: PM70
- change_id: CHG_460
  change_type: merge
  theme_id: PM15
  summary: Merged PM71 into PM15.
  rationale: PM71 duplicates a mechanism already represented under PM15’s flexibility/mandate framing, making PM71
    redundant.
  details:
    merged_from: [PM71]
    merged_into: PM15
    reviewed_theme_id: PM71
- change_id: CHG_461
  change_type: merge
  theme_id: PM2
  summary: Merged PM72 into PM2.
  rationale: PM72 duplicates a mechanism already represented under PM2’s compliance/monitoring framing, making PM72
    redundant.
  details:
    merged_from: [PM72]
    merged_into: PM2
    reviewed_theme_id: PM72
- change_id: CHG_462
  change_type: merge
  theme_id: PM15
  summary: Merged PM73 into PM15.
  rationale: PM73 duplicates a mechanism already represented under PM15’s flexibility/mandate framing, making PM73
    redundant.
  details:
    merged_from: [PM73]
    merged_into: PM15
    reviewed_theme_id: PM73
- change_id: CHG_463
  change_type: no_change
  theme_id: PM74
  summary: Reviewed PM74; no merge.
  rationale: No other theme captures the same causal process of disclosure constraints (data access and vested interests)
    obscuring evaluation; related evaluation themes focus on objective ambiguity or heterogeneity rather than
    disclosure barriers.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM74
- change_id: CHG_464
  change_type: no_change
  theme_id: PM75
  summary: Reviewed PM75; no merge.
  rationale: No other theme captures the same causal process of counterfactual uncertainty undermining additionality
    assessment; related additionality themes focus on credit rules rather than the inherent counterfactual
    problem.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM75
- change_id: CHG_465
  change_type: merge
  theme_id: PM3
  summary: Merged PM76 into PM3.
  rationale: PM76’s mechanism describes price increases driven by compliance/penalty risk and administrative burden, which
    is a specific instance of cost pass-through captured by PM3.
  details:
    merged_from: [PM76]
    merged_into: PM3
    reviewed_theme_id: PM76
- change_id: CHG_466
  change_type: no_change
  theme_id: PM78
  summary: Reviewed PM78; no merge.
  rationale: No other theme captures the same causal process of offset-generated exports concentrating in incumbents and
    limiting SME/job gains; related themes describe export-support capacity-building rather than concentration
    outcomes.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM78
- change_id: CHG_467
  change_type: merge
  theme_id: PM52
  summary: Merged PM79 into PM52.
  rationale: PM79 duplicates a mechanism already represented under PM52’s additionality-focused framing, making PM79
    redundant.
  details:
    merged_from: [PM79]
    merged_into: PM52
    reviewed_theme_id: PM79
- change_id: CHG_468
  change_type: no_change
  theme_id: PM80
  summary: Reviewed PM80; no merge.
  rationale: No other theme captures the same causal process of firm-level gains coexisting with weak national net benefit
    and misalignment with policy goals; related distributive themes discuss rent shifts but not firm-vs-
    national divergence.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM80
- change_id: CHG_469
  change_type: no_change
  theme_id: PM81
  summary: Reviewed PM81; no merge.
  rationale: No other theme captures the same causal process of using indirect offsets to extend industrial activity beyond
    a program’s life; related themes address sourcing persistence under obligations rather than deliberate
    extension via indirect offsets.
  details:
    merged_from: []
    merged_into: null
    reviewed_theme_id: PM81
```
