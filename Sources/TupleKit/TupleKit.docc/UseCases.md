# Use cases for Tuple

Use `Tuple` to keep a fixed group of members whose static types differ. Each member keeps its own type, so the compiler checks every read, write, and transform.

`Tuple` is a product value, not a collection. Its shape, the ordered list of member types, is part of its type: `Tuple<Int, String>` and `Tuple<String, Int>` are different types. The examples assume `import TupleKit`. A tuple owns its members. Methods that return a tuple leave the original unchanged unless a mutable subscript writes through it.

---

## Choose an API

| Need | API | Result |
| --- | --- | --- |
| Read or replace a known member | `tuple.0`, `tuple[\.0]` | The member's static type |
| Change one member in a copy | `updating(_:_:)` | A tuple with the same shape |
| Change a member inside a nested tuple | `tuple[\.2][\.1]`, nested `updating(_:_:)` | The nested member's static type |
| Transform every member | `mapEach(_:)` | A tuple whose types the transforms choose |
| Transform every member concurrently | `concurrentMapEach(_:_:)` | A tuple in position order |
| Map one or two selected members | `tuple[\.0, map:]`, `tuple[\.0, \.1, map:]` | The closure's result type |
| Visit every member | `forEachTyped(_:)`, `tryForEachTyped(_:)` | One typed callback per member |
| Add members | `appending(_:)`, `appendingTransformed(_:_:)`, `+` | A tuple with a longer shape |
| Combine async sequences | `zipToTuples(_:)` | An `AsyncSequence` of tuples |
| Require every optional member | `unwrapped(_:)` | The unwrapped members, or `nil` |
| Require every result to succeed | `collected(_:)` | A `Result` of the successful values |
| Wait for running tasks | `values(of:)` | The task values in position order |
| Pair two tuples by position | `zip(_:_:)` | A tuple of built-in pairs |
| Read a position known only at runtime | `member(at:as:)` | A checked `Result` |
| Inspect members without their types | `erasedMembers` | `[Any]` |
| Match a tuple in a `switch` | `TuplePattern` | A predicate per member |
| List every combination of enum members | `allCases` | The cartesian product, in position order |
| Store enum members as their raw values | `rawValues`, `init(rawValues:)` | A tuple of raw values, or `nil` |
| Add or subtract member by member | `adding(_:)`, `subtracting(_:)`, `zero` | A tuple of the same type |
| Pass a tuple where `AdditiveArithmetic` is required | `elementwise`, `ElementwiseTuple` | A view whose `+` adds member by member |

---

## Create a tuple

Pass the members to the initializer, or wrap a built-in tuple with `init(members:)`. The `members` property returns the built-in tuple.

```swift
let session = Tuple(42, "ready", true)
let fromBuiltIn = Tuple(members: (42, "ready", true))
let builtIn: (Int, String, Bool) = session.members

print(session)                  // Tuple(42, "ready", true)
print(session.debugDescription) // Tuple<Int, String, Bool> { 42 (Int), "ready" (String), true (Bool) }
print(session.count)            // 3
print(session == fromBuiltIn, builtIn.0)
```

`count` is the number of members, and `isEmpty` is `true` only for `Tuple()`.

---

## Read or change a known member

`tuple.0` reads or writes a member through dynamic member lookup. `tuple[\.0]` does the same through a key path into the built-in tuple. The compiler rejects a wrong member type.

```swift
var tuple = Tuple(42, "ready")
let number: Int = tuple[\.0]
tuple.0 = number + 1
tuple[\.1] = "running"
print(tuple) // Tuple(43, "running")
```

### Change one member in a copy

`updating(_:_:)` returns a copy with one member transformed. The member keeps its type. A thrown error propagates, and no copy is returned.

```swift
let original = Tuple(2, "ready")
let tripled = original.updating(\.0) { $0 * 3 }
print(original, tripled) // Tuple(2, "ready") Tuple(6, "ready")
```

### Change a member inside a nested tuple

Chain key-path subscripts to reach a member of a tuple stored inside another tuple. Nest `updating` calls to change it in a copy.

