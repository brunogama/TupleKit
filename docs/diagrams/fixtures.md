# Standalone Swift fixtures

These are not SwiftPM targets. Declarations come from `swiftc -frontend -dump-parse`. Negative and known-compiler-bug inputs may intentionally fail type-checking, so these are containment diagrams, not resolved call graphs.

---

## Tests/KnownCompilerBugs

```mermaid
flowchart LR
  n0["ConcatenationChainOfFourOperands.swift"]
  n1["concatenateFour() :3"]
  n2["ForAwaitOverDirectZipToTuplesCall.swift"]
  n3["render(ids:names:) :3"]
  n4["InlineTupleArgumentToUnwrapped.swift"]
  n5["unwrapInlineTuple() :3"]
  n6["KeyPathRootedAtTuplePassedToMap.swift"]
  n7["mapThroughKeyPath() :5"]
  n8["MemberAccessOnAppendedResult.swift"]
  n9["readAMemberStraightOffAnAppendedTuple() :6"]
  n10["OneMemberDynamicMemberAccess.swift"]
  n11["readOnlyMember() :3"]
  n12["RawRepresentableConformanceBreaksNestedLiterals.swift"]
  n13["init(rawValue:) :10"]
  n14["nested() :15"]
  n15["StoredKeyPathRootedAtTuple.swift"]
  n16["storeKeyPath() :3"]
  n17["TwoPackResultDoesNotUnify.swift"]
  n18["join(_:_:) :3"]
  n19["useJoinedType() :12"]
  n0 --> n1
  n2 --> n3
  n4 --> n5
  n6 --> n7
  n8 --> n9
  n10 --> n11
  n12 --> n13
  n12 --> n14
  n15 --> n16
  n17 --> n19
  n17 --> n18
```

---

## Tests/NegativeTypeChecks

```mermaid
flowchart LR
  n0["ConcurrentMapEachRequiresSendableMembers.swift"]
  n1["run() :7"]
  n2["CoreImportExposesNoOperators.swift"]
  n3["EqualityAcrossDifferentShapes.swift"]
  n4["ForEachTypedCallbackCountMismatch.swift"]
  n5["KeyPathMemberTypeMismatch.swift"]
  n6["MapEachOutputTypeMismatch.swift"]
  n7["run() :3"]
  n8["MappingSubscriptInputTypeMismatch.swift"]
  n9["NonSendableTupleAcrossActors.swift"]
  n10["receive(_:) :8"]
  n11["send(to:) :12"]
  n12["ZipToTuplesElementTypeMismatch.swift"]
  n13["run(numbers:names:) :5"]
  n0 --> n1
  n6 --> n7
  n9 --> n11
  n9 --> n10
  n12 --> n13
```

---

## Tests/PositiveTypeChecks

```mermaid
flowchart LR
  n0["UnaryCallbacks.swift"]
  n1["visitUnary(_:action:) :3"]
  n2["mapUnary() :12"]
  n0 --> n2
  n0 --> n1
```
