# Use cases for HeterogeneousBox

Choose typed tuple operations when the member positions are known in source code. Choose collection operations when positions are discovered at runtime and losing the distinct static types is acceptable.

The examples assume `import HeterogeneousBox`. A box owns its tuple value. Methods that return a box leave the original box unchanged unless a mutable subscript explicitly writes through it.

---

## Choose an access path

| Need | API | Result |
| --- | --- | --- |
| Read or replace a known tuple member | `box.0`, `box[\.0]`, `value(at:)` | The member's static type |
| Change one known member in a copy | `updating(_:_:)` | A new box with the same member types |
| Transform the entire box | `mapBox(_:)` | A new box with types chosen by the closure |
| Transform a raw tuple | `mapTuple(_:_:)` | A new box with types chosen by the closure |
| Map selected typed members | `box[\.0, map:]` or `box[\.0, \.1, map:]` | A closure-selected output type |
| Compose synchronous functions | `>>>` and `|>` | A new function or its applied result |
| Visit every member without `Any` | `forEachTyped(_:)`, `tryForEachTyped(_:)` | One typed callback per member |
| Consume a fixed snapshot asynchronously | `asyncValues()` | A finite `AsyncSequence` of `Any` |
| Record assignments to a fixed property type | `@AccumulatingValue`, `@AccumulatingBox` | Typed history snapshots |
| Read an unknown runtime position | `element(at:as:)` | A checked `Result` |
| Use `Collection` algorithms | `map`, `filter`, `reduce`, and related methods | Values passed as `Any` |

`Collection.Element` is `Any`. A standard iterator cannot return `Int` for one position and `String` for another while conforming to `IteratorProtocol`. Typed traversal uses the parameter pack instead.

---

## Construct a box and inspect its shape

### `init(_:)` and `init(tuple:)`

Pass separate values when constructing a new group. Pass an existing tuple to `init(tuple:)` when values already arrived together or were produced by a generic pack operation. Both initializers preserve the types and order of members.

```swift
let direct = HeterogeneousBox(42, "ready", true)
let values = (42, "ready", true)
let forwarded = HeterogeneousBox(tuple: values)

let number: Int = direct.0
let message: String = forwarded.1
```

The public `value` property exposes the stored tuple for a read, such as `direct.value.1`. Its setter is private. Use the writable typed subscripts to replace members.

### `count` and `isEmpty`

Use `count` to drive runtime indexing and `isEmpty` for an empty box. They count the parameter-pack members, including members whose value is an optional `nil`.

```swift
let empty = HeterogeneousBox()
let optional = HeterogeneousBox(nil as Int?, "ready")

assert(empty.isEmpty)
assert(optional.count == 2)
```

### `array` and the collection indices

Use `array` when an API explicitly requires `[Any]`. It preserves member order but erases the distinct static types. `startIndex` is zero, `endIndex` is `count`, and `index(after:)` advances by one. The integer subscript reads a value at a valid collection index as `Any`.

```swift
let box = HeterogeneousBox(42, "ready")
var index = box.startIndex
while index < box.endIndex {
    let item: Any = box[index]
    print(item)
    index = box.index(after: index)
}

let erased: [Any] = box.array
```

`makeIterator()` creates one `[Any]` snapshot for a standard `for-in` pass. The iterator yields `Any` and does not reflect later writes to the box.

```swift
var mutable = HeterogeneousBox(42, "ready")
var iterator = mutable.makeIterator()
mutable[\.0] = 43
let originalFirst = iterator.next() as? Int // 42
```

---

## Read or change a known member

### Dynamic member lookup, `value(at:)`, and the key-path subscript

`box.0` is a typed read or write through the tuple's writable key path. `value(at:)` accepts a typed key path for a read. `box[\.0]` accepts a writable key path for a read or write. Wrong member types are rejected by the compiler.

```swift
var box = HeterogeneousBox(42, "ready")
let number: Int = box.value(at: \.0)
let status: String = box[\.1]

box.0 = 43
box[\.1] = "running"
```

These APIs are best for a fixed layout whose positions are known to the caller. The one-member case has a code-generation issue in the tested Swift 6.4.2 toolchain for direct `.0` and `.value` access. For that case, use `element(at:as:)` until the compiler issue is resolved.

### `updating(_:_:)`

Use `updating` to transform one member while keeping the original box and the tuple's member types. The closure may throw; the error propagates and no modified box is returned.

