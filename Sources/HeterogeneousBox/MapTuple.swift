/// Maps a typed tuple into a new heterogeneous box.
/// The generic input also accepts other source values; the closure must return a box.
public func mapTuple<Input, each Output>(
    _ tuple: Input,
    _ transform: (Input) throws -> HeterogeneousBox<repeat each Output>
) rethrows -> HeterogeneousBox<repeat each Output> {
    try transform(tuple)
}
