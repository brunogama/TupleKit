# Function map: TupleKitTests

One chart per file. Nodes list explicit Swift callable declarations with source lines. Arrows show compiler-resolved references to functions, including calls and function values. Gray nodes are callees declared elsewhere; a shaded node with no project location is not mapped to a declaration in these charts.

---

## AdditionalConformanceTests.swift

[`Tests/TupleKitTests/AdditionalConformanceTests.swift`](../../Tests/TupleKitTests/AdditionalConformanceTests.swift)

```mermaid
flowchart LR
  n0["AdditionalConformanceTests.bitwiseCopyableWhenEveryMemberIs() :17"]
  n1["size(of:) [syntax only] :18"]
  n2["AdditionalConformanceTests.allCasesIsTheCartesianProductWithTheLastMemberFastest() :24"]
  n3["AdditionalConformanceTests.allCasesIsEmptyWhenAnyMemberHasNoCases() :33"]
  n4["AdditionalConformanceTests.emptyTupleHasExactlyOneCase() :37"]
  n5["AdditionalConformanceTests.rawValuesRoundTrip() :42"]
  n6["AdditionalConformanceTests.rawValuesInitializerFailsWhenAnyMemberHasNoCase() :49"]
  n7["AdditionalConformanceTests.writesToATextOutputStream() :54"]
  n8["AdditionalConformanceTests.elementWiseArithmetic() :63"]
  n9["AdditionalConformanceTests.plusStillConcatenatesTuplesOfTheSameType() :72"]
  n10["AdditionalConformanceTests.elementwiseViewConformsToAdditiveArithmetic() :82"]
  n11["sum(_:) [syntax only] :83"]
  n12["AdditionalConformanceTests.elementwiseViewEqualityComparesEveryMember() :93"]
  n13["AdditionalConformanceTests.elementwiseViewIsHashableAndPrintsTheTuple() :101"]
  n14["AdditionalConformanceTests.elementwiseTupleSetterReplacesTheTuple() :108"]
  n15["Tuple.init(_:) (Tuple.swift:35)"]
  n16["==(_:_:) [unmapped]"]
  n17["==(_:_:) [unmapped]"]
  n18["Tuple.==(_:_:) (Tuple+Equatable.swift:14)"]
  n19["Tuple.init(rawValues:) (Tuple+RawRepresentable.swift:28)"]
  n20["==(_:_:) [unmapped]"]
  n21["==(_:_:) [unmapped]"]
  n22["Tuple.write(to:) (Tuple+TextOutputStreamable.swift:12)"]
  n23["==(_:_:) [unmapped]"]
  n24["print(_:separator:terminator:to:) [unmapped]"]
  n25["Tuple.subtracting(_:) (Tuple+Arithmetic.swift:47)"]
  n26["Tuple.adding(_:) (Tuple+Arithmetic.swift:33)"]
  n27["Tuple.+(_:_:) (Tuple+Concatenation.swift:58)"]
  n28["ElementwiseTuple.-(_:_:) (ElementwiseTuple.swift:49)"]
  n29["ElementwiseTuple.init(_:) (ElementwiseTuple.swift:22)"]
  n30["reduce(_:_:) [unmapped]"]
  n31["map(_:) [unmapped]"]
  n32["+(_:_:) [unmapped]"]
  n33["ElementwiseTuple.==(_:_:) (ElementwiseTuple.swift:55)"]
  n34["!=(_:_:) [unmapped]"]
  n0 --> n16
  n0 --> n15
  n2 --> n17
  n2 --> n16
  n2 --> n15
  n4 --> n16
  n4 --> n15
  n5 --> n20
  n5 --> n18
  n5 --> n19
  n5 --> n15
  n6 --> n21
  n6 --> n19
  n6 --> n15
  n7 --> n23
  n7 --> n24
  n7 --> n22
  n7 --> n15
  n8 --> n26
  n8 --> n25
  n8 --> n18
  n8 --> n15
  n9 --> n27
  n9 --> n18
  n9 --> n15
  n10 --> n30
  n10 --> n31
  n10 --> n32
  n10 --> n29
  n10 --> n28
  n10 --> n18
  n10 --> n15
  n12 --> n34
  n12 --> n33
  n12 --> n15
  n13 --> n23
  n13 --> n16
  n13 --> n15
  n14 --> n33
  n14 --> n18
  n14 --> n15
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n15,n16,n17,n18,n19,n20,n21,n22,n23,n24,n25,n26,n27,n28,n29,n30,n31,n32,n33,n34 elsewhere
```

---

## AppendTests.swift

[`Tests/TupleKitTests/AppendTests.swift`](../../Tests/TupleKitTests/AppendTests.swift)

```mermaid
flowchart LR
  n0["TupleKitTests.appendingOneMemberKeepsTypesAndLeavesTheSourceUnchanged() :6"]
  n1["TupleKitTests.tupleInitializerKeepsElementTypes() :14"]
  n2["TupleKitTests.genericParameterPackForwarding() :21"]
  n3["forward(_:) [syntax only] :22"]
  n4["TupleKitTests.appendingToEmptyAndOneMemberTuples() :33"]
  n5["Tuple.appending(_:) (Tuple.swift:121)"]
  n6["Tuple.==(_:_:) (Tuple+Equatable.swift:14)"]
  n7["Tuple.init(_:) (Tuple.swift:35)"]
  n8["Tuple.init(members:) (Tuple.swift:47)"]
  n9["==(_:_:) [unmapped]"]
  n10["==(_:_:) [unmapped]"]
  n0 --> n6
  n0 --> n7
  n0 --> n5
  n1 --> n9
  n1 --> n10
  n1 --> n8
  n2 --> n9
  n2 --> n10
  n2 --> n7
  n4 --> n9
  n4 --> n6
  n4 --> n7
  n4 --> n5
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n5,n6,n7,n8,n9,n10 elsewhere
```

---

## AsyncMemberWorkTests.swift

[`Tests/TupleKitTests/AsyncMemberWorkTests.swift`](../../Tests/TupleKitTests/AsyncMemberWorkTests.swift)

