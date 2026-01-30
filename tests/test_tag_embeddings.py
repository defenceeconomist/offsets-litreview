import unittest
from pathlib import Path
import tempfile
import sys

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS))

from tag_embeddings import (  # noqa: E402
    EmbeddingCache,
    embed_texts,
    embed_with_cache,
    normalize_inputs,
)


class TestNormalizeInputs(unittest.TestCase):
    def test_list_of_strings(self):
        items = ["alpha", "beta"]
        normalized = normalize_inputs(items)
        self.assertEqual([n.id for n in normalized], ["0", "1"])
        self.assertEqual([n.text for n in normalized], items)

    def test_list_of_dicts(self):
        items = [{"id": "a", "text": "alpha"}, {"text": "beta"}]
        normalized = normalize_inputs(items)
        self.assertEqual([n.id for n in normalized], ["a", "1"])
        self.assertEqual([n.text for n in normalized], ["alpha", "beta"])

    def test_dict_mapping(self):
        items = {"x": "alpha", "y": "beta"}
        normalized = normalize_inputs(items)
        self.assertEqual([n.id for n in normalized], ["x", "y"])
        self.assertEqual([n.text for n in normalized], ["alpha", "beta"])

    def test_missing_text_key(self):
        with self.assertRaises(ValueError):
            normalize_inputs([{"id": "a"}])


class TestEmbeddingCache(unittest.TestCase):
    def test_round_trip(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            path = Path(tmpdir) / "embeddings.sqlite"
            cache = EmbeddingCache(str(path))
            vec = np.array([1.0, 2.0, 3.0], dtype=np.float32)
            cache.set("model", "text", vec)
            loaded = cache.get("model", "text")
            cache.close()
        self.assertIsNotNone(loaded)
        self.assertTrue(np.allclose(loaded, vec))


class TestEmbeddingFunctions(unittest.TestCase):
    def test_embed_texts_normalizes(self):
        def embed_fn(texts):
            return np.array([[3.0, 4.0], [0.0, 0.0]], dtype=np.float32)

        vecs = embed_texts(["a", "b"], embed_fn, normalize=True)
        self.assertTrue(np.allclose(vecs[0], np.array([0.6, 0.8], dtype=np.float32)))
        self.assertTrue(np.allclose(vecs[1], np.array([0.0, 0.0], dtype=np.float32)))

    def test_embed_with_cache_reuses(self):
        calls = {"count": 0}

        def embed_fn(texts):
            calls["count"] += 1
            return np.eye(len(texts), dtype=np.float32)

        texts = ["a", "b"]
        with tempfile.TemporaryDirectory() as tmpdir:
            path = Path(tmpdir) / "embeddings.sqlite"
            cache = EmbeddingCache(str(path))
            first = embed_with_cache(texts, embed_fn, model_name="m", cache=cache, normalize=False)
            self.assertEqual(calls["count"], 1)
            second = embed_with_cache(texts, embed_fn, model_name="m", cache=cache, normalize=False)
            self.assertEqual(calls["count"], 1)
            cache.close()

        self.assertTrue(np.allclose(first, second))


if __name__ == "__main__":
    unittest.main()
