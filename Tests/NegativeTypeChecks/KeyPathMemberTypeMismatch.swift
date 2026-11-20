import TupleKit

let box = Tuple(1, "a")
let text: String = box[\.0]  // expected-error
