
<p align="center">
  <img src=".github/assets/images/IMG_0546.jpg" alt="Banner">
</p>


# HeterogeneousBox

![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrunogama%2FHeterogeneousBox%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brunogama/HeterogeneousBox)[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrunogama%2FHeterogeneousBox%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brunogama/HeterogeneousBox)

A Swift package for heterogeneous values backed by a typed tuple. It uses parameter packs (introduced in Swift 5.9) and pack iteration (introduced in Swift 6.0). Runtime collection access is type-erased to `Any`.

---

## What is HeterogeneousBox?

HeterogeneousBox provides a flexible solution for working with collections of mixed types in Swift while retaining their types in a generic tuple. Runtime indexing and collection methods expose elements as `Any`, so callers must cast when using those APIs.

The generic tuple preserves the static type of each element. Collection-style APIs trade that information for runtime indexing.

---

## Features

- **Type-Safe Heterogeneous Collections**: Store elements of different types while preserving their type information
- **Typed Tuple Access**: Access tuple elements by positional key path with their static types; runtime-indexed access is type-erased
- **Clean API**: Simple, intuitive interface for working with mixed-type collections
- **Swift Parameter Packs**: Leverages Swift 5.9's parameter packs for improved generic programming
- **Pack Iteration**: Uses Swift 6's `for-in repeat` to traverse the stored tuple
- **Typed Concatenation**: Join boxes with `+` while retaining every member's type
- **Switch Patterns**: Match each box member or any generic value with a predicate in a `switch` case
- **Typed Mapping Subscripts**: Select one or two members by tuple key path and map them without `Any`
- **Function Composition**: Compose synchronous transforms with `>>>` and apply values with `|>`

---

## Requirements

- Swift 6.0+
- Swift 6 language mode
- iOS 15.0+ / macOS 14.0+ (platforms declared in `Package.swift`)

---

## Installation

### Swift Package Manager

This checkout targets the planned 6.0.0 release. The 1.0.8 tag in the installation example is the latest tag currently present in this repository and does not include the new APIs described below. Use a local package dependency to try this checkout before 6.0.0 is released.

To add HeterogeneousBox to your Swift project using Swift Package Manager, declare it as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/brunogama/HeterogeneousBox.git", .exact("1.0.8"))
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["HeterogeneousBox"]),
    // ... other targets
]
```

Then, execute `swift package resolve` in your terminal.

### Xcode

Alternatively, you can add the package dependency via Xcode:

1. Navigate to File > Add Packages...
2. Enter the repository URL: `https://github.com/brunogama/HeterogeneousBox.git`
3. Set the "Dependency Rule" to "Exact Version" and input `1.0.8`
4. Click "Add Package"

---

## Usage

### Basic Example

Here's a simple example of how you might use HeterogeneousBox:

```swift
import HeterogeneousBox

// Create a heterogeneous box with different types
let box = HeterogeneousBox(42, "Hello", 3.14, true)

// Tuple key paths preserve static types; runtime indexing returns Any
let intValue: Int = box.0 // 42
let stringValue: String = box.1 // "Hello"
let doubleValue = box[2] as? Double // 3.14
let boolValue: Bool = box.3 // true
```

### Working with Parameter Packs

HeterogeneousBox leverages Swift's parameter packs to create and manipulate collections of mixed types:

```swift
// Function using parameter packs with HeterogeneousBox
func processValues<each T>(values: repeat each T) -> HeterogeneousBox<repeat each T> {
    HeterogeneousBox(repeat each values)
}

// Use with mixed types
let mixedBox = processValues(values: 100, "Swift", 99.9)
```

### Typed access across actors

`HeterogeneousBox` conforms to `Sendable` when every stored element does. A tuple of `@Sendable` handlers can therefore be passed to an actor while keeping each handler's argument and result types.

