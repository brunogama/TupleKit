import TupleKit

typealias Sessions = TupleZipSequence<AsyncStream<Int>, AsyncStream<String>>

func run(numbers: AsyncStream<Int>, names: AsyncStream<String>) {
  let sessions: Sessions = zipToTuples(names, numbers)  // expected-error
}