```mermaid
flowchart LR
  n0["AsyncMemberWorkTests.synchronousMapEachTransformsEachMemberToItsOwnType() :14"]
  n1["AsyncMemberWorkTests.synchronousMapEachStopsAtFirstTypedError() :37"]
  n2["AsyncMemberWorkTests.mapEachRunsTransformsInTupleOrderAndKeepsOutputTypes() :56"]
  n3["AsyncMemberWorkTests.mapEachStopsAtFirstTypedError() :78"]
  n4["AsyncMemberWorkTests.mapEachAcceptsNonSendableMembersOnTheCallersActor() :106"]
  n5["Tuple.mapEach(_:) (Tuple+AsyncMemberWork.swift:17)"]
  n6["Tuple.==(_:_:) (Tuple+Equatable.swift:14)"]
  n7["Tuple.init(_:) (Tuple.swift:35)"]
  n8["append(_:) [unmapped]"]
  n9["==(_:_:) [unmapped]"]
  n10["/(_:_:) [unmapped]"]
  n11["init(_:) [unmapped]"]
  n12["Tuple.mapEach(_:) (Tuple+AsyncMemberWork.swift:42)"]
  n13["Tuple.subscript(_:) (Tuple+TypedAccess.swift:20)"]
  n14["==(_:_:) [unmapped]"]
  n15["init(_:) [unmapped]"]
  n16["yield() [unmapped]"]
  n17["record(_:severity:sourceLocation:) [unmapped]"]
  n18["==(_:_:) [unmapped]"]
  n19["init() [unmapped]"]
  n20["uppercased() [unmapped]"]
  n21["==(_:_:) [unmapped]"]
  n22["==(_:_:) [unmapped]"]
  n23["+=(_:_:) [unmapped]"]
  n0 --> n8
  n0 --> n9
  n0 --> n10
  n0 --> n11
  n0 --> n5
  n0 --> n6
  n0 --> n7
  n1 --> n8
  n1 --> n9
  n1 --> n5
  n1 --> n7
  n2 --> n14
  n2 --> n8
  n2 --> n9
  n2 --> n15
  n2 --> n16
  n2 --> n10
  n2 --> n11
  n2 --> n12
  n2 --> n13
  n2 --> n7
  n3 --> n17
  n3 --> n18
  n3 --> n8
  n3 --> n9
  n3 --> n12
  n3 --> n7
  n4 --> n19
  n4 --> n20
  n4 --> n21
  n4 --> n22
  n4 --> n23
  n4 --> n12
  n4 --> n13
  n4 --> n7
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20,n21,n22,n23 elsewhere
```

---

## CombiningTests.swift

[`Tests/TupleKitTests/CombiningTests.swift`](../../Tests/TupleKitTests/CombiningTests.swift)

```mermaid
flowchart LR
  n0["CombiningTests.unwrappedReturnsMembersWhenEveryMemberHasAValue() :9"]
  n1["CombiningTests.unwrappedReturnsNilWhenAnyMemberIsNil() :17"]
  n2["CombiningTests.unwrappedKeepsANestedNilThatIsItselfAValue() :23"]
  n3["CombiningTests.collectedReturnsSuccessesInPositionOrder() :34"]
  n4["CombiningTests.collectedReturnsTheFirstFailureInPositionOrder() :43"]
  n5["CombiningTests.valuesAwaitsNonThrowingTasksInPositionOrder() :53"]
  n6["CombiningTests.valuesRethrowsTheFirstFailingTaskInPositionOrder() :61"]
  n7["CombiningTests.zipPairsMembersByPosition() :70"]
  n8["CombiningTests.zipDoesNotShadowSequenceZip() :77"]
  n9["Tuple.init(_:) (Tuple.swift:35)"]
  n10["unwrapped(_:) (Tuple+Combining.swift:16)"]
  n11["==(_:_:) [unmapped]"]
  n12["==(_:_:) [unmapped]"]
  n13["!=(_:_:) [unmapped]"]
  n14["==(_:_:) [unmapped]"]
  n15["Tuple.==(_:_:) (Tuple+Equatable.swift:14)"]
  n16["collected(_:) (Tuple+Combining.swift:37)"]
  n17["get() [unmapped]"]
  n18["values(of:) (Tuple+Combining.swift:63)"]
  n19["init(name:priority:operation:) [unmapped]"]
  n20["values(of:) (Tuple+Combining.swift:86)"]
  n21["init(name:priority:operation:) [unmapped]"]
  n22["Tuple.subscript(_:) (Tuple+TypedAccess.swift:20)"]
  n23["zip(_:_:) (Tuple+Combining.swift:105)"]
  n24["==(_:_:) [unmapped]"]
  n25["init(_:) [unmapped]"]
  n26["==(_:_:) [unmapped]"]
  n27["zip(_:_:) [unmapped]"]
  n0 --> n11
  n0 --> n10
  n0 --> n9
  n1 --> n12
  n1 --> n10
  n1 --> n9
  n2 --> n13
  n2 --> n14
  n2 --> n10
  n2 --> n9
  n3 --> n17
  n3 --> n16
  n3 --> n15
  n3 --> n9
  n4 --> n17
  n4 --> n16
  n4 --> n9
  n5 --> n19
  n5 --> n18
  n5 --> n15
  n5 --> n9
  n6 --> n21
  n6 --> n20
  n6 --> n9
  n7 --> n24
  n7 --> n23
  n7 --> n22
  n7 --> n9
  n8 --> n25
  n8 --> n26
  n8 --> n27
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20,n21,n22,n23,n24,n25,n26,n27 elsewhere
```

---

## ConcurrentMapEachTests.swift

[`Tests/TupleKitTests/ConcurrentMapEachTests.swift`](../../Tests/TupleKitTests/ConcurrentMapEachTests.swift)

