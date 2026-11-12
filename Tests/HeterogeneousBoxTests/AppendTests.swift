import XCTest

@testable import HeterogeneousBox

extension HeterogeneousBoxTests {
    func testAppendingPreservesElementTypesAndOriginalBox() {
        let original = HeterogeneousBox(42)
        let extended = original.appending(values: "swift", true)

        XCTAssertEqual(original.count, 1)
        XCTAssertEqual(extended.count, 3)
        XCTAssertEqual(extended.0, 42)
        XCTAssertEqual(extended.1, "swift")
        XCTAssertEqual(extended.2, true)
    }

    func testTupleInitializerKeepsElementTypes() {
        let box = HeterogeneousBox(tuple: (7, "tuple"))

        XCTAssertEqual(box.0, 7)
        XCTAssertEqual(box.1, "tuple")
    }

    func testGenericParameterPackForwarding() {
        func forward<each T>(
            _ values: repeat each T
        ) -> HeterogeneousBox<repeat each T> {
            HeterogeneousBox(repeat each values)
        }

        let box = forward(1, "forwarded")
        XCTAssertEqual(box.0, 1)
        XCTAssertEqual(box.1, "forwarded")
    }

    func testAppendingToEmptyBox() {
        let original = HeterogeneousBox()
        let extended = original.appending(values: "first", 2)

        XCTAssertTrue(original.isEmpty)
        XCTAssertEqual(extended.0, "first")
        XCTAssertEqual(extended.1, 2)
    }
}
