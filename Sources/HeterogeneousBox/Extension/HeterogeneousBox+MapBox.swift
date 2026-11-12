extension HeterogeneousBox {
    /// Maps the whole typed box to a new box whose types are selected by the closure.
    public func mapBox<each Output>(
        _ transform: (Self) throws -> HeterogeneousBox<repeat each Output>
    ) rethrows -> HeterogeneousBox<repeat each Output> {
        try transform(self)
    }
}