```mermaid
flowchart LR
  n0["Recorder.record(_:) :13"]
  n1["Recorder.contains(_:) :18"]
  n2["Recorder.wait(for:) :22"]
  n3["ConcurrentMapEachTests.concurrentMapEachKeepsSourceOrderWhenLaterMembersFinishFirst() :30"]
  n4["ConcurrentMapEachTests.concurrentMapEachStartsEveryTransformBeforeAnyFinishes() :52"]
  n5["ConcurrentMapEachTests.concurrentMapEachCancelsSiblingsWhenOneThrows() :73"]
  n6["ConcurrentMapEachTests.cancellingTheCallerCancelsEveryTransform() :102"]
  n7["ConcurrentMapEachTests.concurrentMapEachPreservesOptionalNilOutputs() :123"]
  n8["ConcurrentMapEachTests.concurrentMapEachOnEmptyBoxReturnsEmptyBox() :135"]
  n9["ConcurrentMapEachTests.theFirstTransformToThrowProvidesTheError() :140"]
  n10["removeValue(forKey:) [unmapped]"]
  n11["append(_:) [unmapped]"]
  n12["resume() [unmapped]"]
  n13["??(_:_:) [unmapped]"]
  n14["contains(_:) [unmapped]"]
  n15["withCheckedContinuation(function:_:) [unmapped]"]
  n16["subscript(_:default:) [unmapped]"]
  n17["init() [unmapped]"]
  n18["Tuple.==(_:_:) (Tuple+Equatable.swift:14)"]
  n19["Tuple.init(_:) (Tuple.swift:35)"]
  n20["concurrentMapEach(_:_:) (Tuple+AsyncMemberWork.swift:78)"]
  n21["==(_:_:) [unmapped]"]
  n22["*(_:_:) [unmapped]"]
  n23["record(_:severity:sourceLocation:) [unmapped]"]
  n24["sleep(for:tolerance:clock:) [unmapped]"]
  n25["==(_:_:) [unmapped]"]
  n26["seconds(_:) [unmapped]"]
  n27["init(name:priority:operation:) [unmapped]"]
  n28["cancel() [unmapped]"]
  n29["get() [unmapped]"]
  n30["init(_:) [unmapped]"]
  n0 --> n10
  n0 --> n11
  n0 --> n12
  n0 --> n13
  n1 --> n14
  n2 --> n15
  n2 --> n16
  n2 --> n14
  n2 --> n11
  n3 --> n17
  n3 --> n21
  n3 --> n22
  n3 --> n20
  n3 --> n18
  n3 --> n19
  n3 --> n0
  n3 --> n2
  n4 --> n17
  n4 --> n20
  n4 --> n18
  n4 --> n19
  n4 --> n0
  n4 --> n1
  n4 --> n2
  n5 --> n17
  n5 --> n23
  n5 --> n24
  n5 --> n25
  n5 --> n26
  n5 --> n20
  n5 --> n19
  n5 --> n0
  n5 --> n1
  n6 --> n27
  n6 --> n24
  n6 --> n28
  n6 --> n29
  n6 --> n26
  n6 --> n20
  n6 --> n19
  n7 --> n30
  n7 --> n20
  n7 --> n18
  n7 --> n19
  n8 --> n20
  n8 --> n19
  n9 --> n17
  n9 --> n23
  n9 --> n24
  n9 --> n25
  n9 --> n26
  n9 --> n20
  n9 --> n19
  n9 --> n0
  n9 --> n2
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20,n21,n22,n23,n24,n25,n26,n27,n28,n29,n30 elsewhere
```

---

## ConformanceTests.swift

[`Tests/TupleKitTests/ConformanceTests.swift`](../../Tests/TupleKitTests/ConformanceTests.swift)

```mermaid
flowchart LR
  n0["ConformanceTests.codableRoundTripsMembersInPositionOrder() :6"]
  n1["ConformanceTests.decodingRejectsTooFewValues() :23"]
  n2["ConformanceTests.decodingRejectsExtraValues() :35"]
  n3["ConformanceTests.decodingRejectsAMemberOfTheWrongType() :47"]
  n4["ConformanceTests.comparableOrdersByTheFirstDifferingPosition() :59"]
  n5["ConformanceTests.comparableStopsAtAnUnorderedMember() :73"]
  n6["ConformanceTests.hashableDistinguishesMembers() :81"]
  n7["ConformanceTests.equatableComparesEveryMember() :86"]
  n8["ConformanceTests.equalTuplesProduceEqualHashes() :94"]
  n9["ConformanceTests.hashableSupportsLookupWithCollidingMembers() :103"]
  n10["ConformanceTests.comparableMatchesBuiltInTupleOrdering() :113"]
  n11["agree(_:_:) [syntax only] :114"]
  n12["ConformanceTests.codableRoundTripsNestedTuples() :129"]
  n13["CollidingMember.hash(into:) :144"]
  n14["decode(_:from:) [unmapped]"]
  n15["init() [unmapped]"]
  n16["encode(_:) [unmapped]"]
  n17["init() [unmapped]"]
  n18["Tuple.==(_:_:) (Tuple+Equatable.swift:14)"]
  n19["Tuple.init(_:) (Tuple.swift:35)"]
  n20["==(_:_:) [unmapped]"]
  n21["init(bytes:encoding:) [unmapped]"]
  n22["init(_:) [unmapped]"]
  n23["record(_:severity:sourceLocation:) [unmapped]"]
  n24["init(describing:) [unmapped]"]
  n25["Tuple.#60;(_:_:) (Tuple+Comparable.swift:14)"]
  n26["sorted() [unmapped]"]
  n27["==(_:_:) [unmapped]"]
  n28["!(_:) [unmapped]"]
  n29["==(_:_:) [unmapped]"]
  n30["!=(_:_:) [unmapped]"]
  n31["Tuple.hash(into:) (Tuple+Hashable.swift:11)"]
  n32["finalize() [unmapped]"]
  n33["init() [unmapped]"]
  n34["init(value:) [unmapped]"]
  n35["subscript(_:) [unmapped]"]
  n36["init(_:) [unmapped]"]
  n37["==(_:_:) [unmapped]"]
  n38["#60;(_:_:) [unmapped]"]
  n39["combine(_:) [unmapped]"]
  n0 --> n14
  n0 --> n15
  n0 --> n16
  n0 --> n17
  n0 --> n20
  n0 --> n21
  n0 --> n18
  n0 --> n19
  n1 --> n14
  n1 --> n15
  n1 --> n22
  n1 --> n23
  n1 --> n24
  n2 --> n14
  n2 --> n15
  n2 --> n22
  n2 --> n23
  n2 --> n24
  n3 --> n14
  n3 --> n15
  n3 --> n22
  n3 --> n23
  n3 --> n24
  n4 --> n26
  n4 --> n27
  n4 --> n28
  n4 --> n25
  n4 --> n19
  n5 --> n28
  n5 --> n25
  n5 --> n19
  n6 --> n29
  n6 --> n19
  n7 --> n30
  n7 --> n18
  n7 --> n19
  n8 --> n29
  n8 --> n32
  n8 --> n33
  n8 --> n31
  n8 --> n19
  n9 --> n34
  n9 --> n35
  n9 --> n20
  n9 --> n30
  n9 --> n36
  n9 --> n29
  n9 --> n19
  n10 --> n37
  n10 --> n38
  n10 --> n25
  n10 --> n19
  n12 --> n14
  n12 --> n15
  n12 --> n16
  n12 --> n17
  n12 --> n20
  n12 --> n21
  n12 --> n18
  n12 --> n19
  n13 --> n39
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n14,n15,n16,n17,n18,n19,n20,n21,n22,n23,n24,n25,n26,n27,n28,n29,n30,n31,n32,n33,n34,n35,n36,n37,n38,n39 elsewhere
```

