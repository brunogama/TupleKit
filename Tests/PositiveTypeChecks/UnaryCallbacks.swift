import TupleKit

func visitUnary(_ total: inout Int, action: (Int?) -> Void) throws {
  let tuple = Tuple(nil as Int?)
  tuple.forEachTyped { (number: Int?) in total += number ?? 1 }
  tuple.forEachTyped(action)
  try tuple.tryForEachTyped { (number: Int?) in total += number ?? 2 }
  let mapped: Tuple<Int> = tuple.mapEach { (number: Int?) in number ?? 3 }
  total += mapped.members
}

func mapUnary() async -> Tuple<Int> {
  let tuple = Tuple(nil as Int?)
  return await tuple.mapEach { (number: Int?) async -> Int in number ?? 4 }
}