```swift
var plan = Tuple(1, "plan", Tuple(true, 0.5))
plan[\.2][\.1] = 2.0

let doubled = plan.updating(\.2) { inner in inner.updating(\.1) { $0 * 2 } }
print(doubled[\.2][\.1], plan[\.2][\.1]) // 4.0 2.0
```

To reuse a focus, store a key path rooted at the built-in tuple, such as `\(Bool, Double).1`. Any key path rooted at `Tuple`, stored or passed to `map`, crashes the Swift 6.4.2 compiler. The known compiler limits section at the end of this article lists each workaround.

---

## Read a position known only at runtime

`member(at:as:)` returns `.success` with the requested type, `.failure(.outOfBounds(position:))`, or `.failure(.typeMismatch(position:))`. A stored optional `nil` is a successful lookup.

```swift
let tuple = Tuple(42, "ready", nil as Int?)

print(tuple.member(at: 1, as: String.self)) // success("ready")
print(tuple.member(at: 1, as: Int.self))    // failure(...TupleAccessError.typeMismatch(position: 1))
print(tuple.member(at: 9, as: Int.self))    // failure(...TupleAccessError.outOfBounds(position: 9))
print(tuple.member(at: 2, as: Int?.self))   // success(nil)
```

`erasedMembers` copies the members into `[Any]` in position order. Use it for diagnostics or runtime iteration. The loss of static types is visible at the call site.

```swift
let tuple = Tuple(1, "two", 3)
let numbers = tuple.erasedMembers.compactMap { $0 as? Int }
print(numbers) // [1, 3]
```

---

## Add members

`appending(_:)` adds one member. `appendingTransformed(_:_:)` transforms an input and appends the result. `+` joins two tuples. Each keeps every member's static type.

```swift
let base = Tuple(42, "ready")
let flagged: Tuple<Int, String, Bool> = base.appending(true)
let counted: Tuple<Int, String, Int> = base.appendingTransformed("ready") { $0.count }
let joined: Tuple<Int, String, Bool, Double> = base + Tuple(true, 2.5)
print(flagged, counted, joined)
```

The right operand of `+` can have up to six members. Write a chain of four or more `+` operands as separate steps, because one expression of that length fails to type-check on Swift 6.4.2.

```swift
let firstHalf = Tuple(1) + Tuple("a")
let secondHalf = Tuple(true) + Tuple(2.5)
let all: Tuple<Int, String, Bool, Double> = firstHalf + secondHalf
print(all)
```

---

## Transform members

### `mapEach(_:)`

Provide one transform per member. Each transform receives its member's static type and chooses the static type of the matching output member. Transforms run in position order. They share one typed error, and the first thrown error stops iteration.

```swift
let tuple = Tuple(42, "ready")
let mapped: Tuple<Double, Int> = tuple.mapEach(
    { number in Double(number) / 2 },
    { status in status.count }
)
print(mapped) // Tuple(21.0, 5)
```

### Map one or two selected members

The mapping subscripts select members by key path and pass them to a closure. The result can have any type, including another tuple or a function. The tuple is unchanged.

```swift
let stage = Tuple(42, "/accounts/")
let idText: String = stage[\.0, map: { String($0) }]
let path: String = stage[\.1, \.0, map: { prefix, id in "\(prefix)\(id)" }]
print(idText, path) // 42 /accounts/42
```

---

## Visit members

`forEachTyped(_:)` calls one callback per member with that member's static type, in position order. `tryForEachTyped(_:)` stops at the first thrown error.

```swift
let tuple = Tuple(42, "ready")
tuple.forEachTyped(
    { (number: Int) in print(number + 1) },
    { (status: String) in print(status.uppercased()) }
)
```

---

## Work asynchronously

### Await each transform in order

The async `mapEach` overload awaits one transform at a time, in position order, on the caller's actor. Members do not need to be `Sendable`.

