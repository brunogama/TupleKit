import Testing
import TupleKitComposition

struct OperatorPrecedenceTests {
  @Test func inputExpressionsBindBeforeForwardApplication() {
    let arithmetic = 2 + 3 * 4 |> { $0 * 2 }
    let optional: Int? = nil
    let coalesced = optional ?? 5 |> { $0 * 2 }
    let comparison = 2 < 3 |> { !$0 }
    let ternary = true ? 3 : 5 |> { $0 * 2 }
    #expect(arithmetic == 28)
    #expect(coalesced == 10)
    #expect(!comparison)
    #expect(ternary == 6)
  }

  @Test func compositionBindsBeforeApplicationAndAssignment() {
    let double: (Int) -> Int = { $0 * 2 }
    let increment: (Int) -> Int = { $0 + 1 }
    var result = 0
    result = 2 + 3 |> double >>> increment
    #expect(result == 11)
    #expect((3 |> double |> increment) == 7)
  }
}
