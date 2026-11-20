# Function map: TupleKitComposition

One chart per file. Nodes list explicit Swift callable declarations with source lines. Arrows show compiler-resolved references to functions, including calls and function values. Gray nodes are callees declared elsewhere; a shaded node with no project location is not mapped to a declaration in these charts.

---

## AccumulatingValue.swift

[`Sources/TupleKitComposition/AccumulatingValue.swift`](../../Sources/TupleKitComposition/AccumulatingValue.swift)

```mermaid
flowchart LR
  n0["AccumulatingValue.init(wrappedValue:capacity:) :26"]
  n1["AccumulatingValue.getter:wrappedValue :37"]
  n2["AccumulatingValue.setter:wrappedValue :38"]
  n3["AccumulatingValue.getter:projectedValue :48"]
  n4["#62;(_:_:) [unmapped]"]
  n5["precondition(_:_:file:line:) [unmapped]"]
  n6["append(_:) [unmapped]"]
  n7["removeFirst() [unmapped]"]
  n0 --> n4
  n0 --> n5
  n2 --> n6
  n2 --> n4
  n2 --> n7
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n4,n5,n6,n7 elsewhere
```

---

## FunctionComposition.swift

[`Sources/TupleKitComposition/Operators/FunctionComposition.swift`](../../Sources/TupleKitComposition/Operators/FunctionComposition.swift)

```mermaid
flowchart LR
  n0["|#62;(_:_:) :32"]
  n1["#62;#62;#62;(_:_:) :47"]
```

---

## PredicatePattern.swift

[`Sources/TupleKitComposition/PredicatePattern.swift`](../../Sources/TupleKitComposition/PredicatePattern.swift)

```mermaid
flowchart LR
  n0["PredicatePattern.init(_:) :18"]
  n1["PredicatePattern.matches(_:) :26"]
  n2["PredicatePattern.~=(_:_:) :41"]
  n2 --> n1
```
