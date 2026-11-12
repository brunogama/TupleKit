extension HeterogeneousBox: Equatable where repeat each Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for (left, right) in repeat (each lhs.value, each rhs.value) {
            guard left == right else { return false }
        }
        return true
    }

    public func contains<T>(where value: T) -> Bool where T: Equatable {
        array.contains { $0 as? T == value }
    }
}
