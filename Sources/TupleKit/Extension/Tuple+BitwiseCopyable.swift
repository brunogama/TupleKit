/// A tuple is trivially copyable when every member is, so it can be stored in raw memory
/// or passed to APIs that require `BitwiseCopyable`.
///
/// ```swift
/// func store<Value: BitwiseCopyable>(_ value: Value) -> Int { MemoryLayout<Value>.size }
/// let size = store(Tuple(1, true))
/// // size is 9
/// ```
extension Tuple: BitwiseCopyable where repeat each Member: BitwiseCopyable {}
