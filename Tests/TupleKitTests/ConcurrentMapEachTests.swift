import Testing
import TupleKit

private enum StageError: Error, Equatable {
  case rejected
  case timedOut
}

private actor Recorder {
  private(set) var events: [String] = []
  private var waiters: [String: [CheckedContinuation<Void, Never>]] = [:]

  func record(_ event: String) {
    events.append(event)
    for waiter in waiters.removeValue(forKey: event) ?? [] { waiter.resume() }
  }

  func contains(_ event: String) -> Bool {
    events.contains(event)
  }

  func wait(for event: String) async {
    if events.contains(event) { return }
    await withCheckedContinuation { waiters[event, default: []].append($0) }
  }
}

@MainActor
struct ConcurrentMapEachTests {
  @Test func concurrentMapEachKeepsSourceOrderWhenLaterMembersFinishFirst() async throws {
    let recorder = Recorder()
    let box = Tuple(1, 2)

    let mapped = try await concurrentMapEach(
      box,
      { (value: Int) -> Int in
        await recorder.wait(for: "second")
        await recorder.record("first")
        return value * 10
      },
      { (value: Int) -> Int in
        await recorder.record("second")
        return value * 100
      }
    )

    let events = await recorder.events
    #expect(events == ["second", "first"])
    #expect(mapped == Tuple(10, 200))
  }

  @Test func concurrentMapEachStartsEveryTransformBeforeAnyFinishes() async throws {
    let recorder = Recorder()
    let box = Tuple("first", "second")

    let mapped = try await concurrentMapEach(
      box,
      { (name: String) -> Bool in
        await recorder.record("\(name) started")
        await recorder.wait(for: "second started")
        return await recorder.contains("second started")
      },
      { (name: String) -> Bool in
        await recorder.record("\(name) started")
        await recorder.wait(for: "first started")
        return true
      }
    )

    #expect(mapped == Tuple(true, true))
  }

  @Test func concurrentMapEachCancelsSiblingsWhenOneThrows() async {
    let recorder = Recorder()
    let box = Tuple(1, "fail")

    do {
      _ = try await concurrentMapEach(
        box,
        { (value: Int) -> Int in
          do {
            try await Task.sleep(for: .seconds(30))
          }
          catch {
            await recorder.record("sibling cancelled")
            throw error
          }
          return value
        },
        { (_: String) -> String in throw StageError.rejected }
      )
      Issue.record("Expected the second transform to throw")
    }
    catch {
      #expect(error as? StageError == .rejected)
    }

    let siblingCancelled = await recorder.contains("sibling cancelled")
    #expect(siblingCancelled)
  }

  @Test func cancellingTheCallerCancelsEveryTransform() async {
    let box = Tuple(1, 2)
    let task = Task {
      try await concurrentMapEach(
        box,
        { (value: Int) -> Int in
          try await Task.sleep(for: .seconds(30))
          return value
        },
        { (value: Int) -> Int in
          try await Task.sleep(for: .seconds(30))
          return value
        }
      )
    }
    task.cancel()

    let result = await task.result
    #expect(throws: CancellationError.self) { try result.get() }
  }

  @Test func concurrentMapEachPreservesOptionalNilOutputs() async throws {
    let box = Tuple("missing", 5)

    let mapped = try await concurrentMapEach(
      box,
      { (text: String) -> Int? in Int(text) },
      { (value: Int) -> Int? in value }
    )

    #expect(mapped == Tuple(nil as Int?, 5 as Int?))
  }

  @Test func concurrentMapEachOnEmptyBoxReturnsEmptyBox() async throws {
    let mapped = try await concurrentMapEach(Tuple())
    #expect(mapped.isEmpty)
  }

  @Test func theFirstTransformToThrowProvidesTheError() async {
    let box = Tuple(1, 2)
    let recorder = Recorder()

    do {
      _ = try await concurrentMapEach(
        box,
        { (_: Int) -> Int in
          await recorder.record("first started")
          do {
            try await Task.sleep(for: .seconds(30))
          }
          catch {
            throw StageError.rejected
          }
          throw StageError.rejected
        },
        { (_: Int) -> Int in
          await recorder.wait(for: "first started")
          throw StageError.timedOut
        }
      )
      Issue.record("Expected a transform to throw")
    }
    catch {
      #expect(error as? StageError == .timedOut)
    }
  }
}