```swift
let tuple = Tuple(42, "ready")
let mapped: Tuple<Double, Int> = await tuple.mapEach(
    { number in
        await Task.yield()
        return Double(number) / 2
    },
    { status in status.count }
)
print(mapped)
```

### Run transforms concurrently

`concurrentMapEach(_:_:)` runs one transform per member in child tasks and returns the results in position order, whatever order the tasks finish in. Members, transforms, and results must be `Sendable`. When a transform throws, the other tasks are cancelled and the error is rethrown after they finish. Cancelling the caller cancels every task. No task outlives the call.

```swift
let requests = Tuple(Request<[Asset]>(path: "/assets"), Request<LastSession>(path: "/sessions/3"))
let responses: Tuple<[Asset], LastSession> = try await concurrentMapEach(
    requests,
    { try await dispatcher.send($0) },
    { try await dispatcher.send($0) }
)
print(responses)
```

`concurrentMapEach` is a free function. As a method, `@dynamicMemberLookup` on `Tuple` would prevent client modules from inferring `@Sendable` for its closure literals on Swift 6.4.2.

### Chain dependent requests

This example builds each request from the previous response. The tuple carries the typed templates and results. The dispatcher owns network work, errors, and cancellation.

<!-- snippet: standalone -->
```swift
import TupleKit

struct Request<Response: Decodable & Sendable>: Sendable {
    let path: String
}

protocol NetworkDispatcher: Sendable {
    func send<Response: Decodable & Sendable>(_ request: Request<Response>) async throws -> Response
}

struct Account: Codable, Sendable { let id: Int }
struct Preferences: Codable, Sendable { let assetIDs: [Int]; let lastSessionID: Int }
struct Asset: Codable, Sendable { let id: Int }
struct LastSession: Codable, Sendable { let id: Int }

func loadAccount<D: NetworkDispatcher>(
    using dispatcher: D
) async throws -> Tuple<Account, Preferences, Tuple<[Asset], LastSession>> {
    let templates = Tuple(
        Request<Account>(path: "/accounts/42"),
        Request<Preferences>(path: "/accounts/"),
        Tuple(Request<[Asset]>(path: "/assets/"), Request<LastSession>(path: "/sessions/"))
    )

    let account = try await dispatcher.send(templates[\.0])
    let preferencesRequest = templates[\.1, map: { template in
        Request<Preferences>(path: template.path + "\(account.id)/preferences")
    }]
    let preferences = try await dispatcher.send(preferencesRequest)

    let finalRequests = templates[\.2].mapEach(
        { template in
            Request<[Asset]>(path: template.path + preferences.assetIDs.map(String.init).joined(separator: ","))
        },
        { template in Request<LastSession>(path: template.path + "\(preferences.lastSessionID)") }
    )
    let responses = try await concurrentMapEach(
        finalRequests,
        { try await dispatcher.send($0) },
        { try await dispatcher.send($0) }
    )
    return Tuple(account, preferences, responses)
}
```

The first two sends run in order because each request needs the previous response. The last two run concurrently and keep their different response types.

---

## Combine async sequences into tuples

`zipToTuples(_:)` combines async sequences into one sequence whose elements are complete tuples. Each element holds the next value from every base.

```swift
let (ids, idInput) = AsyncStream.makeStream(of: Int.self)
let (names, nameInput) = AsyncStream.makeStream(of: String.self)
idInput.yield(1)
nameInput.yield("first")
idInput.finish()
nameInput.finish()

let sessions = zipToTuples(ids, names)
for try await session in sessions {
    print(session[\.0] + 1, session[\.1].uppercased())
}
```

Each call to the iterator's `next()` requests one element from each base, in position order, on the consuming task. The sequence starts no task and adds no buffer, so the bases control buffering and backpressure. Iteration ends when any base ends or throws. A thrown error is rethrown once, and later calls return `nil`. The sequence is `Sendable` when every base is.

Bind the sequence to a constant before the loop. Writing `zipToTuples(...)` directly after `in` crashes the Swift 6.4.2 compiler.

---

## Combine members that wrap values

These functions turn a tuple of wrappers into one wrapper around a tuple. They keep each member's static type.

