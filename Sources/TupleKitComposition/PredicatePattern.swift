/// A reusable `switch` pattern for any value type.
///
/// ```swift
/// let even = PredicatePattern<Int> { $0.isMultiple(of: 2) }
/// let parity: String
/// switch 4 {
/// case even: parity = "even"
/// default: parity = "odd"
/// }
/// // parity is "even"
/// ```
public struct PredicatePattern<Value> {
  private let predicate: (Value) -> Bool

  /// Creates a pattern from a predicate.
  ///
  /// - Parameter predicate: A closure that returns `true` when a value matches.
  public init(_ predicate: @escaping (Value) -> Bool) {
    self.predicate = predicate
  }

  /// Returns a Boolean value that indicates whether a value satisfies the predicate.
  ///
  /// - Parameter value: The value to test.
  /// - Returns: The predicate's result.
  public func matches(_ value: Value) -> Bool {
    predicate(value)
  }
}

extension PredicatePattern {
  /// Matches a value against a predicate pattern in a `switch` case.
  ///
  /// You don't call this operator directly. Swift calls it for each `case` that holds a
  /// ``PredicatePattern``. `Value` doesn't need to conform to `Equatable`.
  ///
  /// - Parameters:
  ///   - pattern: The pattern in the `case`.
  ///   - value: The value that the `switch` examines.
  /// - Returns: The pattern's predicate result.
  public static func ~= (pattern: Self, value: Value) -> Bool {
    pattern.matches(value)
  }
}
