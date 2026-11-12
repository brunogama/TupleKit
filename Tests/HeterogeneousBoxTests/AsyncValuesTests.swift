import HeterogeneousBox
import XCTest

final class AsyncValuesTests: XCTestCase {
    func testAsyncValuesPreserveOrderAndOptionalNil() async {
        let box = HeterogeneousBox(1, nil as String?, "done")
        var iterator = box.asyncValues().makeAsyncIterator()

        let first = await iterator.next()
        let second = await iterator.next()
        let third = await iterator.next()
        let end = await iterator.next()

        XCTAssertEqual(first as? Int, 1)
        XCTAssertNotNil(second)
        XCTAssertTrue(second is String?)
        XCTAssertEqual(third as? String, "done")
        XCTAssertNil(end)
    }

    func testAsyncValuesAreASnapshotAndSupportForAwait() async {
        var box = HeterogeneousBox(1, "ready")
        let sequence = box.asyncValues()
        box[\.0] = 2

        var visited: [String] = []
        for await element in sequence {
            visited.append(String(describing: element))
        }

        XCTAssertEqual(visited, ["1", "ready"])
    }

    func testCancelledConsumerStopsBeforeNextValue() async {
        let box = HeterogeneousBox(1, "ready")
        let didEmit = await Task { () -> Bool in
            var iterator = box.asyncValues().makeAsyncIterator()
            withUnsafeCurrentTask { task in
                task?.cancel()
            }
            return await iterator.next() != nil
        }
        .value

        XCTAssertFalse(didEmit)
    }
}
