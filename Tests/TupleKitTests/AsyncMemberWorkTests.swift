import Testing
import TupleKit

private enum StageError: Error, Equatable {
  case rejected
}

private final class Counter {
  var value = 0
}

@MainActor
struct AsyncMemberWorkTests {
  @Test func synchronousMapEachTransformsEachMemberToItsOwnType() {
    let tuple = Tuple(2, "ready", true)
    var order: [Int] = []

    let mapped: Tuple<Double, Int, String> = tuple.mapEach(
      { number in
        order.append(0)
        return Double(number) / 4
      },
      { text in
        order.append(1)
        return text.count
      },
      { flag in
        order.append(2)
        return flag ? "yes" : "no"
      }
    )

    #expect(order == [0, 1, 2])
    #expect(mapped == Tuple(0.5, 5, "yes"))
  }

  @Test func synchronousMapEachStopsAtFirstTypedError() {
    let tuple = Tuple(1, 2)
    var visited: [Int] = []

    #expect(throws: StageError.rejected) {
      try tuple.mapEach(
        { (value: Int) throws(StageError) -> Int in
          visited.append(value)
          throw .rejected
        },
        { (value: Int) throws(StageError) -> Int in
          visited.append(value)
          return value
        }
      )
    }
    #expect(visited == [1])
  }

  @Test func mapEachRunsTransformsInTupleOrderAndKeepsOutputTypes() async {
    let box = Tuple(2, "ready")
    var order: [String] = []

    let mapped: Tuple<Double, [Character]> = await box.mapEach(
      { number in
        await Task.yield()
        order.append("number")
        return Double(number) / 4
      },
      { text in
        await Task.yield()
        order.append("text")
        return Array(text)
      }
    )

    #expect(order == ["number", "text"])
    #expect(mapped[\.0] == 0.5)
    #expect(mapped[\.1] == ["r", "e", "a", "d", "y"])
  }

  @Test func mapEachStopsAtFirstTypedError() async {
    let box = Tuple(1, 2, 3)
    var visited: [Int] = []

    do {
      _ = try await box.mapEach(
        { (value: Int) async throws(StageError) -> Int in
          visited.append(value)
          return value
        },
        { (value: Int) async throws(StageError) -> Int in
          visited.append(value)
          throw .rejected
        },
        { (value: Int) async throws(StageError) -> Int in
          visited.append(value)
          return value
        }
      )
      Issue.record("Expected the second transform to throw")
    }
    catch {
      #expect(error == .rejected)
    }

    #expect(visited == [1, 2])
  }

  @Test func mapEachAcceptsNonSendableMembersOnTheCallersActor() async {
    let counter = Counter()
    let box = Tuple(counter, "label")

    let mapped = await box.mapEach(
      { (counter: Counter) async -> Int in
        counter.value += 1
        return counter.value
      },
      { (label: String) async -> String in label.uppercased() }
    )

    #expect(mapped[\.0] == 1)
    #expect(mapped[\.1] == "LABEL")
    #expect(counter.value == 1)
  }

}
