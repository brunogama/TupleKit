# Tuple is a product value, not a collection

The library's type is a fixed-shape product value: each member keeps its own static type. For the initial TupleKit release (1.0.0), we renamed it from `HeterogeneousBox` to `Tuple` and removed its `Collection` conformance and every API that returned or accepted members as `Any`. The two personalities conflicted. `for x in box` silently produced `Any`, `map` could not be the typed map callers expected, and "box" suggested indirect storage that the type never had. Runtime access is now explicit through `erasedMembers` and the checked `member(at:as:)`.

## Considered Options

- **Keep `Collection` alongside the typed API.** Rejected: Swift cannot deprecate a conformance, so it would stay part of the type's identity forever.
- **Keep the name `HeterogeneousBox`.** Rejected: the module has the same name, which blocks module qualification such as `HeterogeneousBox.Tuple`.
- **`TypedTuple` or `HList`.** Rejected: `TypedTuple` is redundant in Swift, and `HList` is obscure outside functional programming.

## Consequences

Runtime access through `Any` is opt-in, so code that relied on iterating members has to name `erasedMembers`. The package and module were later renamed to TupleKit, and the deprecated `HeterogeneousBox` typealias was removed. See ADR 0003.
