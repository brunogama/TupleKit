@dynamicMemberLookup
public struct HeterogeneousBox<each Value> {
    public private(set) var value: (repeat each Value)

    public init(_ value: repeat each Value) {
        self.value = (repeat each value)
    }

    public init(tuple: (repeat each Value)) {
        self.value = tuple
    }

    public subscript(position: Int) -> Any {
        array[position]
    }

    public func getElement(at position: Int) -> Any {
        let elements = array
        guard elements.indices.contains(position) else {
            fatalError("Index out of bounds")
        }
        return elements[position]
    }

    public func getTypeInferedElement<T>(at position: Int) -> T {
        let elements = array
        guard elements.indices.contains(position) else {
            fatalError("Index out of bounds")
        }
        guard let typedElement = elements[position] as? T else {
            preconditionFailure("Element at position \(position) is not \(T.self)")
        }
        return typedElement
    }

    public subscript<U>(typeInfered position: Int) -> U {
        guard let element = array[position] as? U else {
            preconditionFailure("Element at position \(position) is not \(U.self)")
        }
        return element
    }

    public subscript<Output>(
        dynamicMember keyPath: WritableKeyPath<(repeat each Value), Output>
    ) -> Output {
        get { value[keyPath: keyPath] }
        set { value[keyPath: keyPath] = newValue }
    }

    public var count: Int {
        var total = 0
        for _ in repeat each value {
            total += 1
        }
        return total
    }

    public var isEmpty: Bool {
        count == 0
    }

    public var array: [Any] {
        var elements: [Any] = []
        elements.reserveCapacity(count)
        for element in repeat each value {
            elements.append(element)
        }
        return elements
    }

    public func reduce<Result>(
        _ initialResult: Result,
        _ nextPartialResult: (Result, Any) throws -> Result
    ) rethrows -> Result {
        var result = initialResult
        for element in repeat each value {
            result = try nextPartialResult(result, element)
        }
        return result
    }

    public var nonNilValues: [Any] {
        array.compactMap { value in
            if let optional = value as? OptionalType, optional.isNil {
                return nil
            }
            return value
        }
    }

    public func dump() {
        Swift.dump(value)
    }

    public func filteredByType<T>(_ type: T.Type) -> [T] {
        array.compactMap { $0 as? T }
    }

    public func appending<each T>(
        values: repeat each T
    ) -> HeterogeneousBox<repeat each Value, repeat each T> {
        HeterogeneousBox<repeat each Value, repeat each T>(
            tuple: (repeat each value, repeat each values)
        )
    }

    /// Transforms one input and appends its result without erasing the result type.
    public func appendingTransformed<Input, Output>(
        _ input: Input,
        _ transform: (Input) throws -> Output
    ) rethrows -> HeterogeneousBox<repeat each Value, Output> {
        HeterogeneousBox<repeat each Value, Output>(
            tuple: (repeat each value, try transform(input))
        )
    }

    /// Visits each member with a callback matching that member's static type.
    public func forEachTyped(_ actions: repeat (each Value) -> Void) {
        for (action, member) in repeat (each actions, each value) {
            action(member)
        }
    }

    /// Visits each member in order, stopping when a callback throws.
    public func tryForEachTyped(_ actions: repeat (each Value) throws -> Void) throws {
        for (action, member) in repeat (each actions, each value) {
            try action(member)
        }
    }
}

private protocol OptionalType {
    var isNil: Bool { get }
}

extension Optional: OptionalType {
    var isNil: Bool { self == nil }
}

/// A box may cross an actor boundary only when every stored value may do so.
extension HeterogeneousBox: Sendable where repeat each Value: Sendable {}
