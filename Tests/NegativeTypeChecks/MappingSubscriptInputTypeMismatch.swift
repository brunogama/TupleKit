import TupleKit

let box = Tuple(1, "a")
let length: Int = box[\.0, map: { (text: String) in text.count }]  // expected-error