```swift
let original = HeterogeneousBox(2, "ready")
let tripled = original.updating(\.0) { $0 * 3 }

assert(original.0 == 2)
assert(tripled.0 == 6)
```

`updating` cannot change that member from `Int` to `String`. Use `mapBox` or build another box for a type-changing transform.

---

## Read a runtime position and handle failure

### `element(at:as:)`

Use `element(at:as:)` when the position comes from configuration, input, or another runtime source. It returns `.success` with the requested type or `.failure(.outOfBounds(index:))` or `.failure(.typeMismatch(index:))`. Negative positions are out of bounds. A stored optional `nil` is still a successful lookup.

```swift
let box = HeterogeneousBox(42, "ready")
switch box.element(at: 1, as: String.self) {
case .success(let status):
    print(status)
case .failure(let error):
    print(error)
}

let optional = HeterogeneousBox(nil as Int?, "ready")
let foundNil = optional.element(at: 0, as: Int?.self)
// foundNil is .success(nil), not .failure
```

### Integer subscript, `getElement(at:)`, `getTypeInferedElement(at:)`, and `[typeInfered:]`

These older runtime-position APIs are useful when an invariant already proves the position and type. They do not return a recoverable lookup error:

| API | Valid lookup | Invalid position or type |
| --- | --- | --- |
| `box[index]` | `Any` | Array bounds trap |
| `getElement(at:)` | `Any` | `fatalError` |
| `getTypeInferedElement(at:)` | Caller-inferred type | `fatalError` or precondition failure |
| `box[typeInfered: index]` | Caller-inferred type | Array bounds trap or precondition failure |

```swift
let box = HeterogeneousBox(42, "ready")
let erased: Any = box.getElement(at: 0)
let number: Int = box.getTypeInferedElement(at: 0)
let status: String = box[typeInfered: 1]
```

The inferred type comes from the destination, not from the runtime index. For untrusted positions, use `element(at:as:)`.

The package also publishes `Array[safe:]`. After explicitly requesting `box.array`, `array[safe: index]` returns `nil` for a negative or out-of-range array index. It still yields an `Any` value at a valid index.

```swift
let items = box.array
let missing: Any? = items[safe: 100] // nil
```

---

## Build and transform boxes

### `appending(values:)`

Append one or more values to create a box with a longer generic type pack. The original box does not change. Pass all new values in one call when they are already available.

```swift
let original = HeterogeneousBox(42)
let extended = original.appending(values: "ready", true)
// extended has Int, String, Bool members
```

For repeated append calls, give each intermediate box its own binding. This helps the tested compiler infer the new pack after every step.

### `appendingTransformed(_:_:)`

Use this when each next member is computed from an input value. The transform runs once and its output type becomes the type of the appended member. A thrown error propagates without changing the source box.

```swift
let source = HeterogeneousBox(12, "ready")
let first = HeterogeneousBox()
    .appendingTransformed(source.value.0) { String($0) }
let result = first.appendingTransformed(source.value.1) { $0.count }
// result has String and Int members
```

### The `+` operator

Use `+` to concatenate two existing boxes. It preserves each side's static member types and order. An empty box acts as the identity. Store intermediate results when combining several boxes to keep type inference manageable.

```swift
let identity = HeterogeneousBox()
let left = HeterogeneousBox(42, "ready")
let right = HeterogeneousBox(true)
let joined = left + right
let unchanged = identity + joined
```

### `mapBox(_:)`

Use `mapBox` when one closure needs the complete source box and should choose every member of a new box. The closure receives `Self` and must return `HeterogeneousBox<repeat each Output>`. Output member types and count are independent of the source layout. A thrown error propagates.

```swift
let source = HeterogeneousBox(12, "ready", true)
let mapped: HeterogeneousBox<String, Int, Bool> = source.mapBox { box in
    HeterogeneousBox("\(box.value.0)", box.value.1.count, !box.value.2)
}
```

Returning a plain `String` from this closure is a compile-time error. The normal collection `map` below instead returns an array.

### `mapTuple(_:_:)`

Use the free `mapTuple` function when the source is already a raw tuple. Its closure receives that tuple with its member types intact and must return a new box. The source parameter is generic because Swift does not allow extensions on tuple types; the function can also accept another source type.

```swift
let tuple = (12, "ready")
let mapped: HeterogeneousBox<String, Int> = mapTuple(tuple) { values in
    HeterogeneousBox("\(values.0)", values.1.count)
}
```

