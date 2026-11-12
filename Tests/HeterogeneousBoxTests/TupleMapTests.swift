import HeterogeneousBox
import XCTest

private enum TupleMapFailure: Error {
    case rejected
}

final class TupleMapTests: XCTestCase {
    func testMapsRawTupleIntoBoxWithNewTypes() {
        let tuple = (12, "ready", true)
        let box: HeterogeneousBox<String, Int, Bool> = mapTuple(tuple) { values in
            HeterogeneousBox("\(values.0)", values.1.count, !values.2)
        }

        XCTAssertEqual(box.0, "12")
        XCTAssertEqual(box.1, 5)
        XCTAssertEqual(box.2, false)
        XCTAssertEqual(tuple.0, 12)
    }

    func testMapsTupleToOneMemberAndPropagatesErrors() {
        let tuple = (nil as Int?, "ready")
        let box: HeterogeneousBox<String> = mapTuple(tuple) { values in
            HeterogeneousBox(values.0.map(String.init) ?? values.1)
        }
        XCTAssertEqual(box.element(at: 0, as: String.self), .success("ready"))

        XCTAssertThrowsError(
            try mapTuple(tuple) { _ -> HeterogeneousBox<Int, String> in
                throw TupleMapFailure.rejected
            }
        ) { error in
            XCTAssertTrue(error is TupleMapFailure)
        }
    }
}
