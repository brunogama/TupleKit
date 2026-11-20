/// A typed predicate for each member of a tuple, for use in a `switch` case.
///
/// ```swift
/// let urgent = TuplePattern<Int, String>({ $0 > 90 }, { _ in true })
/// let priority: String
/// switch Tuple(95, "disk") {
/// case urgent: priority = "urgent"
/// default: priority = "normal"
/// }
/// // priority is "urgent"
/// ```
public struct TuplePattern<each Member> {
  private let predicates: (repeat (each Member) -> Bool)

  /// Creates a pattern from one predicate per member.
  ///
  /// - Parameter predicates: One closure per member, in position order. Each closure
  ///   returns `true` when its member matches.
  public init(_ predicates: repeat @escaping (each Member) -> Bool) {
    self.predicates = (repeat each predicates)
  }

  /// Returns a Boolean value that indicates whether every member satisfies its predicate.
  ///
  /// Predicates run in position order and stop at the first one that returns `false`.
  ///
  /// ```swift
  /// let positive = TuplePattern<Int, Int>({ $0 > 0 }, { $0 > 0 })
  /// let matched = positive.matches(Tuple(1, -2))  // false
  /// ```
  ///
  /// - Parameter tuple: The tuple to test.
  /// - Returns: `true` when every predicate returns `true`.
  public func matches(_ tuple: Tuple<repeat each Member>) -> Bool {
    for (predicate, member) in repeat (each predicates, each tuple.members) {
      guard predicate(member) else { return false }
    }
    return true
  }
}

extension TuplePattern {
  /// Matches a tuple against a typed pattern in a `switch` case.
  ///
  /// You don't call this operator directly. Swift calls it for each `case` that holds a
  /// ``TuplePattern``.
  ///
  /// - Parameters:
  ///   - pattern: The pattern in the `case`.
  ///   - members: The tuple that the `switch` examines.
  /// - Returns: `true` when every member satisfies its predicate.
  public static func ~= (pattern: Self, members: Tuple<repeat each Member>) -> Bool {
    pattern.matches(members)
  }
}
