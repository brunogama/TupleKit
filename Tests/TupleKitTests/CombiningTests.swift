import Testing
import TupleKit

private enum LookupError: Error, Equatable {
  case missing(String)
}

struct CombiningTests {
  @Test func unwrappedReturnsMembersWhenEveryMemberHasAValue() {
    let source = Tuple(1 as Int?, "ready" as String?)

    let members = unwrapped(source)

    #expect(members == Tuple(1, "ready"))
  }

  @Test func unwrappedReturnsNilWhenAnyMemberIsNil() {
    let source = Tuple(1 as Int?, nil as String?, true as Bool?)

    #expect(unwrapped(source) == nil)
  }

  @Test func unwrappedKeepsANestedNilThatIsItselfAValue() {
    let nested: Int?? = .some(nil)

    let source = Tuple(nested)

    let members = unwrapped(source)

    #expect(members != nil)
    #expect(members?.members == .some(nil))
  }

  @Test func collectedReturnsSuccessesInPositionOrder() throws {
    let results = Tuple(
      Result<Int, LookupError>.success(1),
      Result<String, LookupError>.success("ready")
    )

    #expect(try collected(results).get() == Tuple(1, "ready"))
  }

  @Test func collectedReturnsTheFirstFailureInPositionOrder() {
    let results = Tuple(
      Result<Int, LookupError>.success(1),
      Result<String, LookupError>.failure(.missing("name")),
      Result<Bool, LookupError>.failure(.missing("flag"))
    )

    #expect(throws: LookupError.missing("name")) { try collected(results).get() }
  }

  @Test func valuesAwaitsNonThrowingTasksInPositionOrder() async {
    let tasks = Tuple(Task { 1 }, Task { "ready" })

    let members = await values(of: tasks)

    #expect(members == Tuple(1, "ready"))
  }

  @Test func valuesRethrowsTheFirstFailingTaskInPositionOrder() async {
    let tasks = Tuple(
      Task<Int, any Error> { 1 },
      Task<String, any Error> { throw LookupError.missing("name") }
    )

    await #expect(throws: LookupError.missing("name")) { try await values(of: tasks) }
  }

  @Test func zipPairsMembersByPosition() {
    let pairs = zip(Tuple(1, "a"), Tuple(true, 2.5))

    #expect(pairs[\.0] == (1, true))
    #expect(pairs[\.1] == ("a", 2.5))
  }

  @Test func zipDoesNotShadowSequenceZip() {
    #expect(Array(zip([1, 2], ["a", "b"])).count == 2)
  }
}
