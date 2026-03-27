#!/usr/bin/env python3
"""Tests for check-phase.py phase computation logic."""

import sys
from pathlib import Path

# Import from same directory
sys.path.insert(0, str(Path(__file__).parent))
from importlib.machinery import SourceFileLoader
mod = SourceFileLoader("check_phase", str(Path(__file__).parent / "check-phase.py")).load_module()


def test_phase1_new_account():
    """Day 0, 0 followers = Phase 1."""
    assert mod.compute_phase(0, 0) == 1

def test_phase1_age_but_no_followers():
    """Day 15 but only 30 followers = still Phase 1 (need 50)."""
    assert mod.compute_phase(15, 30) == 1

def test_phase1_followers_but_no_age():
    """Day 5 but 100 followers = still Phase 1 (need 14 days)."""
    assert mod.compute_phase(5, 100) == 1

def test_phase2_both_met():
    """Day 14, 50 followers = Phase 2."""
    assert mod.compute_phase(14, 50) == 2

def test_phase2_exceeds_minimums():
    """Day 20, 150 followers = still Phase 2 (not yet Phase 3)."""
    assert mod.compute_phase(20, 150) == 2

def test_phase3_both_met():
    """Day 28, 200 followers = Phase 3."""
    assert mod.compute_phase(28, 200) == 3

def test_phase3_well_past():
    """Day 60, 500 followers = Phase 3."""
    assert mod.compute_phase(60, 500) == 3

def test_phase3_age_but_not_followers():
    """Day 30 but only 100 followers = Phase 2 (not Phase 3, need 200)."""
    assert mod.compute_phase(30, 100) == 2

def test_phase3_followers_but_not_age():
    """Day 20 but 300 followers = Phase 2 (not Phase 3, need 28 days)."""
    assert mod.compute_phase(20, 300) == 2

def test_parse_yaml_flat():
    """Test the minimal YAML parser."""
    import tempfile
    content = """account:
  handle: "@GetRushOS"
  created_at: "2026-03-19"
  premium: true
phase: 1
cooldown:
  active: false
  since: null
last_session: "2026-03-20"
"""
    tmp = Path(tempfile.mktemp(suffix=".yaml"))
    tmp.write_text(content)
    data = mod.parse_yaml_flat(tmp)
    assert data["account"]["handle"] == "@GetRushOS"
    assert data["account"]["created_at"] == "2026-03-19"
    assert data["account"]["premium"] is True
    assert data["phase"] == "1"
    assert data["cooldown"]["active"] is False
    assert data["cooldown"]["since"] is None
    assert data["last_session"] == "2026-03-20"
    tmp.unlink()


if __name__ == "__main__":
    tests = [v for k, v in sorted(globals().items()) if k.startswith("test_")]
    passed = 0
    failed = 0
    for test in tests:
        try:
            test()
            passed += 1
            print(f"  PASS: {test.__name__}")
        except AssertionError as e:
            failed += 1
            print(f"  FAIL: {test.__name__}: {e}")
        except Exception as e:
            failed += 1
            print(f"  ERROR: {test.__name__}: {e}")
    print(f"\n{passed} passed, {failed} failed")
    sys.exit(1 if failed else 0)