---

## GenericClientTests.swift

[`Tests/TupleKitTests/GenericClientTests.swift`](../../Tests/TupleKitTests/GenericClientTests.swift)

```mermaid
flowchart LR
  n0["checkGenericShape(_:count:description:) :5"]
  n1["genericEncoding(_:) :20"]
  n2["GenericClientTests.genericClientsKeepEmptyUnaryAndMixedShapes() :27"]
  n3["GenericClientTests.genericEncodingPropagatesMemberErrors() :35"]
  n4["Tuple.write(to:) (Tuple+TextOutputStreamable.swift:12)"]
  n5["==(_:_:) [unmapped]"]
  n6["hasPrefix(_:) [unmapped]"]
  n7["==(_:_:) [unmapped]"]
  n8["==(_:_:) [unmapped]"]
  n9["encode(_:) [unmapped]"]
  n10["init() [unmapped]"]
  n11["Tuple.init(_:) (Tuple.swift:35)"]
  n12["==(_:_:) [unmapped]"]
  n13["init(bytes:encoding:) [unmapped]"]
  n0 --> n5
  n0 --> n6
  n0 --> n7
  n0 --> n8
  n0 --> n4
  n1 --> n9
  n1 --> n10
  n2 --> n12
  n2 --> n13
  n2 --> n11
  n2 --> n0
  n2 --> n1
  n3 --> n11
  n3 --> n1
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n4,n5,n6,n7,n8,n9,n10,n11,n12,n13 elsewhere
```

---

## LifetimeTests.swift

[`Tests/TupleKitTests/LifetimeTests.swift`](../../Tests/TupleKitTests/LifetimeTests.swift)

```mermaid
flowchart LR
  n0["Tracked.init(_:) :8"]
  n1["LifetimeTests.tupleReleasesItsMembers() :19"]
  n2["LifetimeTests.patternReleasesTheObjectsItsPredicatesCapture() :34"]
  n3["LifetimeTests.concurrentMapEachReleasesCapturesAfterReturning() :48"]
  n4["LifetimeTests.concurrentMapEachReleasesCapturesAfterThrowing() :67"]
  n5["LifetimeTests.zipToTuplesReleasesItsBasesAfterIteration() :86"]
  n6["Tuple.mapEach(_:) (Tuple+AsyncMemberWork.swift:17)"]
  n7["Tuple.==(_:_:) (Tuple+Equatable.swift:14)"]
  n8["Tuple.init(_:) (Tuple.swift:35)"]
  n9["!(_:) [unmapped]"]
  n10["==(_:_:) [unmapped]"]
  n11["==(_:_:) [unmapped]"]
  n12["TuplePattern.matches(_:) (TuplePattern.swift:34)"]
  n13["TuplePattern.init(_:) (TuplePattern.swift:19)"]
  n14["concurrentMapEach(_:_:) (Tuple+AsyncMemberWork.swift:78)"]
  n15["*(_:_:) [unmapped]"]
  n16["+(_:_:) [unmapped]"]
  n17["init() [unmapped]"]
  n18["sleep(for:tolerance:clock:) [unmapped]"]
  n19["seconds(_:) [unmapped]"]
  n20["zipToTuples(_:) (TupleZipSequence.swift:109)"]
  n21["append(_:) [unmapped]"]
  n22["==(_:_:) [unmapped]"]
  n23["yield(_:) [unmapped]"]
  n24["finish() [unmapped]"]
  n25["init(_:bufferingPolicy:_:) [unmapped]"]
  n1 --> n9
  n1 --> n10
  n1 --> n11
  n1 --> n6
  n1 --> n7
  n1 --> n8
  n1 --> n0
  n2 --> n10
  n2 --> n11
  n2 --> n8
  n2 --> n13
  n2 --> n12
  n2 --> n0
  n3 --> n15
  n3 --> n16
  n3 --> n11
  n3 --> n14
  n3 --> n7
  n3 --> n8
  n3 --> n0
  n4 --> n17
  n4 --> n18
  n4 --> n16
  n4 --> n11
  n4 --> n19
  n4 --> n14
  n4 --> n8
  n4 --> n0
  n5 --> n21
  n5 --> n22
  n5 --> n23
  n5 --> n24
  n5 --> n25
  n5 --> n11
  n5 --> n20
  n5 --> n0
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20,n21,n22,n23,n24,n25 elsewhere
```

---

## MirrorTests.swift

[`Tests/TupleKitTests/MirrorTests.swift`](../../Tests/TupleKitTests/MirrorTests.swift)

