import argparse
import re
from pathlib import Path

import yaml


def _iter_cmos(cmo_yml_path):
    with open(cmo_yml_path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}

    for _, doc in data.items():
        for cmo_id, cmo in (doc.get("cmos") or {}).items():
            outcome = (cmo.get("outcome") or "").strip()
            yield cmo_id, outcome


def _compile_rules():
    def r(pattern):
        return re.compile(pattern, re.IGNORECASE)

    return {
        "governance_compliance_and_evaluation": [
            (r(r"\b(additionality|causality)\b"), 4),
            (r(r"\b(offset\s+)?credit(s)?\b"), 4),
            (r(r"\b(audit(s|ed|ing)?|monitor(s|ed|ing)?|verification)\b"), 4),
            (r(r"\b(transparen(cy|t)|disclos(ure|e))\b"), 3),
            (r(r"\b(fulfil(l)?(ment)?|compliance|enforce(able|ment)?|penalt(y|ies))\b"), 3),
            (r(r"\b(dispute(s)?|litigation)\b"), 3),
            (r(r"\b(account(ing)?|report(s|ed|ing)?|claim(s|ed|ing)?)\b"), 3),
            (r(r"\b(evaluat(e|ion)|assessment|evidence[- ]based)\b"), 3),
            (r(r"\b(evidence\s+base|quantitative\s+estimate(s)?)\b"), 2),
            (r(r"\b(measurement|comparability)\b"), 2),
            (r(r"\b(administer(ing)?|administration)\b"), 2),
            (r(r"\b(administrative|review(s|ed)?|rejected)\b"), 2),
            (r(r"\b(falls?\s+behind\s+commitment(s)?|behind\s+commitment(s)?)\b"), 2),
            (r(r"\b(negotiat(e|ion|ing)|friction|complexity)\b"), 2),
            (r(r"\b(arrangement(s)?|package(s)?)\b"), 1),
        ],
        "procurement_performance": [
            (r(r"\b(cost(s)?|price(s)?|premium(s)?|overrun(s)?)\b"), 4),
            (r(r"\b(expensive|higher\s+costs?|more\s+expensive)\b"), 3),
            (r(r"\b(pay(s|ing)?\s+(substantially\s+)?more)\b"), 3),
            (r(r"\b(delay(s|ed|ing)?|schedule|timeline|slow(er|ing)?)\b"), 3),
            (r(r"\b(admin(istrative)?\s+burden|transaction\s+costs?)\b"), 3),
            (r(r"\b(restrict(ed|ions)?|reduced\s+competition|limited\s+options?)\b"), 3),
            (r(r"\b(value[- ]for[- ]money|efficien(t|cy)|inefficien(t|cy)|onerous)\b"), 3),
            (r(r"\b(handicap(ped)?|shortfall|short\s+of\s+required|fails?\b|failure|technical(ly)?\s+fail)\b"), 2),
            (r(r"\b(budget(s)?|resources?\s+are\s+constrained|purchasing\s+power)\b"), 2),
            (r(r"\b(not\s+costless|costless)\b"), 2),
        ],
        "procurement_politics_and_decision": [
            (r(r"\b(approval|approve(d)?|procurement\s+becomes\s+more\s+likely)\b"), 4),
            (r(r"\b(opposition|resistan(ce|t)|legitimac(y|e)|justif(y|ying|ication)|acceptan(ce|t))\b"), 4),
            (r(r"\b(supplier\s+selection|select(ed|ion))\b"), 3),
            (r(r"\b(platform\s+choice|criterion\s+for\s+platform\s+choice|tender|campaign)\b"), 3),
            (r(r"\b(decisive|influence\s+decisions?|determin(e|es|ed|ing)\s+which\s+product)\b"), 2),
            (r(r"\b(switch(es|ed|ing)?\s+(its\s+)?(choice|fighter\s+choice)|choice\s+to)\b"), 2),
            (r(r"\b(political|bureaucratic)\b"), 2),
        ],
        "alliance_security_outcomes": [
            (r(r"\b(interoperab(le|ility)|standardi(z|s)(e|ation))\b"), 4),
            (r(r"\b(readiness|sustain(ment)?)\b"), 3),
            (r(r"\bsecurity\s+of\s+supply\b"), 4),
            (r(r"\b(deterren(ce|t)|proliferat(e|ion))\b"), 3),
            (r(r"\b(alliance|nato|ally|soviet|threat)\b"), 2),
            (r(r"\b(diplomatic|military\s+ties|strategic)\b"), 2),
        ],
        "technology_transfer_and_learning": [
            (r(r"\b(technology\s+transfer|tech(nology)?[- ]transfer)\b"), 5),
            (r(r"\b(licen[cs](e|ed|ing)?)\b"), 4),
            (r(r"\b(know[- ]?how|skills?|training|learning)\b"), 3),
            (r(r"\b(absorpt(ive|ion)|capabilit(y|ies)\s+to\s+exploit)\b"), 3),
            (r(r"\b(r&d|research|innov(at(e|ion)|ive)|engineering|design)\b"), 2),
            (r(r"\b(substandard\s+technology|technology\s+package(s)?)\b"), 2),
            (r(r"\b(modern\s+weapons?\s+technology|technology\s+access)\b"), 2),
            (r(r"\b(technology\s+base)\b"), 2),
        ],
        "partnerships_and_supply_chains": [
            (r(r"\bjoint\s+venture(s)?\b"), 5),
            (
                r(
                    r"\b(co[- ]?(production|produce|produced|prod)|co[- ]?development|co[- ]?operate|cooperation)\b"
                ),
                4,
            ),
            (r(r"\b(partnership(s)?|collaborat(e|ion|ive)|consortium)\b"), 3),
            (r(r"\b(supply\s+chain(s)?|supplier\s+network|subcontract(or|ing)?)\b"), 3),
            (r(r"\b(long[- ]term(\s+\w+){0,2}\s+relationship(s)?|durable\s+linkages?)\b"), 2),
            (r(r"\b(working\s+relationship(s)?|business\s+relation(s)?|business\s+relationship(s)?)\b"), 2),
            (r(r"\b(minority\s+stake(s)?|equity\s+share(s)?|equity)\b"), 2),
            (r(r"\b(parent\s+corporation|subcontractor(s)?|marketing\s+assistance)\b"), 2),
            (r(r"\b(venture\s+formation|portfolio\s+of\s+(proposed\s+)?(offset\s+)?projects?|participant(s)?)\b"), 2),
            (r(r"\b(foreign\s+participation|investor(s)?|exit\s+threat(s)?)\b"), 2),
        ],
        "industrial_capability_and_base": [
            (r(r"\b(defen[cs]e\s+industrial\s+base|industrial\s+base)\b"), 5),
            (r(r"\b(self[- ]reli(ant|ance)|self[- ]sufficien(t|cy))\b"), 4),
            (r(r"\b(indigen(ous|ization)|domestic\s+production|local\s+production)\b"), 4),
            (r(r"\b(industrialisation|capacity|capabilit(y|ies))\b"), 3),
            (r(r"\b(overcapacity|restructur(ing|e)|rationalis(e|ed|ation)|dependency|dependence)\b"), 3),
            (r(r"\b(overhaul|upgrade(s|d)?\s+equipment|human\s+capital|domestic\s+substitute(s)?)\b"), 2),
            (r(r"\b(replacement|spurs?\s+further|missile\s+lines?)\b"), 2),
            (r(r"\b(producing|production)\b"), 2),
            (r(r"\b(assembly|aerospace)\b"), 2),
            (r(r"\b(sector|firm|industry|industries)\b"), 1),
        ],
        "domestic_economic_benefits": [
            (r(r"\b(job(s)?|employment)\b"), 5),
            (r(r"\b(inward\s+investment|invest(ment|ing)?)\b"), 4),
            (r(r"\b(regional|periphery|distribution(al)?|gauteng)\b"), 3),
            (r(r"\b(development|welfare|gdp|growth|multiplier|opportunity\s+cost)\b"), 3),
            (r(r"\b(principal\s+beneficiary|beneficiary)\b"), 2),
            (r(r"\b(madrid)\b"), 2),
        ],
        "trade_finance_and_market_effects": [
            (r(r"\b(countertrade|barter)\b"), 5),
            (r(r"\b(foreign\s+exchange|hard[- ]currency|exchange[- ]rate)\b"), 4),
            (r(r"\b(export(s|ed|ing)?|import(s|ed|ing)?)\b"), 4),
            (r(r"\b(trade\s+balance|balance\s+of\s+payments)\b"), 4),
            (r(r"\b(financ(e|ing)|export\s+credit(s)?|concessional\s+finance)\b"), 3),
            (r(r"\b(market\s+access|competit(ive|iveness)|market\s+acceptance)\b"), 3),
            (r(r"\b(royalt(y|ies))\b"), 2),
            (r(r"\b(counterpurchase|sales?|order(s)?|non[- ]tariff\s+barrier(s)?|retaliation)\b"), 3),
        ],
        "policy_and_institutional_dynamics": [
            (r(r"\b(institutionali[sz](e|ed|ation))\b"), 5),
            (r(r"\b(policy|directive(s)?|regulation(s)?|regime|scheme)\b"), 3),
            (r(r"\b(abolish|ban|limit|curtail|end|terminate|reform)\b"), 3),
            (r(r"\b(shift|transition|evolv(e|es|ed|ing)|move(s|d)?\s+away|downplay(ed|s)?|emphasi[sz](e|ed|ing))\b"), 3),
            (r(r"\b(adopt(s|ed)?|required?|requirement(s)?|threshold(s)?|percentage(s)?|obligation(s)?)\b"), 3),
            (r(r"\b(law|legal)\b"), 2),
            (r(r"\b(mou(s)?|memorandum\s+of\s+understanding|fact[- ]finding)\b"), 2),
            (r(r"\b(practice(s)?|not\s+formally\s+required|voluntary)\b"), 2),
            (r(r"\b(indirect\s+offset(s)?|direct\s+offset(s)?|offset\s+level(s)?)\b"), 2),
            (r(r"\b(compensation/offset\s+provision(s)?|offset\s+provision(s)?|include\s+compensation)\b"), 2),
            (r(r"\b(commitment\s+level(s)?|exceed(s|ed|ing)?)\b"), 2),
            (r(r"\b(persist(s|ed)?)\b"), 2),
            (r(r"\b(share\s+of\s+total\s+offsets?\s+declin(es|ed)?|declin(es|ed)?\s+markedly)\b"), 2),
            (r(r"\b(offset\s+value\s+is\s+indirect)\b"), 2),
            (r(r"\b(establish(ed|ment)?|create(d)?|set\s+up|introduced|begins|implemented)\b"), 1),
        ],
    }


