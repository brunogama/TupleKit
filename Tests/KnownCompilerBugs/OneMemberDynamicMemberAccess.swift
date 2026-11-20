import TupleKit

func readOnlyMember() {
  let single = Tuple(5)
  print(single.0)  // known-bug
}
