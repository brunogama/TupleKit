import HeterogeneousBox
import XCTest

private enum TransformFailure: Error {
    case rejected
}

private struct Message {
    let id: Int
    let text: String
}

final class OperatorsAndHigherOrderTests: XCTestCase {
    func testConcatenationPreservesTypesAndInputs() {
        let left = HeterogeneousBox(7, "first")
        let right = HeterogeneousBox(true, 2.5)
        let joined = left + right

        XCTAssertEqual(joined.0, 7)
        XCTAssertEqual(joined.1, "first")
        XCTAssertEqual(joined.2, true)
        XCTAssertEqual(joined.3, 2.5)
        XCTAssertEqual(left.count, 2)
        XCTAssertEqual(right.count, 2)

        let empty = HeterogeneousBox()
        XCTAssertEqual((empty + left).0, 7)
        XCTAssertEqual((left + empty).1, "first")
        XCTAssertTrue((empty + empty).isEmpty)
    }

    func testPredicatePatternWorksInSwitch() {
        let accepted = HeterogeneousBoxPattern<Int, String>(
            { $0 > 0 },
            { $0.hasPrefix("ready") }
        )
        let fallback = HeterogeneousBoxPattern<Int, String>(
            { $0 > 0 },
            { !$0.isEmpty }
        )

        func classify(_ box: HeterogeneousBox<Int, String>) -> String {
            switch box {
            case accepted: "accepted"
            case fallback: "fallback"
            default: "rejected"
            }
        }

        XCTAssertEqual(classify(HeterogeneousBox(1, "ready-now")), "accepted")
        XCTAssertEqual(classify(HeterogeneousBox(1, "waiting")), "fallback")
        XCTAssertEqual(classify(HeterogeneousBox(-1, "ready-now")), "rejected")
        XCTAssertTrue(
            HeterogeneousBoxPattern<Int, String>({ $0 == 1 }, { $0 == "one" })
                .matches(HeterogeneousBox(1, "one"))
        )
        XCTAssertTrue(HeterogeneousBoxPattern().matches(HeterogeneousBox()))
    }

    func testGenericPredicatePatternMatchesAnyValueType() {
        func matches<Value>(_ value: Value, pattern: PredicatePattern<Value>) -> Bool {
            switch value {
            case pattern: true
            default: false
            }
        }

        let even = PredicatePattern<Int> { $0.isMultiple(of: 2) }
        let nonempty = PredicatePattern<String> { !$0.isEmpty }
        let selectedMessage = PredicatePattern<Message> { $0.id == 7 && $0.text == "ready" }
        let selectedBox = PredicatePattern<HeterogeneousBox<Int, String>> {
            $0.0 > 0 && $0.1 == "ready"
        }

        XCTAssertTrue(matches(8, pattern: even))
        XCTAssertFalse(matches(9, pattern: even))
        XCTAssertTrue(matches("hello", pattern: nonempty))
        XCTAssertTrue(matches(Message(id: 7, text: "ready"), pattern: selectedMessage))
        XCTAssertFalse(matches(Message(id: 8, text: "ready"), pattern: selectedMessage))
        XCTAssertTrue(matches(HeterogeneousBox(1, "ready"), pattern: selectedBox))
    }

    func testTypedUpdateCopiesAndPropagatesErrors() {
        let original = HeterogeneousBox(2, "ready")
        let updated = original.updating(\.0) { $0 * 3 }

        XCTAssertEqual(original.0, 2)
        XCTAssertEqual(updated.0, 6)
        XCTAssertEqual(updated.1, "ready")

        XCTAssertThrowsError(
            try original.updating(\.0) { _ in
                throw TransformFailure.rejected
            }
        ) { error in
            XCTAssertTrue(error is TransformFailure)
        }
    }

    func testBuildsNewBoxWithOneTypeChangingTransformationAtATime() {
        let source = HeterogeneousBox(12, "ready", true)
        let first = HeterogeneousBox()
            .appendingTransformed(source.value.0) { String($0) }
        let second = first.appendingTransformed(source.value.1) { $0.count }
        let transformed = second.appendingTransformed(source.value.2) { $0 ? "yes" : "no" }

        XCTAssertEqual(transformed.0, "12")
        XCTAssertEqual(transformed.1, 5)
        XCTAssertEqual(transformed.2, "yes")
        XCTAssertEqual(source.0, 12)
        XCTAssertEqual(source.1, "ready")
        XCTAssertEqual(source.2, true)
    }

