"""
Tests for 02-expand-prompt-skill-refs.py

Run:  python3 -m pytest ~/.agents-system/hooks/tests/ -v
  or: python3 ~/.agents-system/hooks/tests/test_expand_prompt_skill_refs.py
"""

import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path

HOOK = Path(__file__).parent.parent / "02-expand-prompt-skill-refs.py"


# ---------------------------------------------------------------------------
# Load hook as module so we can test internal functions without subprocess
# ---------------------------------------------------------------------------
spec = importlib.util.spec_from_file_location("skill_hook", HOOK)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


def _run(prompt: str, cwd: str = "/tmp", claude: bool = True) -> tuple[int, str]:
    """Invoke the hook via subprocess, return (returncode, stdout)."""
    data = json.dumps({"prompt": prompt, "cwd": cwd, "hook_event_name": "UserPromptSubmit"})
    env = os.environ.copy()
    if claude:
        env["CLAUDE_PROJECT_DIR"] = "/tmp"
    else:
        env.pop("CLAUDE_PROJECT_DIR", None)
    result = subprocess.run(
        [sys.executable, str(HOOK)],
        input=data,
        capture_output=True,
        text=True,
        env=env,
        timeout=10,
    )
    return result.returncode, result.stdout


# ---------------------------------------------------------------------------
# Unit tests for find_skill
# ---------------------------------------------------------------------------
class TestFindSkill(unittest.TestCase):

    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        # skill tree: tmp/skills/browser/domain-skills/higgsfield
        #             tmp/skills/browser/app-skills/slack
        #             tmp/skills/animator/node_modules/browser  ← must be pruned
        self._make("skills/browser/SKILL.md", "---\ndescription: Browser automation\n---\n")
        self._make("skills/browser/domain-skills/higgsfield/SKILL.md",
                   "---\ndescription: Higgsfield image gen\n---\n")
        self._make("skills/browser/app-skills/slack/SKILL.md", "# Slack\nSlack skill.\n")
        # Decoy inside node_modules — must NOT be returned for $browser
        self._make("skills/animator/node_modules/browser/fake.txt", "")

    def _make(self, rel: str, content: str):
        p = Path(self.tmp) / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(content)

    def _search_dirs(self):
        return [str(Path(self.tmp) / "skills")]

    def test_fuzzy_top_level(self):
        result = mod.find_skill("browser", self._search_dirs())
        self.assertIsNotNone(result)
        self.assertEqual(Path(result).name, "browser")
        self.assertNotIn("node_modules", result)

    def test_fuzzy_nested(self):
        result = mod.find_skill("higgsfield", self._search_dirs())
        self.assertIsNotNone(result)
        self.assertTrue(result.endswith("higgsfield"))
        self.assertNotIn("node_modules", result)

    def test_relative_path(self):
        result = mod.find_skill("browser/domain-skills/higgsfield", self._search_dirs())
        self.assertIsNotNone(result)
        self.assertTrue(result.endswith("higgsfield"))

    def test_deep_relative_path(self):
        result = mod.find_skill("domain-skills/higgsfield", self._search_dirs())
        self.assertIsNotNone(result)
        self.assertTrue(result.endswith("higgsfield"))

    def test_node_modules_pruned(self):
        # $browser should hit the real browser dir, not animator/node_modules/browser
        result = mod.find_skill("browser", self._search_dirs())
        self.assertNotIn("node_modules", result or "")

    def test_unknown_skill(self):
        result = mod.find_skill("composerxyz", self._search_dirs())
        self.assertIsNone(result)