---

## Map selected members and compose functions

The read-only mapping subscripts select members by typed tuple key paths. A one-path closure receives one member; a two-path closure receives values in key-path order. The output can be any type, including another box or a function. Each closure runs once for a subscript read. Neither form writes through to the source box.

```swift
let stage = HeterogeneousBox(42, "/accounts/")
let idText: String = stage[\.0, map: { String($0) }]
let path: String = stage[\.1, \.0, map: { prefix, id in
    "\(prefix)\(id)"
}]

let addPreferences: (String) -> String = { $0 + "/preferences" }
let addRevision: (String) -> String = { $0 + "?revision=1" }
let nextPath = path |> addPreferences >>> addRevision
// "/accounts/42/preferences?revision=1"
```

`>>>` returns a function that calls its left operand, then passes that result to its right operand. `|>` applies a value to a function. Composition has higher precedence than application, so the last expression means `path |> (addPreferences >>> addRevision)`. The operators accept synchronous, nonthrowing functions. They do not enforce absence of side effects, retain actor isolation, or manage asynchronous work. Keep effects and dispatch explicit at the caller.

Use key paths for static member selection. A runtime integer does not carry a member's static type and is outside these subscripts. A variadic key-path mapping subscript was tested locally but crashed the Swift 6.4.2 type checker; the public API includes the validated one- and two-path forms only. On the same toolchain, `box[\.0, map:]` for a one-member box crashes during code generation, like direct `box.0` access. Use checked `element(at:as:)` for a one-member box until that compiler issue is resolved.

---

## Chain typed requests, then dispatch an array in parallel

A request pipeline can have this shape: `Request<Account>`, then `Request<Preferences>` built from the account response, then `[Request<Asset>]` built from the preferences response. The array contains requests with one response type. `mapBox` transforms each completed, typed stage into the next stage; the network calls remain explicit `await` operations outside its synchronous closure.

```swift
struct Request<Response: Decodable & Sendable>: Sendable {
    let path: String
}

protocol NetworkDispatcher: Sendable {
    func send<Response: Decodable & Sendable>(
        _ request: Request<Response>
    ) async throws -> Response
}

struct Account: Codable, Sendable {
    let id: Int
}

struct Preferences: Codable, Sendable {
    let assetIDs: [Int]
    let lastSessionID: Int
}

struct Asset: Codable, Sendable {
    let id: Int
}

func sendParallel<Response: Decodable & Sendable, D: NetworkDispatcher>(
    _ requests: [Request<Response>],
    using dispatcher: D
) async throws -> [Response] {
    try await withThrowingTaskGroup(of: (Int, Response).self) { group in
        for (index, request) in requests.enumerated() {
            group.addTask {
                (index, try await dispatcher.send(request))
            }
        }

        var completed: [(Int, Response)] = []
        for try await pair in group {
            completed.append(pair)
        }
        return completed.sorted { $0.0 < $1.0 }.map { $0.1 }
    }
}

func loadAccount<D: NetworkDispatcher>(
    using dispatcher: D
) async throws -> HeterogeneousBox<Account, Preferences, [Asset]> {
    let first = Request<Account>(path: "/accounts/42")
    let account = try await dispatcher.send(first)

    let second: HeterogeneousBox<Account, Request<Preferences>> =
        HeterogeneousBox(first, account).mapBox { completed in
            let account = completed.value.1
            return HeterogeneousBox(
                account,
                Request<Preferences>(path: "/accounts/\(account.id)/preferences")
            )
        }
    let preferences = try await dispatcher.send(second.value.1)

    let parallel: HeterogeneousBox<Account, Preferences, [Request<Asset>]> =
        HeterogeneousBox(second.value.0, preferences).mapBox { responses in
            let requests = responses.value.1.assetIDs.map {
                Request<Asset>(path: "/assets/\($0)")
            }
            return HeterogeneousBox(responses.value.0, responses.value.1, requests)
        }
    let assets = try await sendParallel(parallel.value.2, using: dispatcher)

    return HeterogeneousBox(parallel.value.0, parallel.value.1, assets)
}
```

