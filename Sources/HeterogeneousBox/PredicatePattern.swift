/// A reusable `switch` pattern for any value type.
public struct PredicatePattern<Value> {
    private let predicate: (Value) -> Bool

    public init(_ predicate: @escaping (Value) -> Bool) {
        self.predicate = predicate
    }

    public func matches(_ value: Value) -> Bool {
        predicate(value)
    }
}

/// Matches a value without requiring `Value` to conform to `Equatable`.
public func ~= <Value>(pattern: PredicatePattern<Value>, value: Value) -> Bool {
    pattern.matches(value)
}
