import TupleKit

func concatenateFour() {
  let joined = Tuple(5) + Tuple(true) + Tuple("a") + Tuple(1.5)  // known-bug
  print(joined)
}
