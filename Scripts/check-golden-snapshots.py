"""Require declared golden tests and tracked fixtures, then verify them without recording."""

import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "Scripts" / "required-golden-snapshots.json"
SUITE = "TupleKitSnapshotTests.GoldenSnapshotTests"
FIXTURES = Path("Tests/TupleKitSnapshotTests/__Snapshots__/GoldenSnapshotTests")


def read_contracts() -> dict[str, list[str]]:
    try:
        contracts = json.loads(MANIFEST.read_text(encoding="utf-8"))
    except (OSError, ValueError) as error:
        raise ValueError(f"cannot read {MANIFEST.name}: {error}") from error
    if not isinstance(contracts, dict) or not contracts:
        raise ValueError("declare at least one snapshot test in required-golden-snapshots.json")
    for test, fixtures in contracts.items():
        if not test.isidentifier() or not isinstance(fixtures, list) or not fixtures:
            raise ValueError(f"expected a test name and nonempty fixture list: {test!r}")
        for name in fixtures:
            if not isinstance(name, str) or name in {"", ".", ".."} or Path(name).name != name:
                raise ValueError(f"expected a fixture filename for {test}: {name!r}")
    return contracts


def fixture_problems(contracts: dict[str, list[str]]) -> list[str]:
    pushed_ref = os.environ.get("PRE_COMMIT_TO_REF")
    if pushed_ref:
        command = ["git", "ls-tree", "-rz", "--name-only", pushed_ref, "--", str(FIXTURES)]
        missing_message = "Snapshot fixture not in pushed commit"
    else:
        command = ["git", "ls-files", "-z", "--", str(FIXTURES)]
        missing_message = "Untracked snapshot fixture"
    tracked_paths = set(os.fsdecode(subprocess.check_output(command, cwd=ROOT)).split("\0"))
    fixture_names = {name for fixtures in contracts.values() for name in fixtures}
    problems = []
    for name in sorted(fixture_names):
        path = FIXTURES / name
        if not (ROOT / path).is_file():
            problems.append(f"Missing snapshot fixture: {name} (expected at {path})")
        elif str(path) not in tracked_paths:
            problems.append(f"{missing_message}: {name} (stage and commit {path})")
    return problems


def test_problems(contracts: dict[str, list[str]], environment: dict[str, str]) -> list[str]:
    listing = subprocess.check_output(["swift", "test", "list"], cwd=ROOT, env=environment, text=True)
    discovered = {line.strip().removesuffix("()") for line in listing.splitlines()}
    required = {f"{SUITE}/{test}" for test in contracts}
    return [f"Missing snapshot test: {test}" for test in sorted(required - discovered)]


def main() -> int:
    environment = {**os.environ, "SNAPSHOT_TESTING_RECORD": "never"}
    try:
        contracts = read_contracts()
        problems = fixture_problems(contracts) or test_problems(contracts, environment)
        if problems:
            print("\n".join(problems), file=sys.stderr)
            return 1
        return subprocess.run(
            ["swift", "test", "--skip-build", "--filter", f"{re.escape(SUITE)}/"],
            cwd=ROOT,
            env=environment,
            check=False,
        ).returncode
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"Could not verify required golden snapshots: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
