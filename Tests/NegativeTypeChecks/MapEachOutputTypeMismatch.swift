import TupleKit

func run() async {
  let box = Tuple(1, "a")
  let mapped: Tuple<String, String> = await box.mapEach({ $0 + 1 }, { $0 })  // expected-error
}
