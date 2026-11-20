import TupleKit

final class Counter {
  var value = 0
}

func run() async throws {
  let box = Tuple(Counter(), 1)
  _ = try await concurrentMapEach(box, { $0.value }, { $0 })  // expected-error
}