```mermaid
flowchart LR
  n0["MirrorTests.reflectsMembersAsPositionLabeledTupleChildren() :5"]
  n1["MirrorTests.dumpMatchesABuiltInTupleWithTheSameMembers() :13"]
  n2["MirrorTests.emptyTupleHasNoChildren() :23"]
  n3["Tuple.init(_:) (Tuple.swift:35)"]
  n4["init(describing:) [unmapped]"]
  n5["==(_:_:) [unmapped]"]
  n6["==(_:_:) [unmapped]"]
  n7["map(_:) [unmapped]"]
  n8["init(reflecting:) [unmapped]"]
  n9["==(_:_:) [unmapped]"]
  n10["dump(_:to:name:indent:maxDepth:maxItems:) [unmapped]"]
  n0 --> n4
  n0 --> n5
  n0 --> n6
  n0 --> n7
  n0 --> n8
  n0 --> n3
  n1 --> n9
  n1 --> n10
  n1 --> n3
  n2 --> n8
  n2 --> n3
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n3,n4,n5,n6,n7,n8,n9,n10 elsewhere
```

---

## NestedFocusTests.swift

[`Tests/TupleKitTests/NestedFocusTests.swift`](../../Tests/TupleKitTests/NestedFocusTests.swift)

```mermaid
flowchart LR
  n0["NestedFocusTests.chainedKeyPathSubscriptsWriteThroughNestedBoxes() :7"]
  n1["NestedFocusTests.nestedUpdatingReturnsACopyAndLeavesTheSourceUnchanged() :16"]
  n2["Tuple.==(_:_:) (Tuple+Equatable.swift:14)"]
  n3["Tuple.init(_:) (Tuple.swift:35)"]
  n4["Tuple.subscript(_:) (Tuple+TypedAccess.swift:20)"]
  n5["toggle() [unmapped]"]
  n6["Tuple.updating(_:_:) (Tuple+TypedAccess.swift:38)"]
  n7["==(_:_:) [unmapped]"]
  n8["*(_:_:) [unmapped]"]
  n0 --> n5
  n0 --> n2
  n0 --> n4
  n0 --> n3
  n1 --> n7
  n1 --> n8
  n1 --> n4
  n1 --> n6
  n1 --> n3
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n2,n3,n4,n5,n6,n7,n8 elsewhere
```

---

## OperatorsAndHigherOrderTests.swift

[`Tests/TupleKitTests/OperatorsAndHigherOrderTests.swift`](../../Tests/TupleKitTests/OperatorsAndHigherOrderTests.swift)

```mermaid
flowchart LR
  n0["OperatorsAndHigherOrderTests.concatenationResultIsUsableAsItsStaticType() :9"]
  n1["OperatorsAndHigherOrderTests.concatenationAcceptsEveryRightArityUpToSix() :17"]
  n2["OperatorsAndHigherOrderTests.concatenationWithEmptyTuples() :28"]
  n3["OperatorsAndHigherOrderTests.concatenationChainsOfThreeOperandsAndStepwiseLongerChains() :36"]
  n4["OperatorsAndHigherOrderTests.predicatePatternWorksInSwitch() :46"]
  n5["classify(_:) [syntax only] :56"]
  n6["OperatorsAndHigherOrderTests.typedUpdateCopiesAndPropagatesErrors() :74"]
  n7["OperatorsAndHigherOrderTests.buildsNewBoxWithOneTypeChangingTransformationAtATime() :89"]
  n8["OperatorsAndHigherOrderTests.appendingTransformedPropagatesErrorAndHandlesOptionalNil() :104"]
  n9["OperatorsAndHigherOrderTests.typedTraversalKeepsMemberTypesAndOrder() :123"]
  n10["OperatorsAndHigherOrderTests.throwingTypedTraversalStopsAtFailure() :141"]
  n11["OperatorsAndHigherOrderTests.throwingTypedTraversalCompletesInOrder() :158"]
  n12["Tuple.+(_:_:) (Tuple+Concatenation.swift:58)"]
  n13["Tuple.==(_:_:) (Tuple+Equatable.swift:14)"]
  n14["Tuple.init(_:) (Tuple.swift:35)"]
  n15["Tuple.+(_:_:) (Tuple+Concatenation.swift:35)"]
  n16["Tuple.+(_:_:) (Tuple+Concatenation.swift:87)"]
  n17["Tuple.+(_:_:) (Tuple+Concatenation.swift:117)"]
  n18["Tuple.+(_:_:) (Tuple+Concatenation.swift:148)"]
  n19["Tuple.+(_:_:) (Tuple+Concatenation.swift:180)"]
  n20["Tuple.+(_:_:) (Tuple+Concatenation.swift:15)"]
  n21["==(_:_:) [unmapped]"]
  n22["TuplePattern.matches(_:) (TuplePattern.swift:34)"]
  n23["TuplePattern.init(_:) (TuplePattern.swift:19)"]
  n24["==(_:_:) [unmapped]"]
  n25["hasPrefix(_:) [unmapped]"]
  n26["!(_:) [unmapped]"]
  n27["#62;(_:_:) [unmapped]"]
  n28["==(_:_:) [unmapped]"]
  n29["Tuple.updating(_:_:) (Tuple+TypedAccess.swift:38)"]
  n30["*(_:_:) [unmapped]"]
  n31["Tuple.appendingTransformed(_:_:) (Tuple.swift:137)"]
  n32["init(_:) [unmapped]"]
  n33["==(_:_:) [unmapped]"]
  n34["+=(_:_:) [unmapped]"]
  n35["??(_:_:) [unmapped]"]
  n36["Tuple.forEachTyped(_:) (Tuple.swift:158)"]
  n37["append(_:) [unmapped]"]
  n38["==(_:_:) [unmapped]"]
  n39["==(_:_:) [unmapped]"]
  n40["Tuple.tryForEachTyped(_:) (Tuple.swift:177)"]
  n0 --> n12
  n0 --> n13
  n0 --> n14
  n1 --> n15
  n1 --> n12
  n1 --> n16
  n1 --> n17
  n1 --> n18
  n1 --> n19
  n1 --> n13
  n1 --> n14
  n2 --> n21
  n2 --> n20
  n2 --> n12
  n2 --> n13
  n2 --> n14
  n3 --> n15
  n3 --> n12
  n3 --> n13
  n3 --> n14
  n4 --> n24
  n4 --> n25
  n4 --> n26
  n4 --> n27
  n4 --> n28
  n4 --> n14
  n4 --> n23
  n4 --> n22
  n6 --> n24
  n6 --> n30
  n6 --> n28
  n6 --> n29
  n6 --> n14
  n7 --> n24
  n7 --> n32
  n7 --> n33
  n7 --> n28
  n7 --> n14
  n7 --> n31
  n8 --> n24
  n8 --> n28
  n8 --> n34
  n8 --> n35
  n8 --> n14
  n8 --> n31
  n9 --> n37
  n9 --> n38
  n9 --> n39
  n9 --> n14
  n9 --> n36
  n10 --> n37
  n10 --> n38
  n10 --> n14
  n10 --> n40
  n11 --> n32
  n11 --> n37
  n11 --> n38
  n11 --> n14
  n11 --> n40
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n12,n13,n14,n15,n16,n17,n18,n19,n20,n21,n22,n23,n24,n25,n26,n27,n28,n29,n30,n31,n32,n33,n34,n35,n36,n37,n38,n39,n40 elsewhere
```

