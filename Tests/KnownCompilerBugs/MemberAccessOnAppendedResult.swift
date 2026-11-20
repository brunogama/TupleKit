import TupleKit

// Reading a member of an `appending`, `appendingTransformed`, or `+` result in the same
// expression fails to type-check on Swift 6.4.2. Binding the result to a constant first
// is the workaround.
func readAMemberStraightOffAnAppendedTuple() {
  let tuple = Tuple(1, "a")
  let longer = tuple.appending(true)
  _ = longer.count
  _ = longer.2
  let joined = tuple + Tuple(2.5)
  _ = joined.count
  _ = tuple.appending(true).count  // known-bug
  _ = (tuple + Tuple(2.5)).count  // known-bug
  _ = tuple.appendingTransformed("a") { $0.count }.count  // known-bug
}
