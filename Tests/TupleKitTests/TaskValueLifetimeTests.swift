import Testing
import TupleKit

private struct TaskValueFailure: Error {}

private actor ValueGate {
  private var continuation: CheckedContinuation<Void, Never>?
  private var started: CheckedContinuation<Void, Never>?
  private(set) var finished = false

  func wait() async -> String {
    await withCheckedContinuation { continuation in
      self.continuation = continuation
      started?.resume()
      started = nil
    }
    finished = true
    return "ready"
  }

  func waitUntilStarted() async {
    if continuation != nil { return }
    await withCheckedContinuation { started = $0 }
  }

  func release() {
    continuation?.resume()
    continuation = nil
  }
}

struct TaskValueLifetimeTests {
  @Test func failureReturnsBeforeLaterTasksFinishWithoutCancellingThem() async throws {
    let gate = ValueGate()
    let later = Task<String, any Error> { await gate.wait() }
    await gate.waitUntilStarted()
    let tasks = Tuple(Task<Int, any Error> { throw TaskValueFailure() }, later)

    await #expect(throws: TaskValueFailure.self) { try await values(of: tasks) }

    #expect(await !gate.finished)
    #expect(!later.isCancelled)
    await gate.release()
    #expect(try await later.value == "ready")
  }
}