The first two requests run in dependency order. If `assetIDs` is `[7, 8]`, the final stage contains `[Request<Asset>(path: "/assets/7"), Request<Asset>(path: "/assets/8")]`; those two requests run concurrently. `sendParallel` attaches each request's input index to its response, then sorts by index because child tasks may finish in any order. A thrown error cancels sibling tasks through the task group; the dispatcher must cooperate with cancellation to stop network work. The returned box retains the distinct response types: `Account`, `Preferences`, and `[Asset]`. Iterating `asyncValues()` here would erase those distinctions to `Any`.

### Compose two different final request types

An array cannot contain `Request<[Asset]>` and `Request<LastSession>` while preserving both generic response types. Use a nested box for the fixed pair. The mapping subscripts below compose request-building functions; only `dispatcher.send` performs network work.

```swift
struct LastSession: Codable, Sendable {
    let id: Int
}

func loadAccountAndSession<D: NetworkDispatcher>(
    using dispatcher: D
) async throws -> HeterogeneousBox<Account, Preferences, HeterogeneousBox<[Asset], LastSession>> {
    let plan = HeterogeneousBox(
        Request<Account>(path: "/accounts/42"),
        Request<Preferences>(path: "/accounts/"),
        HeterogeneousBox(
            Request<[Asset]>(path: "/assets/"),
            Request<LastSession>(path: "/sessions/")
        )
    )

    let toPreferences: (Account) -> Request<Preferences> =
        plan[\.1, map: { template in
            { account in
                Request<Preferences>(path: template.path + "\(account.id)/preferences")
            }
        }]
    let addRevision: (Request<Preferences>) -> Request<Preferences> = { request in
        Request<Preferences>(path: request.path + "?revision=1")
    }
    let toParallel: (Preferences) -> HeterogeneousBox<Request<[Asset]>, Request<LastSession>> =
        plan[\.2, map: { templates in
            { preferences in
                HeterogeneousBox(
                    Request<[Asset]>(
                        path: templates.value.0.path
                            + preferences.assetIDs.map(String.init).joined(separator: ",")
                    ),
                    Request<LastSession>(
                        path: templates.value.1.path + "\(preferences.lastSessionID)"
                    )
                )
            }
        }]

    let account = try await dispatcher.send(plan.value.0)
    let preferencesRequest: Request<Preferences> = account |> toPreferences >>> addRevision
    let preferences = try await dispatcher.send(preferencesRequest)
    let requests = preferences |> toParallel

    async let assets: [Asset] = dispatcher.send(requests.value.0)
    async let lastSession: LastSession = dispatcher.send(requests.value.1)
    return HeterogeneousBox(
        account,
        preferences,
        HeterogeneousBox(try await assets, try await lastSession)
    )
}
```

The first two sends remain sequential because the later request needs the earlier response. The final two sends start concurrently with `async let` and retain different response types. Both await expressions are required before returning the result box. If either send throws, structured concurrency cancels the sibling; the dispatcher still needs to honor cancellation. This is a caller-level network workflow, not a network feature of HeterogeneousBox.

---

## Visit members with typed callbacks

### `forEachTyped(_:)`

Provide one callback for each member. Each callback receives its corresponding member's static type, in tuple order, without passing through `Any`. Use this to invoke a fixed group of handlers with distinct argument types.

```swift
let box = HeterogeneousBox(42, "ready")
box.forEachTyped(
    { (number: Int) in print(number + 1) },
    { (status: String) in print(status.uppercased()) }
)
```

The callback count and input types must match the box's type pack. An empty box accepts no callbacks.

### `tryForEachTyped(_:)`

Use the throwing variant for validation or serialization that may fail. It invokes callbacks in tuple order and stops at the first thrown error. Later callbacks do not run.

```swift
enum ValidationError: Error { case invalidNumber }
let box = HeterogeneousBox(42, "ready")

try box.tryForEachTyped(
    { (number: Int) in
        guard number >= 0 else { throw ValidationError.invalidNumber }
    },
    { (status: String) in print(status) }
)
```

---

## Consume a snapshot as an AsyncSequence

`asyncValues()` returns `HeterogeneousBoxAsyncValues`, a finite `AsyncSequence` over a snapshot made when the method is called. The adapter starts no producer task and owns no `AsyncStream` continuation. Each call to its iterator's `next()` yields one value, so the consumer controls the pace. `makeAsyncIterator()` starts a fresh pass over the same snapshot.

```swift
let box = HeterogeneousBox(42, "ready")
for await item in box.asyncValues() {
    print(item)
}
```

