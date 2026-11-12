# ``HeterogeneousBox``

Keep a fixed group of values with different static types, and use collection operations when runtime indexing is needed.

---

## Overview

`HeterogeneousBox` stores a parameter-pack tuple. Tuple positions and key paths retain their static types. Its `Collection` conformance exposes `Any` because a collection has one element type.

The package also provides typed transforms, switch patterns, checked runtime lookup, finite async iteration, assignment-history property wrappers, and conditional `Sendable` conformance.

---

## Topics

### Guides

- <doc:UseCases>
