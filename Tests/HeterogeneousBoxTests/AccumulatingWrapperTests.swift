import HeterogeneousBox
import XCTest

private struct WrappedState {
    @AccumulatingBox var box = HeterogeneousBox(1, "ready")
    @AccumulatingValue var count = 1
    @AccumulatingValue var optional: String? = nil
}

private struct BoundedWrappedState {
    @AccumulatingValue(capacity: 2) var count = 1
    @AccumulatingValue(capacity: 2) var optional: String? = nil
    @AccumulatingBox(capacity: 2) var box = HeterogeneousBox(1, "ready")
}

private actor WrappedStateOwner {
    @AccumulatingBox var box = HeterogeneousBox(1, "ready")

    func set(_ number: Int, status: String) {
        box = HeterogeneousBox(number, status)
    }

    func snapshots() -> [HeterogeneousBox<Int, String>] {
        $box
    }
}

final class AccumulatingWrapperTests: XCTestCase {
    func testBoxWrapperRecordsTypedSnapshots() {
        var state = WrappedState()
        state.box = HeterogeneousBox(2, "running")
        state.box = HeterogeneousBox(3, "done")

        XCTAssertEqual(state.box.0, 3)
        XCTAssertEqual(state.$box.count, 3)
        XCTAssertEqual(state.$box[0].0, 1)
        XCTAssertEqual(state.$box[1].1, "running")
        XCTAssertEqual(state.$box[2].0, 3)

        state.box[\.0] = 4
        XCTAssertEqual(state.$box.count, 4)
        XCTAssertEqual(state.$box[3].0, 4)

        var copy = state.$box
        copy.removeAll()
        XCTAssertEqual(state.$box.count, 4)
    }

    func testValueWrapperRecordsHomogeneousAssignmentsAndNil() {
        var state = WrappedState()
        state.count = 2
        state.count = 3
        state.optional = nil
        state.optional = "ready"

        XCTAssertEqual(state.$count, [1, 2, 3])
        XCTAssertEqual(state.$optional.count, 3)
        XCTAssertNil(state.$optional[0])
        XCTAssertNil(state.$optional[1])
        XCTAssertEqual(state.$optional[2], "ready")
    }

    func testActorCanOwnTypedBoxHistory() async {
        let owner = WrappedStateOwner()
        await owner.set(2, status: "running")
        let snapshots = await owner.snapshots()

        XCTAssertEqual(snapshots.count, 2)
        XCTAssertEqual(snapshots[0].0, 1)
        XCTAssertEqual(snapshots[1].1, "running")
    }

    func testBoundedValueHistoryRetainsNewestAssignmentsIncludingNil() {
        var state = BoundedWrappedState()
        state.count = 2
        state.count = 3
        state.optional = nil
        state.optional = "ready"

        XCTAssertEqual(state.count, 3)
        XCTAssertEqual(state.$count, [2, 3])
        XCTAssertEqual(state.$optional.count, 2)
        XCTAssertNil(state.$optional[0])
        XCTAssertEqual(state.$optional[1], "ready")
    }

    func testBoundedBoxHistoryRetainsNewestTypedSnapshots() {
        var state = BoundedWrappedState()
        state.box = HeterogeneousBox(2, "running")
        state.box[\.0] = 3

        XCTAssertEqual(state.box.0, 3)
        XCTAssertEqual(state.$box.count, 2)
        XCTAssertEqual(state.$box[0].0, 2)
        XCTAssertEqual(state.$box[1].1, "running")
        XCTAssertEqual(state.$box[1].0, 3)
    }

    func testCapacityOneKeepsOnlyCurrentValue() {
        var wrapper = AccumulatingValue(wrappedValue: 1, capacity: 1)
        wrapper.wrappedValue = 2
        wrapper.wrappedValue = 3

        XCTAssertEqual(wrapper.wrappedValue, 3)
        XCTAssertEqual(wrapper.projectedValue, [3])
    }
}