The sequence's `Element` is `Any`, matching the standard collection boundary. It cannot express a different static type at each position. Use `forEachTyped` for typed callbacks. A stored optional `nil` is emitted as a value rather than ending the sequence; only an actual `nil` from `next()` signals the end. If the consuming task is canceled before a call to `next()`, that call returns `nil`. The adapter does not create an independently running task to cancel or await.

```swift
let optional = HeterogeneousBox(nil as Int?, "ready")
var iterator = optional.asyncValues().makeAsyncIterator()
let first = await iterator.next() // Contains the stored optional nil
let second = await iterator.next() // Contains "ready"
let end = await iterator.next() // nil means iteration finished
```

---

## Use type-erased higher order operations

The following collection-style functions visit members in order and pass each value as `Any`. Their closures can throw, and an error propagates. Use them for diagnostics, filtering, or aggregating mixed values when runtime casts are appropriate.

| Function | Use case | Result |
| --- | --- | --- |
| `map(_:)` | Render each member with one common output type | `[T]` |
| `compactMap(_:)` | Extract values for which a cast or conversion succeeds | `[T]` |
| `filter(_:)` | Keep original values matching a predicate | `[Any]` |
| `first(where:)` | Find the first matching runtime value | `Any?` |
| `allSatisfy(_:)` | Validate every member, stopping at the first failure | `Bool` |
| `contains(where:)` | Find any matching member, stopping at the first match | `Bool` |
| `reduce(_:_:)` | Combine all members into one accumulator | Chosen result type |

```swift
let box = HeterogeneousBox(1, "two", 3)
let labels = box.map { String(describing: $0) }
let numbers = box.compactMap { $0 as? Int } // [1, 3]
let numericItems = box.filter { $0 is Int } // [Any]
let firstText = box.first { $0 is String } as? String
let allHaveText = box.allSatisfy { !String(describing: $0).isEmpty }
let hasText = box.contains { $0 is String }
let total = box.reduce(0) { sum, item in sum + (item as? Int ?? 0) }
```

`map` and `compactMap` return homogeneous arrays. `filter` retains the original values as `Any`, not a shorter heterogeneous box. `first(where:)` returns `nil` when there is no match. `allSatisfy` is true for an empty box; `contains(where:)` is false for an empty box.

---

## Inspect values and produce diagnostics

### `filteredByType(_:)` and `nonNilValues`

`filteredByType` extracts all members that can be cast to one requested type. Use it for a runtime report, not for a statically typed position. `nonNilValues` drops members whose optional value is `nil` and returns the rest as `[Any]`.

```swift
let box = HeterogeneousBox(1, "ready", 2, nil as Int?)
let numbers: [Int] = box.filteredByType(Int.self) // [1, 2]
let present: [Any] = box.nonNilValues // three members
```

### `dump()`, `description`, and `debugDescription`

Call `dump()` during debugging to write the underlying tuple to standard output. Use `description` for a concise display string and `debugDescription` when member type names are useful. The two description properties implement `CustomStringConvertible` and `CustomDebugStringConvertible`.

```swift
let box = HeterogeneousBox(42, "ready")
print(box.description)
print(box.debugDescription)
box.dump()
```

Do not use these human-readable strings as a serialization format or a stable cache key.

---

## Compare values and use boxes as keys

`==` compares corresponding members in order when every member type conforms to `Equatable`. The two boxes must have the same generic layout. `hash(into:)` combines member hashes in the same order when every member type conforms to `Hashable`; use boxes as `Set` members or dictionary keys under that condition.

`contains(where: value)` is a separate value-search helper available on an equatable box. It checks whether any member can be cast to the search value's type and equals that value. Its `where:` argument is a value, while the collection `contains(where:)` above takes a predicate closure.

```swift
let first = HeterogeneousBox(42, "ready")
let second = HeterogeneousBox(42, "ready")
let equal = first == second
let containsReady = first.contains(where: "ready")
let unique = Set([first, second]) // one member
```

---

## Match boxes and other values in a switch

### `HeterogeneousBoxPattern`, `matches(_:)`, and `~=`

Initialize a box pattern with one predicate for each member's static type. `matches(_:)` returns true only if every predicate succeeds, stopping at the first failure. Its `~=` overload lets the same pattern appear as a `switch` case.

```swift
let ready = HeterogeneousBoxPattern<Int, String>(
    { $0 > 0 },
    { $0.hasPrefix("ready") }
)
let box = HeterogeneousBox(42, "ready-now")
let directMatch = ready.matches(box)

switch box {
case ready: print("ready")
default: print("other")
}
```

