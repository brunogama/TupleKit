/// Orders tuples lexicographically by position, as Swift orders built-in tuples.
///
/// ```swift
/// let ordered = Tuple(1, "z") < Tuple(2, "a")  // true
/// ```
extension Tuple: Comparable where repeat each Member: Comparable {
  /// Returns a Boolean value that indicates whether the first differing member of `lhs`
  /// is less than the member of `rhs` at the same position.
  ///
  /// - Parameters:
  ///   - lhs: A tuple to compare.
  ///   - rhs: Another tuple of the same type.
  /// - Returns: `true` when `lhs` orders before `rhs`. Equal tuples return `false`.
  public static func < (lhs: Self, rhs: Self) -> Bool {
    for (left, right) in repeat (each lhs.members, each rhs.members) {
      if left == right { continue }
      return left < right
    }
    return false
  }
}
