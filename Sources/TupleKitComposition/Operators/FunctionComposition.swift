/// The precedence of `|>`, below ternary expressions and `>>>`, above assignment.
precedencegroup ForwardApplicationPrecedence {
  associativity: left
  higherThan: AssignmentPrecedence
  lowerThan: TernaryPrecedence
}

/// The precedence of `>>>`, which binds tighter than `|>`.
precedencegroup ForwardCompositionPrecedence {
  associativity: left
  higherThan: ForwardApplicationPrecedence
}

/// Forward application. `value |> transform` calls `transform(value)`.
infix operator |> : ForwardApplicationPrecedence
/// Forward composition. `first >>> second` runs `first` and then `second`.
infix operator >>> : ForwardCompositionPrecedence

/// Applies a value to a synchronous, nonthrowing transform.
///
/// Chains read left to right, in the order the transforms run.
///
/// ```swift
/// let length = "ready" |> { $0.count }
/// // length is 5
/// ```
///
/// - Parameters:
///   - value: The input to the transform.
///   - transform: The function to apply.
/// - Returns: The transform's result.
public func |> <Input, Output>(value: Input, transform: (Input) -> Output) -> Output {
  transform(value)
}

/// Composes two synchronous, nonthrowing transforms in left-to-right order.
///
/// ```swift
/// let shout = { (text: String) in text.uppercased() } >>> { $0 + "!" }
/// let loud = shout("ready")  // "READY!"
/// ```
///
/// - Parameters:
///   - first: The transform that runs first.
///   - second: The transform that receives the output of `first`.
/// - Returns: A function that runs `first` and then `second`.
public func >>> <Input, Intermediate, Output>(
  first: @escaping (Input) -> Intermediate,
  second: @escaping (Intermediate) -> Output
) -> (Input) -> Output {
  { input in second(first(input)) }
}