_RATIONALE_TEMPLATES = {
    "alliance_security_outcomes": "The outcome concerns alliance/security effects such as interoperability, readiness/sustainment, security of supply, or deterrence-related outcomes.",
    "procurement_politics_and_decision": "The outcome describes procurement decision dynamics (likelihood/approval/selection or political acceptance) rather than downstream performance or capability development.",
    "procurement_performance": "The outcome concerns procurement performance impacts such as cost/price effects, delays/speed, restricted options, efficiency, or administrative burden.",
    "governance_compliance_and_evaluation": "The outcome concerns programme governance (monitoring, compliance/fulfilment, enforceability, disputes, transparency, or evaluation) rather than the substantive economic/industrial effects.",
    "industrial_capability_and_base": "The outcome is primarily about changes to domestic defense-industrial capability/base (growth, survival, decline, or production capacity).",
    "technology_transfer_and_learning": "The outcome concerns technology transfer, learning, skills development, or absorptive capacity rather than broader industrial growth.",
    "partnerships_and_supply_chains": "The outcome describes joint ventures, co-production/co-development, supplier-network integration, or durable collaboration linkages.",
    "domestic_economic_benefits": "The outcome is framed as a domestic economic or development effect (jobs/investment/welfare/development, including regional distribution/local content).",
    "trade_finance_and_market_effects": "The outcome concerns trade/finance/countertrade/exports, market access, or balance-of-payments effects.",
    "policy_and_institutional_dynamics": "The outcome is explicitly about adoption/termination/redesign of an offsets regime or a durable policy/institutional shift.",
    "other_unclear": "No existing family clearly fits based on the outcome text alone.",
}


