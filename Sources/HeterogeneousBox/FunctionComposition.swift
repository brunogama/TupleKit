precedencegroup ForwardApplicationPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

precedencegroup ForwardCompositionPrecedence {
    associativity: left
    higherThan: ForwardApplicationPrecedence
}

infix operator |> : ForwardApplicationPrecedence
infix operator >>> : ForwardCompositionPrecedence

/// Applies a value to a synchronous, nonthrowing transform.
public func |> <Input, Output>(value: Input, transform: (Input) -> Output) -> Output {
    transform(value)
}

/// Composes two synchronous, nonthrowing transforms in left-to-right order.
public func >>> <Input, Intermediate, Output>(
    first: @escaping (Input) -> Intermediate,
    second: @escaping (Intermediate) -> Output
) -> (Input) -> Output {
    { input in second(first(input)) }
}
