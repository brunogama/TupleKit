import TupleKit

let box = Tuple(1, "a")
box.forEachTyped({ (_: Int) in })  // expected-error
