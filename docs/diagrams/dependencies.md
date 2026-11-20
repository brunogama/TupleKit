# Dependencies

Arrows point from a consumer to its dependency. The SwiftPM target and package graphs are separate: a resolved package is not necessarily linked into a library product.

---

## SwiftPM products and targets

From [`Package.swift`](../../Package.swift) and `swift package describe --type json`. Both library targets have no third-party product dependency.

```mermaid
flowchart LR
  n0["TupleKit (library)"]
  n1["TupleKitClient (executable)"]
  n2["TupleKitComposition (library)"]
  n3["TupleKitCompositionTests (test)"]
  n4["TupleKitSnapshotTests (test)"]
  n5["TupleKitTests (test)"]
  n6["SnapshotTesting (external test product)"]
  n7["TupleKit (product)"]
  n8["TupleKitComposition (product)"]
  n9["TupleKitClient (product)"]
  n1 --> n0
  n3 --> n0
  n3 --> n2
  n4 --> n6
  n4 --> n0
  n5 --> n0
  n7 --> n0
  n9 --> n1
  n8 --> n2
```

---

## Resolved external packages

From `swift package show-dependencies --format json`, checked against the local, Git-ignored `Package.resolved`. The root declaration supports the snapshot test target.

```mermaid
flowchart LR
  n0["TupleKit"]
  n1["swift-snapshot-testing 1.19.7"]
  n2["swift-custom-dump 1.7.3"]
  n3["swift-issue-reporting 2.1.2"]
  n4["swift-syntax 604.0.0"]
  n0 --> n1
  n2 --> n3
  n1 --> n2
  n1 --> n4
```

---

## Imports by SwiftPM target

Source imports, not linker edges. Implicit Swift imports are not included; imports inside conditional compilation blocks are shown regardless of platform. Isolated files have no explicit imports.

### TupleKit

```mermaid
flowchart LR
  n0["ElementwiseTuple.swift"]
  n1["Tuple+CustomPlaygroundDisplayConvertible.swift"]
  n2["Tuple+CustomReflectable.swift"]
  n3["Tuple+CustomStringConvertible.swift"]
  n4["Tuple+TextOutputStreamable.swift"]
  n5["Tuple+Arithmetic.swift"]
  n6["Tuple+AsyncMemberWork.swift"]
  n7["Tuple+BitwiseCopyable.swift"]
  n8["Tuple+CaseIterable.swift"]
  n9["Tuple+Codable.swift"]
  n10["Tuple+Combining.swift"]
  n11["Tuple+Comparable.swift"]
  n12["Tuple+Concatenation.swift"]
  n13["Tuple+Equatable.swift"]
  n14["Tuple+Hashable.swift"]
  n15["Tuple+MappingSubscript.swift"]
  n16["Tuple+RawRepresentable.swift"]
  n17["Tuple+TypedAccess.swift"]
  n18["Tuple.swift"]
  n19["TuplePattern.swift"]
  n20["TupleZipSequence.swift"]
```

### TupleKitClient

```mermaid
flowchart LR
  n0["Log.swift"]
  n1["main.swift"]
  n2["TupleKit"]
  n1 --> n2
```

### TupleKitComposition

```mermaid
flowchart LR
  n0["AccumulatingValue.swift"]
  n1["FunctionComposition.swift"]
  n2["PredicatePattern.swift"]
```

### TupleKitCompositionTests

```mermaid
flowchart LR
  n0["AccumulatingWrapperTests.swift"]
  n1["CompositionLifetimeTests.swift"]
  n2["FunctionCompositionTests.swift"]
  n3["OperatorPrecedenceTests.swift"]
  n4["PredicatePatternTests.swift"]
  n5["Testing"]
  n6["TupleKit"]
  n7["TupleKitComposition"]
  n0 --> n5
  n0 --> n6
  n0 --> n7
  n1 --> n5
  n1 --> n7
  n2 --> n5
  n2 --> n6
  n2 --> n7
  n3 --> n5
  n3 --> n7
  n4 --> n5
  n4 --> n6
  n4 --> n7
```

### TupleKitSnapshotTests

```mermaid
flowchart LR
  n0["GoldenSnapshotTests.swift"]
  n1["Foundation"]
  n2["SnapshotTesting"]
  n3["Testing"]
  n4["TupleKit"]
  n0 --> n1
  n0 --> n2
  n0 --> n3
  n0 --> n4
```

### TupleKitTests

```mermaid
flowchart LR
  n0["AdditionalConformanceTests.swift"]
  n1["AppendTests.swift"]
  n2["AsyncMemberWorkTests.swift"]
  n3["CombiningTests.swift"]
  n4["ConcurrentMapEachTests.swift"]
  n5["ConformanceTests.swift"]
  n6["GenericClientTests.swift"]
  n7["LifetimeTests.swift"]
  n8["MirrorTests.swift"]
  n9["NestedFocusTests.swift"]
  n10["OperatorsAndHigherOrderTests.swift"]
  n11["PlaygroundDisplayTests.swift"]
  n12["ShapeTests.swift"]
  n13["TaskValueLifetimeTests.swift"]
  n14["TupleTests.swift"]
  n15["TypedAccessTests.swift"]
  n16["ZipResourceLifetimeTests.swift"]
  n17["ZipToTuplesTests.swift"]
  n18["Foundation"]
  n19["Testing"]
  n20["TupleKit"]
  n0 --> n19
  n0 --> n20
  n1 --> n19
  n1 --> n20
  n2 --> n19
  n2 --> n20
  n3 --> n19
  n3 --> n20
  n4 --> n19
  n4 --> n20
  n5 --> n18
  n5 --> n19
  n5 --> n20
  n6 --> n18
  n6 --> n19
  n6 --> n20
  n7 --> n19
  n7 --> n20
  n8 --> n19
  n8 --> n20
  n9 --> n19
  n9 --> n20
  n10 --> n19
  n10 --> n20
  n11 --> n19
  n11 --> n20
  n12 --> n18
  n12 --> n19
  n12 --> n20
  n13 --> n19
  n13 --> n20
  n14 --> n19
  n14 --> n20
  n15 --> n19
  n15 --> n20
  n16 --> n18
  n16 --> n19
  n16 --> n20
  n17 --> n18
  n17 --> n19
  n17 --> n20
```