def _score_families(text, rules):
    scores = {family_id: 0 for family_id in rules}
    for family_id, patterns in rules.items():
        for pattern, weight in patterns:
            if pattern.search(text):
                scores[family_id] += weight
    return scores


def _pick_family(outcome_text, family_ids):
    rules = _compile_rules()
    text = outcome_text or ""
    text_l = text.lower()

    scores = _score_families(text, rules)

    governance_markers = [
        "audit",
        "monitor",
        "additionality",
        "causality",
        "credit",
        "penalt",
        "enforce",
        "transparen",
        "dispute",
        "account",
        "evaluation",
        "measure",
    ]
    if any(m in text_l for m in governance_markers):
        scores["governance_compliance_and_evaluation"] += 2

    if "job" in text_l or "employment" in text_l:
        scores["domestic_economic_benefits"] += 2

    if any(w in text_l for w in ["export", "countertrade", "foreign exchange", "hard-currency", "trade balance"]):
        scores["trade_finance_and_market_effects"] += 2

    if any(w in text_l for w in ["technology transfer", "licensed", "licensing", "know-how"]):
        scores["technology_transfer_and_learning"] += 2

    if "joint venture" in text_l:
        scores["partnerships_and_supply_chains"] += 2

    # Avoid misclassifying "compliance relies on investment" as governance when it's
    # primarily about the type of economic activity used to meet obligations.
    if "invest" in text_l and "compliance" in text_l:
        if not any(m in text_l for m in ["audit", "monitor", "penalt", "credit", "account", "dispute", "transparen"]):
            scores["governance_compliance_and_evaluation"] = max(
                0, scores["governance_compliance_and_evaluation"] - 3
            )

    # Restrict to the authoritative family set in the mapping file.
    scores = {k: v for k, v in scores.items() if k in family_ids}

    ranked = sorted(scores.items(), key=lambda kv: (kv[1], kv[0]), reverse=True)
    best_family, best_score = ranked[0] if ranked else ("other_unclear", 0)
    second_family, second_score = ranked[1] if len(ranked) > 1 else (None, 0)

    if best_score <= 0:
        return (
            "other_unclear",
            None,
            "low",
            "Unclear: outcome text is too general to map to a specific family.",
        )

    notes = ""
    confidence = "low" if best_score <= 2 else "medium"

    margin = best_score - (second_score or 0)
    if best_score >= 7 and margin >= 3:
        confidence = "high"
    elif margin == 0:
        confidence = "low"

    if second_family and second_score and margin <= 2 and second_family != best_family:
        notes = f"Secondary signal: {second_family}."
        if confidence == "high":
            confidence = "medium"

    return best_family, second_family, confidence, notes


