import Foundation
import Testing
import TupleKit

private struct StreamFailure: Error, Equatable {}

private func stream<Element: Sendable>(
  _ elements: Element...
) -> AsyncStream<Element> {
  AsyncStream { continuation in
    for element in elements {
      continuation.yield(element)
    }
    continuation.finish()
  }
}

private struct ReleasingSequence: AsyncSequence {
  let resource: NSObject

  struct AsyncIterator: AsyncIteratorProtocol {
    var resource: NSObject?

    mutating func next() async -> Int? {
      resource = nil
      return nil
    }
  }

  func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(resource: resource)
  }
}

private func trackedZip() -> (
  TupleZipSequence<ReleasingSequence, AsyncStream<String>>.AsyncIterator,
  () -> Bool
) {
  let resource = NSObject()
  let isReleased = { [weak resource] in resource == nil }
  let releasing = ReleasingSequence(resource: resource)
  let sequence = zipToTuples(releasing, stream("x"))
  let iterator = sequence.makeAsyncIterator()
  return (iterator, isReleased)
}

struct ZipBoxesTests {
  @Test
  func zipBoxesPairsElementsByPositionAndKeepsMemberTypes() async throws {
    let boxes = zipToTuples(
      stream(1, 2),
      stream("a", "b"),
      stream(true, false)
    )

    var collected: [Tuple<Int, String, Bool>] = []
    for try await box in boxes {
      collected.append(box)
    }

    #expect(collected == [Tuple(1, "a", true), Tuple(2, "b", false)])
  }

  @Test func loopElementsSupportTypedKeyPathAccess() async throws {
    let sessions = zipToTuples(stream(1, 2), stream("a", "b"))

    var rendered: [String] = []
    for try await session in sessions {
      rendered.append("\(session[\.0] + 1):\(session[\.1].uppercased())")
    }

    #expect(rendered == ["2:A", "3:B"])
  }

  @Test func zipBoxesEndsWithTheShortestBaseAndStaysFinished() async throws {
    let sequence = zipToTuples(stream(1, 2, 3), stream("only"))
    var iterator = sequence.makeAsyncIterator()

    let first = try await iterator.next()
    let end = try await iterator.next()
    let afterEnd = try await iterator.next()

    #expect(first == Tuple(1, "only"))
    #expect(end == nil)
    #expect(afterEnd == nil)
  }

  @Test func exhaustedFirstBaseDoesNotPullAThrowingLaterBase() async throws {
    let empty = stream() as AsyncStream<Int>
    let throwing = AsyncThrowingStream<String, any Error> { continuation in
      continuation.finish(throwing: StreamFailure())
    }
    var iterator = zipToTuples(empty, throwing).makeAsyncIterator()

    let end = try await iterator.next()
    let afterEnd = try await iterator.next()

    #expect(end == nil)
    #expect(afterEnd == nil)
  }

  @Test func finishedZipReleasesResourcesHeldByACompletedBase() async throws {
    var (iterator, isReleased) = trackedZip()

    let end = try await iterator.next()

    #expect(end == nil)
    #expect(isReleased())
    _ = iterator
  }

  @Test func zipWithoutBasesEndsBeforeYieldingAnything() async throws {
    var iterator = zipToTuples().makeAsyncIterator()

    let first = try await iterator.next()
    let second = try await iterator.next()

    #expect(first == nil)
    #expect(second == nil)
  }

  @Test func zipBoxesEmitsOptionalNilMembersAsValues() async throws {
    let sequence = zipToTuples(stream(nil as Int?, 4), stream("x", "y"))
    var iterator = sequence.makeAsyncIterator()

    let first = try await iterator.next()

    #expect(first == Tuple(nil as Int?, "x"))
  }

  @Test func zipBoxesRethrowsABaseFailureAndThenFinishes() async throws {
    let failing = AsyncThrowingStream<Int, any Error> { continuation in
      continuation.yield(1)
      continuation.finish(throwing: StreamFailure())
    }
    let sequence = zipToTuples(failing, stream("a", "b", "c"))
    var iterator = sequence.makeAsyncIterator()

    let first = try await iterator.next()
    #expect(first == Tuple(1, "a"))

    do {
      _ = try await iterator.next()
      Issue.record("Expected the base failure")
    }
    catch {
      #expect(error as? StreamFailure == StreamFailure())
    }
    let afterFailure = try await iterator.next()
    #expect(afterFailure == nil)
  }

  @Test
  func zipBoxesCanBeConsumedInAnotherTaskWhenBasesAreSendable() async throws {
    let boxes = zipToTuples(stream(1, 2), stream("a", "b"))

    let count =
      try await Task.detached {
        var count = 0
        for try await _ in boxes {
          count += 1
        }
        return count
      }
      .value

    #expect(count == 2)
  }
}
