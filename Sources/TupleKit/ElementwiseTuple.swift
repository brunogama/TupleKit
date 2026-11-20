/// A view of a tuple whose `+` and `-` work member by member.
///
/// `Tuple.+` concatenates, so `Tuple` itself cannot conform to `AdditiveArithmetic` without
/// giving one expression two meanings. This view owns that conformance instead. Reach it
/// through ``Tuple/elementwise`` or ``init(_:)`` and read the result back through ``tuple``.
///
/// Convert a collection with `map(ElementwiseTuple.init)`. Don't write `map(\.elementwise)`:
/// on Swift 6.4.2 every key path rooted at `Tuple` crashes the compiler.
///
/// ```swift
/// let steps = [Tuple(1, 0.5), Tuple(2, 0.25), Tuple(3, 0.25)]
/// let total = steps.map(ElementwiseTuple.init).reduce(.zero, +).tuple
/// // total is Tuple(6, 1.0)
/// ```
public struct ElementwiseTuple<each Member: AdditiveArithmetic>: AdditiveArithmetic {
  /// The tuple this view wraps.
  public var tuple: Tuple<repeat each Member>

  /// Creates a view over a tuple.
  ///
  /// - Parameter tuple: The tuple whose members to add or subtract.
  public init(_ tuple: Tuple<repeat each Member>) {
    self.tuple = tuple
  }

  /// A view whose every member is that member type's `zero`.
  public static var zero: Self {
    Self(Tuple(members: (repeat (each Member).zero)))
  }

  /// Returns a view that adds the members of `rhs` to the members of `lhs`, position by
  /// position.
  ///
  /// - Parameters:
  ///   - lhs: A view to add to.
  ///   - rhs: A view of the same type.
  /// - Returns: The position-wise sums.
  public static func + (lhs: Self, rhs: Self) -> Self {
    Self(lhs.tuple.adding(rhs.tuple))
  }

  /// Returns a view that subtracts the members of `rhs` from the members of `lhs`,
  /// position by position.
  ///
  /// - Parameters:
  ///   - lhs: A view to subtract from.
  ///   - rhs: A view of the same type.
  /// - Returns: The position-wise differences.
  public static func - (lhs: Self, rhs: Self) -> Self {
    Self(lhs.tuple.subtracting(rhs.tuple))
  }

  /// Returns a Boolean value that indicates whether every pair of members at the same
  /// position is equal.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    for (left, right) in repeat (each lhs.tuple.members, each rhs.tuple.members) {
      guard left == right else { return false }
    }
    return true
  }
}

/// The view may cross an actor boundary when every member may do so.
extension ElementwiseTuple: Sendable where repeat each Member: Sendable {}

/// Hashes the members in position order.
extension ElementwiseTuple: Hashable where repeat each Member: Hashable {
  /// Feeds every member into the hasher, in position order.
  ///
  /// - Parameter hasher: The hasher to combine the members into.
  public func hash(into hasher: inout Hasher) {
    tuple.hash(into: &hasher)
  }
}

/// Prints the wrapped tuple.
extension ElementwiseTuple: CustomStringConvertible {
  /// The wrapped tuple's description.
  public var description: String {
    tuple.description
  }
}

extension Tuple where repeat each Member: AdditiveArithmetic {
  /// A view of this tuple whose `+` and `-` work member by member.
  ///
  /// Use it where an `AdditiveArithmetic` type is required, such as `reduce(.zero, +)`.
  ///
  /// ```swift
  /// let sum = (Tuple(1, 2.5).elementwise + Tuple(2, 0.5).elementwise).tuple
  /// // sum is Tuple(3, 3.0)
  /// ```
  public var elementwise: ElementwiseTuple<repeat each Member> {
    ElementwiseTuple(self)
  }
}
