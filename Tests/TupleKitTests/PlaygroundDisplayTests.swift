import Testing
import TupleKit

@Test func playgroundDisplayPreservesMemberTypesAndOrder() throws {
  let tuple: any CustomPlaygroundDisplayConvertible = Tuple(42, "ready")

  let displayed = try #require(tuple.playgroundDescription as? (Int, String))

  #expect(displayed.0 == 42)
  #expect(displayed.1 == "ready")
}