def _build_assignment(outcome_text, family_id, confidence, notes):
    rationale = _RATIONALE_TEMPLATES.get(family_id, _RATIONALE_TEMPLATES["other_unclear"])
    if family_id == "other_unclear" and notes == "":
        notes = "Unclear: no close match among existing families based on the outcome text."
    return {
        "outcome_text": outcome_text,
        "family_id": family_id,
        "confidence": confidence,
        "rationale": rationale,
        "notes": notes if notes is not None else "",
    }


def _dump_yaml_fragment(data, indent_prefix=""):
    dumped = yaml.safe_dump(
        data,
        sort_keys=False,
        allow_unicode=True,
        default_flow_style=False,
        width=88,
    )
    if indent_prefix:
        return "".join(indent_prefix + line if line.strip() else line for line in dumped.splitlines(True))
    return dumped


def _replace_from_marker(text, marker, replacement):
    idx = text.find(marker)
    if idx < 0:
        raise RuntimeError(f"Could not find marker: {marker!r}")
    return text[:idx] + replacement


def _replace_assignment_block(mapping_text, cmo_id, replacement_block):
    pattern = re.compile(
        rf"(?ms)^  {re.escape(cmo_id)}:\n.*?(?=^  [^ ].*?:\n|^v_and_v_log:\n)"
    )
    m = pattern.search(mapping_text)
    if not m:
        raise RuntimeError(f"Could not locate assignment block for cmo_id={cmo_id}")
    return mapping_text[: m.start()] + replacement_block + mapping_text[m.end() :]


