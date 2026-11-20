import TupleKit

// A conditional RawRepresentable conformance on Tuple makes the type checker route nested
// literals through `RawValue`, even when no member is RawRepresentable.
extension Tuple: @retroactive RawRepresentable where repeat each Member: RawRepresentable {
  public var rawValue: Tuple<repeat (each Member).RawValue> {
    Tuple<repeat (each Member).RawValue>(members: (repeat (each members).rawValue))
  }

  public init?(rawValue: Tuple<repeat (each Member).RawValue>) {
    return nil
  }
}

func nested() -> Tuple<Int, Tuple<Int, String>> {
  Tuple(1, Tuple(2, "a"))  // known-bug
}
