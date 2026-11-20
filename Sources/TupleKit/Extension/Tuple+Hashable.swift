/// Hashes the members in position order, so a tuple can be a dictionary key or a set member.
///
/// ```swift
/// let seen: Set = [Tuple(1, "a"), Tuple(1, "a")]
/// // seen.count is 1
/// ```
extension Tuple: Hashable where repeat each Member: Hashable {
  /// Feeds every member into the hasher, in position order.
  ///
  /// - Parameter hasher: The hasher to combine the members into.
  public func hash(into hasher: inout Hasher) {
    repeat hasher.combine(each members)
  }
}
