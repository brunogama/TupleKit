/// Records snapshots of boxes with one fixed generic member layout.
@propertyWrapper
public struct AccumulatingBox<each Value> {
    private var storage: AccumulatingValue<HeterogeneousBox<repeat each Value>>

    /// Creates a history with an optional maximum number of box snapshots.
    ///
    /// - Parameters:
    ///   - wrappedValue: The initial box, which is the first history entry.
    ///   - capacity: The number of most recent boxes to retain. Must be positive.
    ///     Pass `nil` to retain every assignment.
    public init(wrappedValue: HeterogeneousBox<repeat each Value>, capacity: Int? = nil) {
        storage = AccumulatingValue(wrappedValue: wrappedValue, capacity: capacity)
    }

    public var wrappedValue: HeterogeneousBox<repeat each Value> {
        get { storage.wrappedValue }
        set { storage.wrappedValue = newValue }
    }

    /// A snapshot of the retained boxes in assignment order.
    public var projectedValue: [HeterogeneousBox<repeat each Value>] {
        storage.projectedValue
    }
}

extension AccumulatingBox: Sendable where repeat each Value: Sendable {}
