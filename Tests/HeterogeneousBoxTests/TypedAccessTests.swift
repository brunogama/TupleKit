import HeterogeneousBox
import XCTest

private actor BoxReceiver {
    func receive(_ value: HeterogeneousBox<Int, String>) -> String {
        "\(value.0):\(value.1)"
    }
}

private actor HandlerRunner {
    func execute(
        _ handlers: HeterogeneousBox<
            @Sendable (Int) async -> String,
            @Sendable (String) async -> Int
        >
    ) async -> (String, Int) {
        let reply = await handlers.0(3)
        let count = await handlers.1("query")
        return (reply, count)
    }
}

final class TypedAccessTests: XCTestCase {
    func testSendableBoxCrossesActorBoundary() async {
        let box = HeterogeneousBox(42, "ready")
        let result = await BoxReceiver().receive(box)
        XCTAssertEqual(result, "42:ready")
    }

    func testTypedKeyPathReadsAndReplacesClosure() {
        var handlers = HeterogeneousBox(
            { (number: Int) in "old-\(number)" },
            { (text: String) in text.count }
        )
        let original: (Int) -> String = handlers.value(at: \.0)
        XCTAssertEqual(original(1), "old-1")

        handlers[\.0] = { "new-\($0)" }
        XCTAssertEqual(handlers[\.0](2), "new-2")
        XCTAssertEqual(handlers[\.1]("abc"), 3)
    }

    func testTypedHandlerBundleCrossesActorBoundary() async {
        let command: @Sendable (Int) async -> String = { "command-\($0)" }
        let query: @Sendable (String) async -> Int = { $0.count }
        let handlers = HeterogeneousBox(command, query)

        let (reply, count) = await HandlerRunner().execute(handlers)
        XCTAssertEqual(reply, "command-3")
        XCTAssertEqual(count, 5)
    }

    func testRuntimeLookupReportsInvalidPositionOrType() {
        let box = HeterogeneousBox(7, "seven")
        XCTAssertEqual(box.element(at: 0, as: Int.self), .success(7))
        XCTAssertEqual(box.element(at: 1, as: String.self), .success("seven"))
        XCTAssertEqual(box.element(at: 0, as: String.self), .failure(.typeMismatch(index: 0)))
        XCTAssertEqual(box.element(at: -1, as: Int.self), .failure(.outOfBounds(index: -1)))
        XCTAssertEqual(box.element(at: 2, as: Int.self), .failure(.outOfBounds(index: 2)))

        let optionalBox = HeterogeneousBox(nil as Int?)
        switch optionalBox.element(at: 0, as: Int?.self) {
        case .success(let value): XCTAssertNil(value)
        case .failure(let error): XCTFail("Stored nil was treated as \(error)")
        }
    }
}
