import TupleKit

var box = Tuple(1, true, "a")
log("\(box)")
log(box.debugDescription)

box.0 += 1
box[\.2] = "b"
log("typed members: \(box.0) \(box.1) \(box.2)")

let checked = box.member(at: 2, as: String.self)
log("checked lookup: \(checked)")

let mismatch = box.member(at: 2, as: Int.self)
log("checked mismatch: \(mismatch)")

log("erased members: \(box.erasedMembers)")

box.forEachTyped(
  { (number: Int) in log("number \(number)") },
  { (flag: Bool) in log("flag \(flag)") },
  { (text: String) in log("text \(text)") }
)

let longer = box + Tuple(2.5)
log("concatenated: \(longer) count: \(longer.count)")
