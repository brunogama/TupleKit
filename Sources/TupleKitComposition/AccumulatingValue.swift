/// Records assigned values of one fixed type, including the initial value.
///
/// Read the history through the projected value, `$property`.
///
/// ```swift
/// struct Session {
///     @AccumulatingValue(capacity: 2) var state = Tuple(1, "idle")
/// }
/// var session = Session()
/// session.state = Tuple(2, "busy")
/// session.state = Tuple(3, "done")
/// let history = session.$state  // [Tuple(2, busy), Tuple(3, done)]
/// ```
@propertyWrapper
public struct AccumulatingValue<Value> {
  private var current: Value
  private var history: [Value]
  private let capacity: Int?

  /// Creates a history with an optional maximum number of entries.
  ///
  /// - Parameters:
  ///   - wrappedValue: The initial value, which is the first history entry.
  ///   - capacity: The number of most recent values to retain. Must be positive.
  ///     Pass `nil` to retain every assignment.
  public init(wrappedValue: Value, capacity: Int? = nil) {
    if let capacity {
      precondition(capacity > 0, "History capacity must be positive")
    }
    current = wrappedValue
    history = [wrappedValue]
    self.capacity = capacity
  }

  /// The most recent value. Assigning a value appends it to the history.
  public var wrappedValue: Value {
    get { current }
    set {
      current = newValue
      history.append(newValue)
      if let capacity, history.count > capacity {
        history.removeFirst()
      }
    }
  }

  /// A snapshot of the retained values in assignment order.
  public var projectedValue: [Value] {
    history
  }
}

/// A history may cross an actor boundary only when its values may do so.
extension AccumulatingValue: Sendable where Value: Sendable {}