# ---------------------------------------------------------------------------
# Unit tests for get_description
# ---------------------------------------------------------------------------
class TestGetDescription(unittest.TestCase):

    def _skill(self, content: str) -> str:
        d = tempfile.mkdtemp()
        Path(d, "SKILL.md").write_text(content)
        return d

    def test_frontmatter_description(self):
        d = self._skill("---\ndescription: My skill desc\n---\n\n# Title\n")
        self.assertEqual(mod.get_description(d), "My skill desc")

    def test_frontmatter_quoted(self):
        d = self._skill('---\ndescription: "Quoted desc"\n---\n')
        self.assertEqual(mod.get_description(d), "Quoted desc")

    def test_fallback_first_content_line(self):
        d = self._skill("# Title\n\nFirst real line here.\n")
        self.assertEqual(mod.get_description(d), "First real line here.")

    def test_no_skill_md(self):
        d = tempfile.mkdtemp()
        self.assertIsNone(mod.get_description(d))

    def test_truncated_to_120(self):
        long_line = "x" * 200
        d = self._skill(f"# H\n{long_line}\n")
        result = mod.get_description(d)
        self.assertLessEqual(len(result), 120)


# ---------------------------------------------------------------------------
# Integration tests via subprocess (full stdin → stdout contract)
# ---------------------------------------------------------------------------
class TestHookIntegration(unittest.TestCase):

    AGENTS_SKILLS = Path.home() / ".agents" / "skills"

    def test_no_dollar_sign_exits_silently(self):
        code, out = _run("just a plain prompt")
        self.assertEqual(code, 0)
        self.assertEqual(out.strip(), "")

    def test_unknown_skill_exits_silently(self):
        code, out = _run("use $zzznoskillhere please")
        self.assertEqual(code, 0)
        self.assertEqual(out.strip(), "")

    def test_browser_skill_expands_to_real_path(self):
        if not (self.AGENTS_SKILLS / "browser").is_dir():
            self.skipTest("~/.agents/skills/browser not present")
        code, out = _run("use $browser for automation")
        self.assertEqual(code, 0)
        self.assertIn("<user-prompt-submit-hook>", out)
        self.assertIn("/skills/browser", out)
        self.assertNotIn("node_modules", out)

    def test_higgsfield_fuzzy_match(self):
        higgsfield = self.AGENTS_SKILLS / "browser" / "domain-skills" / "higgsfield"
        if not higgsfield.is_dir():
            self.skipTest("higgsfield skill not present")
        code, out = _run("$higgsfield generate a sunset image")
        self.assertEqual(code, 0)
        self.assertIn("<user-prompt-submit-hook>", out)
        self.assertIn("higgsfield", out)
        self.assertNotIn("node_modules", out)

    def test_relative_nested_path(self):
        higgsfield = self.AGENTS_SKILLS / "browser" / "domain-skills" / "higgsfield"
        if not higgsfield.is_dir():
            self.skipTest("higgsfield skill not present")
        code, out = _run("use $browser/domain-skills/higgsfield")
        self.assertEqual(code, 0)
        self.assertIn("higgsfield", out)
        self.assertNotIn("node_modules", out)

    def test_multiple_tokens_in_one_prompt(self):
        browser = self.AGENTS_SKILLS / "browser"
        if not browser.is_dir():
            self.skipTest("browser skill not present")
        code, out = _run("use $browser and $higgsfield together")
        self.assertEqual(code, 0)
        # At least browser should expand; higgsfield may or may not exist
        self.assertIn("/skills/browser", out)

    def test_codex_output_format(self):
        """Non-Claude agents get JSON additionalContext instead of wrapper tag."""
        higgsfield = self.AGENTS_SKILLS / "browser" / "domain-skills" / "higgsfield"
        if not higgsfield.is_dir():
            self.skipTest("higgsfield skill not present")
        code, out = _run("$higgsfield test", claude=False)
        self.assertEqual(code, 0)
        parsed = json.loads(out)
        self.assertIn("hookSpecificOutput", parsed)
        self.assertIn("additionalContext", parsed["hookSpecificOutput"])

    def test_dollar_in_code_backtick_not_expanded(self):
        """$PATH-style tokens that don't match skills should pass through silently."""
        code, out = _run("the env var is `$PATH` and `$HOME`")
        self.assertEqual(code, 0)
        self.assertEqual(out.strip(), "")


if __name__ == "__main__":
    unittest.main(verbosity=2)