`unwrapped(_:)` returns the members when every optional has a value, and `nil` when any member is `nil`. It works like `if let` over several values.

```swift
let form = Tuple(Int("42"), "Ada" as String?)
if let user = unwrapped(form) {
    print(user[\.0] + 1, user[\.1].uppercased())
}
```

Pass a tuple held in a constant. On Swift 6.4.2, writing `Tuple(...)` inline as the argument fails to type-check.

`collected(_:)` returns the successful values when every result succeeds, and the first failure in position order otherwise.

```swift
let lookups = Tuple(
    Result<Int, CancellationError>.success(7),
    Result<String, CancellationError>.success("ready")
)
let found = try collected(lookups).get()
print(found[\.0], found[\.1])
```

`values(of:)` waits for tasks that are already running and returns their values in position order. The tasks run concurrently, and the function waits on each one in turn. A throwing overload accepts tasks whose failure type is `any Error` and rethrows the first failure in position order. Neither overload cancels the tasks.

```swift
let downloads = Tuple(Task { 7 }, Task { "ready" })
let results = await values(of: downloads)
print(results[\.0], results[\.1])
```

`zip(_:_:)` pairs the members of two tuples of the same length by position. Tuples of different lengths do not compile. A one-member result follows the one-member rule: its single member is the pair itself, so read it through `\.self` or `.members`.

```swift
let names = Tuple("count", "label")
let current = Tuple(3, "ready")
let fields = zip(names, current)
print(fields[\.0].0, fields[\.0].1)
```

---

## Compare, hash, and encode

A tuple conforms to `Equatable`, `Hashable`, `Comparable`, `Encodable`, `Decodable`, and `Sendable` when every member does. `Comparable` orders tuples by their first differing position, as Swift orders built-in tuples. `Codable` uses an unkeyed container in position order.

```swift
let sorted = [Tuple(2, "a"), Tuple(1, "b"), Tuple(1, "a")].sorted()
print(sorted) // [Tuple(1, "a"), Tuple(1, "b"), Tuple(2, "a")]

let data = try JSONEncoder().encode(Tuple(42, "ready", nil as Double?))
print(String(decoding: data, as: UTF8.self)) // [42,"ready",null]
let decoded = try JSONDecoder().decode(Tuple<Int, String, Double?>.self, from: data)
print(decoded) // Tuple(42, "ready", nil)
```

Decoding fails when the input holds fewer values than the tuple has members, more values, or a value of the wrong type.

A tuple is also `BitwiseCopyable` when every member is, and it writes itself into any `TextOutputStream` without building `description` first.

---

## Enumerate, convert, and add members

When every member is `CaseIterable`, `allCases` is the cartesian product of the member cases, with the last member varying fastest. When every member is `RawRepresentable`, `rawValues` and `init(rawValues:)` convert to and from a tuple of raw values. When every member is `AdditiveArithmetic`, `adding(_:)`, `subtracting(_:)`, and `zero` work member by member.

```swift
enum Size: String, CaseIterable { case small, large }
enum Tone: String, CaseIterable { case light, dark }

let variants = Tuple<Size, Tone>.allCases
print(variants.count) // 4

let raw = Tuple(Size.large, Tone.dark).rawValues
print(raw) // Tuple("large", "dark")
let lifted = Tuple<Size, Tone>(rawValues: Tuple("small", "medium"))
print(lifted as Any) // nil

let moved = Tuple(1, 2.5).adding(Tuple(2, 0.5))
print(moved) // Tuple(3, 3.0)
```

The arithmetic is deliberately not an `AdditiveArithmetic` conformance on `Tuple`. The protocol's `+` would win over concatenation for an uncontextualized `Tuple(1, 2.0) + Tuple(1, 2.0)`, so one expression would mean two things. When a generic algorithm needs an `AdditiveArithmetic` type, use the `elementwise` view, whose `+` and `-` only ever work member by member, and read the tuple back with `tuple`.

