/// Returns the wrapped members when every member has a value, or `nil` when any member is `nil`.
///
/// Pass a tuple held in a constant or variable. On Swift 6.4.2, a `Tuple(...)` expression
/// written inline as the argument wraps each member in another optional and fails to
/// type-check.
///
/// ```swift
/// let form = Tuple(Int("42"), "Ada" as String?)
/// if let user = unwrapped(form) {
///     let greeting = "\(user.1) is \(user.0 + 1) next year"  // "Ada is 43 next year"
/// }
/// ```
///
/// - Parameter tuple: A tuple whose members are all optionals.
/// - Returns: A tuple of the wrapped values, or `nil` when any member is `nil`.
public func unwrapped<each Wrapped>(
  _ tuple: Tuple<repeat (each Wrapped)?>
) -> Tuple<repeat each Wrapped>? {
  for member in repeat each tuple.members {
    guard member != nil else { return nil }
  }
  return Tuple<repeat each Wrapped>(members: (repeat (each tuple.members)!))
}

/// Returns the successful values when every member succeeded, or the first failure in position order.
///
/// ```swift
/// let lookups = Tuple(
///     Result<Int, CancellationError>.success(7),
///     Result<String, CancellationError>.success("ready")
/// )
/// let found = try collected(lookups).get()  // Tuple(7, ready)
/// ```
///
/// - Parameter tuple: A tuple of results that share one failure type.
/// - Returns: A success with every value, or the first failure in position order.
public func collected<each Success, Failure: Error>(
  _ tuple: Tuple<repeat Result<each Success, Failure>>
) -> Result<Tuple<repeat each Success>, Failure> {
  do throws(Failure) {
    // Passing a built-in tuple held in a constant here crashes SIL generation on Swift 6.4.2.
    return .success(
      Tuple<repeat each Success>(members: (repeat try (each tuple.members).get()))
    )
  }
  catch {
    return .failure(error)
  }
}

/// Waits for every task and returns their values in position order.
///
/// The tasks are already running, so they make progress concurrently while this function
/// waits on each one in turn. Cancelling the calling task does not cancel the tasks.
///
/// ```swift
/// let downloads = Tuple(Task { 7 }, Task { "ready" })
/// let results = await values(of: downloads)  // Tuple(7, ready)
/// ```
///
/// - Parameter tasks: A tuple of tasks that can't fail.
/// - Returns: The task values, in position order.
public func values<each Success: Sendable>(
  of tasks: Tuple<repeat Task<each Success, Never>>
) async -> Tuple<repeat each Success> {
  Tuple<repeat each Success>(members: (repeat await (each tasks.members).value))
}

/// Awaits task values in position order, stopping at the first failure.
///
/// The tasks are already running, so they make progress concurrently while this function
/// waits on each one in turn. After a failure, later tasks keep running and are not awaited.
/// Cancelling the calling task does not cancel these tasks.
///
/// ```swift
/// let downloads = Tuple(
///     Task<Int, any Error> { 7 },
///     Task<String, any Error> { "ready" }
/// )
/// let results = try await values(of: downloads)  // Tuple(7, ready)
/// ```
///
/// - Parameter tasks: A tuple of tasks whose failure type is `any Error`.
/// - Returns: The task values, in position order.
/// - Throws: The error of the first failed task in position order.
public func values<each Success: Sendable>(
  of tasks: Tuple<repeat Task<each Success, any Error>>
) async throws -> Tuple<repeat each Success> {
  Tuple<repeat each Success>(members: (repeat try await (each tasks.members).value))
}

/// Pairs the members of two tuples of the same length by position.
///
/// Tuples of different lengths don't compile.
///
/// ```swift
/// let fields = zip(Tuple("count", "label"), Tuple(3, "ready"))
/// let first = fields.0  // ("count", 3)
/// ```
///
/// - Parameters:
///   - first: The tuple whose members come first in each pair.
///   - second: The tuple whose members come second in each pair.
/// - Returns: A tuple of built-in pairs, one per position.
public func zip<each First, each Second>(
  _ first: Tuple<repeat each First>,
  _ second: Tuple<repeat each Second>
) -> Tuple<repeat (each First, each Second)> {
  Tuple<repeat (each First, each Second)>(
    members: (repeat (each first.members, each second.members))
  )
}
