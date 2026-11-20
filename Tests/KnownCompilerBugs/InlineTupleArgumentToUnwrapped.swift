import TupleKit

func unwrapInlineTuple() {
  let members = unwrapped(Tuple(1 as Int?, "ready" as String?))  // known-bug
  print(members as Any)
}
