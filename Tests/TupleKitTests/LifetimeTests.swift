import Testing
import TupleKit

/// An object whose deallocation a test can observe through a weak reference.
private final class Tracked: Sendable {
  let identifier: Int

  init(_ identifier: Int) {
    self.identifier = identifier
  }
}

private struct Rejected: Error {}

/// Each test creates objects in a scope, keeps only weak references outside it, and expects
/// every object to be freed once the scope ends. A retain cycle or a stored closure that
/// outlives its owner keeps the weak reference alive and fails the test.
struct LifetimeTests {
  @Test func tupleReleasesItsMembers() {
    weak var weakMember: Tracked?
    do {
      let member = Tracked(1)
      weakMember = member
      let tuple = Tuple(member, "ready")
      let mapped = tuple.mapEach({ $0.identifier }, { $0.count })
      #expect(mapped == Tuple(1, 5))
      #expect(!tuple.description.isEmpty)
      #expect(tuple.customMirror.children.count == 2)
      #expect(tuple.erasedMembers.count == 2)
    }
    #expect(weakMember == nil)
  }

  @Test func patternReleasesTheObjectsItsPredicatesCapture() {
    weak var weakCaptured: Tracked?
    do {
      let captured = Tracked(7)
      weakCaptured = captured
      let pattern = TuplePattern<Int, String>(
        { $0 == captured.identifier },
        { _ in true }
      )
      #expect(pattern.matches(Tuple(7, "match")))
    }
    #expect(weakCaptured == nil)
  }

  @Test func concurrentMapEachReleasesCapturesAfterReturning() async throws {
    weak var weakCaptured: Tracked?
    weak var weakMember: Tracked?
    do {
      let captured = Tracked(10)
      let member = Tracked(2)
      weakCaptured = captured
      weakMember = member
      let loaded = try await concurrentMapEach(
        Tuple(member, 3),
        { $0.identifier * captured.identifier },
        { $0 + captured.identifier }
      )
      #expect(loaded == Tuple(20, 13))
    }
    #expect(weakCaptured == nil)
    #expect(weakMember == nil)
  }

  @Test func concurrentMapEachReleasesCapturesAfterThrowing() async {
    weak var weakCaptured: Tracked?
    do {
      let captured = Tracked(1)
      weakCaptured = captured
      await #expect(throws: Rejected.self) {
        _ = try await concurrentMapEach(
          Tuple(1, 2),
          { (value: Int) -> Int in
            try await Task.sleep(for: .seconds(10))
            return value + captured.identifier
          },
          { (_: Int) -> Int in throw Rejected() }
        )
      }
    }
    #expect(weakCaptured == nil)
  }

  @Test func zipToTuplesReleasesItsBasesAfterIteration() async throws {
    weak var weakElement: Tracked?
    do {
      let element = Tracked(4)
      weakElement = element
      let objects = AsyncStream<Tracked> { continuation in
        continuation.yield(element)
        continuation.finish()
      }
      let numbers = AsyncStream<Int> { continuation in
        continuation.yield(1)
        continuation.finish()
      }
      let zipped = zipToTuples(objects, numbers)
      var identifiers: [Int] = []
      for try await pair in zipped {
        identifiers.append(pair.0.identifier)
      }
      #expect(identifiers == [4])
    }
    #expect(weakElement == nil)
  }
}
