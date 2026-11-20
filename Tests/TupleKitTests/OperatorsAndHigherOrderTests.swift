import Testing
import TupleKit

private enum TransformFailure: Error {
  case rejected
}

struct OperatorsAndHigherOrderTests {
  @Test func concatenationResultIsUsableAsItsStaticType() {
    let left = Tuple(7, "first")
    let joined: Tuple<Int, String, Bool, Double> = left + Tuple(true, 2.5)

    #expect(joined == Tuple(7, "first", true, 2.5))
    #expect(left == Tuple(7, "first"))
  }

  @Test func concatenationAcceptsEveryRightArityUpToSix() {
    let base = Tuple(0)

    #expect(base + Tuple(1) == Tuple(0, 1))
    #expect(base + Tuple(1, 2) == Tuple(0, 1, 2))
    #expect(base + Tuple(1, 2, 3) == Tuple(0, 1, 2, 3))
    #expect(base + Tuple(1, 2, 3, 4) == Tuple(0, 1, 2, 3, 4))
    #expect(base + Tuple(1, 2, 3, 4, 5) == Tuple(0, 1, 2, 3, 4, 5))
    #expect(base + Tuple(1, 2, 3, 4, 5, 6) == Tuple(0, 1, 2, 3, 4, 5, 6))
  }

  @Test func concatenationWithEmptyTuples() {
    let pair = Tuple(1, "a")

    #expect(pair + Tuple() == pair)
    #expect(Tuple() + pair == pair)
    #expect((Tuple() + Tuple()).isEmpty)
  }

  @Test func concatenationChainsOfThreeOperandsAndStepwiseLongerChains() {
    let three: Tuple<Int, Bool, String> = Tuple(5) + Tuple(true) + Tuple("a")
    let firstHalf = Tuple(5) + Tuple(true)
    let secondHalf = Tuple("a") + Tuple(1.5)
    let four: Tuple<Int, Bool, String, Double> = firstHalf + secondHalf

    #expect(three == Tuple(5, true, "a"))
    #expect(four == Tuple(5, true, "a", 1.5))
  }

  @Test func predicatePatternWorksInSwitch() {
    let accepted = TuplePattern<Int, String>(
      { $0 > 0 },
      { $0.hasPrefix("ready") }
    )
    let fallback = TuplePattern<Int, String>(
      { $0 > 0 },
      { !$0.isEmpty }
    )

    func classify(_ box: Tuple<Int, String>) -> String {
      switch box {
      case accepted: "accepted"
      case fallback: "fallback"
      default: "rejected"
      }
    }

    #expect(classify(Tuple(1, "ready-now")) == "accepted")
    #expect(classify(Tuple(1, "waiting")) == "fallback")
    #expect(classify(Tuple(-1, "ready-now")) == "rejected")
    #expect(
      TuplePattern<Int, String>({ $0 == 1 }, { $0 == "one" })
        .matches(Tuple(1, "one"))
    )
    #expect(TuplePattern().matches(Tuple()))
  }

  @Test func typedUpdateCopiesAndPropagatesErrors() {
    let original = Tuple(2, "ready")
    let updated = original.updating(\.0) { $0 * 3 }

    #expect(original.0 == 2)
    #expect(updated.0 == 6)
    #expect(updated.1 == "ready")

    #expect(throws: TransformFailure.self) {
      try original.updating(\.0) { _ in
        throw TransformFailure.rejected
      }
    }
  }

  @Test func buildsNewBoxWithOneTypeChangingTransformationAtATime() {
    let source = Tuple(12, "ready", true)
    let first = Tuple()
      .appendingTransformed(source.members.0) { String($0) }
    let second = first.appendingTransformed(source.members.1) { $0.count }
    let transformed = second.appendingTransformed(source.members.2) { $0 ? "yes" : "no" }

    #expect(transformed.0 == "12")
    #expect(transformed.1 == 5)
    #expect(transformed.2 == "yes")
    #expect(source.0 == 12)
    #expect(source.1 == "ready")
    #expect(source.2 == true)
  }

  @Test func appendingTransformedPropagatesErrorAndHandlesOptionalNil() {
    let original = Tuple("prefix")
    var transformations = 0
    let transformed = original.appendingTransformed(nil as Int?) { value in
      transformations += 1
      return value ?? 0
    }
    #expect(transformed.0 == "prefix")
    #expect(transformed.1 == 0)
    #expect(transformations == 1)

    #expect(throws: TransformFailure.self) {
      try original.appendingTransformed(1) { _ -> Int in
        throw TransformFailure.rejected
      }
    }
    #expect(original.count == 1)
  }

  @Test func typedTraversalKeepsMemberTypesAndOrder() {
    let box = Tuple(3, "ready", true)
    var visited: [String] = []

    box.forEachTyped(
      { (number: Int) in visited.append("number:\(number)") },
      { (text: String) in visited.append("text:\(text)") },
      { (flag: Bool) in visited.append("flag:\(flag)") }
    )

    #expect(visited == ["number:3", "text:ready", "flag:true"])
    Tuple().forEachTyped()
    Tuple(nil as Int?)
      .forEachTyped { (number: Int?) in
        #expect(number == nil)
      }
  }

  @Test func throwingTypedTraversalStopsAtFailure() {
    let box = Tuple(3, "reject", true)
    var visited: [String] = []

    #expect(throws: TransformFailure.self) {
      try box.tryForEachTyped(
        { (number: Int) in visited.append("\(number)") },
        { (text: String) in
          visited.append(text)
          throw TransformFailure.rejected
        },
        { (flag: Bool) in visited.append("\(flag)") }
      )
    }
    #expect(visited == ["3", "reject"])
  }

  @Test func throwingTypedTraversalCompletesInOrder() throws {
    var visited: [String] = []
    try Tuple(3, "ready")
      .tryForEachTyped(
        { visited.append(String($0)) },
        { visited.append($0) }
      )
    try Tuple().tryForEachTyped()
    #expect(visited == ["3", "ready"])
  }
}
