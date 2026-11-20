"""Exercise the golden snapshot gate as a command in a temporary Git checkout."""

import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

CHECKER = Path(__file__).with_name("check-golden-snapshots.py").resolve()
SUITE = "TupleKitSnapshotTests.GoldenSnapshotTests"
SUITE_FILTER = r"TupleKitSnapshotTests\.GoldenSnapshotTests/"


class GoldenSnapshotGateTests(unittest.TestCase):
    def setUp(self):
        scratch = tempfile.TemporaryDirectory()
        self.addCleanup(scratch.cleanup)
        self.root = Path(scratch.name)
        scripts = self.root / "Scripts"
        scripts.mkdir()
        self.checker = scripts / CHECKER.name
        if CHECKER.is_file():
            shutil.copyfile(CHECKER, self.checker)

        snapshots = self.root / "Tests" / "TupleKitSnapshotTests"
        self.fixture = snapshots / "__Snapshots__" / "GoldenSnapshotTests" / "renderedValue.1.txt"
        self.fixture.parent.mkdir(parents=True)
        self.fixture.write_text("ready\n", encoding="utf-8")
        (scripts / "required-golden-snapshots.json").write_text(
            json.dumps({"renderedValue": [self.fixture.name]}), encoding="utf-8"
        )
        self.git("init", "--quiet")
        self.git("add", str(self.fixture))

        self.discovered = self.root / "discovered.txt"
        self.discovered.write_text(f"{SUITE}/renderedValue()\n", encoding="utf-8")
        fake_swift = self.root / "swift"
        fake_swift.write_text(
            "#!/usr/bin/env python3\n"
            "import os, sys\n"
            "from pathlib import Path\n"
            "args = sys.argv[1:]\n"
            "if args == ['test', 'list']:\n"
            "    sys.stdout.write(Path('discovered.txt').read_text())\n"
            f"elif args == ['test', '--skip-build', '--filter', {SUITE_FILTER!r}]:\n"
            "    assert os.environ['SNAPSHOT_TESTING_RECORD'] == 'never'\n"
            "    sys.exit(int(os.environ.get('SNAPSHOT_EXIT_CODE', '0')))\n"
            "else:\n"
            "    sys.exit(f'unexpected Swift invocation: {args}')\n",
            encoding="utf-8",
        )
        fake_swift.chmod(0o755)

    def git(self, *arguments):
        subprocess.run(["git", *arguments], cwd=self.root, check=True, capture_output=True)

    def run_checker(self, *, snapshot_exit_code=0, pushed_ref=None):
        environment = {
            **os.environ,
            "PATH": f"{self.root}{os.pathsep}{os.environ['PATH']}",
            "SNAPSHOT_TESTING_RECORD": "all",
            "SNAPSHOT_EXIT_CODE": str(snapshot_exit_code),
        }
        environment.pop("PRE_COMMIT_TO_REF", None)
        if pushed_ref is not None:
            environment["PRE_COMMIT_TO_REF"] = pushed_ref
        return subprocess.run(
            [sys.executable, str(self.checker)],
            cwd=self.root, env=environment, capture_output=True, text=True,
        )

    def test_accepts_required_fixture_and_discovered_test_in_read_only_mode(self):
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_rejects_missing_required_test_even_when_fixture_exists(self):
        self.discovered.write_text(f"{SUITE}/renderedValueAlternative()\n", encoding="utf-8")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(f"Missing snapshot test: {SUITE}/renderedValue", result.stderr)

    def test_rejects_an_untracked_fixture(self):
        self.git("rm", "--cached", "--quiet", str(self.fixture))
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(f"Untracked snapshot fixture: {self.fixture.name}", result.stderr)

    def test_rejects_a_missing_fixture(self):
        self.fixture.unlink()
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(f"Missing snapshot fixture: {self.fixture.name}", result.stderr)

    def test_rejects_a_fixture_staged_but_not_in_the_pushed_commit(self):
        self.git("rm", "--cached", "--quiet", str(self.fixture))
        self.git("-c", "user.name=Test", "-c", "user.email=test@example.com",
                 "-c", "commit.gpgsign=false", "commit", "--quiet", "--allow-empty", "-m", "test")
        self.git("add", str(self.fixture))
        result = self.run_checker(pushed_ref="HEAD")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(f"Snapshot fixture not in pushed commit: {self.fixture.name}", result.stderr)

    def test_propagates_snapshot_test_failure(self):
        self.assertEqual(self.run_checker(snapshot_exit_code=7).returncode, 7)


if __name__ == "__main__":
    unittest.main()
