# HeterogeneousBox feature roadmap brainstorm

Status: Four roadmap directions confirmed; concrete API contracts remain a working draft
Date: 2026-11-11
Target release: 6.0.0, planned by the user
Language mode: Swift 6, confirmed by the user and enabled in the local manifest
Research mode: Local package and conversation context only. No external product or Swift toolchain claims are used for prioritization.

---

## Goal and boundary

Explore what should come after the current typed box foundation. The user chose to keep HeterogeneousBox focused on typed building blocks. Command responders, event buses, delegate sessions, and CQRS composition are consumer or companion-library concerns unless a repeated, generic need demonstrates a box-level primitive.

This is an organization of ideas the user has already raised, not a release commitment. Priority is provisional until a concrete app workflow is chosen.

---

## User idea inventory

| ID | Idea expressed in this conversation | Current state |
| --- | --- | --- |
| U-01 | Keep a type-preserving tuple and add members one transformation at a time. | Box construction and `appendingTransformed` exist. |
| U-02 | Map a whole tuple or box into a new box whose closure chooses the output types. | `mapBox` and `mapTuple` exist. |
| U-03 | Add operators, switch patterns, higher order functions, dynamic member lookup, and writable tuple key paths. | Implemented in the current local package, with `Any` retained at the collection boundary. |
| U-04 | Expose an async sequence while preserving useful static types. | `asyncValues()` exists, but its element is `Any`; the user asked whether typed traversal can change that. |
| U-05 | Accumulate whole typed boxes and homogeneous values in property wrappers. | Both wrappers exist with optional bounded history. |
| U-06 | Map one typed network response into the next request, then dispatch an array of requests in parallel. | A strict Swift 6 checked example is in the DocC use case guide; no networking API has been added to the box. |
| U-07 | Make CQRS, delegate wrappers, a command responder, and a message bus easy to build. | Stated as an ecosystem goal. The user selected a typed foundation only for this package. |
| U-08 | Use Combine-like ergonomics without a Combine dependency in AsyncSequenceSubscription. | Separate package direction, relevant to integration rather than HeterogeneousBox core. |
| U-09 | Explore macros, more property wrappers, a better DSL, and improved developer experience. | The user confirmed all four roadmap directions. Concrete macro syntax and additional wrapper behavior remain unspecified. |
| U-10 | Improve subscript interactions. | The user named this as the first concrete developer-experience focus. The desired expression and behavior are still pending. |
| U-11 | Select typed request templates through a subscript and use closures to map a response into the next request or request group. | The user supplied an account-to-preferences-to-parallel-requests sketch, clarified that the arrow is function composition only, and requested implementation with operators. One- and two-key-path mapping subscripts plus `>>>` and `|>` are implemented locally. |
| U-12 | Use a property wrapper that owns a message-bus subscription and updates its current value whenever a message arrives. | A generic AsyncSequence-backed wrapper supports MainActor UI observation and synchronized cross-actor reads. The new typed bus exposes a coalesced state stream, and their integration is tested. |

---

## Confirmed roadmap directions

The user's "yes to all" confirms scope across four areas:

1. Add another useful property-wrapper behavior beyond bounded accumulation.
2. Explore a macro or DSL improvement beyond the implemented mapping subscripts.
3. Support both typed asynchronous work on individual members and streams whose elements are complete typed boxes.
4. Coordinate HeterogeneousBox with AsyncSequenceSubscription and consumer examples.

This confirmation selects the areas, not the exact public API signatures. The request pipeline is the concrete caller example for evaluating syntax. The user later specified that the wrapper owns a message-bus subscription and updates its value on receipt. Subscription lifetime, cancellation, and errors belong in AsyncSequenceSubscription or another companion package rather than a passive box. A write-through focused projection remains a separate assistant-inferred lens candidate, not the user-confirmed wrapper behavior. For the macro track, a before-and-after caller example must identify code that the current key-path subscripts, `mapBox`, and composition operators cannot express clearly.

---

## Verified foundation

The [README](../../../README.md) and [DocC use case guide](../../../Sources/HeterogeneousBox/HeterogeneousBox.docc/UseCases.md) show typed tuple access, whole-box and tuple mapping, incremental append, switch patterns, conditional `Sendable`, checked runtime access, an `Any`-valued async snapshot, and accumulating wrappers.

The [package manifest](../../../Package.swift) uses Swift tools 6.0 and Swift 6 language mode. The public collection element is `Any`, because a Swift `Collection` or `AsyncSequence` has one fixed element type. Typed pack traversal works through a separate callback for each member. The guide documents a local Swift 6.4.2 code-generation issue for direct access to one-member boxes; this is a validation constraint, not a reason to promise a workaround API yet.

---

## Observed developer friction

These are source observations for evaluating the user's DSL and macro ideas, not proposed features:

