import Testing
import TupleKit

private typealias Plan = Tuple<Int, String, Tuple<Bool, Double>>

struct NestedFocusTests {
  @Test func chainedKeyPathSubscriptsWriteThroughNestedBoxes() {
    var plan = Plan(1, "plan", Tuple(true, 0.5))

    plan[\.2][\.1] = 2.0
    plan[\.2][\.0].toggle()

    #expect(plan == Plan(1, "plan", Tuple(false, 2.0)))
  }

  @Test func nestedUpdatingReturnsACopyAndLeavesTheSourceUnchanged() {
    let plan = Plan(1, "plan", Tuple(true, 0.5))

    let updated = plan.updating(\.2) { inner in inner.updating(\.1) { $0 * 4 } }

    #expect(updated[\.2][\.1] == 2.0)
    #expect(plan[\.2][\.1] == 0.5)
  }
}
