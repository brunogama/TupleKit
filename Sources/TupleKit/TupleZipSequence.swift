/// An asynchronous sequence whose elements are complete typed tuples.
///
/// Each element combines the next element of every base sequence, so the tuple keeps one
/// static member type per base. Create one with ``zipToTuples(_:)``.
///
/// The sequence is `Sendable` when every base is.
public struct TupleZipSequence<each Base: AsyncSequence>: AsyncSequence {
  /// A tuple with one element from each base, in base order.
  public typealias Element = Tuple<repeat (each Base).Element>

  private let bases: (repeat each Base)

  fileprivate init(_ bases: repeat each Base) {
    self.bases = (repeat each bases)
  }

  /// Pulls one element from every base per call, in member order, on the caller's task.
  ///
  /// The iterator starts no task and adds no buffer. Iteration ends when any base ends
  /// or throws, and a sequence with no bases yields no elements. Earlier bases may have
  /// supplied elements in the final round; later bases are not pulled after one ends.
  public struct AsyncIterator: AsyncIteratorProtocol {
    private var iterators: (repeat (each Base).AsyncIterator)?

    /// A Boolean value that indicates whether the sequence has no bases to pull from.
    private var hasNoBases: Bool {
      for _ in repeat (each Base).self {
        return false
      }
      return true
    }

    fileprivate init(_ iterators: repeat (each Base).AsyncIterator) {
      self.iterators = (repeat each iterators)
    }

    /// Returns a tuple with the next element of every base, or `nil` when any base ends.
    ///
    /// - Returns: The next tuple, or `nil` after the shortest base ends. A sequence with
    ///   no bases returns `nil` without yielding. After it returns `nil` or throws, later
    ///   calls return `nil`.
    /// - Throws: The first error a base throws, once.
    public mutating func next() async throws -> Element? {
      guard !hasNoBases, let current = iterators else { return nil }
      iterators = nil
      var stopped = false
      let steps = (repeat try await pull(each current, stop: &stopped))
      guard !stopped else { return nil }
      iterators = (repeat (each steps).iterator)
      return Tuple(repeat requireElement((each steps).element))
    }
  }

  /// Creates an iterator that pulls from a fresh iterator of every base.
  ///
  /// - Returns: An iterator over complete tuples.
  public func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(repeat (each bases).makeAsyncIterator())
  }
}

private func pull<Iterator: AsyncIteratorProtocol>(
  _ iterator: Iterator,
  stop: inout Bool
) async throws -> (iterator: Iterator, element: Iterator.Element?) {
  guard !stop else { return (iterator, nil) }
  var iterator = iterator
  let element = try await iterator.next()
  stop = element == nil
  return (iterator, element)
}

private func requireElement<Element>(_ element: Element?) -> Element {
  guard let element else { preconditionFailure("Missing zipped member") }
  return element
}

/// A zip sequence may cross an actor boundary only when every base may do so.
extension TupleZipSequence: Sendable where repeat each Base: Sendable {}

/// Combines asynchronous sequences into one sequence of typed tuples.
///
/// `zipToTuples(accounts, sessions)` yields `Tuple<Account, Session>` values,
/// pairing the first account with the first session, then the second with the second.
/// Iteration ends when the shortest base ends, and a call with no bases yields no
/// elements. The sequence consumes each base once.
///
/// ```swift
/// let ids = AsyncStream<Int> { continuation in
///     continuation.yield(1)
///     continuation.finish()
/// }
/// let names = AsyncStream<String> { continuation in
///     continuation.yield("first")
///     continuation.finish()
/// }
/// var received: [String] = []
/// let sessions = zipToTuples(ids, names)
/// for try await session in sessions {
///     received.append("\(session.0) \(session.1)")  // "1 first"
/// }
/// ```
///
/// Bind the sequence to a constant before the loop. On Swift 6.4.2, writing
/// `zipToTuples(...)` directly after `in` crashes the compiler.
///
/// - Parameter bases: The sequences to combine, in member order.
/// - Returns: A sequence of tuples with one element from each base.
public func zipToTuples<each Base: AsyncSequence>(
  _ bases: repeat each Base
) -> TupleZipSequence<repeat each Base> {
  TupleZipSequence(repeat each bases)
}
