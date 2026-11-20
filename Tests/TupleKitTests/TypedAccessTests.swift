import Testing
import TupleKit

private actor BoxReceiver {
  func receive(_ value: Tuple<Int, String>) -> String {
    "\(value.0):\(value.1)"
  }
}

private actor HandlerRunner {
  func execute(
    _ handlers: Tuple<
      @Sendable (Int) async -> String,
      @Sendable (String) async -> Int
    >
  ) async -> (String, Int) {
    let reply = await handlers.0(3)
    let count = await handlers.1("query")
    return (reply, count)
  }
}

struct TypedAccessTests {
  @Test func sendableBoxCrossesActorBoundary() async {
    let box = Tuple(42, "ready")
    let result = await BoxReceiver().receive(box)
    #expect(result == "42:ready")
  }

  @Test func typedKeyPathReadsAndReplacesClosure() {
    var handlers = Tuple(
      { (number: Int) in "old-\(number)" },
      { (text: String) in text.count }
    )
    let original: (Int) -> String = handlers[\.0]
    #expect(original(1) == "old-1")

    handlers[\.0] = { "new-\($0)" }
    #expect(handlers[\.0](2) == "new-2")
    #expect(handlers[\.1]("abc") == 3)
  }

  @Test func typedHandlerBundleCrossesActorBoundary() async {
    let command: @Sendable (Int) async -> String = { "command-\($0)" }
    let query: @Sendable (String) async -> Int = { $0.count }
    let handlers = Tuple(command, query)

    let (reply, count) = await HandlerRunner().execute(handlers)
    #expect(reply == "command-3")
    #expect(count == 5)
  }

  @Test func runtimeLookupReportsInvalidPositionOrType() {
    let box = Tuple(7, "seven")
    #expect(box.member(at: 0, as: Int.self) == .success(7))
    #expect(box.member(at: 1, as: String.self) == .success("seven"))
    #expect(box.member(at: 0, as: String.self) == .failure(.typeMismatch(position: 0)))
    #expect(box.member(at: -1, as: Int.self) == .failure(.outOfBounds(position: -1)))
    #expect(box.member(at: 2, as: Int.self) == .failure(.outOfBounds(position: 2)))

    let optionalBox = Tuple(nil as Int?)
    switch optionalBox.member(at: 0, as: Int?.self) {
    case .success(let value): #expect(value == nil)
    case .failure(let error): Issue.record("Stored nil was treated as \(error)")
    }
  }
}
