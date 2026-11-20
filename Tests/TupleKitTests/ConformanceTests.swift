import Foundation
import Testing
import TupleKit

struct ConformanceTests {
  @Test func codableRoundTripsMembersInPositionOrder() throws {
    let tuple = Tuple(42, "ready", nil as Double?, [true, false])

    let data = try JSONEncoder().encode(tuple)
    let decoded = try JSONDecoder()
      .decode(
        Tuple<Int, String, Double?, [Bool]>.self,
        from: data
      )

    #expect(
      String(bytes: data, encoding: .utf8)
        == #"[42,"ready",null,[true,false]]"#
    )
    #expect(decoded == tuple)
  }

  @Test func decodingRejectsTooFewValues() {
    let data = Data(#"[42]"#.utf8)

    let error = #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(Tuple<Int, String>.self, from: data)
    }
    guard case .valueNotFound? = error else {
      Issue.record("Expected valueNotFound, got \(String(describing: error))")
      return
    }
  }

  @Test func decodingRejectsExtraValues() {
    let data = Data(#"[42,"ready","extra"]"#.utf8)

    let error = #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(Tuple<Int, String>.self, from: data)
    }
    guard case .dataCorrupted? = error else {
      Issue.record("Expected dataCorrupted, got \(String(describing: error))")
      return
    }
  }

  @Test func decodingRejectsAMemberOfTheWrongType() {
    let data = Data(#"["42","ready"]"#.utf8)

    let error = #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(Tuple<Int, String>.self, from: data)
    }
    guard case .typeMismatch? = error else {
      Issue.record("Expected typeMismatch, got \(String(describing: error))")
      return
    }
  }

  @Test func comparableOrdersByTheFirstDifferingPosition() {
    #expect(Tuple(1, "z") < Tuple(2, "a"))
    #expect(Tuple(1, "a") < Tuple(1, "b"))
    #expect(!(Tuple(1, "b") < Tuple(1, "a")))
    let first = Tuple(1, "a")
    let equalToFirst = Tuple(1, "a")
    #expect(!(first < equalToFirst))
    #expect(
      [Tuple(2, "a"), Tuple(1, "b"), Tuple(1, "a")].sorted() == [
        Tuple(1, "a"), Tuple(1, "b"), Tuple(2, "a"),
      ]
    )
  }

  @Test func comparableStopsAtAnUnorderedMember() {
    let unordered = Double.nan

    #expect(!(Tuple(unordered, 1) < Tuple(unordered, 2)))
    #expect(!(Tuple(unordered, 2) < Tuple(unordered, 1)))
    #expect(!(Tuple(0, unordered, 1) < Tuple(0, unordered, 2)))
  }

  @Test func hashableDistinguishesMembers() {
    let set: Set = [Tuple(1, "a"), Tuple(1, "a"), Tuple(1, "b")]
    #expect(set.count == 2)
  }

  @Test func equatableComparesEveryMember() {
    let first = Tuple(1, "a")
    let equal = Tuple(1, "a")
    #expect(first == equal)
    #expect(first != Tuple(2, "a"))
    #expect(first != Tuple(1, "b"))
  }

  @Test func equalTuplesProduceEqualHashes() {
    var firstHasher = Hasher()
    Tuple(42, "ready").hash(into: &firstHasher)
    var secondHasher = Hasher()
    Tuple(42, "ready").hash(into: &secondHasher)

    #expect(firstHasher.finalize() == secondHasher.finalize())
  }

  @Test func hashableSupportsLookupWithCollidingMembers() {
    let first = Tuple(CollidingMember(value: 1), "a")
    let second = Tuple(CollidingMember(value: 2), "a")
    #expect(first != second)
    #expect(Set([first, first, second]).count == 2)
    let lookup = [first: "first", second: "second"]
    #expect(lookup[Tuple(CollidingMember(value: 1), "a")] == "first")
    #expect(lookup[second] == "second")
  }

  @Test func comparableMatchesBuiltInTupleOrdering() {
    func agree<First: Comparable, Second: Comparable>(
      _ left: (First, Second),
      _ right: (First, Second)
    ) -> Bool {
      (Tuple(left.0, left.1) < Tuple(right.0, right.1)) == (left < right)
    }

    #expect(agree((1, "a"), (1, "b")))
    #expect(agree((1, "b"), (1, "a")))
    #expect(agree((2, "a"), (1, "z")))
    let unordered = Double.nan
    #expect(agree((1, "a"), (1, "a")))
    #expect(agree((unordered, 1), (unordered, 2)))
  }

  @Test func codableRoundTripsNestedTuples() throws {
    let tuple = Tuple(42, Tuple("ready", true))

    let data = try JSONEncoder().encode(tuple)
    let decoded = try JSONDecoder()
      .decode(Tuple<Int, Tuple<String, Bool>>.self, from: data)

    #expect(String(bytes: data, encoding: .utf8) == #"[42,["ready",true]]"#)
    #expect(decoded == tuple)
  }
}

private struct CollidingMember: Hashable {
  let value: Int

  func hash(into hasher: inout Hasher) {
    hasher.combine(0)
  }
}
