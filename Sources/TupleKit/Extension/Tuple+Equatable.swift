/// Compares tuples member by member.
///
/// ```swift
/// let same = Tuple(1, "a") == Tuple(1, "a")  // true
/// ```
extension Tuple: Equatable where repeat each Member: Equatable {
  /// Returns a Boolean value that indicates whether every pair of members at the same
  /// position is equal.
  ///
  /// - Parameters:
  ///   - lhs: A tuple to compare.
  ///   - rhs: Another tuple of the same type.
  /// - Returns: `true` when all members are equal.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    for (left, right) in repeat (each lhs.members, each rhs.members) {
      guard left == right else { return false }
    }
    return true
  }
}
