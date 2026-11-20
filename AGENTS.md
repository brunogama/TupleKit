## Agent skills

### Issue tracker

Issues live as local markdown files under `.scratch/<feature-slug>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default triage roles, recorded as a `Status:` line in each issue file: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

### Swift development conventions

- This repository is a Swift Package Manager library. `Package.swift` defines supported platforms, products, targets, and Swift language mode; do not infer or expand those contracts from local toolchain availability.
- Preserve the package's typed parameter-pack APIs and public behavior. Check `README.md`, `ARCHITECTURE.md`, `GLOSSARY.md`, and relevant ADRs before changing public interfaces or domain terminology.
- Follow the repository's `.swift-format` and SwiftLint configurations as the executable style rules. Do not add local suppressions, exclusions, or alternate formatting policy.
- Keep tests at public behavior boundaries and run the package's documented build and test commands after relevant changes. Add focused regression coverage for behavior changes.
- Use the project-local Swift skills in `.agents/skills/` as guidance; identical copies under `.claude/skills/`, `.pi/skills/`, and `.cursor/skills/` are external to the scaffold manifest and are not checked by `scaffold check`.

<!-- BEGIN swift-quality (managed by provision-swift-quality.sh; edits inside are replaced) -->
# Swift coding and validation contract

## Sources of truth

Before editing Swift code:

1. Read the applicable repository instructions.
2. Read `.swift-format`.
3. Read `.swiftlint.yml`.
4. For test changes, read `Tests/.swiftlint.yml`.
5. Read configurations referenced by those files (for example `parent_config`).
6. Inspect `scripts/swift-style` and `.swift-style.env`.
7. Inspect nearby compliant Swift code.

Do not assume configuration contents.
Do not claim to have inspected files you have not read.

The executable configurations are authoritative over your default style.
Follow higher-priority instructions if a conflict exists, and report limitations.

## Configuration scope

The style wrapper manages:

- `Sources/`: root `.swiftlint.yml`.
- `Benchmarks/`: root `.swiftlint.yml`.
- `Tests/`: explicit `Tests/.swiftlint.yml`.
- All managed files: root `.swift-format`.

`Package.swift` and other directories are outside this gate.

The wrapper does not provide automatic nested configuration discovery.
If the task requires additional configuration scopes, report the mismatch.
Do not change routing or configuration without authorization.

## Start with a brief plan

Before editing, state in a few lines: the files you expect to change, the
configured rules that matter for this change, and the validation commands you
will run. Then do the work; do not stop after the plan unless you need
clarification or authorization.

## Generate compliant code from the start

Before editing, briefly identify the configured requirements relevant to this
task: indentation, line length, documentation, naming and identifier lengths,
parameter counts, function/type/file length, cyclomatic complexity, nesting,
custom rules, and prohibited constructs.

Use the actual configuration, including inherited rules and default-enabled
SwiftLint rules. Do not inspect only the `opt_in_rules` list.

A rule disabled in `.swift-format` is not blanket permission: check SwiftLint
and repository instructions for an independent restriction.

Validation runs with `--strict`: warnings fail exactly like errors.

Design meaningful functions and clear control flow to satisfy structural rules.
Do not move complexity around merely to evade a metric.

## Scope discipline

Track every Swift file you create or modify.

- Preserve unrelated user changes.
- Do not format unrelated files.
- Do not edit generated or vendored files without authorization.
- Do not stage, commit, or push unless requested.
- Do not assume `git diff` lists only your own edits.

## Mandatory edit loop

After a coherent Swift change:

1. Run `bash scripts/swift-style fix <explicit edited Swift files>`.
2. Read diagnostics and fix the underlying violations.
3. Repeat until successful or genuinely blocked.
4. Run the relevant build and tests.
5. After the final Swift edit, run
   `bash scripts/swift-style check <explicit edited Swift files>`.

Use actual repository-relative paths.
Do not use `--all` with `fix`.
Do not run the wrapper with an empty file list.
Any later Swift edit invalidates the affected validation results.
Do not make an unvalidated "small cleanup" after the final successful check.
If the formatter changed code, inspect its changes before reporting completion.

## Use diagnostics as feedback

When a check fails, read the full diagnostic, identify the file, line, and rule,
and decide whether it is a violation you introduced, a pre-existing violation,
a configuration conflict, or a tooling failure. Make the smallest correct fix
within scope and rerun. Do not guess rule semantics when the configuration and
diagnostic can be read. If repeated attempts fail the same way, stop editing
speculatively and report the blocker.

Prefer real compliance over metric manipulation: extract helpers only for real
responsibilities, keep descriptive names instead of abbreviating to satisfy
length limits, and add or update tests when refactoring behavior-sensitive code.

## Git hooks

If the repository has hooks installed (prek or pre-commit), a commit runs
`swift-style format` on staged Swift files and a push runs `swift-style check`.
Hooks are a convenience, not your validation: still run the edit loop above.
If a commit stops because the formatter changed files, review the change,
re-add the files, and commit again.

## Analyzer rules

If `.swiftlint.yml` declares `analyzer_rules`, ordinary style checks do not run
them. Use `scripts/swift-style-analyze` with a clean-build compiler log when
applicable. Do not fabricate a compiler log or claim analysis passed without
running it.

## Prohibited shortcuts

Without explicit authorization, do not:

- Modify style configurations or `.swift-style.env`.
- Modify validation scripts or CI to make a check pass.
- Disable rules or raise thresholds.
- Expand exclusions or baselines.
- Add `swiftlint:disable` or formatter-ignore directives.
- Ignore command failures or append `|| true`.
- Bypass Git hooks with `--no-verify` or `SKIP=` variables.
- Install tools or change the environment without required approval.
- Claim compliance from visual inspection alone.

If a configuration conflict occurs, identify the conflicting rules and report it.

## Validation integrity

A successful style check does not prove compilation, tests, concurrency
correctness, architecture, or analyzer compliance.

Inspect exclusions and suppressions before claiming coverage.
Use repository-documented build and test commands.
Do not invent an Xcode scheme, destination, workspace, or package structure.
If a command cannot run, mark it NOT RUN or BLOCKED and explain why.

## Completion

Before responding, check that you actually read the configurations, followed
them instead of your default style, validated every Swift file you touched
after its final edit, and did not weaken any rule. Then:

- Review your final diff.
- Verify checks ran after the final relevant edits.
- Verify no unauthorized suppressions or policy changes were introduced.
- Preserve unrelated user work.

Report:

### Changes
What changed and why.

### Validation
Exact commands and PASS, FAIL, NOT RUN, or BLOCKED for each.

### Remaining issues
Unresolved violations, failures, or coverage limitations.

Never fabricate validation results.
<!-- END swift-quality -->
