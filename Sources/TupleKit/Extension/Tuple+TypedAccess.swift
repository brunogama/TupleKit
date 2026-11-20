/// The reason a runtime lookup with ``Tuple/member(at:as:)`` failed.
public enum TupleAccessError: Error, Sendable, Equatable {
  /// The position is negative or not less than the member count.
  case outOfBounds(position: Int)
  /// The member at the position isn't of the requested type.
  case typeMismatch(position: Int)
}

extension Tuple {
  /// Reads or replaces a tuple member by a statically typed key path.
  ///
  /// ```swift
  /// var pair = Tuple(1, "a")
  /// pair[\.1] = "b"
  /// let text = pair[\.1]  // "b"
  /// ```
  ///
  /// - Parameter keyPath: A key path into the built-in tuple of members, such as `\.0`.
  /// - Returns: The member, with its static type.
  public subscript<Output>(keyPath: WritableKeyPath<(repeat each Member), Output>) -> Output {
    get { members[keyPath: keyPath] }
    set { self[dynamicMember: keyPath] = newValue }
  }

  /// Returns a copy of the tuple with one member transformed.
  ///
  /// ```swift
  /// let price = Tuple("book", 10)
  /// let discounted = price.updating(\.1) { $0 - 2 }
  /// // discounted is Tuple("book", 8)
  /// ```
  ///
  /// - Parameters:
  ///   - keyPath: The member to transform.
  ///   - transform: A closure that returns the new value of the member.
  /// - Returns: A copy with the new member. The original tuple is unchanged.
  /// - Throws: Rethrows any error that `transform` throws.
  public func updating<Selected>(
    _ keyPath: WritableKeyPath<(repeat each Member), Selected>,
    _ transform: (Selected) throws -> Selected
  ) rethrows -> Self {
    var copy = self
    copy[keyPath] = try transform(copy[keyPath])
    return copy
  }

  /// Reads the member at a position known only at runtime, checked against a type.
  ///
  /// A member holding `nil` succeeds when the requested type is that member's optional
  /// type, and fails with `typeMismatch` when the requested type is non-optional. Prefer
  /// key paths when the position and type are known at compile time.
  ///
  /// ```swift
  /// let row = Tuple(1, "a")
  /// let text = try row.member(at: 1, as: String.self).get()  // "a"
  /// let wrongType = row.member(at: 1, as: Int.self)  // .failure(.typeMismatch(position: 1))
  /// ```
  ///
  /// - Parameters:
  ///   - position: The zero-based position of the member.
  ///   - type: The type to cast the member to.
  /// - Returns: The member, or a ``TupleAccessError`` that says why the lookup failed.
  public func member<Output>(
    at position: Int,
    as type: Output.Type = Output.self
  ) -> Result<Output, TupleAccessError> {
    guard position >= 0 else { return .failure(.outOfBounds(position: position)) }
    var current = 0
    for member in repeat each members {
      if current == position {
        guard let typed = member as? Output else {
          return .failure(.typeMismatch(position: position))
        }
        return .success(typed)
      }
      current += 1
    }
    return .failure(.outOfBounds(position: position))
  }
}
