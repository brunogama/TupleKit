#!/usr/bin/env bash
# Checks positive consumers, rejected programs, and known compiler bugs against the library.
#
# Each fixture in Tests/NegativeTypeChecks must fail to compile, with errors only on lines
# marked "// expected-error". An error on any other line means the fixture broke for an
# unrelated reason and no longer proves its contract.
#
# Each fixture in Tests/KnownCompilerBugs must still hit its compiler bug: a crash, or an
# error only on lines marked "// known-bug". When one compiles, a toolchain fixed that bug:
# remove the documented workaround and the fixture.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

swift build --product TupleKit >/dev/null
bin="$(swift build --show-bin-path)"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

failures=0
for fixture in Tests/PositiveTypeChecks/*.swift; do
    name="$(basename "$fixture")"
    if output="$(swiftc -swift-version 6 -emit-sil -o /dev/null -I "$bin" -I "$bin/Modules" "$fixture" 2>&1)"; then
        echo "ok   $name (positive consumer)"
    else
        echo "FAIL $name: supported consumer did not compile"
        printf '%s\n' "$output"
        failures=$((failures + 1))
    fi
done

for fixture in Tests/NegativeTypeChecks/*.swift; do
    name="$(basename "$fixture")"
    expected_lines="$(grep -n '// expected-error' "$fixture" | cut -d: -f1 | sort -u)"
    if [[ -z "$expected_lines" ]]; then
        echo "FAIL $name: no line is marked // expected-error"
        failures=$((failures + 1))
        continue
    fi

    if output="$(swiftc -swift-version 6 -emit-sil -o /dev/null -I "$bin" -I "$bin/Modules" "$fixture" 2>&1)"; then
        echo "FAIL $name: compiled successfully"
        failures=$((failures + 1))
        continue
    fi

    error_lines="$(printf '%s\n' "$output" \
        | sed -nE "s#^.*${name}:([0-9]+):[0-9]+: error:.*#\1#p" | sort -u)"
    if [[ "$error_lines" != "$expected_lines" ]]; then
        echo "FAIL $name: errors on lines [${error_lines//$'\n'/ }], expected [${expected_lines//$'\n'/ }]"
        printf '%s\n' "$output" | grep -E 'error:' | head -5
        failures=$((failures + 1))
        continue
    fi
    echo "ok   $name"
done

for fixture in Tests/KnownCompilerBugs/*.swift; do
    name="$(basename "$fixture")"
    marked_lines="$(grep -n '// known-bug' "$fixture" | cut -d: -f1 | sort -u)"
    if output="$(swiftc -swift-version 6 -c -o "$scratch/$name.o" -I "$bin" -I "$bin/Modules" "$fixture" 2>&1)"; then
        echo "FAIL $name: compiler fixed; remove the workaround and this fixture"
        failures=$((failures + 1))
        continue
    fi
    if grep -qi 'please submit a bug report' <<<"$output"; then
        echo "ok   $name (still crashes)"
        continue
    fi
    error_lines="$(printf '%s\n' "$output" \
        | sed -nE "s#^.*${name}:([0-9]+):[0-9]+: error:.*#\1#p" | sort -u)"
    if [[ -n "$marked_lines" && "$error_lines" == "$marked_lines" ]]; then
        echo "ok   $name (still rejected)"
    else
        echo "FAIL $name: errors on lines [${error_lines//$'\n'/ }], expected [${marked_lines//$'\n'/ }]"
        grep -E 'error:' <<<"$output" | head -3
        failures=$((failures + 1))
    fi
done

if ((failures > 0)); then
    echo "$failures compiler contract check(s) failed"
    exit 1
fi
