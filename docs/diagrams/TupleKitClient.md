# Function map: TupleKitClient

One chart per file. Nodes list explicit Swift callable declarations with source lines. Arrows show compiler-resolved references to functions, including calls and function values. Gray nodes are callees declared elsewhere; a shaded node with no project location is not mapped to a declaration in these charts.

---

## Log.swift

[`Sources/TupleKitClient/Log.swift`](../../Sources/TupleKitClient/Log.swift)

```mermaid
flowchart LR
  n0["log(_:) :6"]
```

---

## main.swift

[`Sources/TupleKitClient/main.swift`](../../Sources/TupleKitClient/main.swift)

```mermaid
flowchart LR
  n0["File scope / initializers"]
  n1["log(_:) (Log.swift:6)"]
  n2["Tuple.forEachTyped(_:) (Tuple.swift:158)"]
  n3["Tuple.+(_:_:) (Tuple+Concatenation.swift:35)"]
  n4["Tuple.member(at:as:) (Tuple+TypedAccess.swift:63)"]
  n5["Tuple.init(_:) (Tuple.swift:35)"]
  n6["Tuple.subscript(_:) (Tuple+TypedAccess.swift:20)"]
  n7["+=(_:_:) [unmapped]"]
  n0 --> n7
  n0 --> n3
  n0 --> n6
  n0 --> n4
  n0 --> n5
  n0 --> n2
  n0 --> n1
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n1,n2,n3,n4,n5,n6,n7 elsewhere
```
