# Function map: TupleKitSnapshotTests

One chart per file. Nodes list explicit Swift callable declarations with source lines. Arrows show compiler-resolved references to functions, including calls and function values. Gray nodes are callees declared elsewhere; a shaded node with no project location is not mapped to a declaration in these charts.

---

## GoldenSnapshotTests.swift

[`Tests/TupleKitSnapshotTests/GoldenSnapshotTests.swift`](../../Tests/TupleKitSnapshotTests/GoldenSnapshotTests.swift)

```mermaid
flowchart LR
  n0["Sample.init(_:_:) :24"]
  n1["Sample.getter:report :33"]
  n2["GoldenSnapshotTests.textualRepresentations() :59"]
  n3["GoldenSnapshotTests.mirrorDump() :65"]
  n4["GoldenSnapshotTests.jsonEncoding() :71"]
  n5["GoldenSnapshotTests.caseIterableOrder() :83"]
  n6["GoldenSnapshotTests.rawValues() :90"]
  n7["GoldenSnapshotTests.elementwiseArithmetic() :102"]
  n8["GoldenSnapshotTests.concatenation() :114"]
  n9["File scope / initializers"]
  n10["Tuple.write(to:) (Tuple+TextOutputStreamable.swift:12)"]
  n11["assertSnapshot(of:as:named:record:timeout:fileID:file:testName:line:column:) [unmapped]"]
  n12["joined(separator:) [unmapped]"]
  n13["map(_:) [unmapped]"]
  n14["Tuple.init(_:) (Tuple.swift:35)"]
  n15["dump(_:to:name:indent:maxDepth:maxItems:) [unmapped]"]
  n16["Tuple.init(rawValues:) (Tuple+RawRepresentable.swift:28)"]
  n17["init(describing:) [unmapped]"]
  n18["ElementwiseTuple.+(_:_:) (ElementwiseTuple.swift:38)"]
  n19["ElementwiseTuple.-(_:_:) (ElementwiseTuple.swift:49)"]
  n20["ElementwiseTuple.init(_:) (ElementwiseTuple.swift:22)"]
  n21["reduce(_:_:) [unmapped]"]
  n22["Tuple.+(_:_:) (Tuple+Concatenation.swift:58)"]
  n23["init() [unmapped]"]
  n9 --> n23
  n9 --> n14
  n9 --> n0
  n0 --> n10
  n2 --> n11
  n2 --> n12
  n2 --> n13
  n3 --> n11
  n3 --> n15
  n3 --> n14
  n4 --> n11
  n4 --> n14
  n5 --> n11
  n5 --> n12
  n5 --> n13
  n6 --> n11
  n6 --> n17
  n6 --> n16
  n6 --> n14
  n7 --> n11
  n7 --> n21
  n7 --> n13
  n7 --> n20
  n7 --> n18
  n7 --> n19
  n7 --> n14
  n8 --> n11
  n8 --> n22
  n8 --> n14
  classDef elsewhere fill:#e5e7eb,color:#111827,stroke:#6b7280
  class n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20,n21,n22,n23 elsewhere
```
