import HeterogeneousBox
import XCTest

private enum MapError: Error {
    case failed
}

final class TypedMapTests: XCTestCase {
    func testMapsAllMembersToNewStaticTypes() {
        let original = HeterogeneousBox(12, "ready", true)
        let mapped: HeterogeneousBox<String, Int, Bool> = original.mapBox { box in
            HeterogeneousBox("\(box.value.0)", box.value.1.count, !box.value.2)
        }

        XCTAssertEqual(mapped.0, "12")
        XCTAssertEqual(mapped.1, 5)
        XCTAssertEqual(mapped.2, false)
        XCTAssertEqual(original.0, 12)
        XCTAssertEqual(original.1, "ready")
        XCTAssertEqual(original.2, true)
    }

    func testMapCanChangeArity() {
        let original = HeterogeneousBox(12, "ready")
        let more: HeterogeneousBox<Int, String, Bool> = original.mapBox {
            (box: HeterogeneousBox<Int, String>) -> HeterogeneousBox<Int, String, Bool> in
            HeterogeneousBox(box.value.0, box.value.1, true)
        }
        XCTAssertEqual(more.2, true)

        let fewer: HeterogeneousBox<String, Int> = more.mapBox { box in
            HeterogeneousBox(box.value.1, box.value.0)
        }
        XCTAssertEqual(fewer.0, "ready")
        XCTAssertEqual(fewer.1, 12)

        let single: HeterogeneousBox<String> = original.mapBox { _ in
            HeterogeneousBox("constant")
        }
        XCTAssertEqual(single.element(at: 0, as: String.self), .success("constant"))
    }

    func testMapPropagatesClosureError() {
        let original = HeterogeneousBox(12, "ready")
        XCTAssertThrowsError(
            try original.mapBox { _ -> HeterogeneousBox<Int, String> in
                throw MapError.failed
            }
        ) { error in
            XCTAssertTrue(error is MapError)
        }
    }
}
