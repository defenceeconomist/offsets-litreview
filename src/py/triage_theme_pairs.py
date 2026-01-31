import csv
import math
import re
from collections import Counter, defaultdict

import numpy as np
import yaml

from embed_mechanisms import embed_texts

_WORD_RE = re.compile(r"[a-zA-Z']+")

DEFAULT_STOPWORDS = set(
    "the a an and or to of in for on with by as into is are be being been this that these "
    "those via from when where how why which while not only more less without within across"
    .split()
)
DEFAULT_STOPWORDS |= set(
    [
        "offset",
        "offsets",
        "mechanism",
        "mechanisms",
        "process",
        "processes",
        "policy",
        "policies",
        "theme",
        "themes",
        "use",
        "using",
        "used",
        "uses",
        "via",
        "through",
        "based",
        "focus",
        "focuses",
        "include",
        "includes",
        "including",
        "may",
        "can",
        "could",
        "would",
        "should",
        "makes",
        "make",
        "making",
    ]
)


def _stem(word):
    for suf in ("ing", "ed", "ly", "tion", "s"):
        if word.endswith(suf) and len(word) > len(suf) + 2:
            return word[: -len(suf)]
    return word


def _tokens(text, stopwords):
    if text is None:
        return []
    words = _WORD_RE.findall(text.lower())
    return [_stem(w) for w in words if w not in stopwords and len(w) > 2]


def build_tfidf_vectors(theme_texts, stopwords=None, top_terms=8):
    stopwords = stopwords or DEFAULT_STOPWORDS
    term_counts = {}
    df = defaultdict(int)
    for theme_id, text in theme_texts.items():
        cnt = Counter(_tokens(text, stopwords))
        term_counts[theme_id] = cnt
        for term in cnt:
            df[term] += 1

    n_docs = len(theme_texts)
    idf = {term: math.log((n_docs + 1) / (df_t + 1)) + 1 for term, df_t in df.items()}

    vectors = {}
    key_terms = {}
    for theme_id, cnt in term_counts.items():
        total = sum(cnt.values()) or 1
        vec = {term: (freq / total) * idf[term] for term, freq in cnt.items()}
        vectors[theme_id] = vec
        top = sorted(vec.items(), key=lambda x: x[1], reverse=True)[:top_terms]
        key_terms[theme_id] = [t for t, _ in top]

    return vectors, key_terms


def cosine(v1, v2):
    if not v1 or not v2:
        return 0.0
    dot = 0.0
    for term, val in v1.items():
        if term in v2:
            dot += val * v2[term]
    n1 = math.sqrt(sum(v * v for v in v1.values()))
    n2 = math.sqrt(sum(v * v for v in v2.values()))
    if n1 == 0 or n2 == 0:
        return 0.0
    return dot / (n1 * n2)


def triage_theme_pairs(
    theme_pairs_csv,
    proto_themes_yml,
    output_yml,
    likely_threshold=0.2,
    possible_threshold=0.1,
):
    with open(proto_themes_yml, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)

    theme_texts = {}
    for theme in data.get("proto_mechanism_themes", []):
        theme_id = theme.get("theme_id")
        label = theme.get("theme_label", "")
        explanation = theme.get("mechanism_explanation", "")
        theme_texts[theme_id] = f"{label} {explanation}"

    vectors, key_terms = build_tfidf_vectors(theme_texts)

    triage_pairs = []
    with open(theme_pairs_csv, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            a = row["theme_a_id"]
            b = row["theme_b_id"]
            sim = cosine(vectors.get(a, {}), vectors.get(b, {}))
            if sim >= likely_threshold:
                triage = "likely_overlap"
            elif sim >= possible_threshold:
                triage = "possible_overlap"
            else:
                triage = "no_overlap"

            note = ""
            if triage != "no_overlap":
                shared = [t for t in key_terms.get(a, []) if t in key_terms.get(b, [])]
                if shared:
                    note = "Shared terms: " + ", ".join(shared[:4]) + "."
                else:
                    note = "Potential overlap in causal logic based on labels/explanations."

            triage_pairs.append(
                {
                    "pair_id": row["pair_id"],
                    "theme_a_id": a,
                    "theme_b_id": b,
                    "triage": triage,
                    "note": note,
                }
            )

    with open(output_yml, "w", encoding="utf-8") as f:
        yaml.safe_dump({"triage_pairs": triage_pairs}, f, sort_keys=False, allow_unicode=True, width=120)

    return triage_pairs


def triage_theme_pairs_embeddings(
    theme_pairs_csv,
    proto_themes_yml,
    output_yml,
    model_name="all-MiniLM-L6-v2",
    batch_size=32,
    device="cpu",
    normalize=True,
    cache_path="data/embeddings_cache.sqlite",
    likely_threshold=0.6,
    possible_threshold=0.45,
):
    with open(proto_themes_yml, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)

    theme_ids = []
    texts = []
    for theme in data.get("proto_mechanism_themes", []):
        theme_id = theme.get("theme_id")
        label = theme.get("theme_label", "")
        explanation = theme.get("mechanism_explanation", "")
        theme_ids.append(theme_id)
        texts.append(f"{label} {explanation}")

    embeddings = embed_texts(
        texts=texts,
        model_name=model_name,
        batch_size=batch_size,
        normalize=normalize,
        device=device,
        cache_path=cache_path,
    )

    theme_vecs = {tid: embeddings[i] for i, tid in enumerate(theme_ids)}

    triage_pairs = []
    with open(theme_pairs_csv, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            a = row["theme_a_id"]
            b = row["theme_b_id"]
            va = theme_vecs.get(a)
            vb = theme_vecs.get(b)
            if va is None or vb is None:
                sim = 0.0
            else:
                if normalize:
                    sim = float(np.dot(va, vb))
                else:
                    sim = float(np.dot(va, vb) / (np.linalg.norm(va) * np.linalg.norm(vb)))

            if sim >= likely_threshold:
                triage = "likely_overlap"
            elif sim >= possible_threshold:
                triage = "possible_overlap"
            else:
                triage = "no_overlap"

            note = ""
            if triage != "no_overlap":
                note = f"cosine={sim:.3f}"

            triage_pairs.append(
                {
                    "pair_id": row["pair_id"],
                    "theme_a_id": a,
                    "theme_b_id": b,
                    "triage": triage,
                    "note": note,
                }
            )

    with open(output_yml, "w", encoding="utf-8") as f:
        yaml.safe_dump({"triage_pairs": triage_pairs}, f, sort_keys=False, allow_unicode=True, width=120)

    return triage_pairs
