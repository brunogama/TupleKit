# Onboarding: TupleKit

> Get from zero to productive in this codebase.

---

## 1. Welcome & Project Overview

TupleKit is a Swift Package Manager library for fixed-shape product values: its `Tuple` type stores an ordered group of members while preserving each member's own static type. It uses Swift parameter packs, and provides typed access, transformations, combination, and a separate composition product. The primary users are Swift developers who need strongly typed heterogeneous product values. The package also includes a small example executable and test suites. For the full README, see [README.md](README.md); for public API examples, see [UseCases.md](Sources/TupleKit/TupleKit.docc/UseCases.md).

---

## 2. Prerequisites

- **Git and Swift 6.4.2 or later** to clone and build. On macOS, select an Xcode toolchain that reports Swift 6.4.2 or later in `swift --version`. Linux CI supplies Swift 6.4.2 via the `swift:6.4.2` container image; Docker is not a requirement for the local SwiftPM commands. See [Package.swift](Package.swift), [README.md](README.md#installation), and the [Swift workflow](.github/workflows/swift.yml).
- **macOS 14 / iOS 17** are the library deployment minimums, not the host requirements for installing Xcode. The iOS checks build both library products on a macOS runner; there is no iOS app to launch.
- **For the Swift style gate on macOS:** select Xcode 27.3 as pinned in [`.swift-style.env`](.swift-style.env) (the wrapper accepts a matching patch version) and use SwiftLint 0.63.2. The [quality workflow](.github/workflows/swift-quality.yml) shows the matching SwiftLint `.pkg` and installation steps. The wrapper needs `swift format` from the selected toolchain.
- **Python 3** for the repository scripts and Python tests below. The Linux CI job installs `python3` with `apt-get`; the basic Swift build and test commands do not use these scripts.
- **prek (optional)** for Git hooks. With `prek` installed, run `prek install` from the repository root as documented in [`prek.toml`](prek.toml).
- The library has no local database, cache, credentials, or service prerequisite (`ARCHITECTURE.md`).

---

## 3. Getting the Code

Clone the TupleKit repository over HTTPS:

```sh
git clone https://github.com/brunogama/TupleKit.git
cd TupleKit
```

This guide covers `main`. See the [README installation instructions](README.md#installation) to depend on the 1.0.0 release from another package.

---

## 4. Local Setup

This repository is a library, not a long-running web application, so there is no dev-server port or service to start. From a fresh clone, run these commands at the repository root:

```sh
swift --version
swift package resolve
swift build
SNAPSHOT_TESTING_RECORD=never swift test
swift run TupleKitClient
```

SwiftPM resolves SnapshotTesting from GitHub for the snapshot test target; neither library product links it. Setup is working when the tests pass and `TupleKitClient` prints `Tuple(1, true, "a")` followed by a typed debug description. No environment file, database, or credentials are needed to run the library or example.

---

## 5. Project Structure

See [ARCHITECTURE.md](ARCHITECTURE.md) for the component map and data-flow diagram.

```text
.
├── Package.swift
├── Sources/
│   ├── TupleKit/                 # Core Tuple value and APIs
│   ├── TupleKitComposition/      # Function composition, predicates, and accumulating values
│   └── TupleKitClient/           # Small executable example using TupleKit
├── Tests/
│   ├── TupleKitTests/            # Core behavioral tests
│   ├── TupleKitCompositionTests/ # Composition product tests
│   ├── TupleKitSnapshotTests/    # Snapshot/golden-output tests
│   ├── NegativeTypeChecks/       # Expected-to-fail compiler type checks
│   ├── PositiveTypeChecks/       # Compile-time positive checks
│   └── KnownCompilerBugs/        # Reproductions/guards for known compiler issues
├── Scripts/                      # Style, generation, compiler, docs, and test tooling
├── docs/adr/                     # Architecture decision records
├── .github/workflows/            # CI, quality, commit policy, and release workflows
└── Sources/TupleKit/TupleKit.docc/ # DocC guides and API use cases
```

---

## 6. Development Workflow

### Run the example

`swift run TupleKitClient` builds and runs the example consumer from [Local Setup](#4-local-setup).

### Tests

```sh
SNAPSHOT_TESTING_RECORD=never swift test
```

The environment setting makes snapshot tests fail on changed or missing fixtures instead of recording new ones; CI uses the same setting. See [Section 7](#7-testing) for focused test options.

### Formatting and linting

For changed Swift files, pass actual repository-relative paths:

```sh
bash Scripts/swift-style fix Sources/TupleKit/Tuple.swift
bash Scripts/swift-style check Sources/TupleKit/Tuple.swift
```

`fix` applies `swift format` and then runs strict checks; `check` only validates. Use the tool versions in Section 2. To check the complete managed Swift scope:

```sh
bash Scripts/swift-style check --all
```

`Package.swift` is outside the wrapper's managed style scope. The formatter configuration is `.swift-format`; production lint rules are in `.swiftlint.yml`, and test rules inherit them through `Tests/.swiftlint.yml`.

### Build

```sh
swift build
swift build -c release
```

CI runs a release build on macOS and Linux. The package also has iOS 17 build jobs for both library schemes in `.github/workflows/swift.yml`.

### Generated concatenation implementation

When changing the concatenation generator or its generated output, check synchronization with:

```sh
python3 Scripts/generate-concatenation.py --check
```

### Git workflow and commit messages

Contribute through a branch and pull request targeting `main`; CI checks pushes to `main` and pull requests targeting `main` (`.github/workflows/swift.yml`). Every commit and pull request title must follow Conventional Commits, enforced by `.github/workflows/conventional-commits.yml`. For example, use `fix: correct typed member access`. Validate a commit range with:

```sh
python3 Scripts/conventional-commits.py lint origin/main..HEAD
```

The allowed types and release consequences are documented in [CONTRIBUTING.md](CONTRIBUTING.md). No stricter branch naming convention is specified there.

---

## 7. Testing

The Swift targets use **Swift Testing**; the snapshot target also uses **SnapshotTesting** (`Package.swift`, `ARCHITECTURE.md`). Tests are split across `TupleKitTests`, `TupleKitCompositionTests`, and `TupleKitSnapshotTests`. The repository also has compile-time positive and negative checks and known-compiler-bug checks.

Run all Swift tests without changing approved snapshots:

```sh
SNAPSHOT_TESTING_RECORD=never swift test
```

Use SwiftPM's `--filter` to match a module, suite, or test name. For example:

```sh
SNAPSHOT_TESTING_RECORD=never swift test --filter TupleKitTests
SNAPSHOT_TESTING_RECORD=never swift test --filter GoldenSnapshotTests
```

No test watch command is configured. Run the CI line-coverage gate locally with:

```sh
SNAPSHOT_TESTING_RECORD=never swift test --enable-code-coverage
python3 Scripts/check-coverage.py --minimum 96
```

To record snapshots deliberately, follow [CONTRIBUTING.md](CONTRIBUTING.md): use `SNAPSHOT_TESTING_RECORD=missing` for new snapshots or `all` for intentional changes, inspect every changed fixture, then rerun with `never` and run the full test suite. Snapshot files are under `Tests/TupleKitSnapshotTests/__Snapshots__/`.

The repository tooling Python unit tests can be run with:

```sh
python3 -m unittest discover -s Scripts -p 'test_*.py'
```

---

## 8. Code Style & Conventions

- Swift formatting is configured by [`.swift-format`](.swift-format): 2-space indentation, 120-character formatter line length, ordered imports, lower camel case, and no semicolons.
- SwiftLint is strict in `Scripts/swift-style`. Its configured line-length threshold is 100 characters; function-parameter, function/type/file length, complexity, nesting, naming, and custom rules are defined in [`.swiftlint.yml`](.swiftlint.yml). Test files use [`Tests/.swiftlint.yml`](Tests/.swiftlint.yml), which inherits the root rules.
- Use `Tuple`, **member**, **position**, and **shape** in domain-facing names and documentation. The authoritative terminology and discouraged alternatives are in [GLOSSARY.md](GLOSSARY.md).
- Preserve the package's typed parameter-pack APIs and public behavior. Read [README.md](README.md), [ARCHITECTURE.md](ARCHITECTURE.md), [GLOSSARY.md](GLOSSARY.md), and applicable records under [`docs/adr/`](docs/adr/) before changing public interfaces or domain terminology (`AGENTS.md`).
- Public API examples and documented compiler workarounds live in [`Sources/TupleKit/TupleKit.docc/UseCases.md`](Sources/TupleKit/TupleKit.docc/UseCases.md).

---

## 9. Common Tasks

- **Build the package:** `swift build`
- **Run the example client:** `swift run TupleKitClient`
- **Run tests without recording snapshots:** `SNAPSHOT_TESTING_RECORD=never swift test`
- **Format and check the core file:** `bash Scripts/swift-style fix Sources/TupleKit/Tuple.swift`, then `bash Scripts/swift-style check Sources/TupleKit/Tuple.swift`.
- **Check all managed Swift style:** `bash Scripts/swift-style check --all`
- **Check generator output:** `python3 Scripts/generate-concatenation.py --check`
- **Check compiler contracts:** `Scripts/check-compiler-contracts.sh`
- **Validate and run documentation snippets:** `python3 Scripts/check-doc-snippets.py --run`
- **Run all repository Python tooling tests:** `python3 -m unittest discover -s Scripts -p 'test_*.py'`
- **Run full manual hook-stage checks** (requires `prek`): `prek run --all-files --hook-stage manual`

For new public output whose exact representation is a contract, review the golden snapshot manifest at [`Scripts/required-golden-snapshots.json`](Scripts/required-golden-snapshots.json) and the snapshot guidance in [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 10. Debugging & Troubleshooting

- **Style wrapper rejects the environment:** check `swift --version`, `xcodebuild -version`, and `swiftlint version`; the expected Xcode and SwiftLint versions are in `.swift-style.env`. The wrapper also requires `swift format` and the repository configs.
- **Snapshot tests fail:** run with `SNAPSHOT_TESTING_RECORD=never` to prevent accidental writes. Review changed fixtures and follow the snapshot workflow in [CONTRIBUTING.md](CONTRIBUTING.md); don't edit snapshots by hand.
- **Compiler type-check or crash behavior:** consult the known limitations and workarounds in [`UseCases.md`](Sources/TupleKit/TupleKit.docc/UseCases.md) and the related cases under `Tests/KnownCompilerBugs/` or `Tests/NegativeTypeChecks/`.
- **Start clean after a build issue:** `swift package clean` removes SwiftPM build artifacts; then retry `swift build` or `swift test`. No database reset or service reset is needed.
- **Logs:** build and test diagnostics are printed by `swift build` and `swift test`. CI compiler analysis captures verbose build/test output as an artifact in the Swift quality workflow; there is no application log service.
- **VS Code:** [`.vscode/launch.json`](.vscode/launch.json) still names `HeterogeneousBoxClient`. Use `swift run TupleKitClient` instead of the stale launch entries.

---

## 11. CI/CD

CI uses **GitHub Actions**. `.github/workflows/swift.yml` runs for pushes to `main` and pull requests targeting `main`. It runs Swift quality checks, macOS and Linux tests, release builds, compiler-contract checks, documentation-snippet checks, iOS 17 library builds on macOS, generated-code and golden-snapshot checks, Python tooling tests, sanitizers, and a macOS 96% line-coverage gate. `.github/workflows/swift-quality.yml` also runs for pull requests, pushes, merge groups, manual dispatch, and as a reusable workflow; its jobs check strict Swift style and run clean build/test compiler analysis.

The separate Conventional Commits workflow validates commit messages and pull request titles (`.github/workflows/conventional-commits.yml`). To reproduce major checks locally, use:

```sh
SNAPSHOT_TESTING_RECORD=never swift test
swift build -c release
Scripts/check-compiler-contracts.sh
python3 Scripts/check-doc-snippets.py --run
python3 Scripts/generate-concatenation.py --check
python3 Scripts/check-golden-snapshots.py
python3 -m unittest discover -s Scripts -p 'test_*.py'
```

The [quality workflow](.github/workflows/swift-quality.yml) shows the clean compiler-log procedure for `Scripts/swift-style-analyze`. For local sanitizer and style commands, see [`prek.toml`](prek.toml); Linux CI disables ASan leak detection because of XCTest runtime leaks. See [Testing](#7-testing) for coverage.

The [Release workflow](.github/workflows/release.yml) only considers successful Swift workflow runs triggered by a push to `main`, skips runs whose tested commit is no longer the tip of `main`, and publishes only if the commits warrant a release. See [CONTRIBUTING.md](CONTRIBUTING.md#releases). Do not edit the generated `CHANGELOG.md` by hand.

---

## 12. Architecture & Deep Dive

For the full architecture diagram and component details, see [ARCHITECTURE.md](ARCHITECTURE.md). The [dependency diagrams](docs/diagrams/dependencies.md) separate SwiftPM target edges, resolved external packages, file imports, and CI tooling. The [function map index](docs/diagrams/README.md) links to all six SwiftPM targets, standalone compiler fixtures, and repository scripts.

At a high level, `Tuple<each Member>` stores a built-in Swift tuple and uses the parameter pack to preserve each member's type. `TupleKit` provides typed access, transformations, conditional conformances, and asynchronous tuple operations; runtime lookup is checked and explicit type erasure uses `[Any]`. `TupleKitComposition` is a separate product for function composition, predicate matching, and accumulating values. The `TupleKitClient` executable demonstrates consuming the core library. The library products have no runtime network service or persistence layer.

---

## 13. Key Contacts & Resources

- **Project maintainer:** Bruno Gama, named in [README.md](README.md); profile: [github.com/brunogama](https://github.com/brunogama).
- **Repository:** [github.com/brunogama/TupleKit](https://github.com/brunogama/TupleKit).
- **Contributing and release guidance:** [CONTRIBUTING.md](CONTRIBUTING.md).
- **Architecture:** [ARCHITECTURE.md](ARCHITECTURE.md), [GLOSSARY.md](GLOSSARY.md), and [`docs/adr/`](docs/adr/).
- **Team chat/contact channel:** [Unknown &#8212; verify and update].
- **Issue tracker workflow:** [AGENTS.md](AGENTS.md) directs agents to file local Markdown issues under `.scratch/<feature-slug>/`. The referenced `docs/agents/issue-tracker.md` was not present in this checkout.

---

## 14. Changelog

| Date       | Author               | Description                         |
|------------|----------------------|-------------------------------------|
| 2026-11-19 | /generate-onboarding | Initial generation                  |

---

Generated on 2026-11-19.
