# Function map: TupleKitCompositionTests

One chart per file. Nodes list explicit Swift callable declarations with source lines. Arrows show compiler-resolved references to functions, including calls and function values. Gray nodes are callees declared elsewhere; a shaded node with no project location is not mapped to a declaration in these charts.

---

## AccumulatingWrapperTests.swift

[`Tests/TupleKitCompositionTests/AccumulatingWrapperTests.swift`](../../Tests/TupleKitCompositionTests/AccumulatingWrapperTests.swift)

```mermaid
flowchart LR
  n0["WrappedStateOwner.set(_:status:) :20"]
  n1["WrappedStateOwner.snapshots() :24"]
  n2["AccumulatingWrapperTests.boxWrapperRecordsTypedSnapshots() :30"]
  n3["AccumulatingWrapperTests.valueWrapperRecordsHomogeneousAssignmentsAndNil() :50"]
  n4["AccumulatingWrapperTests.actorCanOwnTypedBoxHistory() :64"]
  n5["AccumulatingWrapperTests.boundedValueHistoryRetainsNewestAssignmentsIncludingNil() :74"]
  n6["AccumulatingWrapperTests.boundedBoxHistoryRetainsNewestTypedSnapshots() :88"]
  n7["AccumulatingWrapperTests.capacityOneKeepsOnlyCurrentValue() :100"]
  n8["File scope / initializers"]
  n9["Tuple.init(_:) (Tuple.swift:35)"]
  n10["init() [unmapped]"]
  n11["Tuple.subscript(_:) (Tuple+TypedAccess.swift:20)"]
  n12["==(_:_:) [unmapped]"]
  n13["removeAll(keepingCapacity:) [unmapped]"]
  n14["subscript(_:) [unmapped]"]
  n15["==(_:_:) [unmapped]"]
  n16["==(_:_:) [unmapped]"]
  n17["==(_:_:) [unmapped]"]
  n18["==(_:_:) [unmapped]"]
  n19["init() [unmapped]"]
  n20["init() [unmapped]"]
  n21["AccumulatingValue.init(wrappedValue:capacity:) (AccumulatingValue.swift:26)"]
  n8 --> n9
  n8 --> n21
  n0 --> n9
  n2 --> n10
  n2 --> n12
  n2 --> n13
  n2 --> n14
  n2 --> n15
  n2 --> n11
  n2 --> n9
  n3 --> n10
  n3 --> n16
  n3 --> n17
  n3 --> n14
  n3 --> n15
  n3 --> n18
  n4 --> n19
  n4 --> n12
  n4 --> n14
  n4 --> n15
  n4 --> n0
  n4 --> n1
  n5 --> n20
  n5 --> n16
  n5 --> n17
  n5 --> n14
  n5 --> n15
  n5 --> n18
  n6 --> n20
  n6 --> n12
  n6 --> n14
  n6 --> n15
  n6 --> n11
  n6 --> n9
  n7 --> n17
  n7 --> n15
  n7 --> n21
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20,n21 elsewhere
```

---

## CompositionLifetimeTests.swift

[`Tests/TupleKitCompositionTests/CompositionLifetimeTests.swift`](../../Tests/TupleKitCompositionTests/CompositionLifetimeTests.swift)

```mermaid
flowchart LR
  n0["Tracked.init(_:) :8"]
  n1["CompositionLifetimeTests.predicatePatternReleasesTheObjectsItsPredicateCaptures() :16"]
  n2["CompositionLifetimeTests.boundedHistoryReleasesValuesItDrops() :27"]
  n3["CompositionLifetimeTests.historyReleasesEveryValueWhenItGoesAway() :38"]
  n4["PredicatePattern.matches(_:) (PredicatePattern.swift:26)"]
  n5["PredicatePattern.init(_:) (PredicatePattern.swift:18)"]
  n6["isMultiple(of:) [unmapped]"]
  n7["==(_:_:) [unmapped]"]
  n8["AccumulatingValue.init(wrappedValue:capacity:) (AccumulatingValue.swift:26)"]
  n9["==(_:_:) [unmapped]"]
  n10["map(_:) [unmapped]"]
  n11["==(_:_:) [unmapped]"]
  n1 --> n6
  n1 --> n7
  n1 --> n5
  n1 --> n4
  n1 --> n0
  n2 --> n9
  n2 --> n10
  n2 --> n7
  n2 --> n8
  n2 --> n0
  n3 --> n11
  n3 --> n7
  n3 --> n8
  n3 --> n0
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n4,n5,n6,n7,n8,n9,n10,n11 elsewhere
```

---

## FunctionCompositionTests.swift

[`Tests/TupleKitCompositionTests/FunctionCompositionTests.swift`](../../Tests/TupleKitCompositionTests/FunctionCompositionTests.swift)