```swift
var box = HeterogeneousBox(42, "ready")
let number: Int = box.value(at: \.0)
box[\.0] = 43

switch box.element(at: 1, as: String.self) {
case .success(let text): print(text)
case .failure(let error): print(error)
}
```

Use tuple key paths when the position is known at compile time. `element(at:as:)` is for runtime positions and returns `.outOfBounds` or `.typeMismatch` instead of trapping. A stored optional `nil` remains a successful value. Existing integer indexing and inferred typed indexing retain their original trapping behavior.

### Operators and higher order operations

`+` concatenates boxes without erasing element types. A typed key path can transform one member while leaving the original box unchanged:

```swift
let combined = HeterogeneousBox(2, "ready") + HeterogeneousBox(true)
let doubled = combined.updating(\.0) { $0 * 2 }
// doubled.0 is Int, doubled.1 is String, doubled.2 is Bool
```

Build a new box with a different type for each member by transforming and appending one value at a time:

```swift
let source = HeterogeneousBox(12, "ready", true)
let first = HeterogeneousBox()
    .appendingTransformed(source.value.0) { String($0) }
let second = first.appendingTransformed(source.value.1) { $0.count }
let result = second.appendingTransformed(source.value.2) { $0 ? "yes" : "no" }
// result is HeterogeneousBox<String, Int, String>
```

Each call returns a new box and evaluates its transform once. Keep the intermediate boxes in separate bindings so Swift can infer each new parameter pack. A throwing transform propagates its error without changing the source box.

Use `mapBox` when one closure should decide every output member and its type. The closure must return a new `HeterogeneousBox`; its generic types may differ from the source box:

```swift
let source = HeterogeneousBox(12, "ready", true)
let mapped: HeterogeneousBox<String, Int, Bool> = source.mapBox { box in
    HeterogeneousBox("\(box.value.0)", box.value.1.count, !box.value.2)
}
```

`mapBox` also supports a different number of members and propagates a thrown error. The regular collection `map` still returns an array of values derived from `Any`.

Select one or two typed members and map them directly through a read-only subscript. The closure runs once and does not change the box:

```swift
let parts = HeterogeneousBox(42, "/accounts/")
let path: String = parts[\.1, \.0, map: { prefix, id in
    "\(prefix)\(id)"
}]

let suffix: (String) -> String = { $0 + "/preferences" }
let nextPath = path |> suffix
```

`>>>` composes two synchronous, nonthrowing functions from left to right. `|>` applies a value to a function, so `value |> first >>> second` runs `first` and then `second`. The operators do not perform network calls or manage tasks. Swift does not enforce that a closure has no side effects. The [DocC use case guide](Sources/HeterogeneousBox/HeterogeneousBox.docc/UseCases.md) includes a typed request pipeline with two different parallel response types.

For a raw tuple, use `mapTuple`. Its closure receives the tuple with all member types intact and must return a new box:

```swift
let tuple = (12, "ready")
let mapped: HeterogeneousBox<String, Int> = mapTuple(tuple) { values in
    HeterogeneousBox("\(values.0)", values.1.count)
}
```

Swift does not support extending tuple types directly. `mapTuple` takes a generic input, so it also accepts other source values without erasing their type.

`HeterogeneousBoxPattern` supplies one predicate per member. The `~=` operator lets a pattern be used directly in `switch`:

```swift
let ready = HeterogeneousBoxPattern<Int, String>(
    { $0 > 0 },
    { $0.hasPrefix("ready") }
)

switch HeterogeneousBox(2, "ready-now") {
case ready: print("matched")
default: print("not matched")
}
```

Use `PredicatePattern<Value>` when the switched value is any other type. Its `~=` overload is generic, so no overload is needed for `Int`, `String`, or a custom model:

```swift
struct Message { let id: Int }
let selected = PredicatePattern<Message> { $0.id == 7 }

switch Message(id: 7) {
case selected: print("selected")
default: print("other")
}
```