---

## PlaygroundDisplayTests.swift

[`Tests/TupleKitTests/PlaygroundDisplayTests.swift`](../../Tests/TupleKitTests/PlaygroundDisplayTests.swift)

```mermaid
flowchart LR
  n0["playgroundDisplayPreservesMemberTypesAndOrder() :4"]
  n1["Tuple.init(_:) (Tuple.swift:35)"]
  n2["==(_:_:) [unmapped]"]
  n3["==(_:_:) [unmapped]"]
  n0 --> n2
  n0 --> n3
  n0 --> n1
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n1,n2,n3 elsewhere
```

---

## ShapeTests.swift

[`Tests/TupleKitTests/ShapeTests.swift`](../../Tests/TupleKitTests/ShapeTests.swift)

```mermaid
flowchart LR
  n0["ShapeTests.oneMemberTupleIsAddressedThroughSelf() :6"]
  n1["ShapeTests.oneMemberTupleSupportsEveryOperation() :20"]
  n2["ShapeTests.emptyTupleSupportsEveryOperationThatTakesNoTransforms() :43"]
  n3["Tuple.member(at:as:) (Tuple+TypedAccess.swift:63)"]
  n4["Tuple.updating(_:_:) (Tuple+TypedAccess.swift:38)"]
  n5["Tuple.subscript(_:map:) (Tuple+MappingSubscript.swift:15)"]
  n6["Tuple.init(_:) (Tuple.swift:35)"]
  n7["Tuple.subscript(_:) (Tuple+TypedAccess.swift:20)"]
  n8["==(_:_:) [unmapped]"]
  n9["*(_:_:) [unmapped]"]
  n10["==(_:_:) [unmapped]"]
  n11["+=(_:_:) [unmapped]"]
  n12["==(_:_:) [unmapped]"]
  n13["decode(_:from:) [unmapped]"]
  n14["init() [unmapped]"]
  n15["encode(_:) [unmapped]"]
  n16["init() [unmapped]"]
  n17["Tuple.+(_:_:) (Tuple+Concatenation.swift:35)"]
  n18["Tuple.mapEach(_:) (Tuple+AsyncMemberWork.swift:42)"]
  n19["Tuple.mapEach(_:) (Tuple+AsyncMemberWork.swift:17)"]
  n20["Tuple.#60;(_:_:) (Tuple+Comparable.swift:14)"]
  n21["Tuple.==(_:_:) (Tuple+Equatable.swift:14)"]
  n22["TuplePattern.matches(_:) (TuplePattern.swift:34)"]
  n23["TuplePattern.init(_:) (TuplePattern.swift:19)"]
  n24["concurrentMapEach(_:_:) (Tuple+AsyncMemberWork.swift:78)"]
  n25["==(_:_:) [unmapped]"]
  n26["init(bytes:encoding:) [unmapped]"]
  n27["yield() [unmapped]"]
  n28["+(_:_:) [unmapped]"]
  n29["Tuple.forEachTyped(_:) (Tuple.swift:158)"]
  n30["Tuple.+(_:_:) (Tuple+Concatenation.swift:58)"]
  n31["!(_:) [unmapped]"]
  n0 --> n8
  n0 --> n9
  n0 --> n10
  n0 --> n11
  n0 --> n12
  n0 --> n5
  n0 --> n7
  n0 --> n4
  n0 --> n3
  n0 --> n6
  n1 --> n13
  n1 --> n14
  n1 --> n15
  n1 --> n16
  n1 --> n25
  n1 --> n26
  n1 --> n8
  n1 --> n27
  n1 --> n28
  n1 --> n10
  n1 --> n19
  n1 --> n18
  n1 --> n24
  n1 --> n20
  n1 --> n17
  n1 --> n21
  n1 --> n6
  n1 --> n23
  n1 --> n22
  n2 --> n13
  n2 --> n14
  n2 --> n15
  n2 --> n16
  n2 --> n25
  n2 --> n26
  n2 --> n8
  n2 --> n31
  n2 --> n12
  n2 --> n24
  n2 --> n20
  n2 --> n30
  n2 --> n21
  n2 --> n3
  n2 --> n6
  n2 --> n29
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20,n21,n22,n23,n24,n25,n26,n27,n28,n29,n30,n31 elsewhere
```

---

## TaskValueLifetimeTests.swift

[`Tests/TupleKitTests/TaskValueLifetimeTests.swift`](../../Tests/TupleKitTests/TaskValueLifetimeTests.swift)