```mermaid
flowchart LR
  n0["makePlan() :25"]
  n1["FunctionCompositionTests.typedSubscriptBuildsTheDependentPreferencesRequest() :37"]
  n2["FunctionCompositionTests.typedSubscriptBuildsTheParallelFinalRequests() :62"]
  n3["FunctionCompositionTests.mappingSubscriptPreservesOptionalNilAndSelectionOrder() :86"]
  n4["FunctionCompositionTests.forwardCompositionRunsEachFunctionOnceInOrder() :104"]
  n5["init(path:) [unmapped]"]
  n6["Tuple.init(_:) (Tuple.swift:35)"]
  n7["|#62;(_:_:) (FunctionComposition.swift:32)"]
  n8["#62;#62;#62;(_:_:) (FunctionComposition.swift:47)"]
  n9["init(id:) [unmapped]"]
  n10["Tuple.subscript(_:map:) (Tuple+MappingSubscript.swift:15)"]
  n11["==(_:_:) [unmapped]"]
  n12["+=(_:_:) [unmapped]"]
  n13["init(assetIDs:lastSessionID:) [unmapped]"]
  n14["Tuple.subscript(_:_:map:) (Tuple+MappingSubscript.swift:36)"]
  n15["Tuple.subscript(_:) (Tuple+TypedAccess.swift:20)"]
  n16["joined(separator:) [unmapped]"]
  n17["+(_:_:) [unmapped]"]
  n18["init(_:) [unmapped]"]
  n19["map(_:) [unmapped]"]
  n20["==(_:_:) [unmapped]"]
  n21["+=(_:_:) [unmapped]"]
  n22["map(_:) [unmapped]"]
  n23["==(_:_:) [unmapped]"]
  n24["??(_:_:) [unmapped]"]
  n25["append(_:) [unmapped]"]
  n26["==(_:_:) [unmapped]"]
  n27["+(_:_:) [unmapped]"]
  n0 --> n5
  n0 --> n6
  n1 --> n9
  n1 --> n11
  n1 --> n12
  n1 --> n10
  n1 --> n7
  n1 --> n8
  n1 --> n0
  n2 --> n13
  n2 --> n5
  n2 --> n16
  n2 --> n17
  n2 --> n11
  n2 --> n18
  n2 --> n19
  n2 --> n14
  n2 --> n15
  n2 --> n6
  n2 --> n0
  n3 --> n11
  n3 --> n18
  n3 --> n20
  n3 --> n21
  n3 --> n22
  n3 --> n23
  n3 --> n24
  n3 --> n14
  n3 --> n6
  n4 --> n11
  n4 --> n25
  n4 --> n26
  n4 --> n27
  n4 --> n7
  n4 --> n8
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20,n21,n22,n23,n24,n25,n26,n27 elsewhere
```

---

## OperatorPrecedenceTests.swift

[`Tests/TupleKitCompositionTests/OperatorPrecedenceTests.swift`](../../Tests/TupleKitCompositionTests/OperatorPrecedenceTests.swift)

```mermaid
flowchart LR
  n0["OperatorPrecedenceTests.inputExpressionsBindBeforeForwardApplication() :5"]
  n1["OperatorPrecedenceTests.compositionBindsBeforeApplicationAndAssignment() :17"]
  n2["|#62;(_:_:) (FunctionComposition.swift:32)"]
  n3["!(_:) [unmapped]"]
  n4["#60;(_:_:) [unmapped]"]
  n5["*(_:_:) [unmapped]"]
  n6["+(_:_:) [unmapped]"]
  n7["==(_:_:) [unmapped]"]
  n8["??(_:_:) [unmapped]"]
  n9["#62;#62;#62;(_:_:) (FunctionComposition.swift:47)"]
  n0 --> n3
  n0 --> n4
  n0 --> n5
  n0 --> n6
  n0 --> n7
  n0 --> n8
  n0 --> n2
  n1 --> n5
  n1 --> n6
  n1 --> n7
  n1 --> n2
  n1 --> n9
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n2,n3,n4,n5,n6,n7,n8,n9 elsewhere
```

---

## PredicatePatternTests.swift

[`Tests/TupleKitCompositionTests/PredicatePatternTests.swift`](../../Tests/TupleKitCompositionTests/PredicatePatternTests.swift)

```mermaid
flowchart LR
  n0["PredicatePatternTests.genericPredicatePatternMatchesAnyValueType() :11"]
  n1["matches(_:pattern:) [syntax only] :12"]
  n2["PredicatePattern.init(_:) (PredicatePattern.swift:18)"]
  n3["init(id:text:) [unmapped]"]
  n4["Tuple.init(_:) (Tuple.swift:35)"]
  n5["==(_:_:) [unmapped]"]
  n6["isMultiple(of:) [unmapped]"]
  n7["!(_:) [unmapped]"]
  n8["#38;#38;(_:_:) [unmapped]"]
  n9["#62;(_:_:) [unmapped]"]
  n10["==(_:_:) [unmapped]"]
  n0 --> n3
  n0 --> n5
  n0 --> n6
  n0 --> n7
  n0 --> n8
  n0 --> n9
  n0 --> n10
  n0 --> n4
  n0 --> n2
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n2,n3,n4,n5,n6,n7,n8,n9,n10 elsewhere
```
