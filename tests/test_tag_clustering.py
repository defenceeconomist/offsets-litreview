import unittest
from pathlib import Path
import sys

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS))

from tag_clustering import build_tag_hierarchy, group_near_duplicates  # noqa: E402


class TestGroupNearDuplicates(unittest.TestCase):
    def test_groups_similar_texts(self):
        vectors = {
            "alpha": np.array([1.0, 0.0], dtype=np.float32),
            "alpha2": np.array([0.9, 0.1], dtype=np.float32),
            "beta": np.array([0.0, 1.0], dtype=np.float32),
        }

        def embed_fn(texts):
            return np.vstack([vectors[t] for t in texts])

        groups = group_near_duplicates(
            ["alpha", "alpha2", "beta"],
            embed_fn=embed_fn,
            model_name="m",
            threshold=0.95,
            cache_path=None,
        )

        self.assertEqual(len(groups), 1)
        self.assertEqual(groups[0].texts, ["alpha", "alpha2"])


class TestBuildTagHierarchy(unittest.TestCase):
    def test_builds_hierarchy_when_scipy_available(self):
        try:
            import scipy  # noqa: F401
        except Exception:
            self.skipTest("scipy not available")

        vectors = {
            "alpha": np.array([1.0, 0.0], dtype=np.float32),
            "beta": np.array([0.0, 1.0], dtype=np.float32),
            "gamma": np.array([0.7, 0.3], dtype=np.float32),
        }

        def embed_fn(texts):
            return np.vstack([vectors[t] for t in texts])

        items = ["alpha", "beta", "gamma"]
        result = build_tag_hierarchy(
            items,
            embed_fn=embed_fn,
            model_name="m",
            cache_path=None,
        )

        self.assertEqual(len(result.labels), len(items))
        self.assertEqual(sorted(result.order), [0, 1, 2])


if __name__ == "__main__":
    unittest.main()
