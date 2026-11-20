extension Tuple {
  /// Transforms each member in position order and returns a tuple of the results.
  ///
  /// Provide one transform per member. Each transform receives its member's static type
  /// and chooses the static type of the matching output member. The first thrown error
  /// stops iteration, and later transforms do not run.
  ///
  /// ```swift
  /// let order = Tuple(42, "pending")
  /// let labels = order.mapEach({ "#\($0)" }, { $0.uppercased() })
  /// // labels is Tuple(#42, PENDING)
  /// ```
  ///
  /// - Parameter transforms: One closure per member, in position order.
  /// - Returns: A tuple of the transform results, in position order.
  /// - Throws: The first `Failure` a transform throws.
  public func mapEach<each Output, Failure: Error>(
    _ transforms: repeat (each Member) throws(Failure) -> each Output
  ) throws(Failure) -> Tuple<repeat each Output> {
    Tuple<repeat each Output>(members: (repeat try (each transforms)(each members)))
  }

  /// Transforms each member in position order, awaiting one transform before starting the next.
  ///
  /// Provide one transform per member. Each transform receives its member's static type
  /// and chooses the static type of the matching output member. The first thrown error
  /// stops iteration, and later transforms do not run. The transforms run on the caller's
  /// actor, so they do not need to be `Sendable`.
  ///
  /// ```swift
  /// let ids = Tuple(1, 2)
  /// let doubled = await ids.mapEach(
  ///     { (id: Int) async -> Int in id * 2 },
  ///     { (id: Int) async -> String in "#\(id)" }
  /// )
  /// // doubled is Tuple(2, #2)
  /// ```
  ///
  /// - Parameter transforms: One async closure per member, in position order.
  /// - Returns: A tuple of the transform results, in position order.
  /// - Throws: The first `Failure` a transform throws.
  nonisolated(nonsending) public func mapEach<each Output, Failure: Error>(
    _ transforms:
      repeat nonisolated(nonsending) (each Member) async throws(Failure) -> each Output
  ) async throws(Failure) -> Tuple<repeat each Output> {
    Tuple<repeat each Output>(
      members: (repeat try await (each transforms)(each members))
    )
  }
}

// A method on `Tuple` would lose `@Sendable` inference for closure literals in
// client modules, because `@dynamicMemberLookup` interferes with it on Swift 6.4.2.

/// Transforms every member of a tuple concurrently in child tasks and returns the outputs in position order.
///
/// Provide one transform per member. The output tuple keeps each transform's static result
/// type and the source member order, whatever order the child tasks finish in. When a
/// transform throws, the remaining child tasks are cancelled and the error is rethrown
/// after they finish. Cancelling the calling task cancels every child task. Each transform
/// must cooperate with cancellation to stop early.
///
/// ```swift
/// let ids = Tuple(7, "profile")
/// let loaded = try await concurrentMapEach(
///     ids,
///     { id in id * 10 },
///     { name in name.count }
/// )
/// // loaded is Tuple(70, 7)
/// ```
///
/// - Parameters:
///   - tuple: The tuple whose members to transform.
///   - transforms: One `Sendable` async closure per member, in position order.
/// - Returns: A tuple of the transform results, in position order.
/// - Throws: The first error a transform throws, after every child task finishes.
public func concurrentMapEach<each Member: Sendable, each Output: Sendable>(
  _ tuple: Tuple<repeat each Member>,
  _ transforms: repeat @escaping @Sendable (each Member) async throws -> each Output
) async throws -> Tuple<repeat each Output> {
  let outputs = try await withThrowingTaskGroup(of: (Int, any Sendable).self) { group in
    var position = 0
    for (transform, member) in repeat (each transforms, each tuple.members) {
      let index = position
      group.addTask { (index, try await transform(member)) }
      position += 1
    }
    var outputs = [(any Sendable)?](repeating: nil, count: position)
    for try await (index, output) in group {
      outputs[index] = output
    }
    return outputs
  }
  var position = 0
  func next<Element>(_: Element.Type) -> Element {
    defer { position += 1 }
    // Every child task stores its output at its position before the group finishes.
    guard let output = outputs[position] as? Element else {
      preconditionFailure("No output of type \(Element.self) at position \(position)")
    }
    return output
  }
  return Tuple<repeat each Output>(members: (repeat next((each Output).self)))
}
