#!/usr/bin/env python3
"""Fails when line coverage of the library sources drops below a minimum.

Run after `swift test --enable-code-coverage`:

    python3 Scripts/check-coverage.py --minimum 95

The script reads the llvm-cov JSON export that `swift test --show-codecov-path` names and
reports every library source file in it. llvm-cov lists every compiled file that contains
executable code, even at 0% coverage, so a file with only declarations, such as an empty
conformance, is the only kind that is absent.
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LIBRARY_SOURCES = [ROOT / "Sources" / "TupleKit", ROOT / "Sources" / "TupleKitComposition"]


def codecov_path() -> Path:
    output = subprocess.run(
        ["swift", "test", "--show-codecov-path"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return Path(output.stdout.strip())


def library_files() -> set[Path]:
    return {path.resolve() for source in LIBRARY_SOURCES for path in source.rglob("*.swift")}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--minimum", type=float, required=True, help="minimum line coverage, in percent")
    parser.add_argument("--report", type=Path, help="llvm-cov JSON export; defaults to swift test's path")
    arguments = parser.parse_args()

    report = arguments.report or codecov_path()
    if not report.is_file():
        print(f"FAIL no coverage report at {report}; run swift test --enable-code-coverage first")
        return 1

    expected = library_files()
    covered_lines = 0
    total_lines = 0
    for entry in json.loads(report.read_text())["data"][0]["files"]:
        path = Path(entry["filename"]).resolve()
        if path not in expected:
            continue
        lines = entry["summary"]["lines"]
        covered_lines += lines["covered"]
        total_lines += lines["count"]
        print(f"{lines['percent']:6.1f}%  {path.relative_to(ROOT)}")

    percent = 100 * covered_lines / total_lines if total_lines else 0
    print(f"Line coverage: {percent:.2f}% ({covered_lines} of {total_lines} lines), minimum {arguments.minimum}%")
    if percent < arguments.minimum:
        print("FAIL line coverage is below the minimum")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
