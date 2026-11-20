import Testing
import TupleKit
import TupleKitComposition

private struct WrappedState {
  @AccumulatingValue var box = Tuple(1, "ready")
  @AccumulatingValue var count = 1
  @AccumulatingValue var optional: String?
}

private struct BoundedWrappedState {
  @AccumulatingValue(capacity: 2) var count = 1
  @AccumulatingValue(wrappedValue: nil, capacity: 2) var optional: String?
  @AccumulatingValue(capacity: 2) var box = Tuple(1, "ready")
}

private actor WrappedStateOwner {
  @AccumulatingValue var box = Tuple(1, "ready")

  func set(_ number: Int, status: String) {
    box = Tuple(number, status)
  }

  func snapshots() -> [Tuple<Int, String>] {
    $box
  }
}

struct AccumulatingWrapperTests {
  @Test func boxWrapperRecordsTypedSnapshots() {
    var state = WrappedState()
    state.box = Tuple(2, "running")
    state.box = Tuple(3, "done")

    #expect(state.box.0 == 3)
    #expect(state.$box.count == 3)
    #expect(state.$box[0].0 == 1)
    #expect(state.$box[1].1 == "running")
    #expect(state.$box[2].0 == 3)

    state.box[\.0] = 4
    #expect(state.$box.count == 4)
    #expect(state.$box[3].0 == 4)

    var copy = state.$box
    copy.removeAll()
    #expect(state.$box.count == 4)
  }

  @Test func valueWrapperRecordsHomogeneousAssignmentsAndNil() {
    var state = WrappedState()
    state.count = 2
    state.count = 3
    state.optional = nil
    state.optional = "ready"

    #expect(state.$count == [1, 2, 3])
    #expect(state.$optional.count == 3)
    #expect(state.$optional[0] == nil)
    #expect(state.$optional[1] == nil)
    #expect(state.$optional[2] == "ready")
  }

  @Test func actorCanOwnTypedBoxHistory() async {
    let owner = WrappedStateOwner()
    await owner.set(2, status: "running")
    let snapshots = await owner.snapshots()

    #expect(snapshots.count == 2)
    #expect(snapshots[0].0 == 1)
    #expect(snapshots[1].1 == "running")
  }

  @Test func boundedValueHistoryRetainsNewestAssignmentsIncludingNil() {
    var state = BoundedWrappedState()
    state.count = 2
    state.count = 3
    state.optional = nil
    state.optional = "ready"

    #expect(state.count == 3)
    #expect(state.$count == [2, 3])
    #expect(state.$optional.count == 2)
    #expect(state.$optional[0] == nil)
    #expect(state.$optional[1] == "ready")
  }

  @Test func boundedBoxHistoryRetainsNewestTypedSnapshots() {
    var state = BoundedWrappedState()
    state.box = Tuple(2, "running")
    state.box[\.0] = 3

    #expect(state.box.0 == 3)
    #expect(state.$box.count == 2)
    #expect(state.$box[0].0 == 2)
    #expect(state.$box[1].1 == "running")
    #expect(state.$box[1].0 == 3)
  }

  @Test func capacityOneKeepsOnlyCurrentValue() {
    var wrapper = AccumulatingValue(wrappedValue: 1, capacity: 1)
    wrapper.wrappedValue = 2
    wrapper.wrappedValue = 3

    #expect(wrapper.wrappedValue == 3)
    #expect(wrapper.projectedValue == [3])
  }
}