    func testAppendingTransformedPropagatesErrorAndHandlesOptionalNil() {
        let original = HeterogeneousBox("prefix")
        var transformations = 0
        let transformed = original.appendingTransformed(nil as Int?) { value in
            transformations += 1
            return value ?? 0
        }
        XCTAssertEqual(transformed.0, "prefix")
        XCTAssertEqual(transformed.1, 0)
        XCTAssertEqual(transformations, 1)

        XCTAssertThrowsError(
            try original.appendingTransformed(1) { _ -> Int in
                throw TransformFailure.rejected
            }
        ) { error in
            XCTAssertTrue(error is TransformFailure)
        }
        XCTAssertEqual(original.count, 1)
    }

    func testTypedTraversalKeepsMemberTypesAndOrder() {
        let box = HeterogeneousBox(3, "ready", true)
        var visited: [String] = []

        box.forEachTyped(
            { (number: Int) in visited.append("number:\(number)") },
            { (text: String) in visited.append("text:\(text)") },
            { (flag: Bool) in visited.append("flag:\(flag)") }
        )

        XCTAssertEqual(visited, ["number:3", "text:ready", "flag:true"])
        HeterogeneousBox().forEachTyped()
        HeterogeneousBox(nil as Int?)
            .forEachTyped { (number: Int?) in
                XCTAssertNil(number)
            }
    }

    func testThrowingTypedTraversalStopsAtFailure() {
        let box = HeterogeneousBox(3, "reject", true)
        var visited: [String] = []

        XCTAssertThrowsError(
            try box.tryForEachTyped(
                { (number: Int) in visited.append("\(number)") },
                { (text: String) in
                    visited.append(text)
                    throw TransformFailure.rejected
                },
                { (flag: Bool) in visited.append("\(flag)") }
            )
        ) { error in
            XCTAssertTrue(error is TransformFailure)
        }
        XCTAssertEqual(visited, ["3", "reject"])
    }

    func testTypeErasedHigherOrderOperationsKeepOrder() {
        let box = HeterogeneousBox(1, "two", 3)

        XCTAssertEqual(box.map { String(describing: $0) }, ["1", "two", "3"])
        XCTAssertEqual(box.compactMap { $0 as? Int }, [1, 3])
        XCTAssertEqual(box.filter { $0 is Int }.compactMap { $0 as? Int }, [1, 3])
        XCTAssertEqual(box.first { $0 is String } as? String, "two")
        XCTAssertTrue(box.allSatisfy { String(describing: $0).count > 0 })
        XCTAssertTrue(box.contains { $0 is String })
        XCTAssertFalse(box.contains { $0 is Bool })
        XCTAssertEqual(box.reduce(0) { $0 + ($1 as? Int ?? 0) }, 4)
        XCTAssertEqual(box.map { String(describing: $0) }, Array(box).map { String(describing: $0) })
    }

    func testHigherOrderOperationsShortCircuitAndPropagateErrors() {
        let box = HeterogeneousBox(1, 2, 3)
        var visits = 0
        XCTAssertTrue(
            box.contains { element in
                visits += 1
                return element as? Int == 1
            }
        )
        XCTAssertEqual(visits, 1)

        visits = 0
        XCTAssertFalse(
            box.allSatisfy { element in
                visits += 1
                return element as? Int == 0
            }
        )
        XCTAssertEqual(visits, 1)

        XCTAssertThrowsError(
            try box.map { element -> Int in
                guard let number = element as? Int, number < 2 else {
                    throw TransformFailure.rejected
                }
                return number
            }
        )
    }

    func testEmptyAndOptionalValuesAtCollectionBoundary() {
        let empty = HeterogeneousBox()
        XCTAssertEqual(empty.map { $0 }.count, 0)
        XCTAssertTrue(empty.allSatisfy { _ in false })
        XCTAssertFalse(empty.contains { _ in true })
        XCTAssertNil(empty.first { _ in true })

        let optional = HeterogeneousBox(nil as Int?, "next")
        let first = optional.first { _ in true }
        XCTAssertNotNil(first)
        XCTAssertTrue(first is Int?)
        XCTAssertEqual(optional.map { String(describing: $0) }, ["nil", "next"])
    }
}
