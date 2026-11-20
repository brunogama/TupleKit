import TupleKit

func storeKeyPath() {
  let delay: WritableKeyPath<Tuple<Bool, Double>, Double> = \.1  // known-bug
  print(delay)
}
