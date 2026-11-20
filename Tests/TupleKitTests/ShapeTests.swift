import Foundation
import Testing
import TupleKit

struct ShapeTests {
  @Test func oneMemberTupleIsAddressedThroughSelf() {
    var single = Tuple(5)

    single[\.self] += 1
    let doubled = single.updating(\.self) { $0 * 2 }
    let label = single[\.self, map: { "value \($0)" }]

    #expect(single.members == 6)
    #expect(doubled.members == 12)
    #expect(label == "value 6")
    #expect(single.member(at: 0, as: Int.self) == .success(6))
    #expect(single.member(at: 1, as: Int.self) == .failure(.outOfBounds(position: 1)))
  }

  @Test func oneMemberTupleSupportsEveryOperation() async throws {
    let single = Tuple(5)

    #expect(single.count == 1)
    #expect(single.description == "Tuple(5)")
    #expect(single.debugDescription == "Tuple<Int> { 5 (Int) }")
    #expect(single < Tuple(6))
    #expect(single.mapEach { $0 + 1 } == Tuple(6))
    let awaited = await single.mapEach { value in
      await Task.yield()
      return value + 2
    }
    #expect(awaited == Tuple(7))
    let concurrent = try await concurrentMapEach(single) { $0 + 3 }
    #expect(concurrent == Tuple(8))
    #expect(TuplePattern<Int>({ $0 == 5 }).matches(single))
    #expect(single + Tuple("a") == Tuple(5, "a"))

    let data = try JSONEncoder().encode(single)
    #expect(String(bytes: data, encoding: .utf8) == "[5]")
    #expect(try JSONDecoder().decode(Tuple<Int>.self, from: data) == single)
  }

  @Test func emptyTupleSupportsEveryOperationThatTakesNoTransforms() async throws {
    let empty = Tuple()

    #expect(empty.isEmpty)
    #expect(empty.erasedMembers.isEmpty)
    #expect(empty == Tuple())
    #expect(!(empty < Tuple()))
    #expect(empty.description == "Tuple()")
    #expect(empty.debugDescription == "Tuple<> {}")
    #expect(empty.member(at: 0, as: Int.self) == .failure(.outOfBounds(position: 0)))
    #expect(empty + Tuple(1, "a") == Tuple(1, "a"))
    empty.forEachTyped()
    let concurrent = try await concurrentMapEach(empty)
    #expect(concurrent.isEmpty)

    let data = try JSONEncoder().encode(empty)
    #expect(String(bytes: data, encoding: .utf8) == "[]")
    #expect(try JSONDecoder().decode(type(of: empty), from: data) == empty)
  }
}
