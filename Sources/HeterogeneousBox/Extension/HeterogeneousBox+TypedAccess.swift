public enum HeterogeneousBoxAccessError: Error, Sendable, Equatable {
    case outOfBounds(index: Int)
    case typeMismatch(index: Int)
}

extension HeterogeneousBox {
    /// Reads a tuple member without erasing its type.
    public func value<Output>(at keyPath: KeyPath<(repeat each Value), Output>) -> Output {
        value[keyPath: keyPath]
    }

    /// Reads or replaces a tuple member by a statically typed key path.
    public subscript<Output>(keyPath: WritableKeyPath<(repeat each Value), Output>) -> Output {
        get { value[keyPath: keyPath] }
        set { self[dynamicMember: keyPath] = newValue }
    }

    /// Returns a new box after transforming one typed member.
    public func updating<Member>(
        _ keyPath: WritableKeyPath<(repeat each Value), Member>,
        _ transform: (Member) throws -> Member
    ) rethrows -> Self {
        var copy = self
        copy[keyPath] = try transform(copy[keyPath])
        return copy
    }

    /// Reads a runtime position without conflating an optional `nil` value with lookup failure.
    /// Prefer tuple key paths when the position and type are known at compile time.
    public func element<Output>(
        at position: Int,
        as type: Output.Type = Output.self
    ) -> Result<Output, HeterogeneousBoxAccessError> {
        guard position >= 0 else { return .failure(.outOfBounds(index: position)) }
        var current = 0
        for element in repeat each value {
            if current == position {
                guard let typed = element as? Output else {
                    return .failure(.typeMismatch(index: position))
                }
                return .success(typed)
            }
            current += 1
        }
        return .failure(.outOfBounds(index: position))
    }
}
