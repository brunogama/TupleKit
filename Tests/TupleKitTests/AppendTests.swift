import Testing

@testable import TupleKit

extension TupleKitTests {
  @Test func appendingOneMemberKeepsTypesAndLeavesTheSourceUnchanged() {
    let original = Tuple(42, "swift")
    let extended: Tuple<Int, String, Bool> = original.appending(true)

    #expect(original == Tuple(42, "swift"))
    #expect(extended == Tuple(42, "swift", true))
  }

  @Test func tupleInitializerKeepsElementTypes() {
    let box = Tuple(members: (7, "tuple"))

    #expect(box.0 == 7)
    #expect(box.1 == "tuple")
  }

  @Test func genericParameterPackForwarding() {
    func forward<each T>(
      _ values: repeat each T
    ) -> Tuple<repeat each T> {
      Tuple(repeat each values)
    }

    let box = forward(1, "forwarded")
    #expect(box.0 == 1)
    #expect(box.1 == "forwarded")
  }

  @Test func appendingToEmptyAndOneMemberTuples() {
    let first: Tuple<String> = Tuple().appending("first")
    let second: Tuple<String, Int> = first.appending(2)

    #expect(first.members == "first")
    #expect(second == Tuple("first", 2))
  }
}
