extension Tuple {
  /// Maps one statically selected member without erasing its type.
  ///
  /// The closure receives a snapshot of the selected member. The tuple is unchanged.
  ///
  /// ```swift
  /// let order = Tuple(42, "pending")
  /// let length = order[\.1, map: { $0.count }]  // 7
  /// ```
  ///
  /// - Parameters:
  ///   - keyPath: The member to read.
  ///   - transform: A closure that receives the member.
  /// - Returns: The closure's result.
  public subscript<Selected, Output>(
    _ keyPath: KeyPath<(repeat each Member), Selected>,
    map transform: (Selected) -> Output
  ) -> Output {
    transform(members[keyPath: keyPath])
  }

  /// Maps two statically selected members in key-path order.
  ///
  /// The closure receives snapshots of both members. The tuple is unchanged.
  ///
  /// ```swift
  /// let line = Tuple(3, "item", 2.5)
  /// let total = line[\.0, \.2, map: { Double($0) * $1 }]  // 7.5
  /// ```
  ///
  /// - Parameters:
  ///   - first: The member passed first to the closure.
  ///   - second: The member passed second to the closure.
  ///   - transform: A closure that receives both members.
  /// - Returns: The closure's result.
  public subscript<First, Second, Output>(
    _ first: KeyPath<(repeat each Member), First>,
    _ second: KeyPath<(repeat each Member), Second>,
    map transform: (First, Second) -> Output
  ) -> Output {
    transform(members[keyPath: first], members[keyPath: second])
  }
}
