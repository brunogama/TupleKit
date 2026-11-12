/// A finite asynchronous view of a box's type-erased members.
public struct HeterogeneousBoxAsyncValues: AsyncSequence {
    public typealias Element = Any

    private let elements: [Any]

    fileprivate init(_ elements: [Any]) {
        self.elements = elements
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        private let elements: [Any]
        private var position = 0

        fileprivate init(_ elements: [Any]) {
            self.elements = elements
        }

        public mutating func next() async -> Any? {
            guard !Task.isCancelled, position < elements.count else { return nil }
            defer { position += 1 }
            return .some(elements[position])
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(elements)
    }
}

extension HeterogeneousBox {
    /// Creates a finite async sequence from a type-erased snapshot of the box.
    public func asyncValues() -> HeterogeneousBoxAsyncValues {
        HeterogeneousBoxAsyncValues(array)
    }
}
