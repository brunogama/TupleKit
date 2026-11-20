import Testing
import TupleKit

private enum Size: String, CaseIterable {
  case small
  case large
}

private enum Tone: String, CaseIterable {
  case light
  case dark
}

private enum Uninhabited: CaseIterable {}

struct AdditionalConformanceTests {
  @Test func bitwiseCopyableWhenEveryMemberIs() {
    func size<Value: BitwiseCopyable>(of value: Value) -> Int {
      MemoryLayout<Value>.size
    }
    #expect(size(of: Tuple(1, true)) == MemoryLayout<(Int, Bool)>.size)
  }

  @Test func allCasesIsTheCartesianProductWithTheLastMemberFastest() {
    let expected = [
      Tuple(Size.small, Tone.light), Tuple(Size.small, Tone.dark),
      Tuple(Size.large, Tone.light), Tuple(Size.large, Tone.dark),
    ]
    #expect(Tuple<Size, Tone>.allCases == expected)
    #expect(Tuple<Size, Tone, Size>.allCases.count == 8)
  }

  @Test func allCasesIsEmptyWhenAnyMemberHasNoCases() {
    #expect(Tuple<Size, Uninhabited>.allCases.isEmpty)
  }

  @Test func emptyTupleHasExactlyOneCase() {
    let empty = Tuple()
    #expect(type(of: empty).allCases.count == 1)
  }

  @Test func rawValuesRoundTrip() {
    let tuple = Tuple(Size.large, Tone.dark)

    #expect(tuple.rawValues == Tuple("large", "dark"))
    #expect(Tuple<Size, Tone>(rawValues: tuple.rawValues) == tuple)
  }

  @Test func rawValuesInitializerFailsWhenAnyMemberHasNoCase() {
    #expect(Tuple<Size, Tone>(rawValues: Tuple("medium", "dark")) == nil)
    #expect(Tuple<Size, Tone>(rawValues: Tuple("small", "sepia")) == nil)
  }

  @Test func writesToATextOutputStream() {
    var log = ""
    print(Tuple(1, "a"), to: &log)
    #expect(log == "Tuple(1, \"a\")\n")
    var empty = ""
    Tuple().write(to: &empty)
    #expect(empty == "Tuple()")
  }

  @Test func elementWiseArithmetic() {
    let base = Tuple(1, 2.5)

    #expect(base.adding(Tuple(10, 0.5)) == Tuple(11, 3.0))
    #expect(base.subtracting(Tuple(1, 0.5)) == Tuple(0, 2.0))
    #expect(Tuple<Int, Double>.zero == Tuple(0, 0.0))
    #expect(base.adding(.zero) == base)
  }

  @Test func plusStillConcatenatesTuplesOfTheSameType() {
    let base = Tuple(1, 2.5)

    // Inference happens before the annotation, so an AdditiveArithmetic conformance on
    // Tuple would make the second line fail to compile.
    let inferred = base + base
    let _: Tuple<Int, Double, Int, Double> = inferred
    #expect(inferred == Tuple(1, 2.5, 1, 2.5))
  }

  @Test func elementwiseViewConformsToAdditiveArithmetic() {
    func sum<Value: AdditiveArithmetic>(_ values: [Value]) -> Value {
      values.reduce(.zero, +)
    }
    let steps = [Tuple(1, 0.5), Tuple(2, 0.25), Tuple(3, 0.25)]

    #expect(sum(steps.map(ElementwiseTuple.init)).tuple == Tuple(6, 1.0))
    #expect((Tuple(5, 2.5).elementwise - Tuple(2, 0.5).elementwise).tuple == Tuple(3, 2.0))
    #expect(ElementwiseTuple<Int, Double>.zero.tuple == Tuple(0, 0.0))
  }

  @Test func elementwiseViewEqualityComparesEveryMember() {
    let view = Tuple(1, 2.5).elementwise
    let equalView = Tuple(1, 2.5).elementwise
    #expect(view == equalView)
    #expect(Tuple(1, 2.5).elementwise != Tuple(2, 2.5).elementwise)
    #expect(Tuple(1, 2.5).elementwise != Tuple(1, 3.5).elementwise)
  }

  @Test func elementwiseViewIsHashableAndPrintsTheTuple() {
    let views: Set = [Tuple(1, 2).elementwise, Tuple(1, 2).elementwise, Tuple(2, 1).elementwise]

    #expect(views.count == 2)
    #expect(Tuple(1, 2.5).elementwise.description == "Tuple(1, 2.5)")
  }

  @Test func elementwiseTupleSetterReplacesTheTuple() {
    var view = Tuple(1, 2.5).elementwise

    view.tuple = Tuple(3, 4.5)

    #expect(view.tuple == Tuple(3, 4.5))
    #expect(view == Tuple(3, 4.5).elementwise)
  }
}