```swift
let steps = [Tuple(1, 0.5), Tuple(2, 0.25), Tuple(3, 0.25)]
let total = steps.map(ElementwiseTuple.init).reduce(.zero, +).tuple
print(total) // Tuple(6, 1.0)
```

Pass `ElementwiseTuple.init` or a closure to `map`, not `\.elementwise`. On Swift 6.4.2 every key path rooted at `Tuple` crashes the compiler. See <doc:UseCases#Known-compiler-limits>.

---

## Match a tuple in a switch

`TuplePattern` holds one predicate per member. It matches when every predicate returns `true`. It checks positions in order and stops at the first failure.

```swift
let ready = TuplePattern<Int, String>({ $0 > 0 }, { $0.hasPrefix("ready") })

switch Tuple(1, "ready-now") {
case ready: print("ready")
default: print("other")
}
```

---

## Cross an actor boundary

A tuple is `Sendable` when every member is. The compiler rejects sending a tuple with a non-`Sendable` member to another actor.

```swift
actor Receiver {
    func receive(_ tuple: Tuple<Int, String>) -> String { "\(tuple.0):\(tuple.1)" }
}

let reply = await Receiver().receive(Tuple(42, "ready"))
print(reply)
```

---

## One-member and empty tuples

A one-member built-in tuple is the member itself, so `Tuple(5).members` is an `Int`. Address the member through `\.self`. `tuple.0` on a one-member tuple crashes the Swift 6.4.2 compiler.

```swift
var single = Tuple(5)
single[\.self] += 1
let doubled = single.updating(\.self) { $0 * 2 }
print(single.members, doubled) // 6 Tuple(12)
```

`Tuple()` supports every operation that takes no transforms. A `mapEach()` call with no transforms cannot infer its error type.

---

## Use the composition helpers

The `TupleKitComposition` product holds helpers that are not specific to tuples. Importing `TupleKit` alone brings in none of them, so its global operators cannot collide with another library's operators.

- `|>` applies a value to a function, and `>>>` composes two functions left to right.
- `PredicatePattern` matches any value with a predicate in a `switch`.
- `@AccumulatingValue` records every assigned value, with an optional capacity.

<!-- snippet: standalone -->
```swift
import TupleKit
import TupleKitComposition

struct History {
    @AccumulatingValue(capacity: 2) var state = Tuple(1, "ready")
}

func compose() {
    let addPreferences: (String) -> String = { $0 + "/preferences" }
    let addRevision: (String) -> String = { $0 + "?revision=1" }
    let path = "/accounts/42" |> addPreferences >>> addRevision

    var history = History()
    history.state = Tuple(2, "running")
    print(path, history.$state)
}
```

---

## Known compiler limits

Swift 6.4.2 has these bugs. `Scripts/check-compiler-contracts.sh` keeps a fixture for each one and fails when a toolchain fixes it.

| Code | Result | Workaround |
| --- | --- | --- |
| `tuple.0` on a one-member tuple | Compiler crash | `tuple[\.self]` or `tuple.members` |
| Any key path rooted at `Tuple`, such as `\.1`, `\.count`, or `map(\.elementwise)` | Compiler crash | Pass a function instead, such as `map(ElementwiseTuple.init)` or `map { $0.count }`, or store a key path rooted at the built-in tuple |
| `for try await x in zipToTuples(...)` | Compiler crash | Bind the sequence to a constant first |
| Four or more `+` operands in one expression | Type-check failure | Concatenate in steps |
| A result type that joins two parameter packs | Never unifies with a concrete type | `+` is overloaded by right-hand arity instead |
| `unwrapped(Tuple(...))` with an inline argument | Type-check failure | Bind the tuple to a constant first |
| Reading a member of an `appending`, `appendingTransformed`, or `+` result in the same expression, such as `tuple.appending(true).count` | Type-check failure | Bind the result to a constant first, then read the member |
| A conditional `RawRepresentable` conformance on `Tuple` | Nested literals such as `Tuple(1, Tuple(2, "a"))` fail to type-check | `rawValues` and `init(rawValues:)` are named members instead |