```mermaid
flowchart LR
  n0["ValueGate.wait() :11"]
  n1["ValueGate.waitUntilStarted() :21"]
  n2["ValueGate.release() :26"]
  n3["TaskValueLifetimeTests.failureReturnsBeforeLaterTasksFinishWithoutCancellingThem() :33"]
  n4["withCheckedContinuation(function:_:) [unmapped]"]
  n5["resume() [unmapped]"]
  n6["!=(_:_:) [unmapped]"]
  n7["init() [unmapped]"]
  n8["init() [unmapped]"]
  n9["Tuple.init(_:) (Tuple.swift:35)"]
  n10["values(of:) (Tuple+Combining.swift:86)"]
  n11["==(_:_:) [unmapped]"]
  n12["!(_:) [unmapped]"]
  n13["init(name:priority:operation:) [unmapped]"]
  n0 --> n4
  n0 --> n5
  n1 --> n4
  n1 --> n6
  n2 --> n5
  n3 --> n7
  n3 --> n8
  n3 --> n11
  n3 --> n12
  n3 --> n13
  n3 --> n10
  n3 --> n9
  n3 --> n0
  n3 --> n1
  n3 --> n2
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n4,n5,n6,n7,n8,n9,n10,n11,n12,n13 elsewhere
```

---

## TupleTests.swift

[`Tests/TupleKitTests/TupleTests.swift`](../../Tests/TupleKitTests/TupleTests.swift)

```mermaid
flowchart LR
  n0["TupleKitTests.initializationWithVariadicArguments() :9"]
  n1["TupleKitTests.writeableKeyPathSubscript() :22"]
  n2["TupleKitTests.countAndIsEmpty() :33"]
  n3["TupleKitTests.getElementByWriteableKeyPathSubscript() :45"]
  n4["TupleKitTests.erasedMembersCopiesMembersInPositionOrder() :55"]
  n5["TupleKitTests.descriptionKeepsStringMembersDistinct() :69"]
  n6["TupleKitTests.descriptionQuotesOnlyTextMembers() :75"]
  n7["TupleKitTests.descriptionRendersPrivateTypesWithoutAddresses() :81"]
  n8["TupleKitTests.nestedTuplesRenderInTheirPlainForm() :87"]
  n9["TupleKitTests.descriptionsNameStaticMemberTypes() :98"]
  n10["TupleKitTests.equality() :109"]
  n11["Tuple.init(_:) (Tuple.swift:35)"]
  n12["==(_:_:) [unmapped]"]
  n13["==(_:_:) [unmapped]"]
  n14["subscript(_:) [unmapped]"]
  n15["==(_:_:) [unmapped]"]
  n16["==(_:_:) [unmapped]"]
  n17["!(_:) [unmapped]"]
  n18["==(_:_:) [unmapped]"]
  n19["#60;(_:_:) [unmapped]"]
  n20["subscript(_:) [unmapped]"]
  n21["...(_:) [unmapped]"]
  n22["+(_:_:) [unmapped]"]
  n23["Tuple.==(_:_:) (Tuple+Equatable.swift:14)"]
  n24["!=(_:_:) [unmapped]"]
  n0 --> n12
  n0 --> n13
  n0 --> n14
  n0 --> n15
  n0 --> n11
  n1 --> n16
  n1 --> n15
  n1 --> n11
  n2 --> n17
  n2 --> n15
  n2 --> n11
  n3 --> n16
  n3 --> n18
  n3 --> n19
  n3 --> n15
  n3 --> n11
  n4 --> n12
  n4 --> n14
  n4 --> n15
  n4 --> n11
  n5 --> n16
  n5 --> n11
  n6 --> n16
  n6 --> n20
  n6 --> n21
  n6 --> n11
  n7 --> n16
  n7 --> n11
  n8 --> n16
  n8 --> n11
  n9 --> n22
  n9 --> n16
  n9 --> n11
  n10 --> n24
  n10 --> n23
  n10 --> n11
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n11,n12,n13,n14,n15,n16,n17,n18,n19,n20,n21,n22,n23,n24 elsewhere
```

---

## TypedAccessTests.swift

[`Tests/TupleKitTests/TypedAccessTests.swift`](../../Tests/TupleKitTests/TypedAccessTests.swift)

```mermaid
flowchart LR
  n0["BoxReceiver.receive(_:) :5"]
  n1["HandlerRunner.execute(_:) :11"]
  n2["TypedAccessTests.sendableBoxCrossesActorBoundary() :24"]
  n3["TypedAccessTests.typedKeyPathReadsAndReplacesClosure() :30"]
  n4["TypedAccessTests.typedHandlerBundleCrossesActorBoundary() :43"]
  n5["TypedAccessTests.runtimeLookupReportsInvalidPositionOrType() :53"]
  n6["init() [unmapped]"]
  n7["Tuple.init(_:) (Tuple.swift:35)"]
  n8["==(_:_:) [unmapped]"]
  n9["Tuple.subscript(_:) (Tuple+TypedAccess.swift:20)"]
  n10["==(_:_:) [unmapped]"]
  n11["init() [unmapped]"]
  n12["record(_:severity:sourceLocation:) [unmapped]"]
  n13["Tuple.member(at:as:) (Tuple+TypedAccess.swift:63)"]
  n14["==(_:_:) [unmapped]"]
  n15["==(_:_:) [unmapped]"]
  n2 --> n6
  n2 --> n8
  n2 --> n7
  n2 --> n0
  n3 --> n8
  n3 --> n10
  n3 --> n9
  n3 --> n7
  n4 --> n11
  n4 --> n8
  n4 --> n10
  n4 --> n7
  n4 --> n1
  n5 --> n12
  n5 --> n14
  n5 --> n15
  n5 --> n13
  n5 --> n7
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n6,n7,n8,n9,n10,n11,n12,n13,n14,n15 elsewhere
```

---

## ZipResourceLifetimeTests.swift

[`Tests/TupleKitTests/ZipResourceLifetimeTests.swift`](../../Tests/TupleKitTests/ZipResourceLifetimeTests.swift)