Predicates run in tuple order and stop at the first failure. The existing `map`, `compactMap`, `filter`, `first(where:)`, and `reduce` operations also visit members in tuple order. These collection operations expose `Any`; their results do not preserve the distinct element types. Use tuple access and `updating` when static types matter.

### Typed traversal

Pack iteration can visit each member with its own static type. Supply one callback per member:

```swift
let box = HeterogeneousBox(42, "ready")
box.forEachTyped(
    { (number: Int) in print(number + 1) },
    { (text: String) in print(text.uppercased()) }
)
```

The callbacks run in tuple order. `tryForEachTyped` stops and propagates the first thrown error. This traversal does not expose `Any`. Standard `Collection` iteration still uses one `Element` type, so `for element in box` yields `Any`.

### Async values

`asyncValues()` returns a finite `AsyncSequence` of `Any` from a snapshot of the box. It creates no producer task or `AsyncStream` continuation:

```swift
for await item in HeterogeneousBox(42, "ready").asyncValues() {
    print(item)
}
```

Each iterator yields one member per `next()` call and stops when the consuming task is canceled. A stored optional `nil` remains an emitted value. Use `forEachTyped` when each member needs its own static type.

### Accumulating assignments

`@AccumulatingValue` records a homogeneous history. `@AccumulatingBox` records snapshots of boxes with one fixed member layout:

```swift
struct State {
    @AccumulatingValue(capacity: 2) var count = 1
    @AccumulatingBox(capacity: 2) var box = HeterogeneousBox(1, "ready")
}

var state = State()
state.count = 2
state.box = HeterogeneousBox(2, "running")
let counts = state.$count // [1, 2]
let boxes = state.$box // [HeterogeneousBox<Int, String>]
```

The initial value is the first history entry. Each assignment appends another. With `capacity: 2`, only the two newest entries remain; omit `capacity` to retain all entries. Capacity must be positive. A property wrapper cannot change its generic member layout on assignment; use `appendingTransformed` or `mapBox` to produce a box with different member types.

---

## How It Works

`HeterogeneousBox<each Value>` stores `(repeat each Value)` as a tuple. `for-in repeat` visits its members for count, typed traversal and higher order operations without first creating an array. Runtime collection access still exposes `Any`. Standard iteration creates one `[Any]` snapshot. Typed access is available through tuple key paths such as `box.0`. `appending(values:)` and `+` return boxes with extended type packs, and `HeterogeneousBox(tuple:)` constructs one from a tuple.

---

## Future Developments

Pack iteration arrived in Swift 6.0 and is used by this package. `appendingTransformed` supports type-changing transformations one member at a time; `mapBox` and `mapTuple` accept one closure returning a new typed box. A single call that accepts a parameter pack of separate transforms remains a candidate API; the current Swift 6.4.2 toolchain failed to compile that implementation. In the same toolchain, direct `.0` or `.value` access on a one-member box fails during code generation; `element(at:as:)` remains usable for that case.

---

## Learn More

The [DocC use case guide](Sources/HeterogeneousBox/HeterogeneousBox.docc/UseCases.md) covers every public API with examples and failure behavior.

For more information about Swift Parameter Packs, check out these resources:

- [WWDC23: Generalize APIs with parameter packs](https://developer.apple.com/videos/play/wwdc2023/10168)
- [Swift Evolution Proposal: Parameter Packs](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0393-parameter-packs.md)
- [Swift.org: Iterate Over Parameter Packs in Swift 6.0](https://www.swift.org/blog/pack-iteration/)

---

## About

HeterogeneousBox is developed by [Bruno Gama](https://github.com/brunogama), exploring the powerful capabilities of Swift Parameter Packs for type-safe heterogeneous collections.

Check out the blog post about this package: [The Box: Exploring Swift Parameter Packs](https://bruno.foundation/swift/programming/2025/04/13/the-box/)

---

## License

HeterogeneousBox is available under the MIT license. See the LICENSE file for more info.