---

## Manifest and standalone Swift fixtures

```mermaid
flowchart LR
  n0["Package.swift"]
  n2["ConcatenationChainOfFourOperands.swift"]
  n3["ForAwaitOverDirectZipToTuplesCall.swift"]
  n4["InlineTupleArgumentToUnwrapped.swift"]
  n5["KeyPathRootedAtTuplePassedToMap.swift"]
  n6["MemberAccessOnAppendedResult.swift"]
  n7["OneMemberDynamicMemberAccess.swift"]
  n8["RawRepresentableConformanceBreaksNestedLiterals.swift"]
  n9["StoredKeyPathRootedAtTuple.swift"]
  n10["TwoPackResultDoesNotUnify.swift"]
  n11["ConcurrentMapEachRequiresSendableMembers.swift"]
  n12["CoreImportExposesNoOperators.swift"]
  n13["EqualityAcrossDifferentShapes.swift"]
  n14["ForEachTypedCallbackCountMismatch.swift"]
  n15["KeyPathMemberTypeMismatch.swift"]
  n16["MapEachOutputTypeMismatch.swift"]
  n17["MappingSubscriptInputTypeMismatch.swift"]
  n18["NonSendableTupleAcrossActors.swift"]
  n19["ZipToTuplesElementTypeMismatch.swift"]
  n20["UnaryCallbacks.swift"]
  n21["PackageDescription"]
  n22["TupleKit"]
  n0 --> n21
  n2 --> n22
  n3 --> n22
  n4 --> n22
  n5 --> n22
  n6 --> n22
  n7 --> n22
  n8 --> n22
  n9 --> n22
  n10 --> n22
  n11 --> n22
  n12 --> n22
  n13 --> n22
  n14 --> n22
  n15 --> n22
  n16 --> n22
  n17 --> n22
  n18 --> n22
  n19 --> n22
  n20 --> n22
```

---

## Python tooling imports

```mermaid
flowchart LR
  n0["check-coverage.py"]
  n1["check-doc-snippets.py"]
  n2["check-golden-snapshots.py"]
  n3["conventional-commits.py"]
  n4["generate-concatenation.py"]
  n6["test_check_golden_snapshots.py"]
  n7["test_conventional_commits.py"]
  n8["argparse"]
  n9["datetime"]
  n11["json"]
  n12["os"]
  n13["pathlib"]
  n14["re"]
  n15["shutil"]
  n16["subprocess"]
  n17["sys"]
  n18["tempfile"]
  n19["unittest"]
  n0 --> n8
  n0 --> n11
  n0 --> n13
  n0 --> n16
  n0 --> n17
  n1 --> n11
  n1 --> n13
  n1 --> n14
  n1 --> n16
  n1 --> n17
  n1 --> n18
  n2 --> n11
  n2 --> n12
  n2 --> n13
  n2 --> n14
  n2 --> n16
  n2 --> n17
  n3 --> n8
  n3 --> n9
  n3 --> n12
  n3 --> n13
  n3 --> n14
  n3 --> n16
  n3 --> n17
  n4 --> n13
  n4 --> n17
  n6 --> n11
  n6 --> n12
  n6 --> n13
  n6 --> n15
  n6 --> n16
  n6 --> n17
  n6 --> n18
  n6 --> n19
  n7 --> n12
  n7 --> n13
  n7 --> n16
  n7 --> n17
  n7 --> n18
  n7 --> n19
```

---

## CI and release dependencies

From [the GitHub Actions workflows](../../.github/workflows/) and the tool pins in [`.swift-style.env`](../../.swift-style.env). The release workflow also requires the tested commit to still be the tip of `main`.

```mermaid
flowchart LR
  swift["Swift CI"] --> quality["Reusable Swift Quality"]
  swift --> xcode["macOS: Xcode 27.3"]
  swift --> linux["Linux: swift:6.4.2 image"]
  swift --> ciScripts["Compiler contracts, DocC snippets, coverage, generated code, golden checks"]
  ciScripts --> python["Python 3"]
  ciScripts --> bash["Bash"]
  quality --> xcode
  quality --> lint["SwiftLint 0.63.2"]
  quality --> wrapper["swift-style and swift-style-analyze"]
  wrapper --> bash
  commits["Conventional Commits CI"] --> commitsScript["conventional-commits.py"]
  commitsScript --> python
  release["Release"] -->|requires successful main push run| swift
  release --> commitsScript
  release --> git["Git and GitHub CLI"]
```
