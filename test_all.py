"""Entry point so `python -m unittest` discovers tests/ by default."""

import unittest


def load_tests(loader, tests, pattern):
    return loader.discover("tests")


if __name__ == "__main__":
    unittest.main()
