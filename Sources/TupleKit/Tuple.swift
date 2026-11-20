/// A fixed group of members whose static types can all differ.
///
/// A tuple stores a built-in Swift tuple whose member types come from a parameter pack.
/// Every API keeps each member's static type, so reading, transforming, and comparing
/// members needs no casts. Read and write members by position, the way you use a
/// built-in tuple.
///
/// ```swift
/// var order = Tuple(42, "pending", true)
/// order.1 = "shipped"
/// let status = order.1.uppercased()  // "SHIPPED"
/// ```
///
/// A one-member tuple holds the member itself, so read it with `tuple[\.self]` or
/// `tuple.members` instead of `tuple.0`.
@dynamicMemberLookup
public struct Tuple<each Member> {
  /// The members as a built-in tuple.
  ///
  /// ```swift
  /// let pair = Tuple(1, "a")
  /// let (number, text) = pair.members
  /// // number is 1, text is "a"
  /// ```
  public private(set) var members: (repeat each Member)

  /// Creates a tuple from its members, in position order.
  ///
  /// ```swift
  /// let point = Tuple(3, 4.5, "label")
  /// // point is Tuple(3, 4.5, "label")
  /// ```
  ///
  /// - Parameter members: One value per member. Each value sets that member's type.
  public init(_ members: repeat each Member) {
    self.members = (repeat each members)
  }

  /// Creates a tuple from a built-in tuple.
  ///
  /// ```swift
  /// let point = Tuple<Int, Double>(members: (3, 4.5))
  /// // point is Tuple(3, 4.5)
  /// ```
  ///
  /// - Parameter members: A built-in tuple with one element per member.
  public init(members: (repeat each Member)) {
    self.members = members
  }

  /// Reads or writes the member at a position with the dot syntax of a built-in tuple.
  ///
  /// You don't call this subscript directly. Write `tuple.0`, `tuple.1`, and so on.
  ///
  /// ```swift
  /// var pair = Tuple(1, "a")
  /// pair.0 += 1
  /// // pair.0 is 2
  /// ```
  ///
  /// - Parameter keyPath: A key path into the built-in tuple of members.
  /// - Returns: The member, with its static type.
  public subscript<Output>(
    dynamicMember keyPath: WritableKeyPath<(repeat each Member), Output>
  ) -> Output {
    get { members[keyPath: keyPath] }
    set { members[keyPath: keyPath] = newValue }
  }

  /// The number of members.
  ///
  /// ```swift
  /// let count = Tuple(1, "a", true).count  // 3
  /// ```
  public var count: Int {
    var total = 0
    for _ in repeat each members {
      total += 1
    }
    return total
  }

  /// A Boolean value that indicates whether the tuple has no members.
  ///
  /// ```swift
  /// let empty = Tuple().isEmpty  // true
  /// ```
  public var isEmpty: Bool {
    for _ in repeat each members {
      return false
    }
    return true
  }

  /// The members copied into an array of `Any`, in position order.
  ///
  /// Each member loses its static type. Use this only when positions are discovered at
  /// runtime.
  ///
  /// ```swift
  /// let erased = Tuple(1, "a").erasedMembers
  /// // erased.count is 2
  /// ```
  public var erasedMembers: [Any] {
    var erased: [Any] = []
    for member in repeat each members {
      erased.append(member)
    }
    return erased
  }

  /// Returns a new tuple with one member appended, keeping every member's static type.
  ///
  /// ```swift
  /// let longer = Tuple(1, "a").appending(true)
  /// // longer is Tuple(1, "a", true)
  /// ```
  ///
  /// - Parameter member: The value to add after the last member.
  /// - Returns: A tuple with one more member. The original tuple is unchanged.
  public func appending<Appended>(_ member: Appended) -> Tuple<repeat each Member, Appended> {
    Tuple<repeat each Member, Appended>(members: (repeat each members, member))
  }

  /// Transforms one input and appends the result, keeping the result's static type.
  ///
  /// ```swift
  /// let longer = Tuple("ready").appendingTransformed(21) { $0 * 2 }
  /// // longer is Tuple("ready", 42)
  /// ```
  ///
  /// - Parameters:
  ///   - input: The value to transform.
  ///   - transform: A closure that turns `input` into the new member.
  /// - Returns: A tuple with one more member. The original tuple is unchanged.
  /// - Throws: Rethrows any error that `transform` throws.
  public func appendingTransformed<Input, Output>(
    _ input: Input,
    _ transform: (Input) throws -> Output
  ) rethrows -> Tuple<repeat each Member, Output> {
    Tuple<repeat each Member, Output>(
      members: (repeat each members, try transform(input))
    )
  }

  /// Calls one closure per member, in position order, with that member's static type.
  ///
  /// ```swift
  /// var total = 0
  /// var labels: [String] = []
  /// Tuple(3, "ready").forEachTyped(
  ///     { (number: Int) in total += number },
  ///     { (text: String) in labels.append(text) }
  /// )
  /// ```
  ///
  /// - Parameter actions: One closure per member, in position order.
  public func forEachTyped(_ actions: repeat (each Member) -> Void) {
    for (action, member) in repeat (each actions, each members) {
      action(member)
    }
  }

  /// Calls one throwing closure per member, in position order, and stops at the first error.
  ///
  /// ```swift
  /// var total = 0
  /// var labels: [String] = []
  /// try Tuple(3, "ready").tryForEachTyped(
  ///     { (number: Int) in total += number },
  ///     { (text: String) in labels.append(text) }
  /// )
  /// ```
  ///
  /// - Parameter actions: One closure per member, in position order.
  /// - Throws: The first error a closure throws. Later closures don't run.
  public func tryForEachTyped(_ actions: repeat (each Member) throws -> Void) throws {
    for (action, member) in repeat (each actions, each members) {
      try action(member)
    }
  }
}

/// A tuple may cross an actor boundary only when every member may do so.
extension Tuple: Sendable where repeat each Member: Sendable {}