| Friction | Local evidence | What to learn from the user |
| --- | --- | --- |
| Type-changing stages sometimes need explicit output and closure types. | [Typed mapping tests](../../../Tests/HeterogeneousBoxTests/TypedMapTests.swift) annotate the resulting box and, for an arity change, the closure parameter and result. | Which annotation feels repetitive in a real caller? |
| Typed traversal requires one callback per member. | [Typed traversal tests](../../../Tests/HeterogeneousBoxTests/OperatorsAndHigherOrderTests.swift) provide callbacks corresponding to every tuple member. | Is the intended DSL for construction, transformation, traversal, or all three? |
| Runtime access can still trap. | [HeterogeneousBox.swift](../../../Sources/HeterogeneousBox/HeterogeneousBox.swift) has legacy integer and inferred-type accessors that call `fatalError` or `preconditionFailure`. | Should the next release prefer a checked syntax when a position is known only at runtime? |
| Async member iteration erases types. | [HeterogeneousBoxAsyncValues.swift](../../../Sources/HeterogeneousBox/HeterogeneousBoxAsyncValues.swift) defines `Element = Any`. | Does the caller need one typed member at a time, or a stream of entire typed boxes? |
| Subscripts currently have different safety and type contracts. | [HeterogeneousBox.swift](../../../Sources/HeterogeneousBox/HeterogeneousBox.swift) has integer, inferred-type, and dynamic-member subscripts; [typed access](../../../Sources/HeterogeneousBox/Extension/HeterogeneousBox+TypedAccess.swift) adds a writable tuple-key-path subscript. | Which expression should be more natural, and what should it return or change? |

A local strict Swift 6 type-check probe confirms that a read-only subscript can take a typed tuple key path and a mapping closure, then infer the closure's output type. The probe used the illustrative expression `box[\.0, map: { account in Request<String>(path: "/accounts/\(account.id)/preferences") }]`. A second probe with two typed key paths and a two-argument closure also compiled. One variadic key-path probe aborted the Swift 6.4.2 compiler during type checking, so the general pack form has no positive evidence yet. A later code-generation probe found that using `box[\.0, map:]` on a one-member box also crashes this toolchain, matching the earlier one-member dynamic-member issue. The validated two-member and request-pipeline uses remain available. A runtime `Int` index alone cannot prove the selected member's static type; an API using it would need a checked runtime type contract.

---

## Concrete request-composition sketch

The user's sketch starts from `Request<Account>`, uses the account response to fill a `Request<Preferences>` template, then uses the preferences response to fill requests for assets and a last session. The user clarified that these mapping arrows should be pure function composition; a network dispatcher performs sends separately.

The final two requests have different response types. A Swift array of `Request<[Asset]>` and `Request<LastSession>` cannot preserve both generic types as ordinary array elements. For this fixed pair, the type-preserving shape to evaluate is a nested box:

```swift
HeterogeneousBox<
    Request<Account>,
    Request<Preferences>,
    HeterogeneousBox<Request<[Asset]>, Request<LastSession>>
>
```

This shape is used in the [DocC request-composition example](../../../Sources/HeterogeneousBox/HeterogeneousBox.docc/UseCases.md). The first mapping consumes an `Account` response and the preferences request template. The second consumes a `Preferences` response and both final request templates. The dispatcher remains outside the mapping operation, so task lifetime, errors, and cancellation remain its responsibility. The new mapping subscript returns whatever type its closure produces, so it can return one request or a new box.

---

## Received-message wrapper contract

**Confirmed by the user:** the wrapper owns the subscription, and each received message updates the wrapped value. The local AsyncSequenceSubscription package also exposes `sink` and `sinkDetached` returning a raw `Task<Void, Never>`; upstream errors are passed to a completion closure. A separate `@ReceivedMessage` and `MessageSubscription` implementation provides synchronized snapshots and a typed terminal outcome. The local `/Users/bruno/Developer/AsyncMessaging` path was inaccessible during the earlier audit; the bus now implemented in AsyncSequenceSubscription has its own verified contract.

**Implemented contract:** `$message.start(sequence)` identifies the source explicitly and rejects a second active source. Call `cancelAndWait()` before replacing it. `waitForCompletion()` distinguishes normal finish, cancellation, and upstream failure. Releasing the owner signals cancellation, including when another actor retains the projection, and a retained projection rejects new starts. The source must cooperate with cancellation; its own buffering policy determines upstream delivery.

The user wants both access modes. `@ReceivedMessage` is an observable MainActor wrapper, and its `$` projection is the one subscription owner with a synchronized `latest` snapshot. The source is consumed once, and each MainActor update is awaited. A reference-valued message still needs a `Sendable` contract; synchronization of the slot does not make the referenced object internally safe. The new `AsyncMessageBus` product provides `coalescedMessages()` as a size-one state adapter, and a cross-product test connects it to `@ReceivedMessage`. A real app bus consumer remains to be validated.

