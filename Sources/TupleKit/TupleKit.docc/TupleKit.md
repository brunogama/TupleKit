# ``TupleKit``

Keep a fixed group of members whose static types differ, and transform them without losing those types.

---

## Overview

``Tuple`` stores a built-in tuple whose member types come from a parameter pack. Key paths, `mapEach`, and the conformances work with each member's static type. Runtime access through `Any` is explicit, through `erasedMembers` and `member(at:as:)`.

The module also provides concurrent member transforms, functions that combine tuples of optionals, results, and tasks, sequences of complete tuples, typed switch patterns, and conditional `Equatable`, `Hashable`, `Comparable`, `Codable`, and `Sendable` conformances.

---

## Topics

### Guides

- <doc:UseCases>