```mermaid
flowchart LR
  n0["ResourceSequence.AsyncIterator.next() :19"]
  n1["ResourceSequence.makeAsyncIterator() :30"]
  n2["resourceZip(termination:firstStops:) :37"]
  n3["ZipResourceLifetimeTests.terminationReleasesEveryBase(termination:firstStops:) :55"]
  n4["init() [unmapped]"]
  n5["init() [unmapped]"]
  n6["init(resource:termination:) [unmapped]"]
  n7["init() [unmapped]"]
  n8["init(resource:termination:) [unmapped]"]
  n9["TupleZipSequence.makeAsyncIterator() (TupleZipSequence.swift:57)"]
  n10["zipToTuples(_:) (TupleZipSequence.swift:109)"]
  n11["#38;#38;(_:_:) [unmapped]"]
  n12["==(_:_:) [unmapped]"]
  n13["TupleZipSequence.AsyncIterator.next() (TupleZipSequence.swift:43)"]
  n14["==(_:_:) [unmapped]"]
  n15["==(_:_:) [unmapped]"]
  n16["withExtendedLifetime(_:_:) [unmapped]"]
  n0 --> n4
  n0 --> n5
  n1 --> n6
  n2 --> n7
  n2 --> n8
  n2 --> n11
  n2 --> n12
  n2 --> n9
  n2 --> n10
  n3 --> n14
  n3 --> n15
  n3 --> n12
  n3 --> n16
  n3 --> n13
  n3 --> n2
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16 elsewhere
```

---

## ZipToTuplesTests.swift

[`Tests/TupleKitTests/ZipToTuplesTests.swift`](../../Tests/TupleKitTests/ZipToTuplesTests.swift)

```mermaid
flowchart LR
  n0["stream(_:) :7"]
  n1["ReleasingSequence.AsyncIterator.next() :24"]
  n2["ReleasingSequence.makeAsyncIterator() :30"]
  n3["trackedZip() :35"]
  n4["ZipBoxesTests.zipBoxesPairsElementsByPositionAndKeepsMemberTypes() :49"]
  n5["ZipBoxesTests.loopElementsSupportTypedKeyPathAccess() :64"]
  n6["ZipBoxesTests.zipBoxesEndsWithTheShortestBaseAndStaysFinished() :75"]
  n7["ZipBoxesTests.exhaustedFirstBaseDoesNotPullAThrowingLaterBase() :88"]
  n8["ZipBoxesTests.finishedZipReleasesResourcesHeldByACompletedBase() :102"]
  n9["ZipBoxesTests.zipWithoutBasesEndsBeforeYieldingAnything() :112"]
  n10["ZipBoxesTests.zipBoxesEmitsOptionalNilMembersAsValues() :122"]
  n11["ZipBoxesTests.zipBoxesRethrowsABaseFailureAndThenFinishes() :131"]
  n12["ZipBoxesTests.zipBoxesCanBeConsumedInAnotherTaskWhenBasesAreSendable() :154"]
  n13["yield(_:) [unmapped]"]
  n14["finish() [unmapped]"]
  n15["init(_:bufferingPolicy:_:) [unmapped]"]
  n16["init(resource:) [unmapped]"]
  n17["init() [unmapped]"]
  n18["init(resource:) [unmapped]"]
  n19["TupleZipSequence.makeAsyncIterator() (TupleZipSequence.swift:57)"]
  n20["zipToTuples(_:) (TupleZipSequence.swift:109)"]
  n21["==(_:_:) [unmapped]"]
  n22["Tuple.init(_:) (Tuple.swift:35)"]
  n23["append(_:) [unmapped]"]
  n24["==(_:_:) [unmapped]"]
  n25["Tuple.subscript(_:) (Tuple+TypedAccess.swift:20)"]
  n26["uppercased() [unmapped]"]
  n27["+(_:_:) [unmapped]"]
  n28["TupleZipSequence.AsyncIterator.next() (TupleZipSequence.swift:43)"]
  n29["==(_:_:) [unmapped]"]
  n30["init() [unmapped]"]
  n31["finish(throwing:) [unmapped]"]
  n32["init(_:bufferingPolicy:_:) [unmapped]"]
  n33["record(_:severity:sourceLocation:) [unmapped]"]
  n34["yield(_:) [unmapped]"]
  n35["detached(name:priority:operation:) [unmapped]"]
  n36["==(_:_:) [unmapped]"]
  n37["+=(_:_:) [unmapped]"]
  n0 --> n13
  n0 --> n14
  n0 --> n15
  n2 --> n16
  n3 --> n17
  n3 --> n18
  n3 --> n21
  n3 --> n19
  n3 --> n20
  n3 --> n0
  n4 --> n23
  n4 --> n24
  n4 --> n22
  n4 --> n20
  n4 --> n0
  n5 --> n26
  n5 --> n23
  n5 --> n24
  n5 --> n27
  n5 --> n25
  n5 --> n20
  n5 --> n0
  n6 --> n29
  n6 --> n21
  n6 --> n22
  n6 --> n28
  n6 --> n19
  n6 --> n20
  n6 --> n0
  n7 --> n30
  n7 --> n31
  n7 --> n32
  n7 --> n21
  n7 --> n28
  n7 --> n19
  n7 --> n20
  n7 --> n0
  n8 --> n21
  n8 --> n28
  n8 --> n3
  n9 --> n21
  n9 --> n28
  n9 --> n19
  n9 --> n20
  n10 --> n29
  n10 --> n22
  n10 --> n28
  n10 --> n19
  n10 --> n20
  n10 --> n0
  n11 --> n30
  n11 --> n33
  n11 --> n29
  n11 --> n34
  n11 --> n31
  n11 --> n32
  n11 --> n21
  n11 --> n22
  n11 --> n28
  n11 --> n19
  n11 --> n20
  n11 --> n0
  n12 --> n35
  n12 --> n36
  n12 --> n37
  n12 --> n20
  n12 --> n0
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n13,n14,n15,n16,n17,n18,n19,n20,n21,n22,n23,n24,n25,n26,n27,n28,n29,n30,n31,n32,n33,n34,n35,n36,n37 elsewhere
```
