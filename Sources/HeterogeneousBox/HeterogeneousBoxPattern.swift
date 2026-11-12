/// A typed predicate for each member of a heterogeneous box.
public struct HeterogeneousBoxPattern<each Value> {
    private let predicates: (repeat (each Value) -> Bool)

    public init(_ predicates: repeat @escaping (each Value) -> Bool) {
        self.predicates = (repeat each predicates)
    }

    /// Returns true only if every member satisfies its corresponding predicate.
    public func matches(_ box: HeterogeneousBox<repeat each Value>) -> Bool {
        for (predicate, element) in repeat (each predicates, each box.value) {
            guard predicate(element) else { return false }
        }
        return true
    }
}

/// Allows a typed predicate pattern to be used in a `switch` case.
public func ~= <each Value>(
    pattern: HeterogeneousBoxPattern<repeat each Value>,
    value: HeterogeneousBox<repeat each Value>
) -> Bool {
    pattern.matches(value)
}
