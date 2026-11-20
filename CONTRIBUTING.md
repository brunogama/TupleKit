# Contributing

---

## Commit messages

Every commit must follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). The Conventional Commits workflow checks every commit in a pull request, the pull request title, and every push to `main`, and fails on any message that doesn't match.

```text
type(scope)!: description

Optional body.

BREAKING CHANGE: what callers must change.
```

The type is one of `feat`, `fix`, `perf`, `refactor`, `docs`, `style`, `test`, `build`, `ci`, `chore`, or `revert`. The scope and `!` are optional. Leave a blank line after the subject.

Check messages before you push:

```sh
python3 Scripts/conventional-commits.py lint origin/main..HEAD
```

---

## Releases

A release happens automatically after the Swift workflow passes on `main`. The Release workflow reads the commits since the last `vX.Y.Z` tag and picks the next semantic version:

| Commits since the last tag | Next version |
| --- | --- |
| `!` after the type, or a `BREAKING CHANGE:` footer | Major, such as 1.4.2 to 2.0.0 |
| `feat` | Minor, such as 1.4.2 to 1.5.0 |
| `fix` or `perf` | Patch, such as 1.4.2 to 1.4.3 |
| Only other types | No release |

A `Release-As: X.Y.Z` footer sets the version explicitly. It must be greater than the last tag.

The workflow prepends the release to `CHANGELOG.md`, commits it to `main`, pushes the tag, and publishes a GitHub release with the same notes. `CHANGELOG.md` is generated, so don't edit it by hand.

To preview the next release locally:

```sh
python3 Scripts/conventional-commits.py release
```

---

## Snapshot tests

`Tests/TupleKitSnapshotTests` holds golden master tests built on [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing). Each file under `__Snapshots__` is the approved output for a textual surface of `Tuple`: its description, its debug description, the mirror dump, the JSON encoding, and more. A test fails when the current output differs from its recorded file.

Snapshots are text, so check them on the supported toolchains: CI runs them on macOS and on Linux with Swift 6.4.2. CI sets `SNAPSHOT_TESTING_RECORD=never`, so a missing or changed snapshot fails there instead of being recorded.

The local pre-push hook checks that every test in [`Scripts/required-golden-snapshots.json`](Scripts/required-golden-snapshots.json) is discoverable in the checked-out `GoldenSnapshotTests` suite, that its expected fixtures are committed to the ref being pushed, and that the suite passes without recording. Add a manifest entry when introducing a stable public output whose exact representation is a contract. The hook enforces those declarations; it cannot infer which new APIs should have a golden snapshot.

```sh
prek install --hook-type pre-push
prek run golden-snapshots --all-files --hook-stage pre-push
```

Verify against the recorded files without writing any:

```sh
SNAPSHOT_TESTING_RECORD=never swift test --filter GoldenSnapshotTests
```

To record a snapshot for a new test, use `missing`. When a change to existing output is intended, use `all`:

```sh
SNAPSHOT_TESTING_RECORD=missing swift test --filter GoldenSnapshotTests
SNAPSHOT_TESTING_RECORD=all swift test --filter GoldenSnapshotTests
```

A test that records a snapshot fails on that run. Then:

1. Read every new or changed file under `__Snapshots__` with `git diff`. A recorded file is a proposed result, not proof that the output is right.
2. Confirm that your change explains every changed line. Fix unstable output, such as memory addresses, dates, or unordered collections, instead of recording it.
3. Run the suite again with `SNAPSHOT_TESTING_RECORD=never`, then run `swift test`.
4. Commit the source change and its snapshot files together.

Don't edit snapshot files by hand. Prefer focused `#expect` tests for rules such as arithmetic or error behavior, and use snapshots for output whose exact text is the contract.

---

## Memory, concurrency, and coverage checks

CI runs three slower checks alongside the tests. Each one fails the workflow, and so blocks a release.

| Check | Finds | Runs on |
| --- | --- | --- |
| Thread Sanitizer | Data races between threads or tasks | macOS and Linux |
| Address Sanitizer | Use after free and buffer overflows | macOS and Linux |
| Coverage gate | Line coverage of `Sources/TupleKit` and `Sources/TupleKitComposition` below 96% | macOS |

Run them locally before you push a change to concurrency, closures, or stored references:

```sh
prek run --all-files --hook-stage manual
```

CI does not run a leak sanitizer. Linux disables leak detection because the Swift 6.4.2 XCTest runtime leaks; macOS Address Sanitizer has no leak checker. `LifetimeTests` and `CompositionLifetimeTests` cover the APIs that hold objects or closures on every platform. Each test keeps a weak reference and expects the object to be freed. Add a lifetime test when you add an API that stores a value or a closure.

Don't lower the coverage minimum to make a change pass. Add tests for the new code instead.
