extension HeterogeneousBox {
    /// Maps one statically selected member without erasing its type.
    ///
    /// The closure receives a snapshot of the selected value. The box is unchanged.
    public subscript<Member, Output>(
        _ keyPath: KeyPath<(repeat each Value), Member>,
        map transform: (Member) -> Output
    ) -> Output {
        transform(value[keyPath: keyPath])
    }

    /// Maps two statically selected members in key-path order.
    ///
    /// The closure receives snapshots of both values. The box is unchanged.
    public subscript<First, Second, Output>(
        _ first: KeyPath<(repeat each Value), First>,
        _ second: KeyPath<(repeat each Value), Second>,
        map transform: (First, Second) -> Output
    ) -> Output {
        transform(value[keyPath: first], value[keyPath: second])
    }
}