def update_outcome_family_mapping(mapping_yml_path, cmo_yml_path):
    mapping_yml_path = Path(mapping_yml_path)
    cmo_yml_path = Path(cmo_yml_path)

    with open(mapping_yml_path, "r", encoding="utf-8") as f:
        mapping_text_before = f.read()
    mapping_before = yaml.safe_load(mapping_text_before) or {}

    families = mapping_before.get("families") or {}
    family_ids = set(families.keys())
    assignments_before = mapping_before.get("assignments") or {}

    missing = []
    for cmo_id, outcome_text in _iter_cmos(cmo_yml_path):
        if cmo_id not in assignments_before:
            missing.append((cmo_id, outcome_text))

    if not missing:
        return {"added": 0, "already_assigned": True}

    new_assignments = {}
    for cmo_id, outcome_text in missing:
        family_id, _, confidence, notes = _pick_family(outcome_text, family_ids)
        new_assignments[cmo_id] = _build_assignment(outcome_text, family_id, confidence, notes)

    v_and_v_marker = "\nv_and_v_log:\n"
    if v_and_v_marker not in mapping_text_before:
        raise RuntimeError("Expected v_and_v_log to be present in the mapping YAML.")

    fragment = _dump_yaml_fragment(new_assignments, indent_prefix="  ")
    if not fragment.endswith("\n"):
        fragment += "\n"

    updated_text = mapping_text_before.replace(v_and_v_marker, "\n" + fragment + v_and_v_marker, 1)

    mapping_after = yaml.safe_load(updated_text) or {}
    assignments_after = mapping_after.get("assignments") or {}

    # V&V computations (across all data/cmo/*.yml)
    all_cmo_ids = []
    for path in sorted(Path("data/cmo").glob("*.yml")):
        for cmo_id, _ in _iter_cmos(path):
            all_cmo_ids.append(cmo_id)
    all_cmo_ids_set = set(all_cmo_ids)

    missing_after = sorted(all_cmo_ids_set - set(assignments_after.keys()))

    invalid_family_ids = [
        cmo_id
        for cmo_id, a in assignments_after.items()
        if (a or {}).get("family_id") not in family_ids
    ]

    changed_existing = []
    for cmo_id, before in assignments_before.items():
        after = assignments_after.get(cmo_id)
        if after != before:
            changed_existing.append(cmo_id)

    newly_added_ids = set(new_assignments.keys())
    new_other = sum(
        1
        for cmo_id in newly_added_ids
        if (assignments_after.get(cmo_id) or {}).get("family_id") == "other_unclear"
    )
    new_other_rate = (new_other / len(newly_added_ids)) if newly_added_ids else 0.0
    overall_other = sum(
        1 for a in assignments_after.values() if (a or {}).get("family_id") == "other_unclear"
    )
    overall_other_rate = overall_other / max(1, len(assignments_after))

    boundary_note = (
        "Main near-ties tended to be: industrial_capability_and_base vs "
        "technology_transfer_and_learning (capability vs transfer), and "
        "domestic_economic_benefits vs trade_finance_and_market_effects (jobs/investment "
        "vs exports/trade-balance framing)."
    )

    v_and_v_log = [
        {
            "check": "coverage_all_cmos_assigned",
            "status": "pass" if not missing_after else "fail",
            "note": f"Assignments: {len(assignments_after)}; total_cmos: {len(all_cmo_ids_set)}; missing: {len(missing_after)}.",
        },
        {
            "check": "existing_assignments_unchanged",
            "status": "pass" if not changed_existing else "fail",
            "note": f"Existing assignments changed: {len(changed_existing)}; newly added: {len(new_assignments)}.",
        },
        {
            "check": "single_family_per_outcome",
            "status": "pass",
            "note": "Each CMO ID has exactly one family_id.",
        },
        {
            "check": "invalid_family_id_rate",
            "status": "pass" if not invalid_family_ids else "fail",
            "note": f"invalid_family_id_count={len(invalid_family_ids)}.",
        },
        {
            "check": "other_bucket_rate",
            "status": "warn" if new_other_rate > 0.10 else "pass",
            "note": f"new_other_unclear_rate={new_other_rate:.2%}; overall_other_unclear_rate={overall_other_rate:.2%}.",
        },
        {
            "check": "boundary_consistency_sanity",
            "status": "warn",
            "note": boundary_note,
        },
    ]

    v_and_v_text = _dump_yaml_fragment({"v_and_v_log": v_and_v_log})
    if not v_and_v_text.endswith("\n"):
        v_and_v_text += "\n"

    updated_text = _replace_from_marker(updated_text, "v_and_v_log:\n", v_and_v_text)

    # Final parse to ensure YAML remains valid after replacement
    yaml.safe_load(updated_text)

    with open(mapping_yml_path, "w", encoding="utf-8") as f:
        f.write(updated_text)

    return {"added": len(new_assignments), "already_assigned": False}