### `PredicatePattern<Value>`, `matches(_:)`, and `~=`

Initialize a generic predicate pattern for a whole value. It needs no `Equatable` conformance and no primitive-specific overloads. `matches(_:)` calls its predicate; the generic `~=` overload supports `switch` for `Int`, `String`, a custom model, or a complete box.

```swift
struct Message { let id: Int }
let selected = PredicatePattern<Message> { $0.id == 7 }
let directMatch = selected.matches(Message(id: 7))

switch Message(id: 7) {
case selected: print("selected")
default: print("other")
}
```

These pattern types store ordinary closures. Keep a pattern within its intended isolation context; the patterns themselves do not declare `Sendable` conformance.

---

## Accumulate assignments with property wrappers

### `@AccumulatingValue`

Use `@AccumulatingValue` for a homogeneous history such as counters, status values, or optional values. Its `init(wrappedValue:capacity:)` records the initial value. Every later assignment to `wrappedValue` appends one entry. The projected value, accessed with `$`, is a `[Value]` snapshot of the history.

```swift
struct Progress {
    @AccumulatingValue var count = 1
    @AccumulatingValue var note: String? = nil
}

var progress = Progress()
progress.count = 2
progress.note = nil
progress.note = "ready"

let counts: [Int] = progress.$count // [1, 2]
let notes: [String?] = progress.$note // [nil, nil, "ready"]
```

Set a positive capacity to keep only the newest entries, including the current value. The initial value counts toward capacity. With `capacity: 1`, the history always contains just the current value.

```swift
struct RecentProgress {
    @AccumulatingValue(capacity: 2) var count = 1
}

var recent = RecentProgress()
recent.count = 2
recent.count = 3
let counts = recent.$count // [2, 3]
```

### `@AccumulatingBox`

Use `@AccumulatingBox` when each assignment replaces a complete box with the same generic member layout. Its `init(wrappedValue:capacity:)` records the initial box, `wrappedValue` exposes the current box, and `projectedValue` returns `[HeterogeneousBox<repeat each Value>]`. A write to a member of the wrapped box also writes back through the property wrapper and records another snapshot.

```swift
struct State {
    @AccumulatingBox var box = HeterogeneousBox(1, "ready")
}

var state = State()
state.box = HeterogeneousBox(2, "running")
state.box[\.0] = 3

let current: Int = state.box.0 // 3
let first: Int = state.$box[0].0 // 1
let last: String = state.$box[2].1 // "running"
```

The box layout stays `HeterogeneousBox<Int, String>` for every entry. A property wrapper cannot make its `wrappedValue` gain another generic member type on assignment. Use `appending(values:)`, `appendingTransformed`, `mapBox`, or `mapTuple` to construct a new type-changing box in an ordinary binding.

The same capacity rule applies to whole box snapshots:

```swift
struct RecentState {
    @AccumulatingBox(capacity: 2) var box = HeterogeneousBox(1, "ready")
}

var recentState = RecentState()
recentState.box = HeterogeneousBox(2, "running")
recentState.box[\.0] = 3
let retained: [HeterogeneousBox<Int, String>] = recentState.$box
// retained contains (2, "running") and (3, "running")
```

Both wrappers use value semantics and return a history snapshot through `projectedValue`. Omit `capacity` to retain every assignment until the wrapper is released; `capacity: 0` is invalid and triggers a precondition failure. With a capacity, appending still copies or shifts up to the retained history length, so choose a reasonable limit for frequently written state. Snapshots of boxes containing reference objects do not deep-copy those objects. The wrappers provide no internal synchronization; put a mutable wrapper under an actor or another owner isolation boundary. Each wrapper conditionally conforms to `Sendable` when the stored value types do.

---

## Cross an actor boundary

`HeterogeneousBox` conditionally conforms to `Sendable` when every stored member type is `Sendable`. This is useful for a fixed bundle of data or `@Sendable` handlers sent to an actor. A box containing a non-Sendable reference does not gain this conformance.

```swift
actor Receiver {
    func summarize(_ box: HeterogeneousBox<Int, String>) -> String {
        "\(box.value.0):\(box.value.1)"
    }
}

let reply = await Receiver().summarize(HeterogeneousBox(42, "ready"))
```

Passing a box to an actor does not give collection iteration typed elements, and it does not manage the lifetime of any task or stream stored inside a box.
