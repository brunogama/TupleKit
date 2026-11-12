/// Concatenates two boxes while preserving every member's static type.
public func + <each Left, each Right>(
    lhs: HeterogeneousBox<repeat each Left>,
    rhs: HeterogeneousBox<repeat each Right>
) -> HeterogeneousBox<repeat each Left, repeat each Right> {
    HeterogeneousBox<repeat each Left, repeat each Right>(
        tuple: (repeat each lhs.value, repeat each rhs.value)
    )
}

public func + <each Right>(
    lhs: HeterogeneousBox<>,
    rhs: HeterogeneousBox<repeat each Right>
) -> HeterogeneousBox<repeat each Right> {
    rhs
}

public func + <each Left>(
    lhs: HeterogeneousBox<repeat each Left>,
    rhs: HeterogeneousBox<>
) -> HeterogeneousBox<repeat each Left> {
    lhs
}

public func + (lhs: HeterogeneousBox<>, rhs: HeterogeneousBox<>) -> HeterogeneousBox<> {
    lhs
}
