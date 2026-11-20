/// Element-wise arithmetic for tuples whose members are all `AdditiveArithmetic`.
///
/// These are named methods rather than an `AdditiveArithmetic` conformance on purpose. The
/// protocol's `+ (Self, Self) -> Self` would be preferred over the concatenation operator
/// for two tuples of the same type, so `Tuple(1, 2.0) + Tuple(1, 2.0)` would silently stop
/// producing a four-member tuple.
///
/// ```swift
/// let total = Tuple(1, 2.5).adding(Tuple(10, 0.5))
/// // total is Tuple(11, 3.0)
/// ```
extension Tuple where repeat each Member: AdditiveArithmetic {
  /// A tuple whose every member is that member type's `zero`.
  ///
  /// ```swift
  /// let origin = Tuple<Int, Double>.zero
  /// // origin is Tuple(0, 0.0)
  /// ```
  public static var zero: Self {
    Tuple(members: (repeat (each Member).zero))
  }

  /// Returns a tuple that adds the members of `other` to the members of this tuple,
  /// position by position.
  ///
  /// ```swift
  /// let moved = Tuple(1, 2.5).adding(Tuple(2, 0.5))
  /// // moved is Tuple(3, 3.0)
  /// ```
  ///
  /// - Parameter other: A tuple of the same type.
  /// - Returns: The position-wise sums.
  public func adding(_ other: Self) -> Self {
    Tuple(members: (repeat (each members) + (each other.members)))
  }

  /// Returns a tuple that subtracts the members of `other` from the members of this tuple,
  /// position by position.
  ///
  /// ```swift
  /// let delta = Tuple(5, 2.5).subtracting(Tuple(2, 0.5))
  /// // delta is Tuple(3, 2.0)
  /// ```
  ///
  /// - Parameter other: A tuple of the same type.
  /// - Returns: The position-wise differences.
  public func subtracting(_ other: Self) -> Self {
    Tuple(members: (repeat (each members) - (each other.members)))
  }
}
