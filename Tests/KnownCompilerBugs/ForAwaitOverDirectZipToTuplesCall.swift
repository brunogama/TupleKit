import TupleKit

func render(ids: AsyncStream<Int>, names: AsyncStream<String>) async throws {
  for try await pair in zipToTuples(ids, names) {  // known-bug
    print(pair)
  }
}