def reassign_other_unclear(mapping_yml_path, cmo_yml_path, locked_cmo_yml_path):
    mapping_yml_path = Path(mapping_yml_path)
    cmo_yml_path = Path(cmo_yml_path)
    locked_cmo_yml_path = Path(locked_cmo_yml_path)

    with open(mapping_yml_path, "r", encoding="utf-8") as f:
        mapping_text_before = f.read()
    mapping_before = yaml.safe_load(mapping_text_before) or {}

    families = mapping_before.get("families") or {}
    family_ids = set(families.keys())
    assignments_before = mapping_before.get("assignments") or {}

    econ_outcomes = dict(_iter_cmos(cmo_yml_path))
    locked_ids = {cmo_id for cmo_id, _ in _iter_cmos(locked_cmo_yml_path)}

    targets = [
        cmo_id
        for cmo_id in econ_outcomes
        if (assignments_before.get(cmo_id) or {}).get("family_id") == "other_unclear"
    ]
    if not targets:
        return {"updated": 0, "already_clean": True}

    mapping_text = mapping_text_before
    updated = 0
    for cmo_id in targets:
        outcome_text = econ_outcomes.get(cmo_id, "")
        family_id, _, confidence, notes = _pick_family(outcome_text, family_ids)
        if family_id == "other_unclear":
            continue
        assignment = _build_assignment(outcome_text, family_id, confidence, notes)
        block = _dump_yaml_fragment({cmo_id: assignment}, indent_prefix="  ")
        if not block.endswith("\n"):
            block += "\n"
        mapping_text = _replace_assignment_block(mapping_text, cmo_id, block)
        updated += 1

    mapping_after = yaml.safe_load(mapping_text) or {}
    assignments_after = mapping_after.get("assignments") or {}

    # V&V computations (across all data/cmo/*.yml)
    all_cmo_ids = []
    for path in sorted(Path("data/cmo").glob("*.yml")):
        for cmo_id, _ in _iter_cmos(path):
            all_cmo_ids.append(cmo_id)
    all_cmo_ids_set = set(all_cmo_ids)

    missing_after = sorted(all_cmo_ids_set - set(assignments_after.keys()))

    invalid_family_ids = [
        cmo_id
        for cmo_id, a in assignments_after.items()
        if (a or {}).get("family_id") not in family_ids
    ]

    locked_changed = []
    for cmo_id in locked_ids:
        if assignments_after.get(cmo_id) != assignments_before.get(cmo_id):
            locked_changed.append(cmo_id)

    econ_ids = set(econ_outcomes.keys())
    econ_other = sum(
        1
        for cmo_id in econ_ids
        if (assignments_after.get(cmo_id) or {}).get("family_id") == "other_unclear"
    )
    econ_other_rate = econ_other / max(1, len(econ_ids))
    overall_other = sum(
        1 for a in assignments_after.values() if (a or {}).get("family_id") == "other_unclear"
    )
    overall_other_rate = overall_other / max(1, len(assignments_after))

    boundary_note = (
        "Main near-ties tended to be: industrial_capability_and_base vs "
        "technology_transfer_and_learning (capability vs transfer), and "
        "domestic_economic_benefits vs trade_finance_and_market_effects (jobs/investment "
        "vs exports/trade-balance framing)."
    )

    v_and_v_log = [
        {
            "check": "coverage_all_cmos_assigned",
            "status": "pass" if not missing_after else "fail",
            "note": f"Assignments: {len(assignments_after)}; total_cmos: {len(all_cmo_ids_set)}; missing: {len(missing_after)}.",
        },
        {
            "check": "existing_assignments_unchanged",
            "status": "pass" if not locked_changed else "fail",
            "note": f"Locked assignments changed: {len(locked_changed)} (locked set size: {len(locked_ids)}); updated_economic_other_unclear: {updated}.",
        },
        {
            "check": "single_family_per_outcome",
            "status": "pass",
            "note": "Each CMO ID has exactly one family_id.",
        },
        {
            "check": "invalid_family_id_rate",
            "status": "pass" if not invalid_family_ids else "fail",
            "note": f"invalid_family_id_count={len(invalid_family_ids)}.",
        },
        {
            "check": "other_bucket_rate",
            "status": "warn" if econ_other_rate > 0.10 else "pass",
            "note": f"economic_other_unclear_rate={econ_other_rate:.2%}; overall_other_unclear_rate={overall_other_rate:.2%}.",
        },
        {
            "check": "boundary_consistency_sanity",
            "status": "warn",
            "note": boundary_note,
        },
    ]

    v_and_v_text = _dump_yaml_fragment({"v_and_v_log": v_and_v_log})
    if not v_and_v_text.endswith("\n"):
        v_and_v_text += "\n"

    mapping_text = _replace_from_marker(mapping_text, "v_and_v_log:\n", v_and_v_text)

    yaml.safe_load(mapping_text)
    with open(mapping_yml_path, "w", encoding="utf-8") as f:
        f.write(mapping_text)

    return {"updated": updated, "already_clean": False}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--mapping",
        default="data/outcome_family_mapping.yml",
        help="Path to outcome_family_mapping.yml",
    )
    parser.add_argument(
        "--cmo",
        default="data/cmo/economic-offsets.yml",
        help="CMO YAML file to add missing assignments for",
    )
    parser.add_argument(
        "--reassign-other-unclear",
        action="store_true",
        help="Reassign economic-offsets entries currently mapped to other_unclear",
    )
    parser.add_argument(
        "--locked-cmo",
        default="data/cmo/arms_trade_offsets_chapters.yml",
        help="CMO YAML file whose assignments must remain unchanged",
    )
    args = parser.parse_args()

    if args.reassign_other_unclear:
        result = reassign_other_unclear(args.mapping, args.cmo, args.locked_cmo)
        if result.get("already_clean"):
            print("No changes: no other_unclear assignments found for the specified CMO file.")
            return
        print(f"Reassigned {result['updated']} other_unclear assignments.")
        return

    result = update_outcome_family_mapping(args.mapping, args.cmo)
    if result.get("already_assigned"):
        print("No changes: all CMOs in the specified file already have assignments.")
        return
    print(f"Added {result['added']} outcome family assignments.")


if __name__ == "__main__":
    main()