The [SwiftAdditions AppPlugins example](https://github.com/AdevintaSpain/SwiftAdditions/blob/main/SwiftAdditions/Classes/Startup/AppPlugins.swift) suggested a startup gate that buffers delegate events until readiness. The Combine-free `StartupEventGate` now lives in the separate `AsyncMessageBus` product. It forwards synchronously, has a bounded FIFO queue, rejects overflow, and returns undelivered events on close. `MessageBus` separately handles typed async events with awaited handlers, bounded pending messages, aggregated failures, and explicit subscription ownership. No SwiftAdditions dependency was added.

---

## Candidate roadmap order

| Horizon | User need being developed | Decision to make before adding public API | Evidence gate |
| --- | --- | --- | --- |
| Typed mapping subscript | U-10 and U-11: select members and map them to the next typed pipeline stage | Implemented locally for one or two typed tuple key paths, with `>>>` and `|>` for synchronous function composition and application. The closure chooses whether the output is a request or a box. | Public-client compilation, tests for call order and source immutability, DocC, and release build. |
| Lens and wrapper | U-09 and U-12: reusable typed focus plus subscription-owning received-message views | `@ReceivedMessage` and `MessageSubscription` are implemented in AsyncSequenceSubscription with explicit activation, replacement after completion, typed terminal results, owner-release cancellation, and two access modes. Reusable typed focus remains open. Keep box focus separate from task ownership. | The subscription target passed 56 tests. The new bus target passed 14 tests, including the coalesced stream to wrapper integration. A real app consumer remains to be tested. |
| DSL and macro | U-09: clearer composition syntax beyond mapping subscripts | Use the request pipeline to compare current Swift syntax with a proposed expansion. Select a macro only if it removes repeated code without hiding types or dispatch effects. | Public-client expansion, diagnostics, completion, Swift version support, and no hidden task ownership. |
| Typed async member work | U-04: process each member while preserving its static type | Use separate typed callbacks or another pack-based operation. A single `AsyncSequence` cannot change its static `Element` type by position. | Suspension, cancellation, error, ordering, and actor-isolation tests against a real consumer. |
| Whole-box async snapshots | U-04: consume repeated complete boxes | Preserve `HeterogeneousBox<repeat each Value>` as the stream's one `Element` type; decide whether the adapter belongs in a consumer or companion package. | Snapshot identity, producer ownership, cancellation, backpressure, and terminal-error tests. |
| Request pipeline use | U-06: response-to-request mapping and parallel arrays | Which part is reusable box composition, and which part belongs to a network dispatcher that owns tasks and cancellation? | A second concrete request chain, result-order tests, failure/cancellation behavior, and no forced type erasure. |
| Coordinated ecosystem | U-07 and U-08: CQRS, delegates, command responders, message bus, Combine-like subscriptions | Keep domain ownership in companion packages while using the box only where a fixed heterogeneous bundle genuinely helps. `AsyncMessageBus` now provides the synchronous startup gate and actor-based typed bus as a separate product. Coordinate examples and release compatibility without a core dependency cycle. | A real consumer must still validate delegate actor isolation, command and event boundaries, failure policy, and package versions. |

The wrapper work in U-05 is already implemented. Additional wrapper features are left open until a concrete workflow exposes a need.

Existing public operations also need a stability pass before 6.0.0: strict Swift 6 client examples, negative type checks, cross-platform builds, and a migration decision for trapping runtime accessors. The Swift 6 language-mode package passed all 50 tests in debug and release builds. A separate release-mode package consumer reproduced and then verified a fix for the legacy runtime-index accessor. The other checks remain release gates rather than separately proposed user features.

---

## Open API decisions

1. Validate `AsyncMessageBus` with a real app consumer and decide whether the size-one state adapter, bounded pending queue, and same-bus reentrancy rule fit its event semantics.
2. Identify a real before-and-after expression that justifies a macro beyond existing key-path mapping and function operators.
3. Choose the first consumer example for typed async member work and complete-box streams, then locate ownership of tasks and backpressure.
4. Define a compatible release order and sample app across HeterogeneousBox, AsyncSequenceSubscription, and consumer packages.

The user's first priority answer was "macros perhaps, more property wrappers, a better DSL, improve DX." Asked for one desired line of code, the user answered "better subscript interactions," then described a typed index with a closure that maps the pipeline. The user clarified that this is function composition, with network sends outside the arrow, and requested implementation with operators. That first roadmap slice is implemented locally. The user has confirmed all four remaining roadmap directions and specified a wrapper that owns a message-bus subscription, updates on receipt, and supports both MainActor and synchronized cross-actor access. The generic AsyncSequence-backed wrapper and a separate typed bus are implemented locally; real app adoption still needs validation.
