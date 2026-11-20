import Testing
import TupleKit
import TupleKitComposition

private struct Message {
  let id: Int
  let text: String
}

struct PredicatePatternTests {
  @Test func genericPredicatePatternMatchesAnyValueType() {
    func matches<Value>(_ value: Value, pattern: PredicatePattern<Value>) -> Bool {
      switch value {
      case pattern: true
      default: false
      }
    }

    let even = PredicatePattern<Int> { $0.isMultiple(of: 2) }
    let nonempty = PredicatePattern<String> { !$0.isEmpty }
    let selectedMessage = PredicatePattern<Message> { $0.id == 7 && $0.text == "ready" }
    let selectedBox = PredicatePattern<Tuple<Int, String>> {
      $0.0 > 0 && $0.1 == "ready"
    }

    #expect(matches(8, pattern: even))
    #expect(!(matches(9, pattern: even)))
    #expect(matches("hello", pattern: nonempty))
    #expect(matches(Message(id: 7, text: "ready"), pattern: selectedMessage))
    #expect(!(matches(Message(id: 8, text: "ready"), pattern: selectedMessage)))
    #expect(matches(Tuple(1, "ready"), pattern: selectedBox))
  }
}
