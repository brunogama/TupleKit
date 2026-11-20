import Foundation
import Testing
import TupleKit

private enum ZipTermination: Sendable, CaseIterable {
  case end
  case failure
  case cancellation
}

private struct ResourceSequence: AsyncSequence {
  let resource: NSObject
  let termination: ZipTermination?

  struct AsyncIterator: AsyncIteratorProtocol {
    var resource: NSObject?
    let termination: ZipTermination?

    mutating func next() async throws -> Int? {
      guard let termination else { return 1 }
      resource = nil
      switch termination {
      case .end: return nil
      case .failure: throw ResourceFailure()
      case .cancellation: throw CancellationError()
      }
    }
  }

  func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(resource: resource, termination: termination)
  }
}

private struct ResourceFailure: Error {}

private func resourceZip(
  termination: ZipTermination,
  firstStops: Bool
) -> (
  TupleZipSequence<ResourceSequence, ResourceSequence>.AsyncIterator, () -> Bool
) {
  let first = NSObject()
  let second = NSObject()
  let released = { [weak first, weak second] in first == nil && second == nil }
  let sequence = zipToTuples(
    ResourceSequence(resource: first, termination: firstStops ? termination : nil),
    ResourceSequence(resource: second, termination: firstStops ? nil : termination)
  )
  return (sequence.makeAsyncIterator(), released)
}

struct ZipResourceLifetimeTests {
  @Test(arguments: ZipTermination.allCases, [true, false])
  fileprivate func terminationReleasesEveryBase(
    termination: ZipTermination,
    firstStops: Bool
  ) async throws {
    var (iterator, released) = resourceZip(termination: termination, firstStops: firstStops)
    do {
      let result = try await iterator.next()
      #expect(result == nil)
      #expect(termination == .end)
    }
    catch is CancellationError {
      #expect(termination == .cancellation)
    }
    catch is ResourceFailure {
      #expect(termination == .failure)
    }
    #expect(released())
    #expect(try await iterator.next() == nil)
    withExtendedLifetime(iterator) {}
  }
}
